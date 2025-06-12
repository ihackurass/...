/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.aquasocial.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import org.mindrot.jbcrypt.BCrypt;

import pe.aquasocial.entity.Usuario;
import pe.aquasocial.util.Conexion;

/**
 *
 * @author Rodrigo
 */
public class UsuarioDAO implements DAO<Usuario> {

    @Override
    public int insertar(Usuario usuario) throws SQLException {
        String sql = "INSERT INTO usuarios (username,nombre_completo, email, password, rol, verificado, privilegio, baneado) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, usuario.getUsername());
            stmt.setString(2, usuario.getNombreCompleto());
            stmt.setString(3, usuario.getEmail());

            // Encripta la contraseña 
            String hashedPassword = BCrypt.hashpw(usuario.getPassword(), BCrypt.gensalt());
            stmt.setString(4, hashedPassword);

            stmt.setString(5, usuario.getRol());
            stmt.setBoolean(6, usuario.isVerificado());
            stmt.setBoolean(7, usuario.isPrivilegio());
            stmt.setBoolean(8, usuario.isBaneado());

            int filasAfectadas = stmt.executeUpdate();

            if (filasAfectadas == 0) {
                return -1; // No se insertó nada
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                } else {
                    return -1; // No se pudo obtener el ID generado
                }
            }
        }
    }

    @Override
    public boolean actualizar(Usuario usuario) throws SQLException {
        String sql = "UPDATE usuarios SET username = ?, email = ?, password = ?, rol = ?, verificado = ?, privilegio = ?, baneado = ? WHERE id = ?";
        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, usuario.getUsername());
            stmt.setString(2, usuario.getEmail());
            stmt.setString(3, usuario.getPassword());
            stmt.setString(4, usuario.getRol());
            stmt.setBoolean(5, usuario.isVerificado());
            stmt.setBoolean(6, usuario.isPrivilegio());
            stmt.setBoolean(7, usuario.isBaneado());
            stmt.setInt(8, usuario.getId());

            return stmt.executeUpdate() > 0;
        }
    }

    @Override
    public boolean eliminar(int id) throws SQLException {
        // borrado lógico: marcar como baneado y anonimizar
        String sql = "UPDATE usuarios SET baneado = TRUE, verificado = FALSE, privilegio = FALSE, solicito_verificacion = FALSE, "
                + "username = CONCAT('usuario_eliminado_', id), email = CONCAT('eliminado_', id, '@ejemplo.com'), password = MD5(RAND()) "
                + "WHERE id = ?";
        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    @Override
    public Usuario obtenerPorId(int id) throws SQLException {
        String sql = "SELECT * FROM usuarios WHERE id = ?";
        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                Usuario usuario = new Usuario();
                usuario.setId(rs.getInt("id"));
                usuario.setUsername(rs.getString("username"));
                usuario.setNombreCompleto(rs.getString("nombre_completo")); // Campo nuevo
                usuario.setEmail(rs.getString("email"));
                usuario.setPassword(rs.getString("password"));
                usuario.setRol(rs.getString("rol"));
                usuario.setAvatar(rs.getString("avatar"));
                usuario.setVerificado(rs.getBoolean("verificado"));
                usuario.setPrivilegio(rs.getBoolean("privilegio"));
                usuario.setBaneado(rs.getBoolean("baneado"));
                usuario.setSolicitoVerificacion(rs.getBoolean("solicito_verificacion"));
                usuario.setTelefono(rs.getString("telefono"));
                usuario.setIntentosFallidos(rs.getInt("intentos_fallidos"));
                usuario.setBloqueHasta(rs.getTimestamp("bloqueo_hasta"));
                usuario.setFechaRegistro(rs.getTimestamp("fecha_registro"));
                return usuario;
            }
        }
        return null;
    }

    @Override
    public List<Usuario> obtenerTodos() throws SQLException {
        List<Usuario> lista = new ArrayList<>();
        String sql = "SELECT * FROM usuarios";
        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Usuario usuario = new Usuario();
                usuario.setId(rs.getInt("id"));
                usuario.setUsername(rs.getString("username"));
                usuario.setEmail(rs.getString("email"));
                usuario.setPassword(rs.getString("password"));
                usuario.setRol(rs.getString("rol"));
                usuario.setVerificado(rs.getBoolean("verificado"));
                usuario.setPrivilegio(rs.getBoolean("privilegio"));
                usuario.setBaneado(rs.getBoolean("baneado"));
                lista.add(usuario);
            }
        }
        return lista;
    }

    public int obtenerIdPorUsername(String username) throws SQLException {
        String sql = "SELECT id FROM usuarios WHERE username = ?";
        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("id");
            } else {
                throw new SQLException("No se encontró el usuario.");
            }
        }
    }

    public boolean existeUsername(String username) throws SQLException {
        String sql = "SELECT COUNT(*) FROM usuarios WHERE username = ?";
        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    public boolean verificarUsuarioYClaveSecreta(String username, String claveSecreta) throws SQLException {
        String sql = "SELECT u.id FROM usuarios u "
                + "INNER JOIN claves_recuperacion cr ON u.id = cr.usuario_id "
                + "WHERE u.username = ? AND cr.clave_secreta = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username);
            stmt.setString(2, claveSecreta);

            ResultSet rs = stmt.executeQuery();
            return rs.next();
        }
    }

    public boolean actualizarPassword(String username, String nuevaPassword) throws SQLException {
        String sql = "UPDATE usuarios SET password = ? WHERE username = ?";
        String hashedPassword = BCrypt.hashpw(nuevaPassword, BCrypt.gensalt());

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, hashedPassword);
            stmt.setString(2, username);
            int filasActualizadas = stmt.executeUpdate();
            return filasActualizadas > 0;
        }
    }

    public boolean isEmailDisponible(String email) {
        String sql = "SELECT COUNT(*) FROM usuarios WHERE email = ?";
        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) == 0; // True si no existe
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isBanned(int userId) {
        String sql = "SELECT baneado FROM usuarios WHERE id = ?";
        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            java.sql.ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getBoolean("baneado");
            }
        } catch (Exception e) {
            System.err.println("❌ Error al verificar estado de ban en CheckSessionServlet: " + e.getMessage());
            e.printStackTrace();
        }

        return false; // Por defecto, no baneado si hay error
    }
}
