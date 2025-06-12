/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package pe.aquasocial.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import pe.aquasocial.dao.IngresoDAO;
import pe.aquasocial.util.Conexion;
import pe.aquasocial.entity.Ingreso;
import pe.aquasocial.entity.Usuario;

/**
 *
 * @author Home
 */
/**
 * Servlet para gestionar las operaciones relacionadas con los ingresos
 */
@WebServlet(name = "IngresosServlet", urlPatterns = {"/admin/IngresosServlet"})
public class IngresosServlet extends HttpServlet {


    /**
     * Maneja las solicitudes GET al servlet
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Verificar usuario y privilegios
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("rol"))) {
            response.sendRedirect("/LoginServlet");
            return;
        }
        String action = request.getParameter("action");

        if ("generarReporte".equals(action)) {
            generarReporte(request, response);
        } else {
            // Cargar la lista de ingresos
            List<Ingreso> ingresos = obtenerIngresos();
            request.setAttribute("ingresos", ingresos);

            // Redirigir a la página JSP
            request.getRequestDispatcher("/views/admin/ingresos.jsp").forward(request, response);
        }
    }

    /**
     * Maneja las solicitudes POST al servlet
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        // Verificar usuario y privilegios para todas las acciones excepto
        // procesar un nuevo ingreso (que podría venir de usuarios normales)
        if (!"procesarIngreso".equals(action)) {
            Usuario usuarioActual = obtenerUsuarioSesion(request);
            if (usuarioActual == null || !"admin".equals(usuarioActual.getRol())) {
                response.sendRedirect("login.jsp");
                return;
            }
        }

        switch (action) {
            case "updateEstado":
                actualizarEstadoIngreso(request, response);
                break;
            case "procesarIngreso":
                procesarIngreso(request, response);
                break;
            default:
                response.sendRedirect("IngresosServlet");
                break;
        }
    }

    /**
     * Obtiene el usuario de la sesión actual
     */
    private Usuario obtenerUsuarioSesion(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object usuarioObj = session.getAttribute("usuarioLogueado");
            if (usuarioObj instanceof Usuario) {
                return (Usuario) usuarioObj;
            }
        }
        return null;
    }

    /**
     * Obtiene todos los ingresos de la base de datos
     */
    private List<Ingreso> obtenerIngresos() {
        List<Ingreso> ingresos = new ArrayList<>();

        try (Connection conn = Conexion.getConexion()) {
            String sql = "SELECT * FROM Ingresos ORDER BY fecha_hora DESC";
            try (PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

                while (rs.next()) {
                    Ingreso ingreso = new Ingreso();
                    ingreso.setIdIngreso(rs.getInt("id_ingreso"));
                    ingreso.setIdDonador(rs.getInt("id_donador"));
                    ingreso.setIdCreador(rs.getInt("id_creador"));
                    ingreso.setIdPublicacion(rs.getInt("id_publicacion"));
                    ingreso.setCantidad(rs.getDouble("cantidad"));

                    // Convertir Timestamp a LocalDateTime
                    Timestamp timestamp = rs.getTimestamp("fecha_hora");
                    if (timestamp != null) {
                        ingreso.setFechaHora(timestamp.toLocalDateTime());
                    }

                    ingreso.setEstado(rs.getString("estado"));
                    ingreso.setMetodoPago(rs.getString("metodo_pago"));
                    ingreso.setReferenciaPago(rs.getString("referencia_pago"));

                    ingresos.add(ingreso);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return ingresos;
    }

    /**
     * Actualiza el estado de un ingreso
     */
    private void actualizarEstadoIngreso(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        try {
            int ingresoId = Integer.parseInt(request.getParameter("ingresoId"));
            String nuevoEstado = request.getParameter("estado");

            Connection conn = Conexion.getConexion();
            String sql = "UPDATE Ingresos SET estado = ? WHERE id_ingreso = ?";

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, nuevoEstado);
                stmt.setInt(2, ingresoId);

                int filasActualizadas = stmt.executeUpdate();

                if (filasActualizadas > 0) {
                    // Éxito
                    out.print("{\"success\":true,\"message\":\"Estado del ingreso actualizado correctamente.\"}");
                } else {
                    // Ninguna fila actualizada
                    out.print("{\"success\":false,\"message\":\"No se encontró el ingreso a actualizar.\"}");
                }
            } finally {
                if (conn != null) {
                    conn.close();
                }
            }
        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"message\":\"ID de ingreso no válido.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    /**
     * Procesa un nuevo ingreso
     */
    private void procesarIngreso(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int idDonador = Integer.parseInt(request.getParameter("idDonador"));
            int idCreador = Integer.parseInt(request.getParameter("idCreador"));
            int idPublicacion = 0;

            // La publicación es opcional
            String idPublicacionStr = request.getParameter("idPublicacion");
            if (idPublicacionStr != null && !idPublicacionStr.isEmpty()) {
                idPublicacion = Integer.parseInt(idPublicacionStr);
            }

            double cantidad = Double.parseDouble(request.getParameter("cantidad"));
            String metodoPago = request.getParameter("metodoPago");
            String referenciaPago = request.getParameter("referenciaPago");

            Connection conn = null;
            PreparedStatement stmt = null;

            try {
                conn = Conexion.getConexion();
                String sql = "INSERT INTO Ingresos (id_donador, id_creador, id_publicacion, cantidad, estado, metodo_pago, referencia_pago) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?)";

                stmt = conn.prepareStatement(sql);
                stmt.setInt(1, idDonador);
                stmt.setInt(2, idCreador);
                stmt.setInt(3, idPublicacion);
                stmt.setDouble(4, cantidad);
                stmt.setString(5, "Pendiente"); // Estado inicial
                stmt.setString(6, metodoPago);
                stmt.setString(7, referenciaPago);

                int filasInsertadas = stmt.executeUpdate();

                if (filasInsertadas > 0) {
                    request.getSession().setAttribute("successMessage", "¡Gracias por tu donación! El pago está siendo procesado.");
                    response.sendRedirect("home.jsp");
                } else {
                    request.getSession().setAttribute("errorMessage", "Error al procesar el pago. Por favor, inténtalo de nuevo.");
                    response.sendRedirect("home.jsp");
                }
            } finally {
                if (stmt != null) {
                    stmt.close();
                }
                if (conn != null) {
                    conn.close();
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Error: " + e.getMessage());
            response.sendRedirect("home.jsp");
        }
    }

    /**
     * Genera un reporte de ingresos
     */
    private void generarReporte(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/vnd.ms-excel");
        response.setHeader("Content-Disposition", "attachment; filename=Reporte_Ingresos.xls");

        PrintWriter out = response.getWriter();

        // Cabecera del archivo Excel
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<title>Reporte de Ingresos</title>");
        out.println("</head>");
        out.println("<body>");
        out.println("<table border='1'>");
        out.println("<tr><th>ID</th><th>Donador</th><th>Creador</th><th>Publicación</th>"
                + "<th>Cantidad</th><th>Fecha y Hora</th><th>Estado</th>"
                + "<th>Método de Pago</th><th>Referencia</th></tr>");

        // Obtener datos
        try (Connection conn = Conexion.getConexion()) {
            String sql = "SELECT i.*, "
                    + "d.username AS donador_nombre, "
                    + "c.username AS creador_nombre "
                    + "FROM Ingresos i "
                    + "LEFT JOIN usuarios d ON i.id_donador = d.id "
                    + "LEFT JOIN usuarios c ON i.id_creador = c.id "
                    + "ORDER BY i.fecha_hora DESC";

            try (PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

                while (rs.next()) {
                    out.println("<tr>");
                    out.println("<td>" + rs.getInt("id_ingreso") + "</td>");
                    out.println("<td>" + rs.getString("donador_nombre") + "</td>");
                    out.println("<td>" + rs.getString("creador_nombre") + "</td>");
                    out.println("<td>" + rs.getInt("id_publicacion") + "</td>");
                    out.println("<td>" + rs.getDouble("cantidad") + "</td>");
                    out.println("<td>" + rs.getTimestamp("fecha_hora") + "</td>");
                    out.println("<td>" + rs.getString("estado") + "</td>");
                    out.println("<td>" + rs.getString("metodo_pago") + "</td>");
                    out.println("<td>" + rs.getString("referencia_pago") + "</td>");
                    out.println("</tr>");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<tr><td colspan='9'>Error al generar el reporte: " + e.getMessage() + "</td></tr>");
        }

        out.println("</table>");
        out.println("</body>");
        out.println("</html>");
    }
}
