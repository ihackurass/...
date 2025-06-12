package pe.aquasocial.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Cookie;
import pe.aquasocial.entity.Usuario;

/**
 * Utilidad para manejo de sesiones de usuario
 * @author AguaBendita Team
 */
public class SessionUtil {
    
    // Nombres de atributos de sesión
    private static final String SESSION_USER_ID = "id_username";
    private static final String SESSION_USERNAME = "username";
    private static final String SESSION_ROLE = "rol";
    private static final String SESSION_USER_OBJECT = "usuarioLogueado";
    
    // Nombres de cookies
    private static final String COOKIE_REMEMBER_USERNAME = "rememberUsername";
    private static final String COOKIE_USER_ID = "userId";
    private static final String COOKIE_REMEMBER_ME = "rememberMe";
    
    /**
     * Verifica si el usuario está logueado
     * @param request HttpServletRequest
     * @return true si está logueado, false en caso contrario
     */
    public static boolean isUserLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            Integer userId = (Integer) session.getAttribute(SESSION_USER_ID);
            String username = (String) session.getAttribute(SESSION_USERNAME);
            
            // Verificar que los datos básicos estén presentes
            if (userId != null && username != null && !username.trim().isEmpty()) {
                return true;
            }
        }
        
        // Verificar cookies de "recordar"
        return hasRememberMeCookies(request);
    }
    
    /**
     * Obtiene el ID del usuario logueado
     * @param request HttpServletRequest
     * @return ID del usuario o null si no está logueado
     */
    public static Integer getUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            Integer userId = (Integer) session.getAttribute(SESSION_USER_ID);
            if (userId != null) {
                return userId;
            }
        }
        
        // Intentar obtener de cookies
        return getUserIdFromCookie(request);
    }
    
    /**
     * Obtiene el username del usuario logueado
     * @param request HttpServletRequest
     * @return username o null si no está logueado
     */
    public static String getUsername(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            String username = (String) session.getAttribute(SESSION_USERNAME);
            if (username != null && !username.trim().isEmpty()) {
                return username;
            }
        }
        
        // Intentar obtener de cookies
        return getUsernameFromCookie(request);
    }
    
    /**
     * Obtiene el rol del usuario logueado
     * @param request HttpServletRequest
     * @return rol del usuario o null si no está logueado
     */
    public static String getUserRole(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            return (String) session.getAttribute(SESSION_ROLE);
        }
        
        return null;
    }
    
    /**
     * Obtiene el objeto Usuario completo de la sesión
     * @param request HttpServletRequest
     * @return objeto Usuario o null si no está logueado
     */
    public static Usuario getLoggedUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            return (Usuario) session.getAttribute(SESSION_USER_OBJECT);
        }
        
        return null;
    }
    
    /**
     * Verifica si el usuario es administrador
     * @param request HttpServletRequest
     * @return true si es admin, false en caso contrario
     */
    public static boolean isAdmin(HttpServletRequest request) {
        String role = getUserRole(request);
        return "admin".equals(role);
    }
    
    /**
     * Verifica si el usuario tiene privilegios especiales
     * @param request HttpServletRequest
     * @return true si tiene privilegios, false en caso contrario
     */
    public static boolean hasPrivileges(HttpServletRequest request) {
        Usuario usuario = getLoggedUser(request);
        if (usuario != null) {
            return usuario.isPrivilegio();
        }
        return false;
    }
    
    /**
     * Verifica si el usuario está verificado
     * @param request HttpServletRequest
     * @return true si está verificado, false en caso contrario
     */
    public static boolean isVerified(HttpServletRequest request) {
        Usuario usuario = getLoggedUser(request);
        if (usuario != null) {
            return usuario.isVerificado();
        }
        return false;
    }
    
    /**
     * Verifica si el usuario está baneado
     * @param request HttpServletRequest
     * @return true si está baneado, false en caso contrario
     */
    public static boolean isBanned(HttpServletRequest request) {
        Usuario usuario = getLoggedUser(request);
        if (usuario != null) {
            return usuario.isBaneado();
        }
        return false;
    }
    
    /**
     * Invalida la sesión del usuario
     * @param request HttpServletRequest
     */
    public static void invalidateSession(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            try {
                session.invalidate();
                System.out.println("🔓 Sesión invalidada correctamente");
            } catch (Exception e) {
                System.err.println("⚠️ Error al invalidar sesión: " + e.getMessage());
            }
        }
    }
    
    /**
     * Renueva la sesión del usuario (útil para prevenir session fixation)
     * @param request HttpServletRequest
     * @return nueva sesión
     */
    public static HttpSession renewSession(HttpServletRequest request) {
        HttpSession oldSession = request.getSession(false);
        
        if (oldSession != null) {
            // Guardar datos importantes
            Integer userId = (Integer) oldSession.getAttribute(SESSION_USER_ID);
            String username = (String) oldSession.getAttribute(SESSION_USERNAME);
            String role = (String) oldSession.getAttribute(SESSION_ROLE);
            Usuario usuario = (Usuario) oldSession.getAttribute(SESSION_USER_OBJECT);
            
            // Invalidar sesión anterior
            oldSession.invalidate();
            
            // Crear nueva sesión
            HttpSession newSession = request.getSession(true);
            
            // Restaurar datos
            if (userId != null) {
                newSession.setAttribute(SESSION_USER_ID, userId);
                newSession.setAttribute(SESSION_USERNAME, username);
                newSession.setAttribute(SESSION_ROLE, role);
                newSession.setAttribute(SESSION_USER_OBJECT, usuario);
                newSession.setMaxInactiveInterval(3600); // 1 hora
            }
            
            return newSession;
        }
        
        return request.getSession(true);
    }
    
    /**
     * Actualiza los datos del usuario en la sesión
     * @param request HttpServletRequest
     * @param usuario Usuario actualizado
     */
    public static void updateUserInSession(HttpServletRequest request, Usuario usuario) {
        HttpSession session = request.getSession(false);
        if (session != null && usuario != null) {
            session.setAttribute(SESSION_USER_ID, usuario.getId());
            session.setAttribute(SESSION_USERNAME, usuario.getUsername());
            session.setAttribute(SESSION_ROLE, usuario.getRol());
            session.setAttribute(SESSION_USER_OBJECT, usuario);
            
            System.out.println("🔄 Datos de usuario actualizados en sesión: " + usuario.getUsername());
        }
    }
    
    /**
     * Verifica si existen cookies de "recordar usuario"
     * @param request HttpServletRequest
     * @return true si existen las cookies necesarias
     */
    private static boolean hasRememberMeCookies(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return false;
        
        boolean hasRememberMe = false;
        boolean hasUsername = false;
        boolean hasUserId = false;
        
        for (Cookie cookie : cookies) {
            switch (cookie.getName()) {
                case COOKIE_REMEMBER_ME:
                    hasRememberMe = "true".equals(cookie.getValue());
                    break;
                case COOKIE_REMEMBER_USERNAME:
                    hasUsername = cookie.getValue() != null && !cookie.getValue().trim().isEmpty();
                    break;
                case COOKIE_USER_ID:
                    hasUserId = cookie.getValue() != null && !cookie.getValue().trim().isEmpty();
                    break;
            }
        }
        
        return hasRememberMe && hasUsername && hasUserId;
    }
    
    /**
     * Obtiene el username desde las cookies
     * @param request HttpServletRequest
     * @return username o null
     */
    private static String getUsernameFromCookie(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return null;
        
        for (Cookie cookie : cookies) {
            if (COOKIE_REMEMBER_USERNAME.equals(cookie.getName())) {
                return cookie.getValue();
            }
        }
        
        return null;
    }
    
    /**
     * Obtiene el ID del usuario desde las cookies
     * @param request HttpServletRequest
     * @return ID del usuario o null
     */
    private static Integer getUserIdFromCookie(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return null;
        
        for (Cookie cookie : cookies) {
            if (COOKIE_USER_ID.equals(cookie.getName())) {
                try {
                    return Integer.parseInt(cookie.getValue());
                } catch (NumberFormatException e) {
                    System.err.println("⚠️ Error al parsear userId de cookie: " + cookie.getValue());
                    return null;
                }
            }
        }
        
        return null;
    }
    
    /**
     * Obtiene información de debug de la sesión actual
     * @param request HttpServletRequest
     * @return String con información de debug
     */
    public static String getSessionDebugInfo(HttpServletRequest request) {
        StringBuilder info = new StringBuilder();
        info.append("=== SESSION DEBUG INFO ===\n");
        
        HttpSession session = request.getSession(false);
        if (session != null) {
            info.append("Session ID: ").append(session.getId()).append("\n");
            info.append("User ID: ").append(session.getAttribute(SESSION_USER_ID)).append("\n");
            info.append("Username: ").append(session.getAttribute(SESSION_USERNAME)).append("\n");
            info.append("Role: ").append(session.getAttribute(SESSION_ROLE)).append("\n");
            info.append("Max Inactive: ").append(session.getMaxInactiveInterval()).append("s\n");
            info.append("Creation Time: ").append(new java.util.Date(session.getCreationTime())).append("\n");
            info.append("Last Access: ").append(new java.util.Date(session.getLastAccessedTime())).append("\n");
        } else {
            info.append("No active session\n");
        }
        
        // Información de cookies
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            info.append("\n=== COOKIES ===\n");
            for (Cookie cookie : cookies) {
                if (cookie.getName().startsWith("remember") || cookie.getName().equals("userId")) {
                    info.append(cookie.getName()).append(": ").append(cookie.getValue()).append("\n");
                }
            }
        }
        
        return info.toString();
    }
}