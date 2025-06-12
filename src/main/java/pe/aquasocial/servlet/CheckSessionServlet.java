package pe.aquasocial.servlet;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;
import pe.aquasocial.dao.UsuarioDAO;

import pe.aquasocial.util.SessionUtil;
import pe.aquasocial.entity.Usuario;

/**
 * Servlet simple para verificar el estado de la sesión Usado por JavaScript
 * para detectar sesiones expiradas
 */
@WebServlet("/CheckSessionServlet")
public class CheckSessionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JSONObject jsonResponse = new JSONObject();

        try {
            // Verificar si el usuario está logueado
            boolean isLoggedIn = SessionUtil.isUserLoggedIn(request);
            Usuario usuario = SessionUtil.getLoggedUser(request);
            String username = SessionUtil.getUsername(request);

            if (isLoggedIn && usuario != null) {
                // Verificar estado actual del usuario en base de datos
                boolean isBannedInDB = checkUserBannedInDatabase(usuario.getId());

                if (isBannedInDB) {
                    // Usuario baneado - invalidar sesión y notificar
                    SessionUtil.invalidateSession(request);

                    jsonResponse.put("sessionValid", false);
                    jsonResponse.put("userBanned", true);
                    jsonResponse.put("message", "Tu cuenta ha sido suspendida. Contacta al administrador.");
                    jsonResponse.put("redirectUrl", "LoginServlet");

                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    System.out.println("🚫 Usuario baneado detectado y sesión invalidada: " + username);

                } else {
                    // Sesión válida y usuario activo
                    jsonResponse.put("sessionValid", true);
                    jsonResponse.put("userBanned", false);
                    jsonResponse.put("username", username);
                    jsonResponse.put("message", "Sesión activa");

                    response.setStatus(HttpServletResponse.SC_OK);

                    // Actualizar estado en sesión si es necesario
                    if (usuario.isBaneado()) {
                        usuario.setBaneado(false);
                        SessionUtil.updateUserInSession(request, usuario);
                    }
                }

            } else {
                // Sesión inválida
                jsonResponse.put("sessionValid", false);
                jsonResponse.put("userBanned", false);
                jsonResponse.put("message", "Sesión expirada o no existe");
                jsonResponse.put("redirectUrl", "LoginServlet");

                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            }

        } catch (Exception e) {
            // Error al verificar sesión
            e.printStackTrace();

            jsonResponse.put("sessionValid", false);
            jsonResponse.put("message", "Error al verificar sesión");
            jsonResponse.put("error", e.getMessage());

            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }

        response.getWriter().write(jsonResponse.toString());
    }

    private boolean checkUserBannedInDatabase(int userId) {
        try {
            UsuarioDAO usuarioDao = new UsuarioDAO();
            return usuarioDao.isBanned(userId);
        } catch (Exception e) {
            System.err.println("❌ Error al verificar estado de ban: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirigir POST a GET
        doGet(request, response);
    }
}
