package pe.aquasocial.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.ArrayList;
import jakarta.servlet.http.Part;
import java.io.File;
import java.util.List;
import org.json.JSONObject;
import pe.aquasocial.dao.ComentarioDAO;
import pe.aquasocial.dao.ComunidadDAO;
import pe.aquasocial.dao.IngresoDAO;
import pe.aquasocial.dao.LikeDAO;
import pe.aquasocial.dao.PublicacionDAO;
import pe.aquasocial.entity.Comentario;
import pe.aquasocial.entity.Ingreso;
import pe.aquasocial.entity.Publicacion;
import pe.aquasocial.entity.Usuario;
import pe.aquasocial.entity.Comunidad;
import pe.aquasocial.util.Conexion;

@WebServlet("/HomeServlet")
@MultipartConfig(
        maxFileSize = 5242880, // 5MB
        maxRequestSize = 10485760, // 10MB
        fileSizeThreshold = 1024 // 1KB
)
public class HomeServlet extends HttpServlet {

    // DAOs para todas las operaciones
    private PublicacionDAO publicacionDAO;
    private LikeDAO likeDAO;
    private ComentarioDAO comentarioDAO;
    private IngresoDAO ingresoDAO;
    private ComunidadDAO comunidadDAO;

    @Override
    public void init() throws ServletException {
        try {
            if (Conexion.probarConexion()) {
                System.out.println("✅ Conexión a BD establecida correctamente");

                // Inicializar todos los DAOs (existentes)
                publicacionDAO = new PublicacionDAO();
                likeDAO = new LikeDAO();
                comentarioDAO = new ComentarioDAO();
                ingresoDAO = new IngresoDAO();
                comunidadDAO = new ComunidadDAO();

                System.out.println("✅ HomeServlet inicializado con todos los DAOs");
            } else {
                System.err.println("❌ No se pudo conectar a la base de datos");
                throw new ServletException("Error de conexión a BD");
            }
        } catch (Exception e) {
            System.err.println("❌ Error al inicializar HomeServlet: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Error al inicializar servlet", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            action = "home";
        }

        switch (action) {
            case "home":
                mostrarHome(request, response);
                break;
            case "checkLike":
                verificarLike(request, response);
                break;
            default:
                mostrarHome(request, response);
                break;
        }
    }

    private void checkPaymentMessagesInSession(HttpServletRequest request) {
        HttpSession session = request.getSession();

        // Verificar si hay mensaje de pago en sesión
        String messageType = (String) session.getAttribute("paymentMessageType");
        String message = (String) session.getAttribute("paymentMessage");
        String paymentId = (String) session.getAttribute("paymentId");

        if (messageType != null && message != null) {
            System.out.println("📱 Mensaje de pago encontrado en sesión:");
            System.out.println("   - Tipo: " + messageType);
            System.out.println("   - Mensaje: " + message);
            System.out.println("   - Payment ID: " + paymentId);

            // Transferir a request attributes para el JSP
            switch (messageType) {
                case "success":
                    request.setAttribute("successMessagePayment", message);
                    break;
                case "error":
                    request.setAttribute("errorMessagePayment", message);
                    break;
                case "warning":
                    request.setAttribute("warningMessagePayment", message);
                    break;
            }

            // Datos adicionales
            if (paymentId != null) {
                request.setAttribute("paymentId", paymentId);
            }

            // LIMPIAR SESIÓN (importante para evitar mostrar el mensaje múltiples veces)
            session.removeAttribute("paymentMessageType");
            session.removeAttribute("paymentMessage");
            session.removeAttribute("paymentId");
            session.removeAttribute("preferenceId");

            System.out.println("✅ Mensaje transferido a request y limpiado de sesión");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            response.sendRedirect("HomeServlet");
            return;
        }

        switch (action) {
            case "createPost":
                crearPublicacion(request, response);
                break;
            case "toggleLike":
                toggleLike(request, response);
                break;
            case "addComment":
                agregarComentario(request, response);
                break;
            case "editComment":
                editarComentario(request, response);
                break;
            case "deleteComment":
                eliminarComentario(request, response);
                break;
            default:
                response.sendRedirect("home.jsp");
                break;
        }
    }

    // ========== MOSTRAR HOME ==========
    private void mostrarHome(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            System.out.println("🚀 Iniciando mostrarHome...");
            checkPaymentMessagesInSession(request);
            HttpSession session = request.getSession();
            Usuario usuarioActual = (Usuario) session.getAttribute("usuarioLogueado");

            int idUsuarioActual = usuarioActual != null ? usuarioActual.getId() : 0;

            System.out.println("👤 Usuario logueado: " + usuarioActual.getUsername() + " (ID: " + idUsuarioActual + ")");
            List<Comunidad> misComunidades = comunidadDAO.obtenerComunidadesSeguidas(usuarioActual.getId());
            List<Comunidad> sugerencias = comunidadDAO.obtenerComunidadesSugeridas(usuarioActual.getId(), 3);
            request.setAttribute("comunidadesSugeridas", sugerencias);
            System.out.println("🏠 HomeServlet: Enviando " + sugerencias.size() + " sugerencias");
            request.setAttribute("misComunidadesCount", misComunidades.size());
            // Verificar si es admin de alguna comunidad
            boolean esAdminComunidades = comunidadDAO.esAdminDeAlgunaComunidad(idUsuarioActual);
            request.setAttribute("usuarioEsAdminComunidades", esAdminComunidades);

            // Si es admin, obtener sus comunidades
            if (esAdminComunidades) {
                List<Comunidad> comunidadesQueAdministra = comunidadDAO.obtenerComunidadesQueAdministra(idUsuarioActual);
                request.setAttribute("comunidadesQueAdministra", comunidadesQueAdministra);
                System.out.println("🛡️ Usuario administra " + comunidadesQueAdministra.size() + " comunidades");
            }

            // Obtener publicaciones desde base de datos
            List<Publicacion> publicaciones = publicacionDAO.obtenerPublicacionesHome(idUsuarioActual);

            if (publicaciones == null) {
                publicaciones = new ArrayList<>();
            }

            System.out.println("✅ Se obtuvieron " + publicaciones.size() + " publicaciones");

            for (Publicacion pub : publicaciones) {
                try {
                    List<Comentario> comentarios = comentarioDAO.obtenerPorPublicacion(pub.getIdPublicacion());
                    if (comentarios == null) {
                        comentarios = new ArrayList<>();
                    }

                    // Establecer atributo individual para cada publicación
                    String atributoComentarios = "comentarios_" + pub.getIdPublicacion();
                    request.setAttribute(atributoComentarios, comentarios);

                    System.out.println("📝 Publicación " + pub.getIdPublicacion() + " tiene " + comentarios.size() + " comentarios");
                    System.out.println("📦 Atributo creado: " + atributoComentarios);

                } catch (Exception e) {
                    System.err.println("❌ Error al cargar comentarios para publicación " + pub.getIdPublicacion() + ": " + e.getMessage());
                    // En caso de error, enviar lista vacía
                    request.setAttribute("comentarios_" + pub.getIdPublicacion(), new ArrayList<Comentario>());
                }

                try {
                    // Verificar si el usuario ya dio like
                    boolean usuarioDioLike = likeDAO.usuarioYaDioLike(
                            pub.getIdPublicacion(),
                            usuarioActual.getId()
                    );

                    // Establecer el estado en la publicación
                    pub.setUsuarioDioLike(usuarioDioLike);

                    System.out.println("👍 Publicación " + pub.getIdPublicacion()
                            + " - Usuario dio like: " + usuarioDioLike);

                } catch (Exception e) {
                    System.err.println("❌ Error cargando like para publicación "
                            + pub.getIdPublicacion() + ": " + e.getMessage());
                    pub.setUsuarioDioLike(false); // Valor por defecto
                }
            }

            // Enviar datos a la vista
            request.setAttribute("publicaciones", publicaciones);
            request.setAttribute("totalPublicaciones", publicaciones.size());

            System.out.println("📦 Enviando " + publicaciones.size() + " publicaciones con comentarios individuales al JSP");

            request.getRequestDispatcher("/views/home/home.jsp").forward(request, response);

        } catch (Exception e) {
            System.out.println("❌ ERROR en mostrarHome: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar el home: " + e.getMessage());
            request.setAttribute("publicaciones", new ArrayList<Publicacion>());
            request.setAttribute("totalPublicaciones", 0);
            request.getRequestDispatcher("/views/home/home.jsp").forward(request, response);
        }
    }

    // ========== CREAR PUBLICACIÓN ==========
    private void crearPublicacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Configurar respuesta como JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            HttpSession session = request.getSession();
            Usuario usuarioActual = (Usuario) session.getAttribute("usuarioLogueado");
            if (usuarioActual == null) {
                enviarRespuestaError(response, "Usuario no autenticado", 401);
                return;
            }

            // Obtener parámetros del formulario
            String texto = request.getParameter("texto");
            String permiteDonacionStr = request.getParameter("permiteDonacion");
            String idComunidadStr = request.getParameter("idComunidad");

            // Validaciones
            if (texto == null || texto.trim().isEmpty()) {
                enviarRespuestaError(response, "El texto de la publicación no puede estar vacío", 400);
                return;
            }

            if (texto.length() > 999) {
                enviarRespuestaError(response, "El texto no puede exceder 999 caracteres", 400);
                return;
            }

            // ⭐ AGREGAR VALIDACIÓN DE COMUNIDAD:
            Integer idComunidad = null;
            if (idComunidadStr != null && !idComunidadStr.trim().isEmpty()) {
                try {
                    idComunidad = Integer.parseInt(idComunidadStr);

                    // Verificar que puede publicar en esa comunidad
                    if (!publicacionDAO.puedePublicarEnComunidad(usuarioActual.getId(), idComunidad)) {
                        enviarRespuestaError(response, "No tienes permisos para publicar en esta comunidad", 403);
                        return;
                    }
                } catch (NumberFormatException e) {
                    enviarRespuestaError(response, "ID de comunidad inválido", 400);
                    return;
                }
            }
            // Procesar imagen si existe
            String imagenUrl = null;
            Part imagenPart = request.getPart("imagen");

            if (imagenPart != null && imagenPart.getSize() > 0) {
                // Validar tipo de archivo
                String contentType = imagenPart.getContentType();
                if (contentType == null || !contentType.startsWith("image/")) {
                    enviarRespuestaError(response, "Solo se permiten archivos de imagen", 400);
                    return;
                }

                // Validar tamaño (5MB máximo)
                if (imagenPart.getSize() > 5242880) {
                    enviarRespuestaError(response, "La imagen es muy grande. Máximo 5MB permitido", 400);
                    return;
                }

                // Guardar imagen y obtener URL
                imagenUrl = guardarImagen(imagenPart, usuarioActual.getId());

                if (imagenUrl == null) {
                    enviarRespuestaError(response, "Error al procesar la imagen", 500);
                    return;
                }
            }

            boolean autoAprobar = false;

            if (idComunidad != null) {
                if (usuarioActual.isPrivilegio()) {
                    autoAprobar = true; // Usuario privilegiado puede publicar en cualquier comunidad
                } else if (publicacionDAO.puedePublicarEnComunidad(usuarioActual.getId(), idComunidad)) {
                    autoAprobar = true; // Es admin de esta comunidad específica
                }
            } else {
                autoAprobar = usuarioActual.isPrivilegio();
            }
            // Procesar donaciones
            boolean permiteDonacion = false;
            if (permiteDonacionStr != null && usuarioActual.isPrivilegio()) {
                permiteDonacion = "1".equals(permiteDonacionStr) || "on".equals(permiteDonacionStr);
            }

            // Crear nueva publicación
            Publicacion nuevaPublicacion = new Publicacion(
                    usuarioActual.getId(),
                    texto.trim(),
                    permiteDonacion
            );

            if (imagenUrl != null && !imagenUrl.trim().isEmpty()) {
                nuevaPublicacion.setImagenUrl(imagenUrl.trim());
            }

            // ⭐ CONFIGURAR AUTO-APROBACIÓN Y COMUNIDAD:
            nuevaPublicacion.setEstaAprobado(autoAprobar);

            if (idComunidad != null) {
                nuevaPublicacion.setIdComunidad(idComunidad);
            }

            if (publicacionDAO.crear(nuevaPublicacion)) {

                // ⭐ ACTUALIZAR MENSAJE DE ÉXITO:
                String mensaje;

                if (idComunidad != null) {
                    // PUBLICACIÓN EN COMUNIDAD
                    Comunidad comunidad = comunidadDAO.obtenerPorId(idComunidad);
                    String nombreComunidad = comunidad != null ? comunidad.getNombre() : "la comunidad";

                    if (autoAprobar) {
                        if (usuarioActual.isPrivilegio()) {
                            // Usuario privilegiado publicando en comunidad
                            if (comunidadDAO.esAdminDeComunidad(usuarioActual.getId(), idComunidad)) {
                                mensaje = "¡Publicación creada en " + nombreComunidad + "! Aprobada automáticamente como administrador.";
                            } else {
                                mensaje = "¡Publicación creada en " + nombreComunidad + "! Aprobada automáticamente por tus privilegios.";
                            }
                        } else {
                            // Admin de la comunidad (sin privilegios globales)
                            mensaje = "¡Publicación creada en " + nombreComunidad + "! Aprobada automáticamente como administrador.";
                        }
                    } else {
                        // No se auto-aprueba (usuario normal en comunidad)
                        mensaje = "¡Publicación creada en " + nombreComunidad + "! Pendiente de aprobación.";
                    }

                    // Actualizar contador de publicaciones de la comunidad
                    comunidadDAO.actualizarContadorPublicaciones(idComunidad);

                } else {
                    // PUBLICACIÓN EN FEED PRINCIPAL
                    if (autoAprobar) {
                        // SOLO usuarios privilegiados llegan aquí
                        mensaje = "¡Publicación creada y aprobada automáticamente en el feed principal!";
                    } else {
                        // Usuarios normales Y administradores de comunidades
                        boolean esAdminComunidades = comunidadDAO.esAdminDeAlgunaComunidad(usuarioActual.getId());

                        if (esAdminComunidades) {
                            mensaje = "¡Publicación creada! Tus publicaciones en el feed principal requieren aprobación.";
                        } else {
                            mensaje = "¡Publicación creada! Pendiente de aprobación por un moderador.";
                        }
                    }
                }

                System.out.println("✅ Nueva publicación creada por: " + usuarioActual.getUsername()
                        + (idComunidad != null ? " en comunidad " + idComunidad : " en feed principal"));

                // Enviar respuesta de éxito
                enviarRespuestaExito(response, mensaje, nuevaPublicacion);

            } else {
                enviarRespuestaError(response, "Error al crear la publicación en la base de datos", 500);
            }

        } catch (Exception e) {
            e.printStackTrace();
            enviarRespuestaError(response, "Error inesperado: " + e.getMessage(), 500);
        }
    }

    private String guardarImagen(Part imagenPart, int userId) {
        try {
            // Obtener extensión del archivo
            String fileName = imagenPart.getSubmittedFileName();
            String extension = "";
            if (fileName != null && fileName.contains(".")) {
                extension = fileName.substring(fileName.lastIndexOf("."));
            }

            // Generar nombre único para la imagen
            String nombreArchivo = "post_" + userId + "_" + System.currentTimeMillis() + extension;

            // Definir carpeta de uploads (ajusta la ruta según tu proyecto)
            String uploadPath = getServletContext().getRealPath("/") + "assets/images/uploads/";

            // Crear directorio si no existe
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            // Ruta completa del archivo
            String rutaCompleta = uploadPath + nombreArchivo;

            // Guardar archivo
            imagenPart.write(rutaCompleta);

            // Retornar URL relativa
            return "assets/images/uploads/" + nombreArchivo;

        } catch (Exception e) {
            System.err.println("❌ Error al guardar imagen: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    private void enviarRespuestaExito(HttpServletResponse response, String mensaje, Publicacion publicacion)
            throws IOException {

        JSONObject respuesta = new JSONObject();
        respuesta.put("success", true);
        respuesta.put("message", mensaje);

        // Agregar datos de la publicación creada
        JSONObject postData = new JSONObject();
        postData.put("id", publicacion.getIdPublicacion());
        postData.put("texto", publicacion.getTexto());
        postData.put("imagenUrl", publicacion.getImagenUrl());
        postData.put("permiteDonacion", publicacion.isPermiteDonacion());
        postData.put("estaAprobado", publicacion.isEstaAprobado());
        postData.put("fechaPublicacion", publicacion.getFechaPublicacion().toString());

        respuesta.put("post", postData);

        response.getWriter().write(respuesta.toString());
    }

    private void enviarRespuestaError(HttpServletResponse response, String mensaje, int codigoEstado)
            throws IOException {

        response.setStatus(codigoEstado);

        JSONObject respuesta = new JSONObject();
        respuesta.put("success", false);
        respuesta.put("message", mensaje);
        respuesta.put("error", true);

        response.getWriter().write(respuesta.toString());
    }

    // ========== VERIFICAR LIKE ==========
    private void verificarLike(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            HttpSession session = request.getSession();
            Usuario usuarioActual = (Usuario) session.getAttribute("usuarioLogueado");

            if (usuarioActual == null) {
                out.write("{\"userLiked\": false}");
                return;
            }

            int idPublicacion = Integer.parseInt(request.getParameter("idPublicacion"));

            // Verificar si el usuario ya dio like usando DAO
            boolean userLiked = likeDAO.usuarioYaDioLike(idPublicacion, usuarioActual.getId());

            out.write("{\"userLiked\": " + userLiked + "}");

        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"userLiked\": false}");
        }
    }

    // ========== TOGGLE LIKE ==========
    private void toggleLike(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            HttpSession session = request.getSession();
            Usuario usuarioActual = (Usuario) session.getAttribute("usuarioLogueado");

            if (usuarioActual == null) {
                out.write("{\"success\": false, \"message\": \"Usuario no logueado\"}");
                return;
            }

            int idPublicacion = Integer.parseInt(request.getParameter("idPublicacion"));

            // Verificar si ya dio like
            boolean yadiLike = likeDAO.usuarioYaDioLike(idPublicacion, usuarioActual.getId());

            boolean resultado;
            if (yadiLike) {
                // Quitar like
                resultado = likeDAO.quitarLike(idPublicacion, usuarioActual.getId());
            } else {
                // Agregar like
                resultado = likeDAO.darLike(idPublicacion, usuarioActual.getId());
            }

            if (resultado) {
                // Obtener nuevo conteo
                int nuevoConteo = likeDAO.contarPorPublicacion(idPublicacion);
                boolean estadoActual = !yadiLike;

                out.write(String.format(
                        "{\"success\": true, \"message\": \"Like procesado\", \"newCount\": %d, \"userLiked\": %s}",
                        nuevoConteo, estadoActual
                ));

                System.out.println("✅ Like procesado para publicación " + idPublicacion
                        + " por usuario " + usuarioActual.getUsername());
            } else {
                out.write("{\"success\": false, \"message\": \"Error al procesar like\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\": false, \"message\": \"Error: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    // ========== AGREGAR COMENTARIO ==========
    private void agregarComentario(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            HttpSession session = request.getSession();
            Usuario usuarioActual = (Usuario) session.getAttribute("usuarioLogueado");

            if (usuarioActual == null) {
                out.write("{\"success\": false, \"message\": \"Usuario no logueado\"}");
                return;
            }

            int idPublicacion = Integer.parseInt(request.getParameter("idPublicacion"));
            String contenido = request.getParameter("contenido");

            // Validaciones
            if (contenido == null || contenido.trim().isEmpty()) {
                out.write("{\"success\": false, \"message\": \"El comentario no puede estar vacío\"}");
                return;
            }

            if (contenido.length() > 500) {
                out.write("{\"success\": false, \"message\": \"El comentario no puede exceder 500 caracteres\"}");
                return;
            }

            // Crear nuevo comentario
            Comentario nuevoComentario = new Comentario();
            nuevoComentario.setIdPublicacion(idPublicacion);
            nuevoComentario.setIdUsuario(usuarioActual.getId());
            nuevoComentario.setContenido(contenido.trim());

            // Guardar usando DAO
            if (comentarioDAO.crear(nuevoComentario)) {
                // Obtener nuevo conteo
                int nuevoConteo = comentarioDAO.contarPorPublicacion(idPublicacion);

                // Datos completos para la respuesta
                String nombreUsuario = usuarioActual.getUsername();
                String avatar = usuarioActual.getAvatar();

                // Asegurar que el avatar tenga un valor válido
                if (avatar == null || avatar.trim().isEmpty() || avatar.equals("null")) {
                    avatar = "assets/images/avatars/default.png";
                }

                // Formatear hora
                java.time.LocalDateTime ahora = java.time.LocalDateTime.now();
                java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("HH:mm");
                String horaFormateada = ahora.format(formatter);

                // Crear respuesta JSON completa y estructurada
                StringBuilder jsonBuilder = new StringBuilder();
                jsonBuilder.append("{")
                        .append("\"success\": true,")
                        .append("\"message\": \"Comentario agregado exitosamente\",")
                        .append("\"newCount\": ").append(nuevoConteo).append(",")
                        .append("\"comment\": {")
                        .append("\"id\": ").append(nuevoComentario.getIdComentario()).append(",")
                        .append("\"idPublicacion\": ").append(idPublicacion).append(",")
                        .append("\"idUsuario\": ").append(usuarioActual.getId()).append(",")
                        .append("\"nombreUsuario\": \"").append(escapeJson(nombreUsuario)).append("\",")
                        .append("\"username\": \"@").append(escapeJson(nombreUsuario)).append("\",")
                        .append("\"contenido\": \"").append(escapeJson(contenido.trim())).append("\",")
                        .append("\"hora\": \"").append(horaFormateada).append("\",")
                        .append("\"avatar\": \"").append(avatar).append("\",")
                        .append("\"fechaCompleta\": \"").append(ahora.toString()).append("\"")
                        .append("}")
                        .append("}");

                out.write(jsonBuilder.toString());

                // Log detallado para debugging
                System.out.println("✅ Comentario creado exitosamente:");
                System.out.println("   - ID: " + nuevoComentario.getIdComentario());
                System.out.println("   - Usuario: " + nombreUsuario + " (" + usuarioActual.getId() + ")");
                System.out.println("   - Publicación: " + idPublicacion);
                System.out.println("   - Avatar: " + avatar);
                System.out.println("   - Nuevo conteo: " + nuevoConteo);

                System.out.println("✅ Comentario agregado por: " + usuarioActual.getUsername());
            } else {
                out.write("{\"success\": false, \"message\": \"Error al guardar comentario\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\": false, \"message\": \"Error: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    // ========== CREAR DONACIÓN ==========
    private void crearDonacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            HttpSession session = request.getSession();
            Usuario usuarioActual = (Usuario) session.getAttribute("usuarioLogueado");

            if (usuarioActual == null) {
                out.write("{\"success\": false, \"message\": \"Usuario no logueado\"}");
                return;
            }

            int idPublicacion = Integer.parseInt(request.getParameter("idPublicacion"));
            double cantidad = Double.parseDouble(request.getParameter("cantidad"));
            String metodoPago = request.getParameter("metodoPago");

            // Validaciones básicas
            if (cantidad <= 0 || cantidad > 10000) {
                out.write("{\"success\": false, \"message\": \"La cantidad debe estar entre $1 y $10,000\"}");
                return;
            }

            if (metodoPago == null || metodoPago.trim().isEmpty()) {
                out.write("{\"success\": false, \"message\": \"Debe seleccionar un método de pago\"}");
                return;
            }

            // Verificar que la publicación permita donaciones
            Publicacion publicacion = publicacionDAO.obtenerPorId(idPublicacion);
            if (publicacion == null || !publicacion.isPermiteDonacion()) {
                out.write("{\"success\": false, \"message\": \"Esta publicación no acepta donaciones\"}");
                return;
            }

            // No se puede donar a sí mismo
            if (publicacion.getIdUsuario() == usuarioActual.getId()) {
                out.write("{\"success\": false, \"message\": \"No puedes donarte a ti mismo\"}");
                return;
            }

            // Crear nueva donación (ingreso)
            Ingreso nuevaDonacion = new Ingreso();
            nuevaDonacion.setIdDonador(usuarioActual.getId());
            nuevaDonacion.setIdCreador(publicacion.getIdUsuario());
            nuevaDonacion.setIdPublicacion(idPublicacion);
            nuevaDonacion.setCantidad(cantidad);
            nuevaDonacion.setMetodoPago(metodoPago);
            nuevaDonacion.setEstado("Completado");

            // Generar referencia de pago simple
            String referencia = metodoPago.toUpperCase() + "-" + System.currentTimeMillis();
            nuevaDonacion.setReferenciaPago(referencia);

            // Guardar usando DAO
            if (ingresoDAO.crear(nuevaDonacion)) {
                String jsonResponse = String.format(
                        "{\"success\": true, \"message\": \"Donación procesada exitosamente\", "
                        + "\"donationId\": %d, \"amount\": %.2f, \"recipient\": \"%s\"}",
                        nuevaDonacion.getIdIngreso(),
                        cantidad,
                        escapeJson(publicacion.getNombreUsuario())
                );

                out.write(jsonResponse);

                System.out.println("✅ Donación procesada: $" + cantidad + " de "
                        + usuarioActual.getUsername() + " para publicación " + idPublicacion);
            } else {
                out.write("{\"success\": false, \"message\": \"Error al procesar la donación\"}");
            }

        } catch (NumberFormatException e) {
            out.write("{\"success\": false, \"message\": \"Formato de número inválido\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\": false, \"message\": \"Error: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    // ========== EDITAR COMENTARIO ==========
    private void editarComentario(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            HttpSession session = request.getSession();
            Usuario usuarioActual = (Usuario) session.getAttribute("usuarioLogueado");

            if (usuarioActual == null) {
                out.write("{\"success\": false, \"message\": \"Usuario no logueado\"}");
                return;
            }

            int idComentario = Integer.parseInt(request.getParameter("idComentario"));
            String nuevoContenido = request.getParameter("contenido");

            // Validaciones
            if (nuevoContenido == null || nuevoContenido.trim().isEmpty()) {
                out.write("{\"success\": false, \"message\": \"El comentario no puede estar vacío\"}");
                return;
            }

            if (nuevoContenido.length() > 500) {
                out.write("{\"success\": false, \"message\": \"El comentario no puede exceder 500 caracteres\"}");
                return;
            }

            // Verificar que el comentario existe y pertenece al usuario
            Comentario comentarioExistente = comentarioDAO.obtenerPorId(idComentario);
            if (comentarioExistente == null) {
                out.write("{\"success\": false, \"message\": \"Comentario no encontrado\"}");
                return;
            }

            if (comentarioExistente.getIdUsuario() != usuarioActual.getId()) {
                out.write("{\"success\": false, \"message\": \"No tienes permisos para editar este comentario\"}");
                return;
            }

            // Actualizar comentario
            comentarioExistente.setContenido(nuevoContenido.trim());

            if (comentarioDAO.actualizar(comentarioExistente)) {
                // Crear respuesta JSON
                StringBuilder jsonBuilder = new StringBuilder();
                jsonBuilder.append("{")
                        .append("\"success\": true,")
                        .append("\"message\": \"Comentario actualizado exitosamente\",")
                        .append("\"comment\": {")
                        .append("\"id\": ").append(idComentario).append(",")
                        .append("\"contenido\": \"").append(escapeJson(nuevoContenido.trim())).append("\",")
                        .append("\"editado\": true")
                        .append("}")
                        .append("}");

                out.write(jsonBuilder.toString());

                System.out.println("✅ Comentario editado por: " + usuarioActual.getUsername() + " (ID: " + idComentario + ")");
            } else {
                out.write("{\"success\": false, \"message\": \"Error al actualizar comentario\"}");
            }

        } catch (NumberFormatException e) {
            out.write("{\"success\": false, \"message\": \"ID de comentario inválido\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\": false, \"message\": \"Error: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    // ========== ELIMINAR COMENTARIO ==========
    private void eliminarComentario(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            HttpSession session = request.getSession();
            Usuario usuarioActual = (Usuario) session.getAttribute("usuarioLogueado");

            if (usuarioActual == null) {
                out.write("{\"success\": false, \"message\": \"Usuario no logueado\"}");
                return;
            }

            int idComentario = Integer.parseInt(request.getParameter("idComentario"));

            // Verificar que el comentario existe y pertenece al usuario
            Comentario comentarioExistente = comentarioDAO.obtenerPorId(idComentario);
            if (comentarioExistente == null) {
                out.write("{\"success\": false, \"message\": \"Comentario no encontrado\"}");
                return;
            }

            // Verificar permisos: dueño del comentario o usuario privilegiado
            if (comentarioExistente.getIdUsuario() != usuarioActual.getId() && !usuarioActual.isPrivilegio()) {
                out.write("{\"success\": false, \"message\": \"No tienes permisos para eliminar este comentario\"}");
                return;
            }

            // Eliminar comentario
            if (comentarioDAO.eliminar(idComentario)) {
                // Obtener nuevo conteo de comentarios para la publicación
                int nuevoConteo = comentarioDAO.contarPorPublicacion(comentarioExistente.getIdPublicacion());

                // Crear respuesta JSON
                StringBuilder jsonBuilder = new StringBuilder();
                jsonBuilder.append("{")
                        .append("\"success\": true,")
                        .append("\"message\": \"Comentario eliminado exitosamente\",")
                        .append("\"newCount\": ").append(nuevoConteo).append(",")
                        .append("\"commentId\": ").append(idComentario)
                        .append("}");

                out.write(jsonBuilder.toString());

                System.out.println("✅ Comentario eliminado por: " + usuarioActual.getUsername() + " (ID: " + idComentario + ")");
            } else {
                out.write("{\"success\": false, \"message\": \"Error al eliminar comentario\"}");
            }

        } catch (NumberFormatException e) {
            out.write("{\"success\": false, \"message\": \"ID de comentario inválido\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\": false, \"message\": \"Error: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private String escapeJson(String text) {
        if (text == null) {
            return "";
        }
        return text.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    @Override
    public void destroy() {
        try {
            Conexion.cerrarConexion();
            System.out.println("🛑 HomeServlet destruido y conexión cerrada");
        } catch (Exception e) {
            System.err.println("❌ Error al cerrar conexión: " + e.getMessage());
        }
    }
}
