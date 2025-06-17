/*
 * Servlet para gestión del perfil de usuario
 * Funcionalidades: Actualizar información, cambiar contraseña, avatar y estadísticas
 */
package pe.aquasocial.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import com.google.gson.Gson;
import java.util.ArrayList;
import java.util.List;
import pe.aquasocial.dao.ComentarioDAO;
import pe.aquasocial.dao.UsuarioDAO;
import pe.aquasocial.dao.ComunidadDAO;
import pe.aquasocial.dao.LikeDAO;
import pe.aquasocial.dao.PublicacionDAO;
import pe.aquasocial.entity.Usuario;
import pe.aquasocial.entity.Comunidad;
import pe.aquasocial.entity.Publicacion;
import pe.aquasocial.util.SessionUtil;

@WebServlet(name = "PerfilServlet", urlPatterns = {"/PerfilServlet"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
        maxFileSize = 1024 * 1024 * 2, // 2 MB
        maxRequestSize = 1024 * 1024 * 5 // 5 MB
)
public class PerfilServlet extends HttpServlet {

    private UsuarioDAO usuarioDAO;
    private ComunidadDAO comunidadDAO;
    private PublicacionDAO publicacionDAO;

    private Gson gson;

    // Directorio para subir avatares
    private static final String UPLOAD_DIR = "assets/images/avatars/";
    private static final String[] ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png"};
    private static final String VERIFICATION_UPLOAD_DIR = "assets/images/verificacion/";

    @Override
    public void init() throws ServletException {
        try {
            usuarioDAO = new UsuarioDAO();
            comunidadDAO = new ComunidadDAO();
            publicacionDAO = new PublicacionDAO();

            gson = new Gson();
            System.out.println("✅ PerfilServlet inicializado correctamente");
        } catch (Exception e) {
            System.err.println("❌ Error al inicializar PerfilServlet: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Error al inicializar servlet", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String idUsuarioParam = request.getParameter("id");

        // Si hay un ID de usuario, mostrar perfil de ese usuario
        if (idUsuarioParam != null && !idUsuarioParam.trim().isEmpty()) {
            try {
                int idUsuario = Integer.parseInt(idUsuarioParam);
                mostrarPerfilUsuario(request, response, idUsuario);
                return;
            } catch (NumberFormatException e) {
                System.err.println("❌ ID de usuario no válido: " + idUsuarioParam);
                response.sendRedirect("BuscarServlet");
                return;
            }
        }

        // Si no hay action, mostrar perfil del usuario logueado
        if (action == null) {
            // Verificar que hay usuario logueado
            Usuario usuarioLogueado = SessionUtil.getLoggedUser(request);
            if (usuarioLogueado == null) {
                response.sendRedirect("LoginServlet");
                return;
            }

            // Mostrar página de perfil propio
            request.getRequestDispatcher("/views/user/mi-perfil.jsp").forward(request, response);
            return;
        }

        try {
            switch (action) {
                case "getStats":
                    obtenerEstadisticas(request, response);
                    break;
                default:
                    request.getRequestDispatcher("/views/user/mi-perfil.jsp").forward(request, response);
                    break;
            }
        } catch (Exception e) {
            System.err.println("❌ Error en GET PerfilServlet: " + e.getMessage());
            e.printStackTrace();
            enviarErrorJSON(response, "Error interno del servidor");
        }
    }

    
    /**
     * Mostrar perfil de un usuario específico
     */
    private void mostrarPerfilUsuario(HttpServletRequest request, HttpServletResponse response, int idUsuario)
            throws ServletException, IOException {

        try {
            // ===== 1. OBTENER INFORMACIÓN BÁSICA =====
            Usuario usuarioPerfilado = usuarioDAO.obtenerPorId(idUsuario);

            if (usuarioPerfilado == null) {
                // Usuario no existe
                request.setAttribute("error", "Usuario no encontrado");
                request.getRequestDispatcher("/views/error/404.jsp").forward(request, response);
                return;
            }

            // ===== 2. DETERMINAR TIPO DE PERFIL =====
            Usuario usuarioLogueado = SessionUtil.getLoggedUser(request);
            boolean esPerfilPropio = usuarioLogueado != null && usuarioLogueado.getId() == idUsuario;

            /*
             * esPerfilPropio determina:
             * - true: El usuario está viendo su propio perfil → Mostrar TODO
             * - false: El usuario está viendo el perfil de otra persona → Mostrar solo lo PÚBLICO
             */

            // ===== 3. CALCULAR ESTADÍSTICAS =====
            Map<String, Object> stats = new HashMap<>();

            // 🔥 AQUÍ ES DONDE AGREGAMOS EL CONTEO DE PUBLICACIONES 🔥
            PublicacionDAO publicacionDAO = new PublicacionDAO();
            int totalPublicaciones = publicacionDAO.contarPorUsuario(idUsuario);
            stats.put("totalPublicaciones", totalPublicaciones);

            /*
             * ¿Por qué es importante?
             * - Sin esta línea: La JSP siempre muestra "0 Publicaciones"
             * - Con esta línea: La JSP muestra el número real de publicaciones
             */

            if (esPerfilPropio) {
                // ===== PERFIL PROPIO: Mostrar estadísticas completas =====

                int comunidadesSeguidas = comunidadDAO.contarComunidadesSeguidas(idUsuario);
                int solicitudesEnviadas = comunidadDAO.contarSolicitudesUsuario(idUsuario);
                int solicitudesAprobadas = comunidadDAO.contarSolicitudesAprobadas(idUsuario);
                int comunidadesAdmin = comunidadDAO.contarComunidadesAdmin(idUsuario);

                stats.put("comunidadesSeguidas", comunidadesSeguidas);
                stats.put("solicitudesEnviadas", solicitudesEnviadas);
                stats.put("solicitudesAprobadas", solicitudesAprobadas);
                stats.put("comunidadesAdmin", comunidadesAdmin);

                /*
                 * Para perfil propio también podrías mostrar:
                 * - Publicaciones pendientes de aprobación
                 * - Estadísticas de likes recibidos/dados
                 * - Datos privados de actividad
                 */

            } else {
                // ===== PERFIL DE OTRO: Solo estadísticas públicas =====

                int comunidadesSeguidas = comunidadDAO.contarComunidadesSeguidas(idUsuario);
                stats.put("comunidadesSeguidas", comunidadesSeguidas);

                /*
                 * ⚠️ NOTA IMPORTANTE:
                 * Para otros usuarios, podrías querer mostrar solo publicaciones APROBADAS
                 * en lugar del total, para no revelar publicaciones pendientes:
                 * 
                 * int publicacionesAprobadas = publicacionDAO.contarPublicacionesAprobadasUsuario(idUsuario);
                 * stats.put("totalPublicaciones", publicacionesAprobadas);
                 */
            }

            // ===== 4. OBTENER ACTIVIDAD RECIENTE =====
            Map<String, Object> actividadReciente = obtenerActividadReciente(idUsuario, esPerfilPropio);

            // ===== 5. ENVIAR DATOS A LA JSP =====
            request.setAttribute("usuarioPerfilado", usuarioPerfilado);
            request.setAttribute("estadisticas", stats);              // ← AQUÍ VAN LAS ESTADÍSTICAS
            request.setAttribute("esPerfilPropio", esPerfilPropio);
            request.setAttribute("actividadReciente", actividadReciente);

            /*
             * Estos atributos son los que la JSP usa para mostrar la información:
             * - usuarioPerfilado: Información del usuario (nombre, avatar, etc.)
             * - estadisticas: Números que aparecen en las tarjetas (publicaciones, comunidades, etc.)
             * - esPerfilPropio: Para decidir qué botones/opciones mostrar
             * - actividadReciente: Para la sección de actividad reciente
             */

            // ===== 6. DECIDIR QUÉ PÁGINA MOSTRAR =====
            if (esPerfilPropio) {
                // Página de perfil propio (editable)
                request.getRequestDispatcher("/views/user/mi-perfil.jsp").forward(request, response);
            } else {
                // Página de perfil de otro usuario (solo lectura)
                request.getRequestDispatcher("/views/user/ver-perfil.jsp").forward(request, response);
            }

        } catch (Exception e) {
            System.err.println("❌ Error al mostrar perfil de usuario: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar el perfil del usuario");
            request.getRequestDispatcher("/views/error/500.jsp").forward(request, response);
        }
    }

    
    

    private Map<String, Object> obtenerActividadReciente(int idUsuario, boolean esPerfilPropio) {
        Map<String, Object> actividad = new HashMap<>();

        try {
            // Publicaciones recientes (ya implementado)
            List<Publicacion> publicacionesRecientes = publicacionDAO.obtenerPublicacionesRecientesUsuario(idUsuario, 5);

            // NUEVO: Información de comunidades
            Map<String, Object> infoComunidades = obtenerInfoComunidades(idUsuario, esPerfilPropio);

            if (esPerfilPropio) {
                // Uniones recientes a comunidades
                List<Map<String, Object>> unionesRecientes = comunidadDAO.obtenerUnionesRecientesUsuario(idUsuario, 3);
                actividad.put("unionesRecientes", unionesRecientes);
            }

            actividad.put("publicacionesRecientes", publicacionesRecientes);
            actividad.put("comunidades", infoComunidades);
            actividad.put("tieneActividad", !publicacionesRecientes.isEmpty());

        } catch (Exception e) {
            System.err.println("❌ Error al obtener actividad reciente: " + e.getMessage());
            e.printStackTrace();
            actividad.put("tieneActividad", false);
            actividad.put("publicacionesRecientes", new ArrayList<>());
            actividad.put("comunidades", new HashMap<>());
        }

        return actividad;
    }

    private Map<String, Object> obtenerInfoComunidades(int idUsuario, boolean esPerfilPropio) {
        Map<String, Object> infoComunidades = new HashMap<>();

        try {
            if (esPerfilPropio) {
                // ===== PERFIL PROPIO: Mostrar información completa =====

                // Comunidades que sigue
                List<Comunidad> comunidadesSeguidas = comunidadDAO.obtenerComunidadesSeguidas(idUsuario);
                infoComunidades.put("seguidas", comunidadesSeguidas.size() > 6 ? 
                                   comunidadesSeguidas.subList(0, 6) : comunidadesSeguidas);
                infoComunidades.put("totalSeguidas", comunidadesSeguidas.size());

                // Comunidades que administra
                List<Comunidad> comunidadesAdmin = comunidadDAO.obtenerComunidadesQueAdministra(idUsuario);
                infoComunidades.put("administra", comunidadesAdmin);
                infoComunidades.put("totalAdministra", comunidadesAdmin.size());

                // Comunidades creadas
                List<Comunidad> comunidadesCreadas = comunidadDAO.obtenerComunidadesCreadas(idUsuario);
                infoComunidades.put("creadas", comunidadesCreadas);
                infoComunidades.put("totalCreadas", comunidadesCreadas.size());

                // Estadísticas de solicitudes
                int solicitudesPendientes = comunidadDAO.contarSolicitudesUsuario(idUsuario);
                int solicitudesAprobadas = comunidadDAO.contarSolicitudesAprobadas(idUsuario);
                int solicitudesRechazadas = comunidadDAO.contarSolicitudesRechazadas(idUsuario);

                infoComunidades.put("solicitudesPendientes", solicitudesPendientes);
                infoComunidades.put("solicitudesAprobadas", solicitudesAprobadas);
                infoComunidades.put("solicitudesRechazadas", solicitudesRechazadas);

            } else {
                // ===== PERFIL DE OTRO USUARIO: Solo información pública =====

                // Solo comunidades públicas que sigue
                List<Comunidad> comunidadesPublicas = comunidadDAO.obtenerComunidadesPublicasSeguidas(idUsuario);
                infoComunidades.put("seguidas", comunidadesPublicas.size() > 6 ? 
                                   comunidadesPublicas.subList(0, 6) : comunidadesPublicas);
                infoComunidades.put("totalSeguidas", comunidadesPublicas.size());

                // Comunidades que administra (públicas)
                List<Comunidad> comunidadesAdminPublicas = comunidadDAO.obtenerComunidadesAdminPublicas(idUsuario);
                infoComunidades.put("administra", comunidadesAdminPublicas);
                infoComunidades.put("totalAdministra", comunidadesAdminPublicas.size());
            }

            infoComunidades.put("esPerfilPropio", esPerfilPropio);

            System.out.println("🏘️ Info de comunidades obtenida para usuario " + idUsuario 
                             + " (perfil propio: " + esPerfilPropio + ")");

        } catch (Exception e) {
            System.err.println("❌ Error al obtener info de comunidades: " + e.getMessage());
            e.printStackTrace();
            // Valores por defecto en caso de error
            infoComunidades.put("seguidas", new ArrayList<>());
            infoComunidades.put("administra", new ArrayList<>());
            infoComunidades.put("totalSeguidas", 0);
            infoComunidades.put("totalAdministra", 0);
        }

        return infoComunidades;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            enviarErrorJSON(response, "Acción no especificada");
            return;
        }

        try {
            switch (action) {
                case "updateInfo":
                    actualizarInformacion(request, response);
                    break;
                case "changePassword":
                    cambiarPassword(request, response);
                    break;
                case "changeAvatar":
                    cambiarAvatar(request, response);
                    break;
                case "solicitarVerificacion":
                    procesarSolicitudVerificacion(request, response);
                    break;
                default:
                    enviarErrorJSON(response, "Acción no válida");
                    break;
            }
        } catch (Exception e) {
            System.err.println("❌ Error en POST PerfilServlet: " + e.getMessage());
            e.printStackTrace();
            enviarErrorJSON(response, "Error interno del servidor");
        }
    }

    /**
     * Obtener estadísticas del usuario
     */
    private void obtenerEstadisticas(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        Usuario usuario = SessionUtil.getLoggedUser(request);
        if (usuario == null) {
            enviarErrorJSON(response, "Usuario no autenticado");
            return;
        }

        try {
            Map<String, Object> stats = new HashMap<>();

            // ===== ESTADÍSTICAS BÁSICAS (que ya tienes) =====
            int comunidadesSeguidas = comunidadDAO.contarComunidadesSeguidas(usuario.getId());
            stats.put("comunidadesSeguidas", comunidadesSeguidas);

            int solicitudesEnviadas = comunidadDAO.contarSolicitudesUsuario(usuario.getId());
            stats.put("solicitudesEnviadas", solicitudesEnviadas);

            int solicitudesAprobadas = comunidadDAO.contarSolicitudesAprobadas(usuario.getId());
            stats.put("solicitudesAprobadas", solicitudesAprobadas);

            int comunidadesAdmin = comunidadDAO.contarComunidadesAdmin(usuario.getId());
            stats.put("comunidadesAdmin", comunidadesAdmin);

            // ===== ESTADÍSTICAS DE PUBLICACIONES =====
            PublicacionDAO publicacionDAO = new PublicacionDAO();
            int totalPublicaciones = publicacionDAO.contarPorUsuario(usuario.getId());
            stats.put("totalPublicaciones", totalPublicaciones);

            // ===== SOLO SI IMPLEMENTAS LOS MÉTODOS OPCIONALES =====
            // Descomenta estas líneas cuando tengas los métodos:

            int publicacionesAprobadas = publicacionDAO.contarPublicacionesAprobadasUsuario(usuario.getId());
            stats.put("publicacionesAprobadas", publicacionesAprobadas);
            // 
            int publicacionesPendientes = totalPublicaciones - publicacionesAprobadas;
            stats.put("publicacionesPendientes", publicacionesPendientes);
            //
            LikeDAO likeDAO = new LikeDAO();
            int likesRecibidos = likeDAO.contarLikesRecibidosUsuario(usuario.getId());
            int likesDados = likeDAO.contarLikesDadosUsuario(usuario.getId());
            stats.put("likesRecibidos", likesRecibidos);
            stats.put("likesDados", likesDados);

            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", true);
            responseData.put("stats", stats);

            enviarJSON(response, responseData);

            System.out.println("📊 Estadísticas obtenidas para usuario: " + usuario.getId() 
                             + " - Publicaciones: " + totalPublicaciones);

        } catch (Exception e) {
            System.err.println("❌ Error al obtener estadísticas: " + e.getMessage());
            e.printStackTrace();
            enviarErrorJSON(response, "Error al cargar estadísticas");
        }
    }

    /**
     * Actualizar información personal del usuario
     */
    private void actualizarInformacion(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        Usuario usuario = SessionUtil.getLoggedUser(request);
        if (usuario == null) {
            enviarErrorJSON(response, "Usuario no autenticado");
            return;
        }

        String nombreCompleto = request.getParameter("nombreCompleto");
        String email = request.getParameter("email");
        String bio = request.getParameter("bio");

        // Validaciones básicas
        if (nombreCompleto == null || nombreCompleto.trim().isEmpty()) {
            enviarErrorJSON(response, "El nombre completo es obligatorio");
            return;
        }

        if (email == null || email.trim().isEmpty()) {
            enviarErrorJSON(response, "El email es obligatorio");
            return;
        }

        if (!isValidEmail(email)) {
            enviarErrorJSON(response, "El formato del email no es válido");
            return;
        }

        try {
            // Verificar si el email ya existe (excepto el del usuario actual)
            if (usuarioDAO.existeEmail(email.trim()) && !email.trim().equals(usuario.getEmail())) {
                enviarErrorJSON(response, "Este email ya está en uso por otro usuario");
                return;
            }

            // Actualizar datos
            usuario.setNombreCompleto(nombreCompleto.trim());
            usuario.setEmail(email.trim());

            boolean actualizado = usuarioDAO.actualizar(usuario);

            if (actualizado) {
                // Actualizar sesión
                SessionUtil.updateUserSession(request, usuario);

                Map<String, Object> responseData = new HashMap<>();
                responseData.put("success", true);
                responseData.put("message", "Información actualizada exitosamente");

                enviarJSON(response, responseData);

                System.out.println("✅ Información actualizada para usuario: " + usuario.getId());

            } else {
                enviarErrorJSON(response, "Error al actualizar la información");
            }

        } catch (Exception e) {
            System.err.println("❌ Error al actualizar información: " + e.getMessage());
            e.printStackTrace();
            enviarErrorJSON(response, "Error interno al actualizar información");
        }
    }

    /**
     * Cambiar contraseña del usuario
     */
    private void cambiarPassword(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        Usuario usuario = SessionUtil.getLoggedUser(request);
        if (usuario == null) {
            enviarErrorJSON(response, "Usuario no autenticado");
            return;
        }

        String passwordActual = request.getParameter("passwordActual");
        String passwordNueva = request.getParameter("passwordNueva");

        // Validaciones
        if (passwordActual == null || passwordActual.trim().isEmpty()) {
            enviarErrorJSON(response, "La contraseña actual es obligatoria");
            return;
        }

        if (passwordNueva == null || passwordNueva.trim().isEmpty()) {
            enviarErrorJSON(response, "La nueva contraseña es obligatoria");
            return;
        }

        if (passwordNueva.length() < 8) {
            enviarErrorJSON(response, "La nueva contraseña debe tener al menos 8 caracteres");
            return;
        }

        try {
            // Verificar contraseña actual
            if (!usuarioDAO.verificarPassword(usuario.getId(), passwordActual)) {
                enviarErrorJSON(response, "La contraseña actual es incorrecta");
                return;
            }

            // Cambiar contraseña
            boolean cambiada = usuarioDAO.cambiarPassword(usuario.getId(), passwordNueva);

            if (cambiada) {
                Map<String, Object> responseData = new HashMap<>();
                responseData.put("success", true);
                responseData.put("message", "Contraseña cambiada exitosamente");

                enviarJSON(response, responseData);

                System.out.println("🔒 Contraseña cambiada para usuario: " + usuario.getId());

            } else {
                enviarErrorJSON(response, "Error al cambiar la contraseña");
            }

        } catch (Exception e) {
            System.err.println("❌ Error al cambiar contraseña: " + e.getMessage());
            e.printStackTrace();
            enviarErrorJSON(response, "Error interno al cambiar contraseña");
        }
    }

    /**
     * Cambiar avatar del usuario
     */
    private void cambiarAvatar(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        Usuario usuario = SessionUtil.getLoggedUser(request);
        if (usuario == null) {
            enviarErrorJSON(response, "Usuario no autenticado");
            return;
        }

        try {
            // Obtener el archivo subido
            Part filePart = request.getPart("avatar");

            if (filePart == null || filePart.getSize() == 0) {
                enviarErrorJSON(response, "No se ha seleccionado ningún archivo");
                return;
            }

            String fileName = getFileName(filePart);

            // Validar extensión
            if (!isValidImageFile(fileName)) {
                enviarErrorJSON(response, "Formato de archivo no válido. Use JPG, JPEG o PNG");
                return;
            }

            // Validar tamaño (2MB máximo)
            if (filePart.getSize() > 2 * 1024 * 1024) {
                enviarErrorJSON(response, "El archivo es demasiado grande. Máximo 2MB");
                return;
            }

            // Generar nombre único
            String extension = fileName.substring(fileName.lastIndexOf("."));
            String uniqueFileName = "avatar_" + usuario.getId() + "_" + System.currentTimeMillis() + extension;

            // Crear directorio si no existe
            String uploadPath = getServletContext().getRealPath("") + UPLOAD_DIR;
            Path uploadDir = Paths.get(uploadPath);
            if (!Files.exists(uploadDir)) {
                Files.createDirectories(uploadDir);
            }

            // Guardar archivo
            Path filePath = uploadDir.resolve(uniqueFileName);
            Files.copy(filePart.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

            // Actualizar URL en base de datos
            String avatarUrl = UPLOAD_DIR + uniqueFileName;
            boolean actualizado = usuarioDAO.actualizarAvatar(usuario.getId(), avatarUrl);

            if (actualizado) {
                // Actualizar objeto usuario y sesión
                usuario.setAvatar(avatarUrl);
                SessionUtil.updateUserSession(request, usuario);

                Map<String, Object> responseData = new HashMap<>();
                responseData.put("success", true);
                responseData.put("message", "Avatar actualizado exitosamente");
                responseData.put("avatarUrl", avatarUrl);

                enviarJSON(response, responseData);

                System.out.println("🖼️ Avatar actualizado para usuario: " + usuario.getId());

            } else {
                // Eliminar archivo si falló la actualización en BD
                Files.deleteIfExists(filePath);
                enviarErrorJSON(response, "Error al actualizar el avatar en la base de datos");
            }

        } catch (Exception e) {
            System.err.println("❌ Error al cambiar avatar: " + e.getMessage());
            e.printStackTrace();
            enviarErrorJSON(response, "Error interno al cambiar avatar");
        }
    }

    // ============= SOLICITUD VERIFICACION =========
    private void procesarSolicitudVerificacion(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        Usuario usuario = SessionUtil.getLoggedUser(request);
        if (usuario == null) {
            enviarErrorJSON(response, "Usuario no autenticado");
            return;
        }

        // Verificar que no esté ya verificado
        if (usuario.isVerificado()) {
            enviarErrorJSON(response, "Tu cuenta ya está verificada");
            return;
        }

        // Verificar que no tenga una solicitud pendiente
        if (usuario.isSolicitoVerificacion()) {
            enviarErrorJSON(response, "Ya tienes una solicitud de verificación pendiente");
            return;
        }

        String password = request.getParameter("password");
        String motivo = request.getParameter("motivo");
        String categoria = request.getParameter("categoria");
        String enlaces = request.getParameter("enlaces");

        // Validaciones básicas
        if (password == null || password.trim().isEmpty()) {
            enviarErrorJSON(response, "La contraseña actual es obligatoria");
            return;
        }

        if (motivo == null || motivo.trim().isEmpty()) {
            enviarErrorJSON(response, "El motivo de la solicitud es obligatorio");
            return;
        }

        if (motivo.length() < 50) {
            enviarErrorJSON(response, "El motivo debe tener al menos 50 caracteres");
            return;
        }

        if (motivo.length() > 500) {
            enviarErrorJSON(response, "El motivo no puede exceder 500 caracteres");
            return;
        }

        if (categoria == null || categoria.trim().isEmpty()) {
            enviarErrorJSON(response, "Debes seleccionar una categoría");
            return;
        }

        try {
            // Verificar contraseña actual
            if (!usuarioDAO.verificarPassword(usuario.getId(), password)) {
                enviarErrorJSON(response, "La contraseña actual es incorrecta");
                return;
            }

            // Obtener archivo de documento
            Part documentoPart = request.getPart("documento");
            if (documentoPart == null || documentoPart.getSize() == 0) {
                enviarErrorJSON(response, "El documento de identificación es obligatorio");
                return;
            }

            String fileName = getFileName(documentoPart);

            // Validar tipo de archivo
            if (!isValidImageFile(fileName)) {
                enviarErrorJSON(response, "Formato de archivo no válido. Use JPG, PNG o PDF");
                return;
            }

            // Validar tamaño (5MB máximo)
            if (documentoPart.getSize() > 5 * 1024 * 1024) {
                enviarErrorJSON(response, "El archivo es demasiado grande. Máximo 5MB");
                return;
            }

            // Generar nombre único para el documento
            String extension = fileName.substring(fileName.lastIndexOf("."));
            String uniqueFileName = "verificacion_" + usuario.getId() + "_" + System.currentTimeMillis() + extension;

            // Crear directorio si no existe
            String uploadPath = getServletContext().getRealPath("") + VERIFICATION_UPLOAD_DIR;
            Path uploadDir = Paths.get(uploadPath);
            if (!Files.exists(uploadDir)) {
                Files.createDirectories(uploadDir);
            }

            // Guardar archivo
            Path filePath = uploadDir.resolve(uniqueFileName);
            Files.copy(documentoPart.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

            String documentoUrl = VERIFICATION_UPLOAD_DIR + uniqueFileName;

            // Crear solicitud de verificación en la base de datos
            boolean solicitudCreada = usuarioDAO.crearSolicitudVerificacion(
                usuario.getId(),
                motivo.trim(),
                categoria.trim(),
                documentoUrl,
                enlaces != null ? enlaces.trim() : null
            );

            if (solicitudCreada) {
                // Marcar usuario como que solicitó verificación
                boolean usuarioActualizado = usuarioDAO.marcarSolicitudVerificacion(usuario.getId());

                if (usuarioActualizado) {
                    // Actualizar sesión
                    usuario.setSolicitoVerificacion(true);
                    SessionUtil.updateUserSession(request, usuario);

                    Map<String, Object> responseData = new HashMap<>();
                    responseData.put("success", true);
                    responseData.put("message", "Solicitud de verificación enviada exitosamente. " +
                                              "Nuestro equipo la revisará en un plazo de 3-5 días hábiles.");

                    enviarJSON(response, responseData);

                    System.out.println("✅ Solicitud de verificación creada para usuario: " + usuario.getId());

                } else {
                    // Eliminar archivo si falló la actualización del usuario
                    Files.deleteIfExists(filePath);
                    enviarErrorJSON(response, "Error al procesar la solicitud");
                }
            } else {
                // Eliminar archivo si falló la creación de la solicitud
                Files.deleteIfExists(filePath);
                enviarErrorJSON(response, "Error al crear la solicitud de verificación");
            }

        } catch (Exception e) {
            System.err.println("❌ Error al procesar solicitud de verificación: " + e.getMessage());
            e.printStackTrace();
            enviarErrorJSON(response, "Error interno al procesar la solicitud");
        }
    }
    // ============= MÉTODOS AUXILIARES =============
    /**
     * Obtener nombre del archivo de un Part
     */
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        String[] tokens = contentDisposition.split(";");

        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }

    /**
     * Validar si es un archivo de imagen válido
     */
    private boolean isValidImageFile(String fileName) {
        if (fileName == null || fileName.trim().isEmpty()) {
            return false;
        }

        String lowerFileName = fileName.toLowerCase();
        for (String ext : ALLOWED_EXTENSIONS) {
            if (lowerFileName.endsWith(ext)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Validar formato de email
     */
    private boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }

        String emailRegex = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";
        return email.matches(emailRegex);
    }

    /**
     * Enviar respuesta JSON exitosa
     */
    private void enviarJSON(HttpServletResponse response, Object data) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try (PrintWriter out = response.getWriter()) {
            out.write(gson.toJson(data));
        }
    }

    /**
     * Enviar respuesta JSON de error
     */
    private void enviarErrorJSON(HttpServletResponse response, String message) throws IOException {
        Map<String, Object> errorData = new HashMap<>();
        errorData.put("success", false);
        errorData.put("message", message);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try (PrintWriter out = response.getWriter()) {
            out.write(gson.toJson(errorData));
        }
    }
}
