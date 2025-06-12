/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package pe.aquasocial.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.InputStream;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

import pe.aquasocial.util.Conexion;

/**
 *
 * @author Rodrigo
 */
@WebServlet(name = "SolicitarVerificacionServlet", urlPatterns = {"/SolicitarVerificacionServlet"})
@MultipartConfig(maxFileSize = 1024 * 1024 * 5)
public class SolicitarVerificacionServlet extends HttpServlet {

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
            out.println("<title>Servlet SolicitarVerificacionServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet SolicitarVerificacionServlet at " + request.getContextPath() + "</h1>");
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
        processRequest(request, response);
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
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect("login.jsp?error=notLoggedIn");
            return;
        }

        String motivo = request.getParameter("motivo");
        String contrasena = request.getParameter("contrasena"); 
        Part filePart = request.getPart("documento");
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

        PreparedStatement preparedStatement = null;

        try (Connection conn = Conexion.getConexion()) {
            String sql = "INSERT INTO verificaciones (id_usuario, motivo_solicitud, contrasena_actual, documento_verificacion) VALUES (?, ?, ?, ?)";
            preparedStatement = conn.prepareStatement(sql);
            preparedStatement.setInt(1, userId);
            preparedStatement.setString(2, motivo);
            preparedStatement.setString(3, contrasena); 
            preparedStatement.setString(4, fileName);

            int rowsAffected = preparedStatement.executeUpdate();

            if (rowsAffected > 0) {
                String uploadDirectory = getServletContext().getRealPath("/uploads");
                java.io.File uploadDir = new java.io.File(uploadDirectory);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }
                String filePath = uploadDirectory + java.io.File.separator + fileName;
                try (InputStream fileContent = filePart.getInputStream()) {
                    java.nio.file.Files.copy(fileContent, Paths.get(filePath));
                    response.sendRedirect("verificacion_exitosa.jsp");
                } catch (IOException e) {
                    System.err.println("Error saving file: " + e.getMessage());
                    response.sendRedirect("verificacion_fallida.jsp?error=fileSaveError"); 
                }
            } else {
                response.sendRedirect("verificacion_fallida.jsp?error=dbInsertFailed");
            }

        } catch (SQLException ex) {
            Logger.getLogger(SolicitarVerificacionServlet.class.getName()).log(Level.SEVERE, null, ex);
            response.sendRedirect("verificacion_fallida.jsp?error=dbError"); 
        } finally {
            if (preparedStatement != null) {
                try {
                    preparedStatement.close();
                } catch (SQLException ex) {
                    Logger.getLogger(SolicitarVerificacionServlet.class.getName()).log(Level.SEVERE, null, ex);
                }
            }
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
