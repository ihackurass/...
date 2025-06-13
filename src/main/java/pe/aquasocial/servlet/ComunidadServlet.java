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
import jakarta.servlet.http.Part;
import java.io.File;
import java.util.List;
import java.util.ArrayList;
import org.json.JSONObject;
import org.json.JSONArray;
import pe.aquasocial.dao.ComunidadDAO;
import pe.aquasocial.dao.PublicacionDAO;
import pe.aquasocial.dao.ComentarioDAO;
import pe.aquasocial.dao.LikeDAO;
import pe.aquasocial.entity.Usuario;
import pe.aquasocial.entity.Comunidad;
import pe.aquasocial.entity.ComunidadMiembro;
import pe.aquasocial.entity.Publicacion;
import pe.aquasocial.entity.Comentario;
import pe.aquasocial.util.Conexion;
import pe.aquasocial.util.SessionUtil;

/**
 * Servlet para gestión completa de comunidades Maneja CRUD, membresías,
 * publicaciones y permisos
 */
@WebServlet("/ComunidadServlet")
@MultipartConfig(
        maxFileSize = 5242880, // 5MB
        maxRequestSize = 10485760, // 10MB
        fileSizeThreshold = 1024 // 1KB
)
public class ComunidadServlet extends HttpServlet {

    private ComunidadDAO comunidadDAO;
    private PublicacionDAO publicacionDAO;
    private ComentarioDAO comentarioDAO;
    private LikeDAO likeDAO;

    @Override
    public void init() throws ServletException {
        try {
            if (Conexion.probarConexion()) {
                System.out.println("✅ Conexión a BD establecida en ComunidadServlet");

                // Inicializar DAOs
                comunidadDAO = new ComunidadDAO();
                publicacionDAO = new PublicacionDAO();
                comentarioDAO = new ComentarioDAO();
                likeDAO = new LikeDAO();

                System.out.println("✅ ComunidadServlet inicializado correctamente");
            } else {
                throw new ServletException("Error de conexión a BD");
            }
        } catch (Exception e) {
            System.err.println("❌ Error al inicializar ComunidadServlet: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Error al inicializar servlet", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "list":
                    listarComunidades(request, response);
                    break;
                case "view":
                    verComunidad(request, response);
                    break;
                case "create":
                    mostrarFormularioCrear(request, response);
                    break;
                case "edit":
                    mostrarFormularioEditar(request, response);
                    break;
                case "members":
                    verMiembrosComunidad(request, response);
                    break;
                case "search":
                    buscarComunidades(request, response);
                    break;
                case "checkMembership":
                    verificarMembresia(request, response);
                    break;
                case "myCommunities":
                    verMisComunidades(request, response);
                    break;
                case "managedCommunities":
                    verComunidadesQueAdministro(request, response);
                    break;
                default:
                    listarComunidades(request, response);
                    break;
            }
        } catch (Exception e) {
            System.err.println("❌ Error en GET ComunidadServlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
            request.getRequestDispatcher("/views/error.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            response.sendRedirect("ComunidadServlet");
            return;
        }

        try {
            switch (action) {
                case "create":
                    crearComunidad(request, response);
                    break;
                case "update":
                    actualizarComunidad(request, response);
                    break;
                case "delete":
                    eliminarComunidad(request, response);
                    break;
                case "join":
                    unirseAComunidad(request, response);
                    break;
                case "leave":
                    salirDeComunidad(request, response);
                    break;
                case "promoteAdmin":
                    promoverAAdmin(request, response);
                    break;
                case "demoteAdmin":
                    degradarAdmin(request, response);
                    break;
                case "removeMember":
                    expulsarMiembro(request, response);
                    break;
                case "createPost":
                    crearPublicacionEnComunidad(request, response);
                    break;
                case "checkUsername":
                    verificarUsernameDisponible(request, response);
                    break;
                default:
                    response.sendRedirect("ComunidadServlet");
                    break;
            }
        } catch (Exception e) {
            System.err.println("❌ Error en POST ComunidadServlet: " + e.getMessage());
            e.printStackTrace();
            enviarRespuestaError(response, "Error al procesar la solicitud: " + e.getMessage(), 500);
        }
    }

    // ========== MÉTODOS GET ==========
    /**
     * Listar todas las comunidades públicas
     */
    private void listarComunidades(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("🚀 Listando comunidades públicas...");

        Usuario usuarioActual = SessionUtil.getLoggedUser(request);

        try {
            // Obtener todas las comunidades públicas
            List<Comunidad> comunidades = comunidadDAO.obtenerTodas();

            // Si hay usuario logueado, verificar sus membresías
            if (usuarioActual != null) {
                for (Comunidad comunidad : comunidades) {
                    boolean esSeguidor = comunidadDAO.esMiembroDeComunidad(usuarioActual.getId(), comunidad.getIdComunidad());
                    boolean esAdmin = comunidadDAO.esAdminDeComunidad(usuarioActual.getId(), comunidad.getIdComunidad());
                    boolean esCreador = comunidadDAO.esCreadorDeComunidad(usuarioActual.getId(), comunidad.getIdComunidad());

                    comunidad.setUsuarioEsSeguidor(esSeguidor);
                    comunidad.setUsuarioEsAdmin(esAdmin);
                    comunidad.setUsuarioEsCreador(esCreador);
                }
            }

            request.setAttribute("comunidades", comunidades);
            request.setAttribute("totalComunidades", comunidades.size());

            System.out.println("✅ Enviando " + comunidades.size() + " comunidades al JSP");

            request.getRequestDispatcher("/views/comunidades/list.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("❌ Error al listar comunidades: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar las comunidades");
            request.setAttribute("comunidades", new ArrayList<Comunidad>());
            request.getRequestDispatcher("/views/comunidades/list.jsp").forward(request, response);
        }
    }

    /**
     * Ver detalles de una comunidad específica
     */
    private void verComunidad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idComunidadStr = request.getParameter("id");
        if (idComunidadStr == null || idComunidadStr.trim().isEmpty()) {
            response.sendRedirect("ComunidadServlet");
            return;
        }

        try {
            int idComunidad = Integer.parseInt(idComunidadStr);
            Usuario usuarioActual = SessionUtil.getLoggedUser(request);
            int idUsuarioActual = usuarioActual != null ? usuarioActual.getId() : 0;

            System.out.println("👀 Viendo comunidad ID: " + idComunidad + " por usuario: " + idUsuarioActual);

            // Obtener datos de la comunidad
            Comunidad comunidad = comunidadDAO.obtenerPorId(idComunidad);
            if (comunidad == null) {
                request.setAttribute("error", "Comunidad no encontrada");
                response.sendRedirect("ComunidadServlet");
                return;
            }

            // Verificar permisos del usuario actual
            if (usuarioActual != null) {
                boolean esSeguidor = comunidadDAO.esMiembroDeComunidad(idUsuarioActual, idComunidad);
                boolean esAdmin = comunidadDAO.esAdminDeComunidad(idUsuarioActual, idComunidad);
                boolean esCreador = comunidadDAO.esCreadorDeComunidad(idUsuarioActual, idComunidad);

                comunidad.setUsuarioEsSeguidor(esSeguidor);
                comunidad.setUsuarioEsAdmin(esAdmin);
                comunidad.setUsuarioEsCreador(esCreador);
            }

            // Obtener publicaciones de la comunidad
            List<Publicacion> publicaciones = publicacionDAO.obtenerPorComunidad(idComunidad, idUsuarioActual);

            // Obtener comentarios para cada publicación
            for (Publicacion pub : publicaciones) {
                List<Comentario> comentarios = comentarioDAO.obtenerPorPublicacion(pub.getIdPublicacion());
                request.setAttribute("comentarios_" + pub.getIdPublicacion(), comentarios != null ? comentarios : new ArrayList<>());
            }

            // Obtener miembros si el usuario tiene permisos
            List<ComunidadMiembro> miembros = new ArrayList<>();
            if (usuarioActual != null && (comunidad.isUsuarioEsSeguidor() || comunidad.isUsuarioEsAdmin() || comunidad.isUsuarioEsCreador())) {
                miembros = comunidadDAO.obtenerMiembrosPorComunidad(idComunidad);
            }

            // Verificar si puede publicar en esta comunidad
            boolean puedePublicar = false;
            if (usuarioActual != null) {
                puedePublicar = publicacionDAO.puedePublicarEnComunidad(idUsuarioActual, idComunidad);
            }

            // Enviar datos al JSP
            request.setAttribute("comunidad", comunidad);
            request.setAttribute("publicaciones", publicaciones);
            request.setAttribute("miembros", miembros);
            request.setAttribute("totalPublicaciones", publicaciones.size());
            request.setAttribute("totalMiembros", miembros.size());
            request.setAttribute("puedePublicar", puedePublicar);

            System.out.println("✅ Datos de comunidad enviados al JSP");

            request.getRequestDispatcher("/views/comunidades/view.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            System.err.println("❌ ID de comunidad inválido: " + idComunidadStr);
            response.sendRedirect("ComunidadServlet");
        } catch (Exception e) {
            System.err.println("❌ Error al ver comunidad: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar la comunidad");
            response.sendRedirect("ComunidadServlet");
        }
    }

    /**
     * Mostrar formulario para crear nueva comunidad
     */
    private void mostrarFormularioCrear(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/views/comunidades/create.jsp").forward(request, response);
    }

    /**
     * Ver mis comunidades (como seguidor)
     */
    private void verMisComunidades(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Usuario usuarioActual = SessionUtil.getLoggedUser(request);

        try {
            List<Comunidad> misComunidades = comunidadDAO.obtenerComunidadesSeguidas(usuarioActual.getId());
            for (Comunidad comunidad : misComunidades) {
                boolean esSeguidor = true; // Ya que es de "mis comunidades"
                boolean esAdmin = comunidadDAO.esAdminDeComunidad(usuarioActual.getId(), comunidad.getIdComunidad());
                boolean esCreador = comunidadDAO.esCreadorDeComunidad(usuarioActual.getId(), comunidad.getIdComunidad());

                comunidad.setUsuarioEsSeguidor(esSeguidor);
                comunidad.setUsuarioEsAdmin(esAdmin);
                comunidad.setUsuarioEsCreador(esCreador);
            }
            request.setAttribute("comunidades", misComunidades);
            request.setAttribute("totalComunidades", misComunidades.size());
            request.setAttribute("tituloSeccion", "Mis Comunidades");

            request.getRequestDispatcher("/views/comunidades/list.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("❌ Error al obtener mis comunidades: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar tus comunidades");
            request.getRequestDispatcher("/views/comunidades/list.jsp").forward(request, response);
        }
    }

    /**
     * Ver comunidades que administro
     */
    private void verComunidadesQueAdministro(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Usuario usuarioActual = SessionUtil.getLoggedUser(request);

        if (usuarioActual == null) {
            response.sendRedirect("LoginServlet");
            return;
        }

        try {
            List<Comunidad> comunidadesAdministradas = comunidadDAO.obtenerComunidadesQueAdministra(usuarioActual.getId());
            for (Comunidad comunidad : comunidadesAdministradas) {
                boolean esSeguidor = true; // Ya que administra = también sigue
                boolean esAdmin = true; // Ya que es de "que administro"
                boolean esCreador = comunidadDAO.esCreadorDeComunidad(usuarioActual.getId(), comunidad.getIdComunidad());

                comunidad.setUsuarioEsSeguidor(esSeguidor);
                comunidad.setUsuarioEsAdmin(esAdmin);
                comunidad.setUsuarioEsCreador(esCreador);
            }
            request.setAttribute("comunidades", comunidadesAdministradas);
            request.setAttribute("totalComunidades", comunidadesAdministradas.size());
            request.setAttribute("tituloSeccion", "Comunidades que Administro");
            request.setAttribute("esAdministrador", true);

            request.getRequestDispatcher("/views/comunidades/list.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("❌ Error al obtener comunidades administradas: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar las comunidades que administras");
            request.getRequestDispatcher("/views/comunidades/list.jsp").forward(request, response);
        }
    }

    /**
     * Buscar comunidades
     */
    private void buscarComunidades(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String query = request.getParameter("q");
        if (query == null || query.trim().isEmpty()) {
            response.sendRedirect("ComunidadServlet");
            return;
        }

        try {
            Usuario usuarioActual = SessionUtil.getLoggedUser(request);
            List<Comunidad> resultados = comunidadDAO.buscarPorNombre(query.trim());

            // Si hay usuario logueado, verificar membresías
            if (usuarioActual != null) {
                for (Comunidad comunidad : resultados) {
                    boolean esSeguidor = comunidadDAO.esMiembroDeComunidad(usuarioActual.getId(), comunidad.getIdComunidad());
                    boolean esAdmin = comunidadDAO.esAdminDeComunidad(usuarioActual.getId(), comunidad.getIdComunidad());
                    boolean esCreador = comunidadDAO.esCreadorDeComunidad(usuarioActual.getId(), comunidad.getIdComunidad());

                    comunidad.setUsuarioEsSeguidor(esSeguidor);
                    comunidad.setUsuarioEsAdmin(esAdmin);
                    comunidad.setUsuarioEsCreador(esCreador);
                }
            }

            request.setAttribute("comunidades", resultados);
            request.setAttribute("totalComunidades", resultados.size());
            request.setAttribute("searchQuery", query);
            request.setAttribute("tituloSeccion", "Resultados de búsqueda para: \"" + query + "\"");

            request.getRequestDispatcher("/views/comunidades/search_results.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("❌ Error al buscar comunidades: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error al realizar la búsqueda");
            response.sendRedirect("ComunidadServlet");
        }
    }

    private void verificarUsernameDisponible(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {

            String username = request.getParameter("username");

            if (username == null || username.trim().isEmpty()) {
                JSONObject respuesta = new JSONObject();
                respuesta.put("available", false);
                respuesta.put("message", "Username vacío");
                response.getWriter().write(respuesta.toString());
                return;
            }

            username = username.trim();

            if (username.length() < 3) {
                JSONObject respuesta = new JSONObject();
                respuesta.put("available", false);
                respuesta.put("message", "Muy corto (mínimo 3 caracteres)");
                response.getWriter().write(respuesta.toString());
                return;
            }

            if (username.length() > 50) {
                JSONObject respuesta = new JSONObject();
                respuesta.put("available", false);
                respuesta.put("message", "Muy largo (máximo 50 caracteres)");
                response.getWriter().write(respuesta.toString());
                return;
            }

            // Validar formato (solo letras, números y guiones bajos)
            if (!username.matches("^[a-zA-Z0-9_]+$")) {
                JSONObject respuesta = new JSONObject();
                respuesta.put("available", false);
                respuesta.put("message", "Solo se permiten letras, números y guiones bajos");
                response.getWriter().write(respuesta.toString());
                return;
            }

            // Verificar disponibilidad globalmente (usuarios + comunidades)
            boolean disponible = comunidadDAO.verificarUsernameDisponible(username);

            JSONObject respuesta = new JSONObject();
            respuesta.put("available", disponible);

            if (disponible) {
                respuesta.put("message", "@" + username + " está disponible");
            } else {
                respuesta.put("message", "@" + username + " ya está en uso");
            }

            response.getWriter().write(respuesta.toString());

            System.out.println("✅ Verificación global de username: @" + username + " = "
                    + (disponible ? "disponible" : "ocupado"));

        } catch (Exception e) {
            System.err.println("❌ Error al verificar username globalmente: " + e.getMessage());
            e.printStackTrace();

            JSONObject respuesta = new JSONObject();
            respuesta.put("available", false);
            respuesta.put("message", "Error del servidor al verificar disponibilidad");

            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(respuesta.toString());
        }
    }

    /**
     * Verificar membresía vía AJAX
     */
    private void verificarMembresia(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            Usuario usuarioActual = SessionUtil.getLoggedUser(request);
            if (usuarioActual == null) {
                enviarRespuestaError(response, "Usuario no autenticado", 401);
                return;
            }

            int idComunidad = Integer.parseInt(request.getParameter("idComunidad"));

            boolean esSeguidor = comunidadDAO.esMiembroDeComunidad(usuarioActual.getId(), idComunidad);
            boolean esAdmin = comunidadDAO.esAdminDeComunidad(usuarioActual.getId(), idComunidad);
            boolean esCreador = comunidadDAO.esCreadorDeComunidad(usuarioActual.getId(), idComunidad);

            JSONObject respuesta = new JSONObject();
            respuesta.put("success", true);
            respuesta.put("isMember", esSeguidor);
            respuesta.put("isAdmin", esAdmin);
            respuesta.put("isCreator", esCreador);

            response.getWriter().write(respuesta.toString());

        } catch (Exception e) {
            System.err.println("❌ Error al verificar membresía: " + e.getMessage());
            enviarRespuestaError(response, "Error al verificar membresía", 500);
        }
    }

    // ========== MÉTODOS POST ==========
    /**
     * Crear nueva comunidad
     */
    private void crearComunidad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            Usuario usuarioActual = SessionUtil.getLoggedUser(request);
            if (usuarioActual == null) {
                enviarRespuestaError(response, "Usuario no autenticado", 401);
                return;
            }

            // Obtener parámetros
            String nombre = request.getParameter("nombre");
            String username = request.getParameter("username"); // ⭐ NUEVO
            String descripcion = request.getParameter("descripcion");
            String esPublicaStr = request.getParameter("esPublica");

            // Validaciones básicas
            if (nombre == null || nombre.trim().isEmpty()) {
                enviarRespuestaError(response, "El nombre de la comunidad es requerido", 400);
                return;
            }

            if (nombre.length() < 3 || nombre.length() > 100) {
                enviarRespuestaError(response, "El nombre debe tener entre 3 y 100 caracteres", 400);
                return;
            }

            // ⭐ NUEVAS: Validaciones de username
            if (username == null || username.trim().isEmpty()) {
                enviarRespuestaError(response, "El username de la comunidad es requerido", 400);
                return;
            }

            username = username.trim();

            if (username.length() < 3 || username.length() > 50) {
                enviarRespuestaError(response, "El username debe tener entre 3 y 50 caracteres", 400);
                return;
            }

            // Validar formato de username
            if (!username.matches("^[a-zA-Z0-9_]+$")) {
                enviarRespuestaError(response, "El username solo puede contener letras, números y guiones bajos", 400);
                return;
            }

            // ⭐ NUEVA: Verificar disponibilidad global del username
            if (!comunidadDAO.verificarUsernameDisponible(username)) {
                enviarRespuestaError(response, "El username @" + username + " ya está en uso", 400);
                return;
            }

            // Validaciones de descripción
            if (descripcion == null || descripcion.trim().isEmpty()) {
                enviarRespuestaError(response, "La descripción es requerida", 400);
                return;
            }

            if (descripcion.length() < 10 || descripcion.length() > 1000) {
                enviarRespuestaError(response, "La descripción debe tener entre 10 y 1000 caracteres", 400);
                return;
            }

            // Procesar imagen si existe
            String imagenUrl = null;
            Part imagenPart = request.getPart("imagen");

            if (imagenPart != null && imagenPart.getSize() > 0) {
                // Validar tipo y tamaño
                String contentType = imagenPart.getContentType();
                if (contentType == null || !contentType.startsWith("image/")) {
                    enviarRespuestaError(response, "Solo se permiten archivos de imagen", 400);
                    return;
                }

                if (imagenPart.getSize() > 5242880) { // 5MB
                    enviarRespuestaError(response, "La imagen es muy grande. Máximo 5MB", 400);
                    return;
                }

                imagenUrl = guardarImagenComunidad(imagenPart, usuarioActual.getId());
                if (imagenUrl == null) {
                    enviarRespuestaError(response, "Error al procesar la imagen", 500);
                    return;
                }
            }

            // ⭐ ACTUALIZADO: Crear objeto comunidad con username
            Comunidad nuevaComunidad = new Comunidad();
            nuevaComunidad.setNombre(nombre.trim());
            nuevaComunidad.setUsername(username.toLowerCase().trim()); // ⭐ NUEVO - normalizar a minúsculas
            nuevaComunidad.setDescripcion(descripcion.trim());
            nuevaComunidad.setImagenUrl(imagenUrl);
            nuevaComunidad.setIdCreador(usuarioActual.getId());
            nuevaComunidad.setEsPublica("true".equals(esPublicaStr) || "on".equals(esPublicaStr));

            // ⭐ NUEVA: Validación final antes de guardar
            if (!nuevaComunidad.esValidaParaCrear()) {
                enviarRespuestaError(response, "Los datos de la comunidad no son válidos", 400);
                return;
            }

            // Guardar en base de datos
            if (comunidadDAO.crear(nuevaComunidad)) {
                System.out.println("✅ Comunidad creada: " + nombre + " (@" + username + ") por " + usuarioActual.getUsername());

                JSONObject respuesta = new JSONObject();
                respuesta.put("success", true);
                respuesta.put("message", "¡Comunidad '" + nombre + "' creada exitosamente!");
                respuesta.put("communityId", nuevaComunidad.getIdComunidad());
                respuesta.put("communityUsername", nuevaComunidad.getUsername()); // ⭐ NUEVO
                respuesta.put("redirectUrl", "ComunidadServlet?action=view&id=" + nuevaComunidad.getIdComunidad());

                response.getWriter().write(respuesta.toString());
            } else {
                enviarRespuestaError(response, "Error al crear la comunidad en la base de datos", 500);
            }

        } catch (Exception e) {
            System.err.println("❌ Error al crear comunidad: " + e.getMessage());
            e.printStackTrace();
            enviarRespuestaError(response, "Error inesperado: " + e.getMessage(), 500);
        }
    }

    /**
     * Unirse a una comunidad
     */
    private void unirseAComunidad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            Usuario usuarioActual = SessionUtil.getLoggedUser(request);
            if (usuarioActual == null) {
                enviarRespuestaError(response, "Usuario no autenticado", 401);
                return;
            }

            int idComunidad = Integer.parseInt(request.getParameter("idComunidad"));

            // Verificar que la comunidad existe
            Comunidad comunidad = comunidadDAO.obtenerPorId(idComunidad);
            if (comunidad == null) {
                enviarRespuestaError(response, "Comunidad no encontrada", 404);
                return;
            }

            // Verificar que no es ya miembro
            if (comunidadDAO.esMiembroDeComunidad(usuarioActual.getId(), idComunidad)) {
                enviarRespuestaError(response, "Ya eres miembro de esta comunidad", 400);
                return;
            }

            // Unirse como seguidor
            if (comunidadDAO.seguirComunidad(usuarioActual.getId(), idComunidad)) {
                System.out.println("✅ " + usuarioActual.getUsername() + " se unió a comunidad: " + comunidad.getNombre());

                JSONObject respuesta = new JSONObject();
                respuesta.put("success", true);
                respuesta.put("message", "¡Te has unido a '" + comunidad.getNombre() + "'!");
                respuesta.put("newMemberCount", comunidad.getSeguidoresCount() + 1);

                response.getWriter().write(respuesta.toString());
            } else {
                enviarRespuestaError(response, "Error al unirse a la comunidad", 500);
            }

        } catch (NumberFormatException e) {
            enviarRespuestaError(response, "ID de comunidad inválido", 400);
        } catch (Exception e) {
            System.err.println("❌ Error al unirse a comunidad: " + e.getMessage());
            e.printStackTrace();
            enviarRespuestaError(response, "Error inesperado: " + e.getMessage(), 500);
        }
    }

    /**
     * Salir de una comunidad
     */
    private void salirDeComunidad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            Usuario usuarioActual = SessionUtil.getLoggedUser(request);
            if (usuarioActual == null) {
                enviarRespuestaError(response, "Usuario no autenticado", 401);
                return;
            }

            int idComunidad = Integer.parseInt(request.getParameter("idComunidad"));

            // Verificar que es miembro
            if (!comunidadDAO.esMiembroDeComunidad(usuarioActual.getId(), idComunidad)) {
                enviarRespuestaError(response, "No eres miembro de esta comunidad", 400);
                return;
            }

            // Verificar que no es el creador
            if (comunidadDAO.esCreadorDeComunidad(usuarioActual.getId(), idComunidad)) {
                enviarRespuestaError(response, "No puedes salir de una comunidad que creaste", 400);
                return;
            }

            // Salir de la comunidad
            if (comunidadDAO.dejarDeSeguir(usuarioActual.getId(), idComunidad)) {
                Comunidad comunidad = comunidadDAO.obtenerPorId(idComunidad);

                System.out.println("✅ " + usuarioActual.getUsername() + " salió de comunidad: "
                        + (comunidad != null ? comunidad.getNombre() : idComunidad));

                JSONObject respuesta = new JSONObject();
                respuesta.put("success", true);
                respuesta.put("message", "Has salido de la comunidad");
                if (comunidad != null) {
                    respuesta.put("newMemberCount", Math.max(0, comunidad.getSeguidoresCount() - 1));
                }

                response.getWriter().write(respuesta.toString());
            } else {
                enviarRespuestaError(response, "Error al salir de la comunidad", 500);
            }

        } catch (NumberFormatException e) {
            enviarRespuestaError(response, "ID de comunidad inválido", 400);
        } catch (Exception e) {
            System.err.println("❌ Error al salir de comunidad: " + e.getMessage());
            e.printStackTrace();
            enviarRespuestaError(response, "Error inesperado: " + e.getMessage(), 500);
        }
    }

    /**
     * Crear publicación en comunidad específica
     */
    private void crearPublicacionEnComunidad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            Usuario usuarioActual = SessionUtil.getLoggedUser(request);
            if (usuarioActual == null) {
                enviarRespuestaError(response, "Usuario no autenticado", 401);
                return;
            }

            // Obtener parámetros
            String texto = request.getParameter("texto");
            String idComunidadStr = request.getParameter("idComunidad");
            String permiteDonacionStr = request.getParameter("permiteDonacion");

            // Validaciones básicas
            if (texto == null || texto.trim().isEmpty()) {
                enviarRespuestaError(response, "El texto de la publicación no puede estar vacío", 400);
                return;
            }

            if (texto.length() > 999) {
                enviarRespuestaError(response, "El texto no puede exceder 999 caracteres", 400);
                return;
            }

            int idComunidad = Integer.parseInt(idComunidadStr);

            // Verificar permisos para publicar en la comunidad
            if (!publicacionDAO.puedePublicarEnComunidad(usuarioActual.getId(), idComunidad)) {
                enviarRespuestaError(response, "No tienes permisos para publicar en esta comunidad", 403);
                return;
            }

            // Procesar imagen si existe
            String imagenUrl = null;
            Part imagenPart = request.getPart("imagen");

            if (imagenPart != null && imagenPart.getSize() > 0) {
                String contentType = imagenPart.getContentType();
                if (contentType == null || !contentType.startsWith("image/")) {
                    enviarRespuestaError(response, "Solo se permiten archivos de imagen", 400);
                    return;
                }

                if (imagenPart.getSize() > 5242880) {
                    enviarRespuestaError(response, "La imagen es muy grande. Máximo 5MB", 400);
                    return;
                }

                imagenUrl = guardarImagenPublicacion(imagenPart, usuarioActual.getId());
                if (imagenUrl == null) {
                    enviarRespuestaError(response, "Error al procesar la imagen", 500);
                    return;
                }
            }

            // ============ LÓGICA DE AUTO-APROBACIÓN ============
            boolean autoAprobar = false;
            if (usuarioActual.isPrivilegio()
                    || comunidadDAO.esAdminDeAlgunaComunidad(usuarioActual.getId())) {
                autoAprobar = true;
            }

            // ============ LÓGICA DE DONACIONES ============
            boolean permiteDonacion = false;
            // SOLO usuarios privilegiados pueden recibir donaciones
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

            nuevaPublicacion.setEstaAprobado(autoAprobar);
            nuevaPublicacion.setIdComunidad(idComunidad);

            // Guardar en base de datos
            if (publicacionDAO.crear(nuevaPublicacion)) {
                Comunidad comunidad = comunidadDAO.obtenerPorId(idComunidad);
                String nombreComunidad = comunidad != null ? comunidad.getNombre() : "la comunidad";

                String mensaje;
                if (autoAprobar) {
                    if (usuarioActual.isPrivilegio() && !comunidadDAO.esAdminDeComunidad(usuarioActual.getId(), idComunidad)) {
                        mensaje = "¡Publicación creada en " + nombreComunidad + "! Aprobada automáticamente por tus privilegios.";
                    } else {
                        mensaje = "¡Publicación creada en " + nombreComunidad + "! Aprobada automáticamente como administrador.";
                    }
                } else {
                    mensaje = "¡Publicación creada en " + nombreComunidad + "! Pendiente de aprobación.";
                }

                System.out.println("✅ Nueva publicación en comunidad " + idComunidad + " por: " + usuarioActual.getUsername());

                // Actualizar contador de publicaciones de la comunidad
                comunidadDAO.actualizarContadorPublicaciones(idComunidad);

                JSONObject respuesta = new JSONObject();
                respuesta.put("success", true);
                respuesta.put("message", mensaje);
                respuesta.put("postId", nuevaPublicacion.getIdPublicacion());
                respuesta.put("autoApproved", autoAprobar);
                respuesta.put("allowsDonations", permiteDonacion);

                response.getWriter().write(respuesta.toString());

            } else {
                enviarRespuestaError(response, "Error al crear la publicación en la base de datos", 500);
            }

        } catch (NumberFormatException e) {
            enviarRespuestaError(response, "ID de comunidad inválido", 400);
        } catch (Exception e) {
            System.err.println("❌ Error al crear publicación en comunidad: " + e.getMessage());
            e.printStackTrace();
            enviarRespuestaError(response, "Error inesperado: " + e.getMessage(), 500);
        }
    }

    /**
     * Promover usuario a administrador
     */
    private void promoverAAdmin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            Usuario usuarioActual = SessionUtil.getLoggedUser(request);
            if (usuarioActual == null) {
                enviarRespuestaError(response, "Usuario no autenticado", 401);
                return;
            }

            int idComunidad = Integer.parseInt(request.getParameter("idComunidad"));
            int idUsuarioPromover = Integer.parseInt(request.getParameter("idUsuario"));

            // Verificar que es creador o admin de la comunidad
            if (!comunidadDAO.esCreadorDeComunidad(usuarioActual.getId(), idComunidad)
                    && !comunidadDAO.esAdminDeComunidad(usuarioActual.getId(), idComunidad)) {
                enviarRespuestaError(response, "No tienes permisos para promover administradores", 403);
                return;
            }

            // Verificar que el usuario a promover es miembro
            if (!comunidadDAO.esMiembroDeComunidad(idUsuarioPromover, idComunidad)) {
                enviarRespuestaError(response, "El usuario no es miembro de esta comunidad", 400);
                return;
            }

            // Promover a admin
            if (comunidadDAO.promoverAAdmin(idUsuarioPromover, idComunidad)) {
                System.out.println("✅ Usuario " + idUsuarioPromover + " promovido a admin en comunidad " + idComunidad);

                JSONObject respuesta = new JSONObject();
                respuesta.put("success", true);
                respuesta.put("message", "Usuario promovido a administrador exitosamente");

                response.getWriter().write(respuesta.toString());
            } else {
                enviarRespuestaError(response, "Error al promover usuario", 500);
            }

        } catch (NumberFormatException e) {
            enviarRespuestaError(response, "IDs inválidos", 400);
        } catch (Exception e) {
            System.err.println("❌ Error al promover admin: " + e.getMessage());
            e.printStackTrace();
            enviarRespuestaError(response, "Error inesperado: " + e.getMessage(), 500);
        }
    }

    /**
     * Degradar administrador a seguidor
     */
    private void degradarAdmin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            Usuario usuarioActual = SessionUtil.getLoggedUser(request);
            if (usuarioActual == null) {
                enviarRespuestaError(response, "Usuario no autenticado", 401);
                return;
            }

            int idComunidad = Integer.parseInt(request.getParameter("idComunidad"));
            int idUsuarioDegrader = Integer.parseInt(request.getParameter("idUsuario"));

            // Solo el creador puede degradar admins
            if (!comunidadDAO.esCreadorDeComunidad(usuarioActual.getId(), idComunidad)) {
                enviarRespuestaError(response, "Solo el creador puede degradar administradores", 403);
                return;
            }

            // No puede degradarse a sí mismo si es el creador
            if (idUsuarioDegrader == usuarioActual.getId()) {
                enviarRespuestaError(response, "No puedes degradarte a ti mismo como creador", 400);
                return;
            }

            // Verificar que el usuario es admin
            if (!comunidadDAO.esAdminDeComunidad(idUsuarioDegrader, idComunidad)) {
                enviarRespuestaError(response, "El usuario no es administrador de esta comunidad", 400);
                return;
            }

            // Degradar a seguidor
            if (comunidadDAO.degradarAdmin(idUsuarioDegrader, idComunidad)) {
                System.out.println("✅ Usuario " + idUsuarioDegrader + " degradado a seguidor en comunidad " + idComunidad);

                JSONObject respuesta = new JSONObject();
                respuesta.put("success", true);
                respuesta.put("message", "Administrador degradado a seguidor exitosamente");

                response.getWriter().write(respuesta.toString());
            } else {
                enviarRespuestaError(response, "Error al degradar administrador", 500);
            }

        } catch (NumberFormatException e) {
            enviarRespuestaError(response, "IDs inválidos", 400);
        } catch (Exception e) {
            System.err.println("❌ Error al degradar admin: " + e.getMessage());
            e.printStackTrace();
            enviarRespuestaError(response, "Error inesperado: " + e.getMessage(), 500);
        }
    }

    /**
     * Expulsar miembro de la comunidad
     */
    private void expulsarMiembro(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            Usuario usuarioActual = SessionUtil.getLoggedUser(request);
            if (usuarioActual == null) {
                enviarRespuestaError(response, "Usuario no autenticado", 401);
                return;
            }

            int idComunidad = Integer.parseInt(request.getParameter("idComunidad"));
            int idUsuarioExpulsar = Integer.parseInt(request.getParameter("idUsuario"));

            // Verificar permisos (creador o admin)
            if (!comunidadDAO.esCreadorDeComunidad(usuarioActual.getId(), idComunidad)
                    && !comunidadDAO.esAdminDeComunidad(usuarioActual.getId(), idComunidad)) {
                enviarRespuestaError(response, "No tienes permisos para expulsar miembros", 403);
                return;
            }

            // No puede expulsarse a sí mismo
            if (idUsuarioExpulsar == usuarioActual.getId()) {
                enviarRespuestaError(response, "No puedes expulsarte a ti mismo", 400);
                return;
            }

            // No puede expulsar al creador
            if (comunidadDAO.esCreadorDeComunidad(idUsuarioExpulsar, idComunidad)) {
                enviarRespuestaError(response, "No puedes expulsar al creador de la comunidad", 400);
                return;
            }

            // Admin no puede expulsar a otro admin (solo el creador puede)
            if (comunidadDAO.esAdminDeComunidad(idUsuarioExpulsar, idComunidad)
                    && !comunidadDAO.esCreadorDeComunidad(usuarioActual.getId(), idComunidad)) {
                enviarRespuestaError(response, "Solo el creador puede expulsar administradores", 403);
                return;
            }

            // Expulsar miembro
            if (comunidadDAO.dejarDeSeguir(idUsuarioExpulsar, idComunidad)) {
                System.out.println("✅ Usuario " + idUsuarioExpulsar + " expulsado de comunidad " + idComunidad
                        + " por " + usuarioActual.getUsername());

                JSONObject respuesta = new JSONObject();
                respuesta.put("success", true);
                respuesta.put("message", "Miembro expulsado exitosamente");

                response.getWriter().write(respuesta.toString());
            } else {
                enviarRespuestaError(response, "Error al expulsar miembro", 500);
            }

        } catch (NumberFormatException e) {
            enviarRespuestaError(response, "IDs inválidos", 400);
        } catch (Exception e) {
            System.err.println("❌ Error al expulsar miembro: " + e.getMessage());
            e.printStackTrace();
            enviarRespuestaError(response, "Error inesperado: " + e.getMessage(), 500);
        }
    }

    /**
     * Actualizar comunidad
     */
    private void actualizarComunidad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            Usuario usuarioActual = SessionUtil.getLoggedUser(request);
            if (usuarioActual == null) {
                enviarRespuestaError(response, "Usuario no autenticado", 401);
                return;
            }

            int idComunidad = Integer.parseInt(request.getParameter("idComunidad"));

            // Verificar permisos (solo creador puede editar)
            if (!comunidadDAO.esCreadorDeComunidad(usuarioActual.getId(), idComunidad)) {
                enviarRespuestaError(response, "Solo el creador puede editar la comunidad", 403);
                return;
            }

            // Obtener comunidad actual
            Comunidad comunidad = comunidadDAO.obtenerPorId(idComunidad);
            if (comunidad == null) {
                enviarRespuestaError(response, "Comunidad no encontrada", 404);
                return;
            }

            // Obtener nuevos datos
            String nombre = request.getParameter("nombre");
            String descripcion = request.getParameter("descripcion");
            String esPublicaStr = request.getParameter("esPublica");

            // Validaciones
            if (nombre == null || nombre.trim().isEmpty()) {
                enviarRespuestaError(response, "El nombre es requerido", 400);
                return;
            }

            if (nombre.length() < 3 || nombre.length() > 100) {
                enviarRespuestaError(response, "El nombre debe tener entre 3 y 100 caracteres", 400);
                return;
            }

            if (descripcion == null || descripcion.trim().isEmpty()) {
                enviarRespuestaError(response, "La descripción es requerida", 400);
                return;
            }

            if (descripcion.length() < 10 || descripcion.length() > 1000) {
                enviarRespuestaError(response, "La descripción debe tener entre 10 y 1000 caracteres", 400);
                return;
            }

            // Procesar nueva imagen si existe
            Part imagenPart = request.getPart("imagen");
            if (imagenPart != null && imagenPart.getSize() > 0) {
                String contentType = imagenPart.getContentType();
                if (contentType == null || !contentType.startsWith("image/")) {
                    enviarRespuestaError(response, "Solo se permiten archivos de imagen", 400);
                    return;
                }

                if (imagenPart.getSize() > 5242880) {
                    enviarRespuestaError(response, "La imagen es muy grande. Máximo 5MB", 400);
                    return;
                }

                String nuevaImagenUrl = guardarImagenComunidad(imagenPart, usuarioActual.getId());
                if (nuevaImagenUrl != null) {
                    comunidad.setImagenUrl(nuevaImagenUrl);
                }
            }

            // Actualizar datos
            comunidad.setNombre(nombre.trim());
            comunidad.setDescripcion(descripcion.trim());
            comunidad.setEsPublica("true".equals(esPublicaStr) || "on".equals(esPublicaStr));

            // Guardar cambios
            if (comunidadDAO.actualizar(comunidad)) {
                System.out.println("✅ Comunidad actualizada: " + nombre + " por " + usuarioActual.getUsername());

                JSONObject respuesta = new JSONObject();
                respuesta.put("success", true);
                respuesta.put("message", "Comunidad actualizada exitosamente");

                response.getWriter().write(respuesta.toString());
            } else {
                enviarRespuestaError(response, "Error al actualizar la comunidad", 500);
            }

        } catch (NumberFormatException e) {
            enviarRespuestaError(response, "ID de comunidad inválido", 400);
        } catch (Exception e) {
            System.err.println("❌ Error al actualizar comunidad: " + e.getMessage());
            e.printStackTrace();
            enviarRespuestaError(response, "Error inesperado: " + e.getMessage(), 500);
        }
    }

    /**
     * Eliminar comunidad
     */
    private void eliminarComunidad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            Usuario usuarioActual = SessionUtil.getLoggedUser(request);
            if (usuarioActual == null) {
                enviarRespuestaError(response, "Usuario no autenticado", 401);
                return;
            }

            int idComunidad = Integer.parseInt(request.getParameter("idComunidad"));

            // Solo el creador puede eliminar
            if (!comunidadDAO.esCreadorDeComunidad(usuarioActual.getId(), idComunidad)) {
                enviarRespuestaError(response, "Solo el creador puede eliminar la comunidad", 403);
                return;
            }

            // Verificar confirmación
            String confirmacion = request.getParameter("confirmacion");
            if (!"ELIMINAR".equals(confirmacion)) {
                enviarRespuestaError(response, "Confirmación requerida", 400);
                return;
            }

            Comunidad comunidad = comunidadDAO.obtenerPorId(idComunidad);
            String nombreComunidad = comunidad != null ? comunidad.getNombre() : "Comunidad " + idComunidad;

            // Eliminar comunidad
            if (comunidadDAO.eliminar(idComunidad)) {
                System.out.println("✅ Comunidad eliminada: " + nombreComunidad + " por " + usuarioActual.getUsername());

                JSONObject respuesta = new JSONObject();
                respuesta.put("success", true);
                respuesta.put("message", "Comunidad '" + nombreComunidad + "' eliminada exitosamente");
                respuesta.put("redirectUrl", "ComunidadServlet");

                response.getWriter().write(respuesta.toString());
            } else {
                enviarRespuestaError(response, "Error al eliminar la comunidad", 500);
            }

        } catch (NumberFormatException e) {
            enviarRespuestaError(response, "ID de comunidad inválido", 400);
        } catch (Exception e) {
            System.err.println("❌ Error al eliminar comunidad: " + e.getMessage());
            e.printStackTrace();
            enviarRespuestaError(response, "Error inesperado: " + e.getMessage(), 500);
        }
    }

    // ========== MÉTODOS AUXILIARES ==========
    /**
     * Guardar imagen de comunidad
     */
    private String guardarImagenComunidad(Part imagenPart, int userId) {
        try {
            String fileName = imagenPart.getSubmittedFileName();
            String extension = "";
            if (fileName != null && fileName.contains(".")) {
                extension = fileName.substring(fileName.lastIndexOf("."));
            }

            String nombreArchivo = "community_" + userId + "_" + System.currentTimeMillis() + extension;
            String uploadPath = getServletContext().getRealPath("/") + "assets/images/comunidades/";

            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            String rutaCompleta = uploadPath + nombreArchivo;
            imagenPart.write(rutaCompleta);

            return "assets/images/comunidades/" + nombreArchivo;

        } catch (Exception e) {
            System.err.println("❌ Error al guardar imagen de comunidad: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Guardar imagen de publicación
     */
    private String guardarImagenPublicacion(Part imagenPart, int userId) {
        try {
            String fileName = imagenPart.getSubmittedFileName();
            String extension = "";
            if (fileName != null && fileName.contains(".")) {
                extension = fileName.substring(fileName.lastIndexOf("."));
            }

            String nombreArchivo = "post_community_" + userId + "_" + System.currentTimeMillis() + extension;
            String uploadPath = getServletContext().getRealPath("/") + "assets/images/uploads/";

            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            String rutaCompleta = uploadPath + nombreArchivo;
            imagenPart.write(rutaCompleta);

            return "assets/images/uploads/" + nombreArchivo;

        } catch (Exception e) {
            System.err.println("❌ Error al guardar imagen de publicación: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Enviar respuesta de error en formato JSON
     */
    private void enviarRespuestaError(HttpServletResponse response, String mensaje, int codigoEstado)
            throws IOException {

        response.setStatus(codigoEstado);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JSONObject respuesta = new JSONObject();
        respuesta.put("success", false);
        respuesta.put("message", mensaje);
        respuesta.put("error", true);
        respuesta.put("timestamp", System.currentTimeMillis());

        response.getWriter().write(respuesta.toString());
    }

    /**
     * Escapar texto para JSON
     */
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

    /**
     * Mostrar formulario de edición
     */
    private void mostrarFormularioEditar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idComunidadStr = request.getParameter("id");
        if (idComunidadStr == null || idComunidadStr.trim().isEmpty()) {
            response.sendRedirect("ComunidadServlet");
            return;
        }

        try {
            int idComunidad = Integer.parseInt(idComunidadStr);
            Usuario usuarioActual = SessionUtil.getLoggedUser(request);

            if (usuarioActual == null) {
                response.sendRedirect("LoginServlet");
                return;
            }

            // Verificar que es el creador
            if (!comunidadDAO.esCreadorDeComunidad(usuarioActual.getId(), idComunidad)) {
                request.setAttribute("error", "No tienes permisos para editar esta comunidad");
                response.sendRedirect("ComunidadServlet?action=view&id=" + idComunidad);
                return;
            }

            Comunidad comunidad = comunidadDAO.obtenerPorId(idComunidad);
            if (comunidad == null) {
                request.setAttribute("error", "Comunidad no encontrada");
                response.sendRedirect("ComunidadServlet");
                return;
            }

            request.setAttribute("comunidad", comunidad);
            request.getRequestDispatcher("/views/comunidades/edit.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("ComunidadServlet");
        } catch (Exception e) {
            System.err.println("❌ Error al mostrar formulario de edición: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar el formulario de edición");
            response.sendRedirect("ComunidadServlet");
        }
    }

    /**
     * Ver miembros de una comunidad
     */
    private void verMiembrosComunidad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idComunidadStr = request.getParameter("id");
        if (idComunidadStr == null || idComunidadStr.trim().isEmpty()) {
            response.sendRedirect("ComunidadServlet");
            return;
        }

        try {
            int idComunidad = Integer.parseInt(idComunidadStr);
            Usuario usuarioActual = SessionUtil.getLoggedUser(request);

            // Obtener datos de la comunidad
            Comunidad comunidad = comunidadDAO.obtenerPorId(idComunidad);
            if (comunidad == null) {
                request.setAttribute("error", "Comunidad no encontrada");
                response.sendRedirect("ComunidadServlet");
                return;
            }

            // Verificar permisos (debe ser miembro para ver otros miembros)
            boolean esMiembro = false;
            boolean esAdmin = false;
            boolean esCreador = false;

            if (usuarioActual != null) {
                esMiembro = comunidadDAO.esMiembroDeComunidad(usuarioActual.getId(), idComunidad);
                esAdmin = comunidadDAO.esAdminDeComunidad(usuarioActual.getId(), idComunidad);
                esCreador = comunidadDAO.esCreadorDeComunidad(usuarioActual.getId(), idComunidad);
            }

            if (!esMiembro && !comunidad.isEsPublica()) {
                request.setAttribute("error", "No tienes permisos para ver los miembros de esta comunidad");
                response.sendRedirect("ComunidadServlet?action=view&id=" + idComunidad);
                return;
            }

            // Obtener lista de miembros
            List<ComunidadMiembro> miembros = comunidadDAO.obtenerMiembrosPorComunidad(idComunidad);

            // Establecer permisos del usuario actual
            request.setAttribute("comunidad", comunidad);
            request.setAttribute("miembros", miembros);
            request.setAttribute("totalMiembros", miembros.size());
            request.setAttribute("esMiembro", esMiembro);
            request.setAttribute("esAdmin", esAdmin);
            request.setAttribute("esCreador", esCreador);

            request.getRequestDispatcher("/views/comunidades/members.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("ComunidadServlet");
        } catch (Exception e) {
            System.err.println("❌ Error al ver miembros: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar los miembros");
            response.sendRedirect("ComunidadServlet");
        }
    }

    @Override
    public void destroy() {
        try {
            Conexion.cerrarConexion();
            System.out.println("🛑 ComunidadServlet destruido y conexión cerrada");
        } catch (Exception e) {
            System.err.println("❌ Error al cerrar conexión en ComunidadServlet: " + e.getMessage());
        }
    }
}
