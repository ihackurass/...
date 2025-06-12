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
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import pe.aquasocial.entity.Publicacion;
import pe.aquasocial.entity.Usuario;

import pe.aquasocial.util.Conexion;

/**
 *
 * @author Home
 */
/**
 * Servlet para gestionar las operaciones CRUD de publicaciones
 *
 */
@WebServlet(name = "PublicacionesServlet", urlPatterns = {"/admin/PublicacionesServlet"})
public class PublicacionesServlet extends HttpServlet {

    /**
     * Maneja las solicitudes GET al servlet
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("rol"))) {
            response.sendRedirect("../LoginServlet");
            return;
        }

        try {
            // Obtener datos (puedes reemplazar por llamadas a DAO si tienes)
            List<Publicacion> publicaciones = obtenerPublicaciones();
            request.setAttribute("publicaciones", publicaciones);

            List<Usuario> usuarios = obtenerUsuarios();
            request.setAttribute("usuarios", usuarios);

            request.getRequestDispatcher("/views/admin/publicaciones.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error al cargar datos.");
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

        switch (action) {
            case "update":
                actualizarPublicacion(request, response);
                break;
            case "delete":
                eliminarPublicacion(request, response);
                break;
            case "aprobar":
                aprobarPublicacion(request, response);
                break;
            default:
                response.sendRedirect("PublicacionesServlet");
                break;
        }
    }

    /**
     * Obtiene todas las publicaciones de la base de datos
     *
     * @return Lista de publicaciones
     */
    private List<Publicacion> obtenerPublicaciones() {
        List<Publicacion> publicaciones = new ArrayList<>();

        try (Connection conn = Conexion.getConexion()) {
            String sql = "SELECT * FROM Publicaciones ORDER BY fecha_publicacion DESC";
            try (PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

                while (rs.next()) {
                    Publicacion publicacion = new Publicacion();
                    publicacion.setIdPublicacion(rs.getInt("id_publicacion"));
                    publicacion.setIdUsuario(rs.getInt("id_usuario"));
                    publicacion.setTexto(rs.getString("texto"));
                    publicacion.setImagenUrl(rs.getString("imagen_url"));
                    publicacion.setPermiteDonacion(rs.getBoolean("permite_donacion"));
                    publicacion.setEstaAprobado(rs.getBoolean("esta_aprobado"));

                    // Convertir Timestamp a LocalDateTime
                    Timestamp timestamp = rs.getTimestamp("fecha_publicacion");
                    if (timestamp != null) {
                        publicacion.setFechaPublicacion(timestamp.toLocalDateTime());
                    }

                    publicaciones.add(publicacion);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return publicaciones;
    }

    /**
     * Obtiene la lista de usuarios para mostrar los nombres
     *
     * @return Lista de usuarios
     */
    private List<Usuario> obtenerUsuarios() {
        List<Usuario> usuarios = new ArrayList<>();

        try (Connection conn = Conexion.getConexion()) {
            String sql = "SELECT id, username FROM usuarios";
            try (PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

                while (rs.next()) {
                    Usuario usuario = new Usuario();
                    usuario.setId(rs.getInt("id"));
                    usuario.setUsername(rs.getString("username"));
                    usuarios.add(usuario);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return usuarios;
    }

    /**
     * Actualiza una publicación existente
     */
    private void actualizarPublicacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        try {
            int publicacionId = Integer.parseInt(request.getParameter("publicacionId"));
            String texto = request.getParameter("texto");
            String imagenUrl = request.getParameter("imagenUrl");
            boolean permiteDonacion = Boolean.parseBoolean(request.getParameter("permiteDonacion"));
            boolean estaAprobado = Boolean.parseBoolean(request.getParameter("estaAprobado"));

            Connection conn = Conexion.getConexion();
            String sql = "UPDATE Publicaciones SET texto = ?, imagen_url = ?, permite_donacion = ?, esta_aprobado = ? WHERE id_publicacion = ?";

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, texto);
                stmt.setString(2, imagenUrl);
                stmt.setBoolean(3, permiteDonacion);
                stmt.setBoolean(4, estaAprobado);
                stmt.setInt(5, publicacionId);

                int filasActualizadas = stmt.executeUpdate();

                if (filasActualizadas > 0) {
                    // Éxito
                    out.print("{\"success\":true,\"message\":\"Publicación actualizada correctamente.\"}");
                } else {
                    // Ninguna fila actualizada
                    out.print("{\"success\":false,\"message\":\"No se encontró la publicación a actualizar.\"}");
                }
            } finally {
                if (conn != null) {
                    conn.close();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    /**
     * Elimina una publicación
     */
    private void eliminarPublicacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int publicacionId = Integer.parseInt(request.getParameter("publicacionId"));
        boolean esUsuarioEliminado = Boolean.parseBoolean(request.getParameter("esUsuarioEliminado"));

        try (Connection conn = Conexion.getConexion()) {
            String sql = "DELETE FROM Publicaciones WHERE id_publicacion = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, publicacionId);
                int filasEliminadas = stmt.executeUpdate();

                if (filasEliminadas > 0) {
                    // Mensaje de éxito según el tipo de eliminación
                    String mensaje = "Publicación eliminada correctamente.";
                    if (esUsuarioEliminado) {
                        mensaje = "Publicación de usuario eliminado borrada correctamente.";
                    }
                    request.getSession().setAttribute("successMessage", mensaje);
                } else {
                    request.setAttribute("errorMessage", "No se encontró la publicación a eliminar.");
                }

                response.sendRedirect("PublicacionesServlet");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error al eliminar la publicación: " + e.getMessage());
            doGet(request, response);
        }
    }

    /**
     * Aprueba una publicación
     */
    private void aprobarPublicacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int publicacionId = Integer.parseInt(request.getParameter("publicacionId"));

        try (Connection conn = Conexion.getConexion()) {
            String sql = "UPDATE Publicaciones SET esta_aprobado = true WHERE id_publicacion = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, publicacionId);
                stmt.executeUpdate();
            }

            response.sendRedirect("PublicacionesServlet");
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al aprobar la publicación: " + e.getMessage());
            doGet(request, response);
        }
    }
}
