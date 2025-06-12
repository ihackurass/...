/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.aquasocial.dao;

/**
 *
 * @author Home
 */

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import pe.aquasocial.entity.ClaveRecuperacion;
import pe.aquasocial.util.Conexion;

public class ClaveRecuperacionDAO implements DAO<ClaveRecuperacion> {
    
    @Override
    public int insertar(ClaveRecuperacion claveRecuperacion) throws SQLException {
        String sql = "INSERT INTO claves_recuperacion (usuario_id, clave_secreta, fecha_creacion) VALUES (?, ?, ?)";
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, claveRecuperacion.getUsuarioId());
            stmt.setString(2, claveRecuperacion.getClaveSecreta());
            stmt.setTimestamp(3, new Timestamp(System.currentTimeMillis()));
            
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
    public boolean actualizar(ClaveRecuperacion claveRecuperacion) throws SQLException {
        String sql = "UPDATE claves_recuperacion SET clave_secreta = ? WHERE id = ?";
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, claveRecuperacion.getClaveSecreta());
            stmt.setInt(2, claveRecuperacion.getId());
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    @Override
    public boolean eliminar(int id) throws SQLException {
        String sql = "DELETE FROM claves_recuperacion WHERE id = ?";
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }
    
    @Override
    public ClaveRecuperacion obtenerPorId(int id) throws SQLException {
        String sql = "SELECT * FROM claves_recuperacion WHERE id = ?";
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                ClaveRecuperacion clave = new ClaveRecuperacion();
                clave.setId(rs.getInt("id"));
                clave.setUsuarioId(rs.getInt("usuario_id"));
                clave.setClaveSecreta(rs.getString("clave_secreta"));
                clave.setFechaCreacion(rs.getTimestamp("fecha_creacion"));
                return clave;
            }
        }
        return null;
    }
    
    @Override
    public List<ClaveRecuperacion> obtenerTodos() throws SQLException {
        List<ClaveRecuperacion> lista = new ArrayList<>();
        String sql = "SELECT * FROM claves_recuperacion ORDER BY fecha_creacion DESC";
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql); 
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                ClaveRecuperacion clave = new ClaveRecuperacion();
                clave.setId(rs.getInt("id"));
                clave.setUsuarioId(rs.getInt("usuario_id"));
                clave.setClaveSecreta(rs.getString("clave_secreta"));
                clave.setFechaCreacion(rs.getTimestamp("fecha_creacion"));
                lista.add(clave);
            }
        }
        return lista;
    }
    
    // ============= MÉTODOS ESPECÍFICOS =============
    
    /**
     * Método crear para compatibilidad con el servlet (wrapper de insertar)
     * @param claveRecuperacion la clave de recuperación a crear
     * @return true si se creó exitosamente
     */
    public boolean crear(ClaveRecuperacion claveRecuperacion) throws SQLException {
        int id = insertar(claveRecuperacion);
        if (id > 0) {
            claveRecuperacion.setId(id); // Establecer el ID generado
            return true;
        }
        return false;
    }
    
    /**
     * Obtener clave de recuperación por usuario ID
     * @param usuarioId el ID del usuario
     * @return la clave de recuperación o null si no existe
     */
    public ClaveRecuperacion obtenerPorUsuarioId(int usuarioId) throws SQLException {
        String sql = "SELECT * FROM claves_recuperacion WHERE usuario_id = ? ORDER BY fecha_creacion DESC LIMIT 1";
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, usuarioId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                ClaveRecuperacion clave = new ClaveRecuperacion();
                clave.setId(rs.getInt("id"));
                clave.setUsuarioId(rs.getInt("usuario_id"));
                clave.setClaveSecreta(rs.getString("clave_secreta"));
                clave.setFechaCreacion(rs.getTimestamp("fecha_creacion"));
                return clave;
            }
        }
        return null;
    }
    
    /**
     * Verificar si una clave secreta es válida para un usuario
     * @param usuarioId el ID del usuario
     * @param claveSecreta la clave secreta a verificar
     * @return true si la clave es válida
     */
    public boolean verificarClaveSecreta(int usuarioId, String claveSecreta) throws SQLException {
        String sql = "SELECT COUNT(*) FROM claves_recuperacion WHERE usuario_id = ? AND clave_secreta = ?";
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, usuarioId);
            stmt.setString(2, claveSecreta);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
        return false;
    }
    
    /**
     * Eliminar todas las claves de recuperación de un usuario
     * @param usuarioId el ID del usuario
     * @return true si se eliminaron las claves
     */
    public boolean eliminarPorUsuarioId(int usuarioId) throws SQLException {
        String sql = "DELETE FROM claves_recuperacion WHERE usuario_id = ?";
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, usuarioId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Actualizar clave secreta de un usuario (elimina la anterior y crea una nueva)
     * @param usuarioId el ID del usuario
     * @param nuevaClaveSecreta la nueva clave secreta
     * @return true si se actualizó correctamente
     */
    public boolean actualizarClaveSecreta(int usuarioId, String nuevaClaveSecreta) throws SQLException {
        Connection conn = null;
        try {
            conn = Conexion.getConexion();
            conn.setAutoCommit(false); // Iniciar transacción
            
            // Eliminar clave anterior
            String sqlDelete = "DELETE FROM claves_recuperacion WHERE usuario_id = ?";
            try (PreparedStatement stmtDelete = conn.prepareStatement(sqlDelete)) {
                stmtDelete.setInt(1, usuarioId);
                stmtDelete.executeUpdate();
            }
            
            // Insertar nueva clave
            String sqlInsert = "INSERT INTO claves_recuperacion (usuario_id, clave_secreta, fecha_creacion) VALUES (?, ?, ?)";
            try (PreparedStatement stmtInsert = conn.prepareStatement(sqlInsert)) {
                stmtInsert.setInt(1, usuarioId);
                stmtInsert.setString(2, nuevaClaveSecreta);
                stmtInsert.setTimestamp(3, new Timestamp(System.currentTimeMillis()));
                stmtInsert.executeUpdate();
            }
            
            conn.commit(); // Confirmar transacción
            return true;
            
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback(); // Revertir transacción en caso de error
                } catch (SQLException rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // Restaurar auto-commit
                    conn.close();
                } catch (SQLException closeEx) {
                    closeEx.printStackTrace();
                }
            }
        }
    }
    
    /**
     * Obtener todas las claves de recuperación de un usuario
     * @param usuarioId el ID del usuario
     * @return lista de claves de recuperación
     */
    public List<ClaveRecuperacion> obtenerPorUsuario(int usuarioId) throws SQLException {
        List<ClaveRecuperacion> lista = new ArrayList<>();
        String sql = "SELECT * FROM claves_recuperacion WHERE usuario_id = ? ORDER BY fecha_creacion DESC";
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, usuarioId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                ClaveRecuperacion clave = new ClaveRecuperacion();
                clave.setId(rs.getInt("id"));
                clave.setUsuarioId(rs.getInt("usuario_id"));
                clave.setClaveSecreta(rs.getString("clave_secreta"));
                clave.setFechaCreacion(rs.getTimestamp("fecha_creacion"));
                lista.add(clave);
            }
        }
        return lista;
    }
    
    /**
     * Verificar si un usuario tiene clave de recuperación configurada
     * @param usuarioId el ID del usuario
     * @return true si tiene clave configurada
     */
    public boolean tieneClaveConfigurada(int usuarioId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM claves_recuperacion WHERE usuario_id = ?";
        
        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, usuarioId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
        return false;
    }
}