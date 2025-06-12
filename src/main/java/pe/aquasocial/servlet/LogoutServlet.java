package pe.aquasocial.servlet;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Cookie;

import pe.aquasocial.entity.Usuario;
import pe.aquasocial.util.SessionUtil;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirigir GET requests a POST para seguridad
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Obtener información del usuario antes del logout
            String username = SessionUtil.getUsername(request);
            Integer userId = SessionUtil.getUserId(request);
            Usuario usuario = SessionUtil.getLoggedUser(request);

            // Log del logout
            if (username != null) {
                System.out.println("🚪 Iniciando logout para usuario: " + username + " (ID: " + userId + ")");
            } else {
                System.out.println("🚪 Logout solicitado sin sesión activa");
            }

            // Limpiar cookies de "recordar" antes de invalidar la sesión
            clearRememberMeCookies(response);

            // Invalidar sesión y configurar mensaje
            boolean sessionInvalidated = invalidateUserSession(request, response);

            if (sessionInvalidated) {
                // Logout exitoso
                setLogoutMessage(request, "success", "Has cerrado sesión correctamente. ¡Hasta pronto!");
                System.out.println("✅ Logout exitoso para: " + (username != null ? username : "usuario anónimo"));
            } else {
                // Logout con advertencia (no había sesión activa)
                setLogoutMessage(request, "warning", "No había una sesión activa, pero has sido desconectado por seguridad.");
                System.out.println("⚠️ Logout sin sesión activa");
            }

        } catch (Exception e) {
            // Error durante el logout
            e.printStackTrace();
            setLogoutMessage(request, "error", "Hubo un problema al cerrar sesión, pero has sido desconectado.");
            System.err.println("❌ Error durante logout: " + e.getMessage());
        }

        // Redirigir al login
        response.sendRedirect("LoginServlet");
    }

    /**
     * Invalida la sesión del usuario y crea una nueva para el mensaje
     *
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return true si había sesión para invalidar, false si no había sesión
     */
    private boolean invalidateUserSession(HttpServletRequest request, HttpServletResponse response) {
        try {
            HttpSession session = request.getSession(false);

            if (session != null) {
                // Obtener datos antes de invalidar para logging
                String sessionId = session.getId();

                // Invalidar sesión
                session.invalidate();

                System.out.println("🔓 Sesión invalidada: " + sessionId);
                return true;
            } else {
                System.out.println("⚠️ No hay sesión activa para invalidar");
                return false;
            }

        } catch (IllegalStateException e) {
            // La sesión ya estaba invalidada
            System.out.println("⚠️ La sesión ya estaba invalidada");
            return false;
        } catch (Exception e) {
            System.err.println("❌ Error al invalidar sesión: " + e.getMessage());
            return false;
        }
    }

    /**
     * Limpia las cookies de "recordar usuario"
     *
     * @param response HttpServletResponse
     */
    private void clearRememberMeCookies(HttpServletResponse response) {
        try {
            // Lista de cookies a limpiar
            String[] cookiesToClear = {
                "rememberUsername",
                "userId",
                "rememberMe"
            };

            for (String cookieName : cookiesToClear) {
                Cookie cookie = new Cookie(cookieName, "");
                cookie.setMaxAge(0); // Eliminar inmediatamente
                cookie.setPath("/");
                cookie.setHttpOnly(true);
                response.addCookie(cookie);
            }

            System.out.println("🍪 Cookies de 'recordar' eliminadas");

        } catch (Exception e) {
            System.err.println("⚠️ Error al limpiar cookies: " + e.getMessage());
        }
    }

    /**
     * Configura el mensaje de logout usando session attributes
     *
     * @param request HttpServletRequest
     * @param type Tipo de mensaje (success, error, warning)
     * @param message Mensaje a mostrar
     */
    private void setLogoutMessage(HttpServletRequest request, String type, String message) {
        try {
            // Crear nueva sesión temporal solo para el mensaje
            HttpSession newSession = request.getSession(true);
            newSession.setAttribute("logoutMessage", message);
            newSession.setAttribute("logoutType", type);
            newSession.setMaxInactiveInterval(300);

            System.out.println("📝 Mensaje de logout configurado en sesión: " + type + " - " + message);

        } catch (Exception e) {
            System.err.println("⚠️ Error al configurar mensaje de logout: " + e.getMessage());
        }
    }

    /**
     * Método para logout programático (para usar desde otros servlets)
     *
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @param customMessage Mensaje personalizado (opcional)
     * @return true si el logout fue exitoso
     */
    public static boolean performLogout(HttpServletRequest request, HttpServletResponse response, String customMessage) {
        try {
            LogoutServlet logoutServlet = new LogoutServlet();

            // Limpiar cookies
            logoutServlet.clearRememberMeCookies(response);

            // Invalidar sesión
            boolean sessionInvalidated = logoutServlet.invalidateUserSession(request, response);

            // Configurar mensaje
            String message = customMessage != null ? customMessage : "Sesión cerrada correctamente";
            logoutServlet.setLogoutMessage(request, "success", message);

            return sessionInvalidated;

        } catch (Exception e) {
            System.err.println("❌ Error en logout programático: " + e.getMessage());
            return false;
        }
    }

    /**
     * Método para forzar logout por seguridad (sesión expirada, cuenta baneada,
     * etc.)
     *
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @param reason Razón del logout forzado
     */
    public static void forceLogout(HttpServletRequest request, HttpServletResponse response, String reason) {
        try {
            LogoutServlet logoutServlet = new LogoutServlet();

            // Log de seguridad
            String username = SessionUtil.getUsername(request);
            System.out.println("🚨 Logout forzado para: " + (username != null ? username : "usuario anónimo") + " - Razón: " + reason);

            // Limpiar cookies
            logoutServlet.clearRememberMeCookies(response);

            // Invalidar sesión
            logoutServlet.invalidateUserSession(request, response);

            // Configurar mensaje de advertencia
            logoutServlet.setLogoutMessage(request, "warning", "Tu sesión ha sido cerrada por seguridad: " + reason);

        } catch (Exception e) {
            System.err.println("❌ Error en logout forzado: " + e.getMessage());
        }
    }

    /**
     * Método para logout con redirección personalizada
     *
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @param message Mensaje personalizado
     * @param type Tipo de mensaje
     * @param redirectUrl URL de redirección
     * @throws IOException
     */
    public static void logoutWithRedirect(HttpServletRequest request, HttpServletResponse response,
            String message, String type, String redirectUrl) throws IOException {
        try {
            LogoutServlet logoutServlet = new LogoutServlet();

            // Limpiar cookies
            logoutServlet.clearRememberMeCookies(response);

            // Invalidar sesión
            logoutServlet.invalidateUserSession(request, response);

            // Configurar mensaje
            logoutServlet.setLogoutMessage(request, type, message);

            // Redirigir a URL personalizada
            response.sendRedirect(redirectUrl != null ? redirectUrl : "LoginServlet");

        } catch (Exception e) {
            System.err.println("❌ Error en logout con redirección: " + e.getMessage());
            response.sendRedirect("LoginServlet");
        }
    }
}
