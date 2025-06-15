package pe.aquasocial.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Cookie;
import org.json.JSONObject;
import org.mindrot.jbcrypt.BCrypt;

import pe.aquasocial.entity.Usuario;
import pe.aquasocial.util.Conexion;
import pe.aquasocial.util.SessionUtil;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Si ya está logueado, redirigir al home
        if (SessionUtil.isUserLoggedIn(request)) {
            response.sendRedirect("HomeServlet");
            return;
        }
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate, private");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        response.setHeader("Last-Modified", new java.util.Date().toString());
        response.setHeader("ETag", String.valueOf(System.currentTimeMillis()));
        
        // Verificar mensajes en la sesión (logout y autenticación)
        HttpSession session = request.getSession(false);
        if (session != null) {
            // Mensajes de logout
            String logoutMessage = (String) session.getAttribute("logoutMessage");
            String logoutType = (String) session.getAttribute("logoutType");

            // Mensajes de autenticación (desde AuthenticationFilter)
            String authMessage = (String) session.getAttribute("authMessage");
            String authMessageType = (String) session.getAttribute("authMessageType");

            // Procesar mensaje de logout (prioridad)
            if (logoutMessage != null) {
                if ("success".equals(logoutType)) {
                    request.setAttribute("successMessage", logoutMessage);
                } else if ("error".equals(logoutType)) {
                    request.setAttribute("errorMessage", logoutMessage);
                } else if ("warning".equals(logoutType)) {
                    request.setAttribute("warningMessage", logoutMessage);
                } else {
                    request.setAttribute("successMessage", logoutMessage);
                }

                session.removeAttribute("logoutMessage");
                session.removeAttribute("logoutType");
                System.out.println("📝 Mensaje de logout mostrado: " + logoutType + " - " + logoutMessage);

                // Si no hay mensaje de logout, procesar mensaje de autenticación
            } else if (authMessage != null) {
                if ("success".equals(authMessageType)) {
                    request.setAttribute("successMessage", authMessage);
                } else if ("error".equals(authMessageType)) {
                    request.setAttribute("errorMessage", authMessage);
                } else if ("warning".equals(authMessageType)) {
                    request.setAttribute("warningMessage", authMessage);
                } else {
                    request.setAttribute("warningMessage", authMessage);
                }

                session.removeAttribute("authMessage");
                session.removeAttribute("authMessageType");
                System.out.println("📝 Mensaje de autenticación mostrado: " + authMessageType + " - " + authMessage);
            }
        }

        request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Configurar respuesta como JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JSONObject jsonResponse = new JSONObject();

        try {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String rememberMe = request.getParameter("rememberMe");

            // Validaciones básicas
            if (username == null || username.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                jsonResponse.put("success", false);
                jsonResponse.put("message", "El nombre de usuario es requerido");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            if (password == null || password.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                jsonResponse.put("success", false);
                jsonResponse.put("message", "La contraseña es requerida");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            username = username.trim();

            // Procesar login
            try (Connection conn = Conexion.getConexion()) {

                // Verificar estado del usuario
                String sqlEstado = "SELECT id, password, nombre_completo, rol, intentos_fallidos, bloqueo_hasta, baneado, "
                                 + "username, email, avatar, verificado, privilegio, solicito_verificacion, telefono, "
                                 + "fecha_registro, ultimo_acceso, fecha_actualizacion, "
                                 + "bio "
                                 + "FROM usuarios WHERE username = ?";

                try (PreparedStatement stmtEstado = conn.prepareStatement(sqlEstado)) {
                    stmtEstado.setString(1, username);
                    ResultSet rsEstado = stmtEstado.executeQuery();

                    if (!rsEstado.next()) {
                        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "Usuario o contraseña incorrectos");
                        response.getWriter().write(jsonResponse.toString());
                        return;
                    }

                    int id = rsEstado.getInt("id");
                    String passwordBD = rsEstado.getString("password");
                    String rol = rsEstado.getString("rol");
                    int intentosFallidos = rsEstado.getInt("intentos_fallidos");
                    Timestamp bloqueoHasta = rsEstado.getTimestamp("bloqueo_hasta");
                    boolean baneado = rsEstado.getBoolean("baneado");

                    // Verificar si está baneado
                    if (baneado) {
                        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "Tu cuenta ha sido suspendida. Contacta al administrador.");
                        response.getWriter().write(jsonResponse.toString());
                        return;
                    }

                    Timestamp ahora = new Timestamp(System.currentTimeMillis());

                    // Verificar si está bloqueado
                    if (bloqueoHasta != null && bloqueoHasta.after(ahora)) {
                        long minutosRestantes = (bloqueoHasta.getTime() - ahora.getTime()) / 60000;
                        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                        jsonResponse.put("success", false);
                        jsonResponse.put("message", "Cuenta bloqueada por múltiples intentos fallidos. Intenta de nuevo en " + minutosRestantes + " minutos.");
                        jsonResponse.put("isBlocked", true);
                        jsonResponse.put("blockTimeMinutes", (int) minutosRestantes);
                        response.getWriter().write(jsonResponse.toString());
                        return;
                    }

                    // Validar contraseña
                    if (BCrypt.checkpw(password, passwordBD)) {
                        // Login correcto - resetear intentos y bloqueo
                        String sqlReset = "UPDATE usuarios SET intentos_fallidos = 0, bloqueo_hasta = NULL WHERE id = ?";
                        try (PreparedStatement stmtReset = conn.prepareStatement(sqlReset)) {
                            stmtReset.setInt(1, id);
                            stmtReset.executeUpdate();
                        }
                        Usuario usuario = new Usuario();
                        // Crear objeto Usuario
                        usuario.setId(rsEstado.getInt("id"));
                        usuario.setUsername(rsEstado.getString("username"));
                        usuario.setNombreCompleto(rsEstado.getString("nombre_completo"));
                        usuario.setPassword(rsEstado.getString("password"));  // ⭐ FALTABA
                        usuario.setEmail(rsEstado.getString("email"));
                        usuario.setRol(rsEstado.getString("rol"));  // ⭐ CORREGIDO (era variable, debe ser de ResultSet)
                        usuario.setAvatar(rsEstado.getString("avatar"));
                        usuario.setVerificado(rsEstado.getBoolean("verificado"));
                        usuario.setPrivilegio(rsEstado.getBoolean("privilegio"));
                        usuario.setBaneado(rsEstado.getBoolean("baneado"));  // ⭐ FALTABA
                        usuario.setSolicitoVerificacion(rsEstado.getBoolean("solicito_verificacion"));
                        usuario.setTelefono(rsEstado.getString("telefono"));
                        usuario.setIntentosFallidos(rsEstado.getInt("intentos_fallidos"));  // ⭐ FALTABA

                        // Timestamps existentes
                        Timestamp bloqueHasta = rsEstado.getTimestamp("bloqueo_hasta");
                        if (bloqueHasta != null) {
                            usuario.setBloqueHasta(bloqueHasta);  // ⭐ FALTABA
                        }

                        Timestamp fechaRegistro = rsEstado.getTimestamp("fecha_registro");
                        if (fechaRegistro != null) {
                            usuario.setFechaRegistro(fechaRegistro);  // ⭐ FALTABA
                        }

                        Timestamp ultimoAcceso = rsEstado.getTimestamp("ultimo_acceso");
                        if (ultimoAcceso != null) {
                            usuario.setUltimoAcceso(ultimoAcceso.toLocalDateTime());
                        }

                        Timestamp fechaActualizacion = rsEstado.getTimestamp("fecha_actualizacion");
                        if (fechaActualizacion != null) {
                            usuario.setFechaActualizacion(fechaActualizacion.toLocalDateTime());
                        }

                        // ⭐ NUEVOS CAMPOS DE CONFIGURACIÓN
                        usuario.setBio(rsEstado.getString("bio"));


                        // Crear sesión
                        HttpSession session = request.getSession();
                        session.setAttribute("id_username", usuario.getId());
                        session.setAttribute("username", usuario.getUsername());
                        session.setAttribute("rol", usuario.getRol());
                        session.setAttribute("usuarioLogueado", usuario);
                        session.setMaxInactiveInterval(3600); // 1 hora

                        // Configurar cookies si "recordar" está marcado
                        if ("true".equals(rememberMe) || "on".equals(rememberMe)) {
                            // Cookie con el username (7 días)
                            Cookie usernameCookie = new Cookie("rememberUsername", usuario.getUsername());
                            usernameCookie.setMaxAge(7 * 24 * 60 * 60); // 7 días
                            usernameCookie.setPath("/");
                            usernameCookie.setHttpOnly(true);
                            response.addCookie(usernameCookie);

                            // Cookie con el ID del usuario (7 días)
                            Cookie userIdCookie = new Cookie("userId", String.valueOf(usuario.getId()));
                            userIdCookie.setMaxAge(7 * 24 * 60 * 60); // 7 días
                            userIdCookie.setPath("/");
                            userIdCookie.setHttpOnly(true);
                            response.addCookie(userIdCookie);

                            // Cookie para indicar que debe recordar (7 días)
                            Cookie rememberCookie = new Cookie("rememberMe", "true");
                            rememberCookie.setMaxAge(7 * 24 * 60 * 60); // 7 días
                            rememberCookie.setPath("/");
                            response.addCookie(rememberCookie);

                            System.out.println("🍪 Cookies configuradas para recordar a: " + usuario.getUsername() + " (ID: " + usuario.getId() + ")");
                        }

                        // Determinar URL de redirección
                        String redirectUrl;
                        if ("admin".equals(usuario.getRol())) {
                            redirectUrl = "admin/home.jsp";
                        } else {
                            redirectUrl = "HomeServlet";
                        }

                        // Respuesta exitosa
                        jsonResponse.put("success", true);
                        jsonResponse.put("message", "Login exitoso. ¡Bienvenido " + usuario.getUsername() + "!");
                        jsonResponse.put("redirectUrl", redirectUrl);
                        jsonResponse.put("userRole", usuario.getRol());
                        jsonResponse.put("username", usuario.getUsername());
                        jsonResponse.put("userId", usuario.getId()); // Agregar ID del usuario al JSON

                        System.out.println("✅ Login exitoso para: " + username + " (ID: " + usuario.getId() + ")");

                    } else {
                        // Contraseña incorrecta - incrementar intentos
                        intentosFallidos++;

                        if (intentosFallidos >= 3) {
                            // Bloquear por 10 minutos
                            Timestamp nuevoBloqueo = new Timestamp(System.currentTimeMillis() + 10 * 60 * 1000);
                            String sqlBloqueo = "UPDATE usuarios SET intentos_fallidos = 0, bloqueo_hasta = ? WHERE id = ?";

                            try (PreparedStatement stmtBloqueo = conn.prepareStatement(sqlBloqueo)) {
                                stmtBloqueo.setTimestamp(1, nuevoBloqueo);
                                stmtBloqueo.setInt(2, id);
                                stmtBloqueo.executeUpdate();
                            }

                            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                            jsonResponse.put("success", false);
                            jsonResponse.put("message", "Has superado el límite de intentos. Cuenta bloqueada por 10 minutos.");
                            jsonResponse.put("isBlocked", true);
                            jsonResponse.put("blockTimeMinutes", 10);

                        } else {
                            // Actualizar intentos fallidos
                            String sqlIntentos = "UPDATE usuarios SET intentos_fallidos = ? WHERE id = ?";

                            try (PreparedStatement stmtIntentos = conn.prepareStatement(sqlIntentos)) {
                                stmtIntentos.setInt(1, intentosFallidos);
                                stmtIntentos.setInt(2, id);
                                stmtIntentos.executeUpdate();
                            }

                            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                            jsonResponse.put("success", false);
                            jsonResponse.put("message", "Usuario o contraseña incorrectos. Intentos restantes: " + (3 - intentosFallidos));
                            jsonResponse.put("remainingAttempts", 3 - intentosFallidos);
                        }

                        System.out.println("❌ Login fallido para: " + username);
                    }
                }

            } catch (SQLException e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Error de conexión a la base de datos");
            }

            response.getWriter().write(jsonResponse.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

            jsonResponse.put("success", false);
            jsonResponse.put("message", "Error interno del servidor. Por favor, intenta de nuevo.");
            jsonResponse.put("error", "INTERNAL_ERROR");

            response.getWriter().write(jsonResponse.toString());
        }
    }

    private String getCookieValue(HttpServletRequest request, String cookieName) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookieName.equals(cookie.getName())) {
                    return cookie.getValue();
                }
            }
        }
        return null;
    }

    public static void setLogoutMessage(HttpServletRequest request, String type, String message) {
        try {
            HttpSession session = request.getSession(true);
            session.setAttribute("logoutMessage", message);
            session.setAttribute("logoutType", type);
            session.setMaxInactiveInterval(300); // 5 minutos para mostrar el mensaje

            System.out.println("📝 Mensaje de logout configurado en sesión: " + type + " - " + message);

        } catch (Exception e) {
            System.err.println("⚠️ Error al configurar mensaje de logout: " + e.getMessage());
        }
    }
}
