/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package pe.aquasocial.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;


import java.sql.SQLException;
import java.util.List;

import pe.aquasocial.entity.Usuario;
import pe.aquasocial.dao.UsuarioDAO;

/**
 *
 * @author Rodrigo
 */
@WebServlet(name = "UsuariosServlet", urlPatterns = {"/admin/UsuariosServlet"})
public class UsuariosServlet extends HttpServlet {

    UsuarioDAO usuarioDAO = new UsuarioDAO();

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
            out.println("<title>Servlet UsuariosServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet UsuariosServlet at " + request.getContextPath() + "</h1>");
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
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("rol"))) {
            response.sendRedirect("../LoginServlet");
            return;
        }

        UsuarioDAO usuarioDAO = new UsuarioDAO();
        try {
            List<Usuario> listaUsuarios = usuarioDAO.obtenerTodos();
            request.setAttribute("usuarios", listaUsuarios);
            request.getRequestDispatcher("/views/admin/usuarios.jsp").forward(request, response);
            System.out.println("Usuarios encontrados: " + listaUsuarios.size());
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error al cargar los usuarios.");
        }
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
                case "update":
                    actualizarUsuario(request, response);
                    break;
                case "delete":
                    eliminarUsuario(request, response);
                    break;
                case "insert":
                    break;
                default:
                    doGet(request, response);
                    break;
            }
        } else {
            doGet(request, response);
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

    private void actualizarUsuario(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        try {
            int id = Integer.parseInt(request.getParameter("usuarioId"));
            UsuarioDAO dao = new UsuarioDAO();
            Usuario usuarioExistente = dao.obtenerPorId(id);

            if (usuarioExistente == null) {
                out.print("{\"success\":false,\"message\":\"Usuario no encontrado.\"}");
                return;
            }

            // Solo actualiza si hay parámetros
            String valor;
            if ((valor = request.getParameter("username")) != null) {
                usuarioExistente.setUsername(valor);
            }
            if ((valor = request.getParameter("email")) != null) {
                usuarioExistente.setEmail(valor);
            }
            if ((valor = request.getParameter("password")) != null) {
                usuarioExistente.setPassword(valor);
            }
            if ((valor = request.getParameter("rol")) != null) {
                usuarioExistente.setRol(valor);
            }
            if ((valor = request.getParameter("verificado")) != null) {
                usuarioExistente.setVerificado(Boolean.parseBoolean(valor));
            }
            if ((valor = request.getParameter("privilegio")) != null) {
                usuarioExistente.setPrivilegio(Boolean.parseBoolean(valor));
            }
            if ((valor = request.getParameter("baneado")) != null) {
                usuarioExistente.setBaneado(Boolean.parseBoolean(valor));
            }

            boolean actualizado = dao.actualizar(usuarioExistente);

            if (actualizado) {
                out.print("{\"success\":true,\"message\":\"Usuario actualizado correctamente.\"}");
            } else {
                out.print("{\"success\":false,\"message\":\"No se pudo actualizar el usuario.\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Error: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    private void eliminarUsuario(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("usuarioId"));
            UsuarioDAO dao = new UsuarioDAO();

            if (dao.eliminar(id)) {
                response.sendRedirect("UsuariosServlet");
            } else {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "No se pudo eliminar el usuario.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error inesperado: " + e.getMessage());
        }
    }
}
