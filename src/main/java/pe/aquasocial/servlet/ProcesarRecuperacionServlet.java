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
import org.json.JSONObject;
import pe.aquasocial.dao.UsuarioDAO;

/**
 *
 * @author Rodrigo
 */
@WebServlet(name = "ProcesarRecuperacionServlet", urlPatterns = {"/ProcesarRecuperacionServlet"})
public class ProcesarRecuperacionServlet extends HttpServlet {

    private UsuarioDAO usuarioDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        usuarioDAO = new UsuarioDAO();
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
            out.println("<title>Servlet ProcesarRecuperacionServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ProcesarRecuperacionServlet at " + request.getContextPath() + "</h1>");
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
        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/auth/recuperar-contraseña.jsp");
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

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        switch (action) {
            case "validateCredentials":
                validarCredenciales(request, response);
                break;
            case "changePassword":
                cambiarPassword(request, response);
                break;
            default:
                response.sendRedirect("ProcesarRecuperacionServlet");
                break;
        }
    }

    private void validarCredenciales(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Configurar respuesta como JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JSONObject jsonResponse = new JSONObject();

        try {
            // Obtener parámetros
            String usuario = request.getParameter("usuario");
            String claveSecreta = request.getParameter("clave_secreta");

            // Validaciones básicas
            if (usuario == null || usuario.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                jsonResponse.put("success", false);
                jsonResponse.put("message", "El nombre de usuario es requerido");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            if (claveSecreta == null || claveSecreta.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                jsonResponse.put("success", false);
                jsonResponse.put("message", "La clave secreta es requerida");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            // Limpiar datos
            usuario = usuario.trim();
            claveSecreta = claveSecreta.trim();

            // Validaciones adicionales
            if (usuario.length() < 3) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                jsonResponse.put("success", false);
                jsonResponse.put("message", "El usuario debe tener al menos 3 caracteres");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            if (claveSecreta.length() < 3) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                jsonResponse.put("success", false);
                jsonResponse.put("message", "La clave secreta debe tener al menos 3 caracteres");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            // Verificar usuario y clave secreta en base de datos
            boolean esValido = usuarioDAO.verificarUsuarioYClaveSecreta(usuario, claveSecreta);

            if (esValido) {
                // Validación exitosa
                System.out.println("✅ Validación exitosa para usuario: " + usuario);

                jsonResponse.put("success", true);
                jsonResponse.put("message", "Usuario y clave secreta validados correctamente");
                jsonResponse.put("usuario", usuario);
                jsonResponse.put("nextStep", "changePassword");

                response.getWriter().write(jsonResponse.toString());

            } else {
                // Credenciales incorrectas
                System.out.println("❌ Validación fallida para usuario: " + usuario);

                //response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Usuario o clave secreta incorrectos");
                jsonResponse.put("error", "INVALID_CREDENTIALS");

                response.getWriter().write(jsonResponse.toString());
            }

        } catch (Exception e) {
            // Error del servidor
            e.printStackTrace();
            System.err.println("❌ Error en validación de credenciales: " + e.getMessage());

            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Error interno del servidor. Intenta de nuevo más tarde.");
            jsonResponse.put("error", "INTERNAL_ERROR");

            response.getWriter().write(jsonResponse.toString());
        }
    }

    /**
     * Cambiar contraseña del usuario
     */
    private void cambiarPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Configurar respuesta como JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JSONObject jsonResponse = new JSONObject();

        try {
            // Obtener parámetros
            String usuario = request.getParameter("usuario");
            String nuevaPassword = request.getParameter("nuevaPassword");
            String confirmarPassword = request.getParameter("confirmarPassword");

            // Validaciones básicas
            if (usuario == null || usuario.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                jsonResponse.put("success", false);
                jsonResponse.put("message", "El nombre de usuario es requerido");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            if (nuevaPassword == null || nuevaPassword.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                jsonResponse.put("success", false);
                jsonResponse.put("message", "La nueva contraseña es requerida");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            if (confirmarPassword == null || confirmarPassword.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                jsonResponse.put("success", false);
                jsonResponse.put("message", "La confirmación de contraseña es requerida");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            // Limpiar datos
            usuario = usuario.trim();

            // Validaciones de contraseña
            if (nuevaPassword.length() < 6) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                jsonResponse.put("success", false);
                jsonResponse.put("message", "La contraseña debe tener al menos 6 caracteres");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            if (!nuevaPassword.equals(confirmarPassword)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Las contraseñas no coinciden");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            // Verificar que el usuario existe
            if (!usuarioDAO.existeUsername(usuario)) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Usuario no encontrado");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            // Actualizar contraseña en base de datos
            boolean actualizado = usuarioDAO.actualizarPassword(usuario, nuevaPassword);

            if (actualizado) {
                // Contraseña actualizada exitosamente
                System.out.println("✅ Contraseña actualizada para usuario: " + usuario);

                jsonResponse.put("success", true);
                jsonResponse.put("message", "Contraseña actualizada exitosamente");
                jsonResponse.put("usuario", usuario);

                response.getWriter().write(jsonResponse.toString());

            } else {
                // Error al actualizar
                System.out.println("❌ Error al actualizar contraseña para usuario: " + usuario);

                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Error al actualizar la contraseña en la base de datos");

                response.getWriter().write(jsonResponse.toString());
            }

        } catch (Exception e) {
            // Error del servidor
            e.printStackTrace();
            System.err.println("❌ Error en cambio de contraseña: " + e.getMessage());

            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Error interno del servidor. Intenta de nuevo más tarde.");

            response.getWriter().write(jsonResponse.toString());
        }
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
