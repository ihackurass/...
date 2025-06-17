/*
 * DAO para gestión de notificaciones
 * Maneja todas las operaciones de base de datos relacionadas con notificaciones
 */
package pe.aquasocial.dao;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import pe.aquasocial.entity.Notificacion;
import pe.aquasocial.util.Conexion;

public class NotificacionDAO {
    
    // ===== CREAR NOTIFICACIÓN =====
    
    /**
     * Crear una nueva notificación
     */
    public boolean crear(Notificacion notificacion) {
        String sql = "INSERT INTO notificaciones (id_usuario_destino, id_usuario_origen, tipo, subtipo, " +
                    "titulo, mensaje, datos_adicionales, icono, color, es_importante) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, notificacion.getIdUsuarioDestino());
            
            if (notificacion.getIdUsuarioOrigen() != null) {
                stmt.setInt(2, notificacion.getIdUsuarioOrigen());
            } else {
                stmt.setNull(2, Types.INTEGER);
            }
            
            stmt.setString(3, notificacion.getTipo());
            stmt.setString(4, notificacion.getSubtipo());
            stmt.setString(5, notificacion.getTitulo());
            stmt.setString(6, notificacion.getMensaje());
            stmt.setString(7, notificacion.getDatosAdicionales());
            stmt.setString(8, notificacion.getIcono());
            stmt.setString(9, notificacion.getColor());
            stmt.setBoolean(10, notificacion.isEsImportante());
            
            int filasAfectadas = stmt.executeUpdate();
            
            if (filasAfectadas > 0) {
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    notificacion.setIdNotificacion(generatedKeys.getInt(1));
                }
                
                System.out.println("🔔 Notificación creada: " + notificacion.getTitulo() + 
                                 " para usuario " + notificacion.getIdUsuarioDestino());
                return true;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al crear notificación: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    // ===== OBTENER NOTIFICACIONES =====
    
    /**
     * Obtener notificaciones de un usuario con paginación
     */
    public List<Notificacion> obtenerPorUsuario(int idUsuario, int limite, int offset) {
        List<Notificacion> notificaciones = new ArrayList<>();
        
        String sql = "SELECT n.*, " +
                    "uo.nombre_completo as nombre_usuario_origen, " +
                    "uo.avatar as avatar_usuario_origen " +
                    "FROM notificaciones n " +
                    "LEFT JOIN usuarios uo ON n.id_usuario_origen = uo.id " +
                    "WHERE n.id_usuario_destino = ? " +
                    "ORDER BY n.fecha_creacion DESC " +
                    "LIMIT ? OFFSET ?";
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idUsuario);
            stmt.setInt(2, limite);
            stmt.setInt(3, offset);
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                notificaciones.add(mapearNotificacion(rs));
            }
            
            System.out.println("📋 Obtenidas " + notificaciones.size() + " notificaciones para usuario " + idUsuario);
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener notificaciones: " + e.getMessage());
            e.printStackTrace();
        }
        
        return notificaciones;
    }
    
    /**
     * Obtener notificaciones por tipo
     */
    public List<Notificacion> obtenerPorTipo(int idUsuario, String tipo, int limite) {
        List<Notificacion> notificaciones = new ArrayList<>();
        
        String sql = "SELECT n.*, " +
                    "uo.nombre_completo as nombre_usuario_origen, " +
                    "uo.avatar as avatar_usuario_origen " +
                    "FROM notificaciones n " +
                    "LEFT JOIN usuarios uo ON n.id_usuario_origen = uo.id " +
                    "WHERE n.id_usuario_destino = ? AND n.tipo = ? " +
                    "ORDER BY n.fecha_creacion DESC " +
                    "LIMIT ?";
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idUsuario);
            stmt.setString(2, tipo);
            stmt.setInt(3, limite);
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                notificaciones.add(mapearNotificacion(rs));
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener notificaciones por tipo: " + e.getMessage());
            e.printStackTrace();
        }
        
        return notificaciones;
    }
    
    /**
     * Obtener notificaciones no leídas
     */
    public List<Notificacion> obtenerNoLeidas(int idUsuario, int limite) {
        List<Notificacion> notificaciones = new ArrayList<>();
        
        String sql = "SELECT n.*, " +
                    "uo.nombre_completo as nombre_usuario_origen, " +
                    "uo.avatar as avatar_usuario_origen " +
                    "FROM notificaciones n " +
                    "LEFT JOIN usuarios uo ON n.id_usuario_origen = uo.id " +
                    "WHERE n.id_usuario_destino = ? AND n.es_leida = FALSE " +
                    "ORDER BY n.fecha_creacion DESC " +
                    "LIMIT ?";
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idUsuario);
            stmt.setInt(2, limite);
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                notificaciones.add(mapearNotificacion(rs));
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener notificaciones no leídas: " + e.getMessage());
            e.printStackTrace();
        }
        
        return notificaciones;
    }
    
    // ===== CONTAR NOTIFICACIONES =====
    
    /**
     * Contar notificaciones no leídas de un usuario
     */
    public int contarNoLeidas(int idUsuario) {
        String sql = "SELECT COUNT(*) FROM notificaciones WHERE id_usuario_destino = ? AND es_leida = FALSE";
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("🔢 Usuario " + idUsuario + " tiene " + count + " notificaciones no leídas");
                return count;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al contar notificaciones no leídas: " + e.getMessage());
            e.printStackTrace();
        }
        
        return 0;
    }
    
    /**
     * Contar total de notificaciones de un usuario
     */
    public int contarTotal(int idUsuario) {
        String sql = "SELECT COUNT(*) FROM notificaciones WHERE id_usuario_destino = ?";
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al contar notificaciones totales: " + e.getMessage());
            e.printStackTrace();
        }
        
        return 0;
    }
    
    // ===== MARCAR COMO LEÍDA =====
    
    /**
     * Marcar una notificación como leída
     */
    public boolean marcarComoLeida(int idNotificacion) {
        String sql = "UPDATE notificaciones SET es_leida = TRUE, fecha_leida = CURRENT_TIMESTAMP " +
                    "WHERE id_notificacion = ?";
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idNotificacion);
            int filasAfectadas = stmt.executeUpdate();
            
            if (filasAfectadas > 0) {
                System.out.println("✅ Notificación " + idNotificacion + " marcada como leída");
                return true;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al marcar notificación como leída: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Marcar todas las notificaciones de un usuario como leídas
     */
    public boolean marcarTodasComoLeidas(int idUsuario) {
        String sql = "UPDATE notificaciones SET es_leida = TRUE, fecha_leida = CURRENT_TIMESTAMP " +
                    "WHERE id_usuario_destino = ? AND es_leida = FALSE";
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idUsuario);
            int filasAfectadas = stmt.executeUpdate();
            
            System.out.println("✅ " + filasAfectadas + " notificaciones marcadas como leídas para usuario " + idUsuario);
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            System.err.println("❌ Error al marcar todas las notificaciones como leídas: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    // ===== ELIMINAR NOTIFICACIONES =====
    
    /**
     * Eliminar una notificación específica
     */
    public boolean eliminar(int idNotificacion) {
        String sql = "DELETE FROM notificaciones WHERE id_notificacion = ?";
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idNotificacion);
            int filasAfectadas = stmt.executeUpdate();
            
            if (filasAfectadas > 0) {
                System.out.println("🗑️ Notificación " + idNotificacion + " eliminada");
                return true;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al eliminar notificación: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Limpiar notificaciones antiguas (más de X días)
     */
    public int limpiarAntiguas(int diasAntiguedad) {
        String sql = "DELETE FROM notificaciones WHERE fecha_creacion < DATE_SUB(NOW(), INTERVAL ? DAY)";
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, diasAntiguedad);
            int filasAfectadas = stmt.executeUpdate();
            
            System.out.println("🗑️ " + filasAfectadas + " notificaciones antiguas eliminadas (+" + diasAntiguedad + " días)");
            return filasAfectadas;
            
        } catch (SQLException e) {
            System.err.println("❌ Error al limpiar notificaciones antiguas: " + e.getMessage());
            e.printStackTrace();
        }
        
        return 0;
    }
    
    // ===== MÉTODO AUXILIAR PARA MAPEAR =====
    
    /**
     * Mapear ResultSet a objeto Notificacion
     */
    private Notificacion mapearNotificacion(ResultSet rs) throws SQLException {
        Notificacion notificacion = new Notificacion();
        
        notificacion.setIdNotificacion(rs.getInt("id_notificacion"));
        notificacion.setIdUsuarioDestino(rs.getInt("id_usuario_destino"));
        
        // id_usuario_origen puede ser null
        int idOrigen = rs.getInt("id_usuario_origen");
        if (!rs.wasNull()) {
            notificacion.setIdUsuarioOrigen(idOrigen);
        }
        
        notificacion.setTipo(rs.getString("tipo"));
        notificacion.setSubtipo(rs.getString("subtipo"));
        notificacion.setTitulo(rs.getString("titulo"));
        notificacion.setMensaje(rs.getString("mensaje"));
        notificacion.setDatosAdicionales(rs.getString("datos_adicionales"));
        notificacion.setIcono(rs.getString("icono"));
        notificacion.setColor(rs.getString("color"));
        notificacion.setEsLeida(rs.getBoolean("es_leida"));
        notificacion.setEsImportante(rs.getBoolean("es_importante"));
        
        // Fechas
        Timestamp fechaCreacion = rs.getTimestamp("fecha_creacion");
        if (fechaCreacion != null) {
            notificacion.setFechaCreacion(fechaCreacion.toLocalDateTime());
        }
        
        Timestamp fechaLeida = rs.getTimestamp("fecha_leida");
        if (fechaLeida != null) {
            notificacion.setFechaLeida(fechaLeida.toLocalDateTime());
        }
        
        // Datos del usuario origen (del JOIN)
        notificacion.setNombreUsuarioOrigen(rs.getString("nombre_usuario_origen"));
        notificacion.setAvatarUsuarioOrigen(rs.getString("avatar_usuario_origen"));
        
        return notificacion;
    }
    
    // ===== MÉTODOS DE UTILIDAD ESPECÍFICOS =====
    
    /**
     * Verificar si existe una notificación específica (para evitar duplicados)
     */
    public boolean existeNotificacion(int idUsuarioDestino, String tipo, String subtipo, String datosAdicionales) {
        String sql = "SELECT COUNT(*) FROM notificaciones " +
                    "WHERE id_usuario_destino = ? AND tipo = ? AND subtipo = ? AND datos_adicionales = ? " +
                    "AND fecha_creacion > DATE_SUB(NOW(), INTERVAL 1 HOUR)"; // Solo en la última hora
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, idUsuarioDestino);
            stmt.setString(2, tipo);
            stmt.setString(3, subtipo);
            stmt.setString(4, datosAdicionales);
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al verificar notificación existente: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
}