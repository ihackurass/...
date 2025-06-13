package pe.aquasocial.filters;

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.json.JSONObject;

import pe.aquasocial.entity.Usuario;
import pe.aquasocial.util.SessionUtil;

/**
 * Filtro que verifica si el usuario está autenticado Se aplica a todas las
 * páginas que requieren login
 */
@WebFilter(filterName = "AuthenticationFilter", urlPatterns = {
    "/HomeServlet", // Página principal
    "/HomeServlet", // Todas las rutas de home
    "/user/*", // Todas las rutas de usuario
    "/posts/*", // Gestión de posts
    "/admin/*", // Área de administración
    "/ComunidadServlet"    
})
public class AuthenticationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("🔍 AuthenticationFilter inicializado");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        httpResponse.setHeader("Pragma", "no-cache");
        httpResponse.setDateHeader("Expires", 0);

        // Obtener información de la request
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = requestURI.substring(contextPath.length());

        System.out.println("🔍 AuthFilter verificando: " + path);

        // Usar SessionUtil para verificar autenticación
        boolean isLoggedIn = SessionUtil.isUserLoggedIn(httpRequest);

        if (isLoggedIn) {
            // Obtener usuario logueado
            Usuario usuarioLogueado = SessionUtil.getLoggedUser(httpRequest);
            String username = usuarioLogueado != null ? usuarioLogueado.getUsername() : SessionUtil.getUsername(httpRequest);

            System.out.println("✅ Usuario autenticado: " + username);

            // Verificar si el usuario está baneado
            if (usuarioLogueado != null && usuarioLogueado.isBaneado()) {
                System.out.println("🚫 Usuario baneado intentando acceder: " + username);
                handleBannedUser(httpRequest, httpResponse);
                return;
            }

            // Verificar si la sesión sigue siendo válida
            HttpSession session = httpRequest.getSession(false);
            if (session != null && isSessionValid(session)) {
                // Actualizar último acceso
                session.setAttribute("lastAccess", System.currentTimeMillis());

                // Verificar acceso específico a rutas de admin
                if (path.startsWith("/admin/") && !SessionUtil.isAdmin(httpRequest)) {
                    System.out.println("🚫 Usuario sin permisos de admin intentando acceder: " + username);
                    handleAccessDenied(httpRequest, httpResponse);
                    return;
                }

                // Todo correcto, continuar
                chain.doFilter(request, response);
            } else {
                // Sesión expirada
                System.out.println("⏰ Sesión expirada para: " + username);
                handleSessionExpired(httpRequest, httpResponse);
            }

        } else {
            // Usuario NO autenticado - redirigir al login
            System.out.println("❌ Usuario no autenticado, redirigiendo a login para: " + path);
            handleLoginRequired(httpRequest, httpResponse);
        }
    }

    /**
     * Verifica si la sesión sigue siendo válida
     */
    private boolean isSessionValid(HttpSession session) {
        if (session == null) {
            return false;
        }

        try {
            // Verificar último acceso (opcional)
            Long lastAccess = (Long) session.getAttribute("lastAccess");
            if (lastAccess != null) {
                long currentTime = System.currentTimeMillis();
                long maxInactiveTime = session.getMaxInactiveInterval() * 1000; // en milisegundos

                // Si ha pasado más tiempo del permitido, sesión inválida
                if ((currentTime - lastAccess) > maxInactiveTime) {
                    return false;
                }
            }

            // Verificar que la sesión no esté invalidada
            session.getAttribute("usuarioLogueado"); // Esto lanza excepción si está invalidada
            return true;

        } catch (IllegalStateException e) {
            // Sesión invalidada
            return false;
        }
    }

    /**
     * Maneja cuando se requiere login
     */
    private void handleLoginRequired(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // Verificar si es petición AJAX
        boolean isAjax = isAjaxRequest(request);

        if (isAjax) {
            // Para peticiones AJAX, enviar respuesta JSON
            JSONObject jsonResponse = new JSONObject();
            jsonResponse.put("success", false);
            jsonResponse.put("loginRequired", true);
            jsonResponse.put("message", "Debes iniciar sesión para acceder a esta página.");
            jsonResponse.put("redirectUrl", "LoginServlet");

            sendJsonResponse(response, HttpServletResponse.SC_UNAUTHORIZED, jsonResponse);
            System.out.println("🔒 Login requerido detectado en petición AJAX");
        } else {
            // Para peticiones normales, crear sesión temporal para mensaje
            HttpSession session = request.getSession(true);
            session.setAttribute("authMessage", "Debes iniciar sesión para acceder a esta página.");
            session.setAttribute("authMessageType", "warning");
            session.setMaxInactiveInterval(300);

            response.sendRedirect("LoginServlet");
            System.out.println("🔒 Login requerido detectado en petición normal, redirigiendo");
        }
    }

    /**
     * Maneja cuando la sesión ha expirado
     */
    private void handleSessionExpired(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // Invalidar sesión completamente
        HttpSession session = request.getSession(false);
        if (session != null) {
            try {
                session.invalidate();
            } catch (IllegalStateException e) {
                // Ya estaba invalidada
            }
        }

        // Verificar si es petición AJAX
        boolean isAjax = isAjaxRequest(request);

        if (isAjax) {
            // Para peticiones AJAX, enviar respuesta JSON
            JSONObject jsonResponse = new JSONObject();
            jsonResponse.put("success", false);
            jsonResponse.put("sessionExpired", true);
            jsonResponse.put("message", "Tu sesión ha expirado. Por favor, inicia sesión nuevamente.");
            jsonResponse.put("redirectUrl", "LoginServlet");

            sendJsonResponse(response, HttpServletResponse.SC_UNAUTHORIZED, jsonResponse);
            System.out.println("⏰ Sesión expirada detectada en petición AJAX");
        } else {
            // Para peticiones normales, crear sesión para mensaje y redirigir
            session = request.getSession(true);
            session.setAttribute("authMessage", "Tu sesión ha expirado. Por favor, inicia sesión nuevamente.");
            session.setAttribute("authMessageType", "warning");
            session.setMaxInactiveInterval(300);

            response.sendRedirect("LoginServlet");
            System.out.println("⏰ Sesión expirada detectada en petición normal, redirigiendo");
        }
    }

    /**
     * Maneja cuando el usuario está baneado
     */
    private void handleBannedUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // Invalidar sesión del usuario baneado
        HttpSession session = request.getSession(false);
        if (session != null) {
            try {
                session.invalidate();
            } catch (IllegalStateException e) {
                // Ya estaba invalidada
            }
        }

        boolean isAjax = isAjaxRequest(request);

        if (isAjax) {
            // Para peticiones AJAX, enviar respuesta JSON
            JSONObject jsonResponse = new JSONObject();
            jsonResponse.put("success", false);
            jsonResponse.put("accountSuspended", true);
            jsonResponse.put("message", "Tu cuenta ha sido suspendida. Contacta al administrador.");
            jsonResponse.put("redirectUrl", "LoginServlet");

            sendJsonResponse(response, HttpServletResponse.SC_FORBIDDEN, jsonResponse);
            System.out.println("🚫 Usuario baneado detectado en petición AJAX");
        } else {
            // Para peticiones normales, crear sesión para mensaje
            session = request.getSession(true);
            session.setAttribute("authMessage", "Tu cuenta ha sido suspendida. Contacta al administrador.");
            session.setAttribute("authMessageType", "error");
            session.setMaxInactiveInterval(300);

            response.sendRedirect("LoginServlet");
            System.out.println("🚫 Usuario baneado detectado en petición normal, redirigiendo");
        }
    }

    /**
     * Maneja cuando se niega el acceso por permisos
     */
    private void handleAccessDenied(HttpServletRequest request, HttpServletResponse response) throws IOException {
        boolean isAjax = isAjaxRequest(request);

        if (isAjax) {
            // Para peticiones AJAX, enviar respuesta JSON
            JSONObject jsonResponse = new JSONObject();
            jsonResponse.put("success", false);
            jsonResponse.put("accessDenied", true);
            jsonResponse.put("message", "No tienes permisos para acceder a esta página.");
            jsonResponse.put("redirectUrl", "HomeServlet");

            sendJsonResponse(response, HttpServletResponse.SC_FORBIDDEN, jsonResponse);
            System.out.println("🛡️ Acceso denegado detectado en petición AJAX");
        } else {
            // Para peticiones normales, crear sesión temporal para mensaje
            HttpSession session = request.getSession(true);
            session.setAttribute("authMessage", "No tienes permisos para acceder a esta página.");
            session.setAttribute("authMessageType", "error");
            session.setMaxInactiveInterval(300);

            // Redirigir al home en lugar del login
            response.sendRedirect("HomeServlet");
            System.out.println("🛡️ Acceso denegado detectado en petición normal, redirigiendo al home");
        }
    }

    /**
     * Verifica si la petición es AJAX
     */
    private boolean isAjaxRequest(HttpServletRequest request) {
        String requestedWith = request.getHeader("X-Requested-With");
        String acceptHeader = request.getHeader("Accept");

        return "XMLHttpRequest".equals(requestedWith)
                || (acceptHeader != null && acceptHeader.contains("application/json"));
    }

    /**
     * Envía respuesta JSON de forma estandarizada
     */
    private void sendJsonResponse(HttpServletResponse response, int statusCode, JSONObject jsonObject) throws IOException {
        response.setStatus(statusCode);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(jsonObject.toString());
    }

    @Override
    public void destroy() {
        System.out.println("🔍 AuthenticationFilter destruido");
    }
}
