/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package pe.aquasocial.servlet;

import jakarta.servlet.RequestDispatcher;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.SQLException;
import org.json.JSONObject;
import pe.aquasocial.dao.ClaveRecuperacionDAO;
import pe.aquasocial.dao.UsuarioDAO;
import pe.aquasocial.entity.ClaveRecuperacion;
import pe.aquasocial.entity.Usuario;
import pe.aquasocial.util.SessionUtil;

/**
 *
 * @author Rodrigo
 */
@WebServlet(name = "RegisterServlet", urlPatterns = {"/RegisterServlet"})
public class RegisterServlet extends HttpServlet {

    // Instanciar los DAOs
    private UsuarioDAO usuarioDAO;
    private ClaveRecuperacionDAO claveDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        // Inicializar DAOs al arrancar el servlet
        usuarioDAO = new UsuarioDAO();
        claveDAO = new ClaveRecuperacionDAO();
    }

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet RegisterServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet RegisterServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Si ya está logueado, redirigir al home
        if (SessionUtil.isUserLoggedIn(request)) {
            response.sendRedirect("HomeServlet");
            return;
        }
        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/auth/register.jsp");
        dispatcher.forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action != null) {
            switch (action) {
                case "checkUsername":
                    verificarUsername(request, response);
                    break;
                case "checkEmail":
                    verificarEmail(request, response);
                    break;
                case "guardarClave":
                    guardarClaveSecreta(request, response);
                    break;
                default:
                    registrarUsuario(request, response);
                    break;
            }
        } else {
            registrarUsuario(request, response);
        }
    }

    private void registrarUsuario(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JSONObject jsonResponse = new JSONObject();

        try {
            // Obtener parámetros del formulario
            String nombreCompleto = request.getParameter("nombre_completo");
            String username = request.getParameter("username");
            String email = request.getParameter("email");
            String telefono = request.getParameter("telefono");
            String password = request.getParameter("password");

            // Validaciones del lado del servidor
            JSONObject validationErrors = validarDatosRegistro(nombreCompleto, username, email, telefono, password);
            if (validationErrors.length() > 0) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);

                jsonResponse.put("success", false);
                jsonResponse.put("message", "Errores de validación");
                jsonResponse.put("fieldErrors", validationErrors);

                response.getWriter().write(jsonResponse.toString());
                return;
            }

            // Limpiar y normalizar datos
            nombreCompleto = nombreCompleto.trim();
            username = username.trim();
            email = email.trim().toLowerCase();
            telefono = telefono.trim();

            // Verificar duplicados
            JSONObject duplicateErrors = new JSONObject();

            if (usuarioDAO.existeUsername(username)) {
                duplicateErrors.put("username", "Usuario no disponible");
            }

            if (!usuarioDAO.isEmailDisponible(email)) {
                duplicateErrors.put("email", "Email ya registrado");
            }

            if (duplicateErrors.length() > 0) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);

                jsonResponse.put("success", false);
                jsonResponse.put("message", "Datos duplicados encontrados");
                jsonResponse.put("fieldErrors", duplicateErrors);

                response.getWriter().write(jsonResponse.toString());
                return;
            }

            // Crear nuevo usuario
            Usuario nuevoUsuario = new Usuario();
            nuevoUsuario.setUsername(username);
            nuevoUsuario.setNombreCompleto(nombreCompleto);
            nuevoUsuario.setPassword(password); // Aquí deberías hashear la contraseña
            nuevoUsuario.setEmail(email);
            nuevoUsuario.setTelefono(telefono);
            nuevoUsuario.setRol("usuario");
            nuevoUsuario.setVerificado(false);
            nuevoUsuario.setPrivilegio(false);
            nuevoUsuario.setBaneado(false);

            // Guardar en base de datos
            int registroExitoso = usuarioDAO.insertar(nuevoUsuario);

            if (registroExitoso > 0) {
                System.out.println("✅ Usuario registrado exitosamente: " + username);

                // Respuesta de éxito con opción de clave secreta
                jsonResponse.put("success", true);
                jsonResponse.put("message", "Usuario registrado exitosamente");
                jsonResponse.put("requireSecretKey", true);
                jsonResponse.put("userId", registroExitoso);

                response.getWriter().write(jsonResponse.toString());

            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

                jsonResponse.put("success", false);
                jsonResponse.put("message", "Error al registrar usuario en la base de datos");

                response.getWriter().write(jsonResponse.toString());
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

            jsonResponse.put("success", false);
            jsonResponse.put("message", "Error inesperado: " + e.getMessage());

            response.getWriter().write(jsonResponse.toString());
        }
    }

    private void verificarUsername(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JSONObject jsonResponse = new JSONObject();

        try {
            String username = request.getParameter("username");

            if (username == null || username.trim().isEmpty()) {
                jsonResponse.put("available", false);
                jsonResponse.put("message", "Username vacío");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            username = username.trim();

            // Validaciones básicas
            if (username.length() < 3) {
                jsonResponse.put("available", false);
                jsonResponse.put("message", "Muy corto");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            if (username.length() > 50) {
                jsonResponse.put("available", false);
                jsonResponse.put("message", "Muy largo");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            // Verificar disponibilidad en base de datos
            boolean disponible = !usuarioDAO.existeUsername(username);

            jsonResponse.put("available", disponible);
            if (!disponible) {
                jsonResponse.put("message", "Username no disponible");
            }

            response.getWriter().write(jsonResponse.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

            jsonResponse.put("available", false);
            jsonResponse.put("message", "Error del servidor");
            response.getWriter().write(jsonResponse.toString());
        }
    }

    private void verificarEmail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JSONObject jsonResponse = new JSONObject();

        try {
            String email = request.getParameter("email");

            if (email == null || email.trim().isEmpty()) {
                jsonResponse.put("available", false);
                jsonResponse.put("message", "Email vacío");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            email = email.trim().toLowerCase();

            // Validación básica de email
            if (!email.contains("@") || !email.contains(".")) {
                jsonResponse.put("available", false);
                jsonResponse.put("message", "Email inválido");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            // Verificar disponibilidad en base de datos
            boolean disponible = usuarioDAO.isEmailDisponible(email);

            jsonResponse.put("available", disponible);
            if (!disponible) {
                jsonResponse.put("message", "Email ya registrado");
            }

            response.getWriter().write(jsonResponse.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

            jsonResponse.put("available", false);
            jsonResponse.put("message", "Error del servidor");
            response.getWriter().write(jsonResponse.toString());
        }
    }

    private void guardarClaveSecreta(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JSONObject jsonResponse = new JSONObject();

        try {
            String usuarioIdStr = request.getParameter("usuario_id");
            String claveSecreta = request.getParameter("clave_secreta");

            // Validaciones
            if (usuarioIdStr == null || usuarioIdStr.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);

                jsonResponse.put("success", false);
                jsonResponse.put("message", "ID de usuario requerido");

                response.getWriter().write(jsonResponse.toString());
                return;
            }

            if (claveSecreta == null || claveSecreta.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);

                jsonResponse.put("success", false);
                jsonResponse.put("message", "Clave secreta requerida");

                response.getWriter().write(jsonResponse.toString());
                return;
            }

            claveSecreta = claveSecreta.trim();

            if (claveSecreta.length() < 3) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);

                jsonResponse.put("success", false);
                jsonResponse.put("message", "La clave secreta debe tener al menos 3 caracteres");

                response.getWriter().write(jsonResponse.toString());
                return;
            }

            int usuarioId = Integer.parseInt(usuarioIdStr);

            // Verificar que el usuario existe
            Usuario usuario = usuarioDAO.obtenerPorId(usuarioId);
            if (usuario == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);

                jsonResponse.put("success", false);
                jsonResponse.put("message", "Usuario no encontrado");

                response.getWriter().write(jsonResponse.toString());
                return;
            }

            // Crear registro de clave de recuperación
            ClaveRecuperacion claveRecuperacion = new ClaveRecuperacion();
            claveRecuperacion.setUsuarioId(usuarioId);
            claveRecuperacion.setClaveSecreta(claveSecreta);

            // Guardar en base de datos
            boolean guardadoExitoso = claveDAO.crear(claveRecuperacion);

            if (guardadoExitoso) {
                System.out.println("✅ Clave secreta guardada para usuario ID: " + usuarioId);

                jsonResponse.put("success", true);
                jsonResponse.put("message", "Clave secreta guardada correctamente");

                response.getWriter().write(jsonResponse.toString());
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

                jsonResponse.put("success", false);
                jsonResponse.put("message", "Error al guardar la clave secreta");

                response.getWriter().write(jsonResponse.toString());
            }

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);

            jsonResponse.put("success", false);
            jsonResponse.put("message", "ID de usuario inválido");

            response.getWriter().write(jsonResponse.toString());
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

            jsonResponse.put("success", false);
            jsonResponse.put("message", "Error inesperado: " + e.getMessage());

            response.getWriter().write(jsonResponse.toString());
        }
    }

    private JSONObject validarDatosRegistro(String nombreCompleto, String username, String email, String telefono, String password) {

        JSONObject errores = new JSONObject();

        // Validar nombre completo
        if (nombreCompleto == null || nombreCompleto.trim().isEmpty()) {
            errores.put("nombre_completo", "El nombre completo es requerido");
        } else if (nombreCompleto.trim().length() < 2) {
            errores.put("nombre_completo", "El nombre completo debe tener al menos 2 caracteres");
        } else if (nombreCompleto.trim().length() > 100) {
            errores.put("nombre_completo", "El nombre completo es muy largo");
        }

        // Validar username
        if (username == null || username.trim().isEmpty()) {
            errores.put("username", "El nombre de usuario es requerido");
        } else if (username.trim().length() < 3) {
            errores.put("username", "El nombre de usuario debe tener al menos 3 caracteres");
        } else if (username.trim().length() > 50) {
            errores.put("username", "El nombre de usuario es muy largo");
        }

        // Validar email
        if (email == null || email.trim().isEmpty()) {
            errores.put("email", "El correo electrónico es requerido");
        } else if (!email.contains("@") || !email.contains(".")) {
            errores.put("email", "El correo electrónico no es válido");
        } else if (email.trim().length() > 100) {
            errores.put("email", "El correo electrónico es muy largo");
        }

        // Validar teléfono
        if (telefono == null || telefono.trim().isEmpty()) {
            errores.put("telefono", "El teléfono es requerido");
        } else if (telefono.trim().length() < 9) {
            errores.put("telefono", "El teléfono debe tener al menos 9 dígitos");
        } else if (telefono.trim().length() > 20) {
            errores.put("telefono", "El teléfono es muy largo");
        }

        // Validar password
        if (password == null || password.isEmpty()) {
            errores.put("password", "La contraseña es requerida");
        } else if (password.length() < 6) {
            errores.put("password", "La contraseña debe tener al menos 6 caracteres");
        } else if (password.length() > 255) {
            errores.put("password", "La contraseña es muy larga");
        }

        return errores;
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
