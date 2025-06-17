/*
 * Servlet para gestión de notificaciones
 * Maneja operaciones básicas de notificaciones
 */
package pe.aquasocial.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.google.gson.Gson;
import pe.aquasocial.dao.NotificacionDAO;
import pe.aquasocial.entity.Usuario;
import pe.aquasocial.entity.Notificacion;
import pe.aquasocial.util.SessionUtil;

@WebServlet(name = "NotificacionServlet", urlPatterns = {"/NotificacionServlet"})
public class NotificacionServlet extends HttpServlet {

    private NotificacionDAO notificacionDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        try {
            notificacionDAO = new NotificacionDAO();
            gson = new Gson();
            System.out.println("✅ NotificacionServlet inicializado correctamente");
        } catch (Exception e) {
            System.err.println("❌ Error al inicializar NotificacionServlet: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Error al inicializar servlet", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        Usuario usuario = SessionUtil.getLoggedUser(request);

        if (usuario == null) {
            enviarErrorJSON(response, "Usuario no autenticado");
            return;
        }

        try {
            switch (action != null ? action : "list") {
                case "list":
                    obtenerNotificaciones(request, response, usuario);
                    break;
                case "count":
                    contarNoLeidas(request, response, usuario);
                    break;
                case "markRead":
                    marcarComoLeida(request, response);
                    break;
                case "markAllRead":
                    marcarTodasComoLeidas(request, response, usuario);
                    break;
                case "delete":
                    eliminarNotificacion(request, response);
                    break;
                case "test":
                    crearNotificacionPrueba(request, response, usuario);
                    break;
                default:
                    obtenerNotificaciones(request, response, usuario);
                    break;
            }
        } catch (Exception e) {
            System.err.println("❌ Error en NotificacionServlet: " + e.getMessage());
            e.printStackTrace();
            enviarErrorJSON(response, "Error interno del servidor");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    // ===== MÉTODOS DE ACCIÓN =====

    /**
     * Obtener lista de notificaciones del usuario
     */
    private void obtenerNotificaciones(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws IOException {

        String tipoParam = request.getParameter("tipo");
        String limiteParam = request.getParameter("limite");
        String offsetParam = request.getParameter("offset");

        int limite = limiteParam != null ? Integer.parseInt(limiteParam) : 10;
        int offset = offsetParam != null ? Integer.parseInt(offsetParam) : 0;

        List<Notificacion> notificaciones;

        if (tipoParam != null && !tipoParam.isEmpty()) {
            // Filtrar por tipo
            notificaciones = notificacionDAO.obtenerPorTipo(usuario.getId(), tipoParam, limite);
        } else {
            // Obtener todas
            notificaciones = notificacionDAO.obtenerPorUsuario(usuario.getId(), limite, offset);
        }

        Map<String, Object> responseData = new HashMap<>();
        responseData.put("success", true);
        responseData.put("notificaciones", notificaciones);
        responseData.put("total", notificacionDAO.contarTotal(usuario.getId()));
        responseData.put("noLeidas", notificacionDAO.contarNoLeidas(usuario.getId()));

        enviarJSON(response, responseData);
        System.out.println("📋 Enviadas " + notificaciones.size() + " notificaciones a usuario " + usuario.getUsername());
    }

    /**
     * Contar notificaciones no leídas
     */
    private void contarNoLeidas(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws IOException {

        int count = notificacionDAO.contarNoLeidas(usuario.getId());

        Map<String, Object> responseData = new HashMap<>();
        responseData.put("success", true);
        responseData.put("count", count);

        enviarJSON(response, responseData);
    }

    /**
     * Marcar una notificación como leída
     */
    private void marcarComoLeida(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String idParam = request.getParameter("id");

        if (idParam == null || idParam.trim().isEmpty()) {
            enviarErrorJSON(response, "ID de notificación requerido");
            return;
        }

        try {
            int idNotificacion = Integer.parseInt(idParam);
            boolean success = notificacionDAO.marcarComoLeida(idNotificacion);

            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", success);
            responseData.put("message", success ? "Notificación marcada como leída" : "Error al marcar como leída");

            enviarJSON(response, responseData);

        } catch (NumberFormatException e) {
            enviarErrorJSON(response, "ID de notificación no válido");
        }
    }

    /**
     * Marcar todas las notificaciones como leídas
     */
    private void marcarTodasComoLeidas(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws IOException {

        boolean success = notificacionDAO.marcarTodasComoLeidas(usuario.getId());

        Map<String, Object> responseData = new HashMap<>();
        responseData.put("success", success);
        responseData.put("message", success ? "Todas las notificaciones marcadas como leídas" : "Error al marcar notificaciones");

        enviarJSON(response, responseData);
    }

    /**
     * Eliminar una notificación
     */
    private void eliminarNotificacion(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String idParam = request.getParameter("id");

        if (idParam == null || idParam.trim().isEmpty()) {
            enviarErrorJSON(response, "ID de notificación requerido");
            return;
        }

        try {
            int idNotificacion = Integer.parseInt(idParam);
            boolean success = notificacionDAO.eliminar(idNotificacion);

            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", success);
            responseData.put("message", success ? "Notificación eliminada" : "Error al eliminar notificación");

            enviarJSON(response, responseData);

        } catch (NumberFormatException e) {
            enviarErrorJSON(response, "ID de notificación no válido");
        }
    }

    /**
     * Crear notificación de prueba (para testing)
     */
    private void crearNotificacionPrueba(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws IOException {

        Notificacion notificacion = new Notificacion();
        notificacion.setIdUsuarioDestino(usuario.getId());
        notificacion.setTipo(Notificacion.Tipos.SISTEMA);
        notificacion.setSubtipo("test");
        notificacion.setTitulo("Notificación de Prueba");
        notificacion.setMensaje("Esta es una notificación de prueba creada en " + 
                              java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("HH:mm:ss")));
        notificacion.setIcono("fa-flask");
        notificacion.setColor(Notificacion.Colores.INFO);
        notificacion.setDatosAdicionales("{\"test\": true, \"timestamp\": " + System.currentTimeMillis() + "}");

        boolean success = notificacionDAO.crear(notificacion);

        Map<String, Object> responseData = new HashMap<>();
        responseData.put("success", success);
        responseData.put("message", success ? "Notificación de prueba creada" : "Error al crear notificación");
        
        if (success) {
            responseData.put("notificacion", notificacion);
        }

        enviarJSON(response, responseData);
    }

    // ===== MÉTODOS DE UTILIDAD =====

    /**
     * Enviar respuesta JSON
     */
    private void enviarJSON(HttpServletResponse response, Object data) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try (PrintWriter out = response.getWriter()) {
            out.print(gson.toJson(data));
            out.flush();
        }
    }

    /**
     * Enviar error JSON
     */
    private void enviarErrorJSON(HttpServletResponse response, String mensaje) throws IOException {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        
        Map<String, Object> errorData = new HashMap<>();
        errorData.put("success", false);
        errorData.put("message", mensaje);
        
        enviarJSON(response, errorData);
    }

    @Override
    public String getServletInfo() {
        return "Servlet para gestión de notificaciones";
    }
}