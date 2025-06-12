/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.aquasocial.dao;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import pe.aquasocial.dao.IComentarioDAO;
import pe.aquasocial.entity.Comentario;
import pe.aquasocial.util.Conexion;

public class ComentarioDAO implements IComentarioDAO {
    
    @Override
    public boolean crear(Comentario comentario) {
        String sql = "INSERT INTO comentarios (id_publicacion, id_usuario, contenido, fecha_comentario) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, comentario.getIdPublicacion());
            stmt.setInt(2, comentario.getIdUsuario());
            stmt.setString(3, comentario.getContenido());
            stmt.setTimestamp(4, Timestamp.valueOf(comentario.getFechaComentario()));
            
            int filasAfectadas = stmt.executeUpdate();
            
            if (filasAfectadas > 0) {
                // Obtener el ID generado
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    comentario.setIdComentario(rs.getInt(1));
                }
                System.out.println("✅ Comentario creado con ID: " + comentario.getIdComentario());
                return true;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al crear comentario: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    @Override
    public Comentario obtenerPorId(int idComentario) {
        String sql = "SELECT c.*, u.username, u.avatar FROM comentarios c " +
                    "LEFT JOIN usuarios u ON c.id_usuario = u.id " +
                    "WHERE c.id_comentario = ?";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idComentario);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapearComentario(rs);
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener comentario por ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    @Override
    public List<Comentario> obtenerTodos() {
        List<Comentario> comentarios = new ArrayList<>();
        String sql = "SELECT c.*, u.username, u.avatar FROM comentarios c " +
                    "LEFT JOIN usuarios u ON c.id_usuario = u.id " +
                    "ORDER BY c.fecha_comentario DESC";
        
        try (Connection conn = Conexion.getConexion();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                comentarios.add(mapearComentario(rs));
            }
            
            System.out.println("📋 Obtenidos " + comentarios.size() + " comentarios totales");
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener todos los comentarios: " + e.getMessage());
            e.printStackTrace();
        }
        return comentarios;
    }
    
    @Override
    public boolean actualizar(Comentario comentario) {
        String sql = "UPDATE comentarios SET contenido = ? WHERE id_comentario = ?";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, comentario.getContenido());
            stmt.setInt(2, comentario.getIdComentario());
            
            int filasAfectadas = stmt.executeUpdate();
            System.out.println("✅ Comentario actualizado: " + filasAfectadas + " filas afectadas");
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar comentario: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    @Override
    public boolean eliminar(int idComentario) {
        String sql = "DELETE FROM comentarios WHERE id_comentario = ?";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idComentario);
            int filasAfectadas = stmt.executeUpdate();
            
            System.out.println("✅ Comentario eliminado: " + filasAfectadas + " filas afectadas");
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Error al eliminar comentario: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    @Override
    public List<Comentario> obtenerPorPublicacion(int idPublicacion) {
        List<Comentario> comentarios = new ArrayList<>();
        String sql = "SELECT c.*, u.username, u.avatar FROM comentarios c " +
                    "LEFT JOIN usuarios u ON c.id_usuario = u.id " +
                    "WHERE c.id_publicacion = ? " +
                    "ORDER BY c.fecha_comentario ASC";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idPublicacion);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                comentarios.add(mapearComentario(rs));
            }
            
            System.out.println("💬 Obtenidos " + comentarios.size() + " comentarios para publicación " + idPublicacion);
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener comentarios por publicación: " + e.getMessage());
            e.printStackTrace();
        }
        return comentarios;
    }
    
    @Override
    public List<Comentario> obtenerPorUsuario(int idUsuario) {
        List<Comentario> comentarios = new ArrayList<>();
        String sql = "SELECT c.*, u.username, u.avatar, p.texto as texto_publicacion FROM comentarios c " +
                    "LEFT JOIN usuarios u ON c.id_usuario = u.id " +
                    "LEFT JOIN publicaciones p ON c.id_publicacion = p.id_publicacion " +
                    "WHERE c.id_usuario = ? " +
                    "ORDER BY c.fecha_comentario DESC";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                comentarios.add(mapearComentario(rs));
            }
            
            System.out.println("👤 Usuario " + idUsuario + " ha hecho " + comentarios.size() + " comentarios");
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener comentarios por usuario: " + e.getMessage());
            e.printStackTrace();
        }
        return comentarios;
    }
    
    @Override
    public int contarPorPublicacion(int idPublicacion) {
        String sql = "SELECT COUNT(*) FROM comentarios WHERE id_publicacion = ?";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idPublicacion);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                int contador = rs.getInt(1);
                System.out.println("📊 Publicación " + idPublicacion + " tiene " + contador + " comentarios");
                return contador;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al contar comentarios por publicación: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
    
    @Override
    public int contarPorUsuario(int idUsuario) {
        String sql = "SELECT COUNT(*) FROM comentarios WHERE id_usuario = ?";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                int contador = rs.getInt(1);
                System.out.println("📊 Usuario " + idUsuario + " ha hecho " + contador + " comentarios");
                return contador;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al contar comentarios por usuario: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
    
    @Override
    public List<Comentario> obtenerRecientes(int limite) {
        List<Comentario> comentarios = new ArrayList<>();
        String sql = "SELECT c.*, u.username, u.avatar, p.texto as texto_publicacion FROM comentarios c " +
                    "LEFT JOIN usuarios u ON c.id_usuario = u.id " +
                    "LEFT JOIN publicaciones p ON c.id_publicacion = p.id_publicacion " +
                    "WHERE p.esta_aprobado = TRUE " +
                    "ORDER BY c.fecha_comentario DESC " +
                    "LIMIT ?";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, limite);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                comentarios.add(mapearComentario(rs));
            }
            
            System.out.println("🕒 Obtenidos " + comentarios.size() + " comentarios recientes");
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener comentarios recientes: " + e.getMessage());
            e.printStackTrace();
        }
        return comentarios;
    }
    
    @Override
    public boolean eliminarPorPublicacion(int idPublicacion) {
        String sql = "DELETE FROM comentarios WHERE id_publicacion = ?";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idPublicacion);
            int filasAfectadas = stmt.executeUpdate();
            
            System.out.println("🗑️ Eliminados " + filasAfectadas + " comentarios de publicación " + idPublicacion);
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Error al eliminar comentarios por publicación: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    @Override
    public List<Comentario> buscarPorTexto(String texto) {
        List<Comentario> comentarios = new ArrayList<>();
        String sql = "SELECT c.*, u.username, u.avatar FROM comentarios c " +
                    "LEFT JOIN usuarios u ON c.id_usuario = u.id " +
                    "LEFT JOIN publicaciones p ON c.id_publicacion = p.id_publicacion " +
                    "WHERE p.esta_aprobado = TRUE AND LOWER(c.contenido) LIKE LOWER(?) " +
                    "ORDER BY c.fecha_comentario DESC";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, "%" + texto + "%");
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                comentarios.add(mapearComentario(rs));
            }
            
            System.out.println("🔍 Encontrados " + comentarios.size() + " comentarios que contienen: '" + texto + "'");
            
        } catch (SQLException e) {
            System.err.println("❌ Error al buscar comentarios por texto: " + e.getMessage());
            e.printStackTrace();
        }
        return comentarios;
    }
    
    // ========== MÉTODOS AUXILIARES ==========
    
    private Comentario mapearComentario(ResultSet rs) throws SQLException {
        Comentario comentario = new Comentario();
        comentario.setIdComentario(rs.getInt("id_comentario"));
        comentario.setIdPublicacion(rs.getInt("id_publicacion"));
        comentario.setIdUsuario(rs.getInt("id_usuario"));
        comentario.setContenido(rs.getString("contenido"));
        
        Timestamp timestamp = rs.getTimestamp("fecha_comentario");
        if (timestamp != null) {
            comentario.setFechaComentario(timestamp.toLocalDateTime());
        }
        
        // Datos del usuario (pueden ser null si el usuario fue eliminado)
        String username = rs.getString("username");
        if (username != null) {
            comentario.setNombreUsuario(username);
            comentario.setUsernameUsuario("@" + username);
            comentario.setAvatarUsuario(rs.getString("avatar"));
        } else {
            // Usuario eliminado - mostrar datos por defecto
            comentario.setNombreUsuario("Usuario eliminado");
            comentario.setUsernameUsuario("@eliminado");
            comentario.setAvatarUsuario("assets/images/avatars/default.png");
        }
        
        return comentario;
    }
    
    // ========== MÉTODOS ADICIONALES PARA ESTADÍSTICAS ==========
    
    public int contarTotalComentarios() {
        String sql = "SELECT COUNT(*) FROM comentarios";
        
        try (Connection conn = Conexion.getConexion();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al contar total de comentarios: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
    
    public List<Object[]> obtenerPublicacionesMasComentadas(int limite) {
        List<Object[]> publicaciones = new ArrayList<>();
        String sql = "SELECT p.id_publicacion, p.texto, u.username, COUNT(c.id_comentario) as total_comentarios " +
                    "FROM publicaciones p " +
                    "LEFT JOIN comentarios c ON p.id_publicacion = c.id_publicacion " +
                    "LEFT JOIN usuarios u ON p.id_usuario = u.id " +
                    "WHERE p.esta_aprobado = TRUE " +
                    "GROUP BY p.id_publicacion, p.texto, u.username " +
                    "ORDER BY total_comentarios DESC " +
                    "LIMIT ?";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, limite);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Object[] datos = {
                    rs.getInt("id_publicacion"),
                    rs.getString("texto"),
                    rs.getString("username"),
                    rs.getInt("total_comentarios")
                };
                publicaciones.add(datos);
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener publicaciones más comentadas: " + e.getMessage());
            e.printStackTrace();
        }
        return publicaciones;
    }
    
    public List<Object[]> obtenerUsuariosMasActivos(int limite) {
        List<Object[]> usuarios = new ArrayList<>();
        String sql = "SELECT u.id, u.username, u.avatar, COUNT(c.id_comentario) as total_comentarios " +
                    "FROM usuarios u " +
                    "LEFT JOIN comentarios c ON u.id = c.id_usuario " +
                    "GROUP BY u.id, u.username, u.avatar " +
                    "ORDER BY total_comentarios DESC " +
                    "LIMIT ?";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, limite);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Object[] datos = {
                    rs.getInt("id"),
                    rs.getString("username"),
                    rs.getString("avatar"),
                    rs.getInt("total_comentarios")
                };
                usuarios.add(datos);
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener usuarios más activos: " + e.getMessage());
            e.printStackTrace();
        }
        return usuarios;
    }
}