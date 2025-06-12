/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.aquasocial.dao;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import pe.aquasocial.dao.ILikeDAO;
import pe.aquasocial.entity.Like;
import pe.aquasocial.util.Conexion;

public class LikeDAO implements ILikeDAO {
    
    @Override
    public boolean crear(Like like) {
        String sql = "INSERT INTO likes (id_publicacion, id_usuario, fecha_like) VALUES (?, ?, ?)";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, like.getIdPublicacion());
            stmt.setInt(2, like.getIdUsuario());
            stmt.setTimestamp(3, Timestamp.valueOf(like.getFechaLike()));
            
            int filasAfectadas = stmt.executeUpdate();
            
            if (filasAfectadas > 0) {
                // Obtener el ID generado
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    like.setIdLike(rs.getInt(1));
                }
                System.out.println("✅ Like creado con ID: " + like.getIdLike());
                return true;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al crear like: " + e.getMessage());
            // Si es error de duplicado (UNIQUE constraint), no es realmente un error
            if (e.getErrorCode() == 1062) { // MySQL duplicate entry error
                System.out.println("⚠️ Usuario ya dio like a esta publicación");
                return false;
            }
            e.printStackTrace();
        }
        return false;
    }
    
    @Override
    public Like obtenerPorId(int idLike) {
        String sql = "SELECT * FROM likes WHERE id_like = ?";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idLike);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapearLike(rs);
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener like por ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    @Override
    public List<Like> obtenerTodos() {
        List<Like> likes = new ArrayList<>();
        String sql = "SELECT * FROM likes ORDER BY fecha_like DESC";
        
        try (Connection conn = Conexion.getConexion();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                likes.add(mapearLike(rs));
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener todos los likes: " + e.getMessage());
            e.printStackTrace();
        }
        return likes;
    }
    
    @Override
    public boolean eliminar(int idLike) {
        String sql = "DELETE FROM likes WHERE id_like = ?";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idLike);
            int filasAfectadas = stmt.executeUpdate();
            
            System.out.println("✅ Like eliminado: " + filasAfectadas + " filas afectadas");
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Error al eliminar like: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    @Override
    public int contarPorPublicacion(int idPublicacion) {
        String sql = "SELECT COUNT(*) FROM likes WHERE id_publicacion = ?";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idPublicacion);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                int contador = rs.getInt(1);
                System.out.println("📊 Publicación " + idPublicacion + " tiene " + contador + " likes");
                return contador;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al contar likes por publicación: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
    
    @Override
    public boolean usuarioYaDioLike(int idPublicacion, int idUsuario) {
        String sql = "SELECT COUNT(*) FROM likes WHERE id_publicacion = ? AND id_usuario = ?";

        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            // ✅ CONFIGURAR PARÁMETROS PRIMERO
            stmt.setInt(1, idPublicacion);
            stmt.setInt(2, idUsuario);

            // ✅ DESPUÉS EJECUTAR Y USAR TRY-WITH-RESOURCES PARA RS
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    boolean yaDioLike = rs.getInt(1) > 0;
                    System.out.println("🔍 Usuario " + idUsuario + " ya dio like a publicación " + idPublicacion + ": " + yaDioLike);
                    return yaDioLike;
                }
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al verificar si usuario ya dio like: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    @Override
    public boolean darLike(int idPublicacion, int idUsuario) {
        // Verificar si ya dio like
        if (usuarioYaDioLike(idPublicacion, idUsuario)) {
            System.out.println("⚠️ Usuario " + idUsuario + " ya dio like a publicación " + idPublicacion);
            return false;
        }
        
        // Crear nuevo like
        Like nuevoLike = new Like(idPublicacion, idUsuario);
        boolean resultado = crear(nuevoLike);
        
        if (resultado) {
            System.out.println("❤️ Usuario " + idUsuario + " dio like a publicación " + idPublicacion);
        }
        
        return resultado;
    }
    
    @Override
    public boolean quitarLike(int idPublicacion, int idUsuario) {
        String sql = "DELETE FROM likes WHERE id_publicacion = ? AND id_usuario = ?";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idPublicacion);
            stmt.setInt(2, idUsuario);
            int filasAfectadas = stmt.executeUpdate();
            
            if (filasAfectadas > 0) {
                System.out.println("💔 Usuario " + idUsuario + " quitó like de publicación " + idPublicacion);
                return true;
            } else {
                System.out.println("⚠️ No se encontró like para quitar");
                return false;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al quitar like: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    @Override
    public List<Like> obtenerPorPublicacion(int idPublicacion) {
        List<Like> likes = new ArrayList<>();
        String sql = "SELECT * FROM likes WHERE id_publicacion = ? ORDER BY fecha_like DESC";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idPublicacion);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                likes.add(mapearLike(rs));
            }
            
            System.out.println("📋 Obtenidos " + likes.size() + " likes para publicación " + idPublicacion);
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener likes por publicación: " + e.getMessage());
            e.printStackTrace();
        }
        return likes;
    }
    
    @Override
    public List<Like> obtenerPorUsuario(int idUsuario) {
        List<Like> likes = new ArrayList<>();
        String sql = "SELECT l.*, p.texto as texto_publicacion FROM likes l " +
                    "LEFT JOIN publicaciones p ON l.id_publicacion = p.id_publicacion " +
                    "WHERE l.id_usuario = ? ORDER BY l.fecha_like DESC";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                likes.add(mapearLike(rs));
            }
            
            System.out.println("📋 Usuario " + idUsuario + " ha dado " + likes.size() + " likes");
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener likes por usuario: " + e.getMessage());
            e.printStackTrace();
        }
        return likes;
    }
    
    @Override
    public boolean eliminarPorPublicacionYUsuario(int idPublicacion, int idUsuario) {
        return quitarLike(idPublicacion, idUsuario);
    }
    
    // ========== MÉTODOS AUXILIARES ==========
    
    private Like mapearLike(ResultSet rs) throws SQLException {
        Like like = new Like();
        like.setIdLike(rs.getInt("id_like"));
        like.setIdPublicacion(rs.getInt("id_publicacion"));
        like.setIdUsuario(rs.getInt("id_usuario"));
        
        Timestamp timestamp = rs.getTimestamp("fecha_like");
        if (timestamp != null) {
            like.setFechaLike(timestamp.toLocalDateTime());
        }
        
        return like;
    }
    
    // ========== MÉTODOS ADICIONALES PARA ESTADÍSTICAS ==========
    
    public int contarTotalLikes() {
        String sql = "SELECT COUNT(*) FROM likes";
        
        try (Connection conn = Conexion.getConexion();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al contar total de likes: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
    
    public List<Object[]> obtenerPublicacionesMasLikeadas(int limite) {
        List<Object[]> publicaciones = new ArrayList<>();
        String sql = "SELECT p.id_publicacion, p.texto, u.username, COUNT(l.id_like) as total_likes " +
                    "FROM publicaciones p " +
                    "LEFT JOIN likes l ON p.id_publicacion = l.id_publicacion " +
                    "LEFT JOIN usuarios u ON p.id_usuario = u.id " +
                    "WHERE p.esta_aprobado = TRUE " +
                    "GROUP BY p.id_publicacion, p.texto, u.username " +
                    "ORDER BY total_likes DESC " +
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
                    rs.getInt("total_likes")
                };
                publicaciones.add(datos);
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener publicaciones más likeadas: " + e.getMessage());
            e.printStackTrace();
        }
        return publicaciones;
    }
    
    public boolean toggleLike(int idPublicacion, int idUsuario) {
        if (usuarioYaDioLike(idPublicacion, idUsuario)) {
            return quitarLike(idPublicacion, idUsuario);
        } else {
            return darLike(idPublicacion, idUsuario);
        }
    }
}