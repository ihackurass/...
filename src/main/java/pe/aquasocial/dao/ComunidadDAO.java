/*
 * DAO para gestión de Comunidades
 * Compatible con agua_bendita_db
 */
package pe.aquasocial.dao;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import pe.aquasocial.entity.Comunidad;
import pe.aquasocial.entity.ComunidadMiembro;
import pe.aquasocial.entity.SolicitudMembresia;
import pe.aquasocial.util.Conexion;

public class ComunidadDAO implements IComunidadDAO {

    // ============= CRUD BÁSICO DE COMUNIDADES =============
    /**
     * Crear nueva comunidad
     */
    public boolean crear(Comunidad comunidad) {
        String sql = "INSERT INTO comunidades (nombre, comunidad_username, descripcion, imagen_url, id_creador, es_publica) VALUES (?,? ,?, ?, ?, ?)";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, comunidad.getNombre().trim());
            stmt.setString(2, comunidad.getUsername().trim());
            stmt.setString(3, comunidad.getDescripcion().trim());
            stmt.setString(4, comunidad.getImagenUrl());
            stmt.setInt(5, comunidad.getIdCreador());
            stmt.setBoolean(6, comunidad.isEsPublica());

            int filasAfectadas = stmt.executeUpdate();

            if (filasAfectadas > 0) {
                // Obtener ID generado
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    comunidad.setIdComunidad(rs.getInt(1));
                }

                // El creador se convierte automáticamente en admin
                agregarMiembro(comunidad.getIdComunidad(), comunidad.getIdCreador(), ComunidadMiembro.ROL_ADMIN);

                System.out.println("✅ Comunidad creada: " + comunidad.getNombre() + " (ID: " + comunidad.getIdComunidad() + ")");
                return true;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al crear comunidad: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Obtener comunidad por ID
     */
    public Comunidad obtenerPorId(int idComunidad) {
        String sql = "SELECT c.*, u.username as username_creador, u.nombre_completo as nombre_creador, u.avatar as avatar_creador "
                + "FROM comunidades c "
                + "LEFT JOIN usuarios u ON c.id_creador = u.id "
                + "WHERE c.id_comunidad = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idComunidad);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return mapearComunidad(rs);
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener comunidad por ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Obtener todas las comunidades públicas
     */
    public List<Comunidad> obtenerTodas() {
        List<Comunidad> comunidades = new ArrayList<>();
        String sql = "SELECT c.*, u.username as username_creador, u.nombre_completo as nombre_creador, u.avatar as avatar_creador "
                + "FROM comunidades c "
                + "LEFT JOIN usuarios u ON c.id_creador = u.id "
                //+ "WHERE c.es_publica = TRUE "
                + "ORDER BY c.seguidores_count DESC, c.fecha_creacion DESC";

        try (Connection conn = Conexion.getConexion(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                comunidades.add(mapearComunidad(rs));
            }

            System.out.println("📋 Obtenidas " + comunidades.size() + " comunidades");

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener todas las comunidades: " + e.getMessage());
            e.printStackTrace();
        }
        return comunidades;
    }

    /**
     * Actualizar comunidad (solo para creadores)
     */
    public boolean actualizar(Comunidad comunidad) {
        String sql = "UPDATE comunidades SET nombre = ?, descripcion = ?, imagen_url = ?, es_publica = ? WHERE id_comunidad = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, comunidad.getNombre().trim());
            stmt.setString(2, comunidad.getDescripcion().trim());
            stmt.setString(3, comunidad.getImagenUrl());
            stmt.setBoolean(4, comunidad.isEsPublica());
            stmt.setInt(5, comunidad.getIdComunidad());

            int filasAfectadas = stmt.executeUpdate();
            System.out.println("✅ Comunidad actualizada: " + filasAfectadas + " filas afectadas");
            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar comunidad: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Eliminar comunidad (solo para creadores o admin sistema)
     */
    public boolean eliminar(int idComunidad) {
        String sql = "DELETE FROM comunidades WHERE id_comunidad = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idComunidad);
            int filasAfectadas = stmt.executeUpdate();

            System.out.println("✅ Comunidad eliminada: " + filasAfectadas + " filas afectadas");
            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.err.println("❌ Error al eliminar comunidad: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public boolean verificarUsernameDisponible(String username) {
        String usernameNormalizado = username.toLowerCase().trim();

        String sqlUsuarios = "SELECT COUNT(*) FROM usuarios WHERE LOWER(username) = ?";

        String sqlComunidades = "SELECT COUNT(*) FROM comunidades WHERE LOWER(comunidad_username) = ?";

        try (Connection conn = Conexion.getConexion()) {

            try (PreparedStatement stmtUsuarios = conn.prepareStatement(sqlUsuarios)) {
                stmtUsuarios.setString(1, usernameNormalizado);
                ResultSet rsUsuarios = stmtUsuarios.executeQuery();

                if (rsUsuarios.next() && rsUsuarios.getInt(1) > 0) {
                    System.out.println("❌ Username '" + username + "' ya existe como usuario");
                    return false;
                }
            }

            try (PreparedStatement stmtComunidades = conn.prepareStatement(sqlComunidades)) {
                stmtComunidades.setString(1, usernameNormalizado);
                ResultSet rsComunidades = stmtComunidades.executeQuery();

                if (rsComunidades.next() && rsComunidades.getInt(1) > 0) {
                    System.out.println("❌ Username '" + username + "' ya existe como comunidad");
                    return false;
                }
            }

            System.out.println("✅ Username '" + username + "' está disponible globalmente");
            return true;

        } catch (SQLException e) {
            System.err.println("❌ Error al verificar username globalmente: " + e.getMessage());
            e.printStackTrace();
        }

        // En caso de error, asumir que no está disponible por seguridad
        return false;
    }

    // ============= GESTIÓN DE MEMBRESÍAS =============
    /**
     * Agregar miembro a comunidad
     */
    public boolean agregarMiembro(int idComunidad, int idUsuario, String rol) {
        String sql = "INSERT INTO comunidad_miembros (id_comunidad, id_usuario, rol) VALUES (?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE rol = VALUES(rol)";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idComunidad);
            stmt.setInt(2, idUsuario);
            stmt.setString(3, rol);

            int filasAfectadas = stmt.executeUpdate();

            if (filasAfectadas > 0) {
                actualizarContadorSeguidores(idComunidad);
                System.out.println("✅ Usuario " + idUsuario + " agregado como " + rol + " a comunidad " + idComunidad);
                return true;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al agregar miembro: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Seguir comunidad (como seguidor)
     */
    public boolean seguirComunidad(int idUsuario, int idComunidad) {
        return agregarMiembro(idComunidad, idUsuario, ComunidadMiembro.ROL_SEGUIDOR);
    }

    /**
     * Dejar de seguir comunidad
     */
    public boolean dejarDeSeguir(int idUsuario, int idComunidad) {
        String sql = "DELETE FROM comunidad_miembros WHERE id_comunidad = ? AND id_usuario = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idComunidad);
            stmt.setInt(2, idUsuario);

            int filasAfectadas = stmt.executeUpdate();

            if (filasAfectadas > 0) {
                actualizarContadorSeguidores(idComunidad);
                System.out.println("✅ Usuario " + idUsuario + " dejó de seguir comunidad " + idComunidad);
                return true;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al dejar de seguir: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Promover seguidor a admin
     */
    public boolean promoverAAdmin(int idUsuario, int idComunidad) {
        String sql = "UPDATE comunidad_miembros SET rol = ? WHERE id_comunidad = ? AND id_usuario = ? AND rol = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, ComunidadMiembro.ROL_ADMIN);
            stmt.setInt(2, idComunidad);
            stmt.setInt(3, idUsuario);
            stmt.setString(4, ComunidadMiembro.ROL_SEGUIDOR);

            int filasAfectadas = stmt.executeUpdate();

            if (filasAfectadas > 0) {
                System.out.println("✅ Usuario " + idUsuario + " promovido a admin en comunidad " + idComunidad);
                return true;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al promover a admin: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Degradar admin a seguidor
     */
    public boolean degradarAdmin(int idUsuario, int idComunidad) {
        String sql = "UPDATE comunidad_miembros SET rol = ? WHERE id_comunidad = ? AND id_usuario = ? AND rol = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, ComunidadMiembro.ROL_SEGUIDOR);
            stmt.setInt(2, idComunidad);
            stmt.setInt(3, idUsuario);
            stmt.setString(4, ComunidadMiembro.ROL_ADMIN);

            int filasAfectadas = stmt.executeUpdate();

            if (filasAfectadas > 0) {
                System.out.println("✅ Usuario " + idUsuario + " degradado a seguidor en comunidad " + idComunidad);
                return true;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al degradar admin: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // ============= CONSULTAS DE PERMISOS =============
    /**
     * Verificar si usuario es miembro de comunidad
     */
    public boolean esMiembroDeComunidad(int idUsuario, int idComunidad) {
        String sql = "SELECT COUNT(*) FROM comunidad_miembros WHERE id_usuario = ? AND id_comunidad = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            stmt.setInt(2, idComunidad);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al verificar membresía: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Verificar si usuario es admin de comunidad
     */
    public boolean esAdminDeComunidad(int idUsuario, int idComunidad) {
        String sql = "SELECT COUNT(*) FROM comunidad_miembros WHERE id_usuario = ? AND id_comunidad = ? AND rol = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            stmt.setInt(2, idComunidad);
            stmt.setString(3, ComunidadMiembro.ROL_ADMIN);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al verificar admin: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Verificar si usuario es creador de comunidad
     */
    public boolean esCreadorDeComunidad(int idUsuario, int idComunidad) {
        String sql = "SELECT COUNT(*) FROM comunidades WHERE id_creador = ? AND id_comunidad = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            stmt.setInt(2, idComunidad);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al verificar creador: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Verificar si usuario es admin de alguna comunidad
     */
    public boolean esAdminDeAlgunaComunidad(int idUsuario) {
        String sql = "SELECT COUNT(*) FROM comunidad_miembros WHERE id_usuario = ? AND rol = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            stmt.setString(2, ComunidadMiembro.ROL_ADMIN);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al verificar admin de alguna comunidad: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // ============= CONSULTAS ESPECÍFICAS =============
    /**
     * Obtener comunidades seguidas por usuario
     */
    public List<Comunidad> obtenerComunidadesSeguidas(int idUsuario) {
        List<Comunidad> comunidades = new ArrayList<>();
        String sql = "SELECT c.*, u.username as username_creador, u.nombre_completo as nombre_creador, u.avatar as avatar_creador "
                + "FROM comunidades c "
                + "LEFT JOIN usuarios u ON c.id_creador = u.id "
                + "INNER JOIN comunidad_miembros cm ON c.id_comunidad = cm.id_comunidad "
                + "WHERE cm.id_usuario = ? "
                + "ORDER BY c.nombre";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                comunidades.add(mapearComunidad(rs));
            }

            System.out.println("👤 Usuario " + idUsuario + " sigue " + comunidades.size() + " comunidades");

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener comunidades seguidas: " + e.getMessage());
            e.printStackTrace();
        }
        return comunidades;
    }

    /**
     * Obtener comunidades que administra un usuario
     */
    public List<Comunidad> obtenerComunidadesQueAdministra(int idUsuario) {
        List<Comunidad> comunidades = new ArrayList<>();
        String sql = "SELECT c.*, u.username as username_creador, u.nombre_completo as nombre_creador, u.avatar as avatar_creador "
                + "FROM comunidades c "
                + "LEFT JOIN usuarios u ON c.id_creador = u.id "
                + "INNER JOIN comunidad_miembros cm ON c.id_comunidad = cm.id_comunidad "
                + "WHERE cm.id_usuario = ? AND cm.rol = ? "
                + "ORDER BY c.nombre";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            stmt.setString(2, ComunidadMiembro.ROL_ADMIN);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                comunidades.add(mapearComunidad(rs));
            }

            System.out.println("🛡️ Usuario " + idUsuario + " administra " + comunidades.size() + " comunidades");

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener comunidades administradas: " + e.getMessage());
            e.printStackTrace();
        }
        return comunidades;
    }

    /**
     * Obtener miembros de una comunidad
     */
    public List<ComunidadMiembro> obtenerMiembrosPorComunidad(int idComunidad) {
        List<ComunidadMiembro> miembros = new ArrayList<>();
        String sql = "SELECT cm.*, u.username, u.nombre_completo, u.avatar, u.email, u.verificado, u.privilegio "
                + "FROM comunidad_miembros cm "
                + "LEFT JOIN usuarios u ON cm.id_usuario = u.id "
                + "WHERE cm.id_comunidad = ? "
                + "ORDER BY cm.rol DESC, cm.fecha_union ASC";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idComunidad);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                miembros.add(mapearComunidadMiembro(rs));
            }

            System.out.println("👥 Comunidad " + idComunidad + " tiene " + miembros.size() + " miembros");

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener miembros: " + e.getMessage());
            e.printStackTrace();
        }
        return miembros;
    }

    // ============= MÉTODOS DE UTILIDAD =============
    /**
     * Actualizar contador de seguidores
     */
    public void actualizarContadorSeguidores(int idComunidad) {
        String sql = "UPDATE comunidades SET seguidores_count = (SELECT COUNT(*) FROM comunidad_miembros WHERE id_comunidad = ?) WHERE id_comunidad = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idComunidad);
            stmt.setInt(2, idComunidad);
            stmt.executeUpdate();

        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar contador de seguidores: " + e.getMessage());
        }
    }

    /**
     * Actualizar contador de publicaciones
     */
    public void actualizarContadorPublicaciones(int idComunidad) {
        String sql = "UPDATE comunidades SET publicaciones_count = (SELECT COUNT(*) FROM publicaciones WHERE id_comunidad = ? AND esta_aprobado = TRUE) WHERE id_comunidad = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idComunidad);
            stmt.setInt(2, idComunidad);
            stmt.executeUpdate();

        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar contador de publicaciones: " + e.getMessage());
        }
    }

    public List<Comunidad> obtenerComunidadesSugeridas(int idUsuario, int limite) {
        List<Comunidad> sugerencias = new ArrayList<>();

        // Solo comunidades que el usuario NO sigue
        String sql = "SELECT c.*, u.username as username_creador, u.nombre_completo as nombre_creador, u.avatar as avatar_creador "
                + "FROM comunidades c "
                + "LEFT JOIN usuarios u ON c.id_creador = u.id "
                + "WHERE c.es_publica = TRUE "
                + "AND c.id_comunidad NOT IN ("
                + "    SELECT cm.id_comunidad FROM comunidad_miembros cm WHERE cm.id_usuario = ?"
                + ") "
                + "ORDER BY c.seguidores_count DESC, c.fecha_creacion DESC "
                + "LIMIT ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            stmt.setInt(2, limite);

            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Comunidad comunidad = mapearComunidad(rs);

                // Como son sugerencias, el usuario NO las sigue
                comunidad.setUsuarioEsSeguidor(false);
                comunidad.setUsuarioEsAdmin(false);
                comunidad.setUsuarioEsCreador(false);

                sugerencias.add(comunidad);
            }

            System.out.println("💡 Obtenidas " + sugerencias.size() + " sugerencias de comunidades para usuario " + idUsuario);

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener sugerencias de comunidades: " + e.getMessage());
            e.printStackTrace();
        }

        return sugerencias;
    }

    /**
     * Buscar comunidades por nombre
     */
    public List<Comunidad> buscarPorNombre(String nombre) {
        List<Comunidad> comunidades = new ArrayList<>();
        String sql = "SELECT c.*, u.username as username_creador, u.nombre_completo as nombre_creador, u.avatar as avatar_creador "
                + "FROM comunidades c "
                + "LEFT JOIN usuarios u ON c.id_creador = u.id "
                + "WHERE LOWER(c.nombre) LIKE LOWER(?) "
                + "ORDER BY c.seguidores_count DESC";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, "%" + nombre + "%");
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                comunidades.add(mapearComunidad(rs));
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al buscar comunidades: " + e.getMessage());
            e.printStackTrace();
        }
        return comunidades;
    }

    public List<Comunidad> buscarPorUsernameExacto(String username) {
        List<Comunidad> comunidades = new ArrayList<>();
        String cleanUsername = username.startsWith("@") ? username.substring(1) : username;

        String sql = "SELECT c.*, u.username as username_creador, u.nombre_completo as nombre_creador, u.avatar as avatar_creador "
                + "FROM comunidades c "
                + "LEFT JOIN usuarios u ON c.id_creador = u.id "
                + "WHERE c.comunidad_username = ? "
                + "ORDER BY c.seguidores_count DESC";

        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, cleanUsername);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                comunidades.add(mapearComunidad(rs));
            }

            System.out.println("🎯 Búsqueda exacta de comunidad por username: " + cleanUsername + 
                              " - Encontradas: " + comunidades.size());

        } catch (SQLException e) {
            System.err.println("❌ Error buscar comunidad username exacto: " + e.getMessage());
            e.printStackTrace();
        }

        return comunidades;
    }

    // ============= MÉTODOS AUXILIARES =============
    /**
     * Mapear ResultSet a objeto Comunidad
     */
    private Comunidad mapearComunidad(ResultSet rs) throws SQLException {
        Comunidad comunidad = new Comunidad();
        comunidad.setIdComunidad(rs.getInt("id_comunidad"));
        comunidad.setNombre(rs.getString("nombre"));
        comunidad.setUsername(rs.getString("comunidad_username"));

        comunidad.setDescripcion(rs.getString("descripcion"));
        comunidad.setImagenUrl(rs.getString("imagen_url"));
        comunidad.setIdCreador(rs.getInt("id_creador"));
        comunidad.setEsPublica(rs.getBoolean("es_publica"));
        comunidad.setSeguidoresCount(rs.getInt("seguidores_count"));
        comunidad.setPublicacionesCount(rs.getInt("publicaciones_count"));

        Timestamp timestamp = rs.getTimestamp("fecha_creacion");
        if (timestamp != null) {
            comunidad.setFechaCreacion(timestamp.toLocalDateTime());
        }

        // Datos del creador (si están disponibles)
        comunidad.setUsernameCreador(rs.getString("username_creador"));
        comunidad.setNombreCreador(rs.getString("nombre_creador"));
        comunidad.setAvatarCreador(rs.getString("avatar_creador"));

        return comunidad;
    }

    /**
     * Mapear ResultSet a objeto ComunidadMiembro
     */
    private ComunidadMiembro mapearComunidadMiembro(ResultSet rs) throws SQLException {
        ComunidadMiembro miembro = new ComunidadMiembro();
        miembro.setIdMembresia(rs.getInt("id_membresia"));
        miembro.setIdComunidad(rs.getInt("id_comunidad"));
        miembro.setIdUsuario(rs.getInt("id_usuario"));
        miembro.setRol(rs.getString("rol"));

        Timestamp timestamp = rs.getTimestamp("fecha_union");
        if (timestamp != null) {
            miembro.setFechaUnion(timestamp.toLocalDateTime());
        }

        // Datos del usuario (si están disponibles)
        miembro.setNombreUsuario(rs.getString("username"));
        miembro.setUsernameUsuario(rs.getString("username"));
        miembro.setNombreCompletoUsuario(rs.getString("nombre_completo"));
        miembro.setAvatarUsuario(rs.getString("avatar"));
        miembro.setEmailUsuario(rs.getString("email"));
        miembro.setUsuarioVerificado(rs.getBoolean("verificado"));
        miembro.setUsuarioPrivilegiado(rs.getBoolean("privilegio"));

        return miembro;
    }

    public boolean crearSolicitudMembresia(int idUsuario, int idComunidad, String mensaje) {
        // ⭐ USAR MySQL ON DUPLICATE KEY UPDATE
        String sql = "INSERT INTO comunidad_solicitudes (id_usuario, id_comunidad, mensaje_solicitud, estado, fecha_solicitud) "
                + "VALUES (?, ?, ?, 'pendiente', CURRENT_TIMESTAMP) "
                + "ON DUPLICATE KEY UPDATE "
                + "mensaje_solicitud = VALUES(mensaje_solicitud), "
                + "estado = 'pendiente', "
                + "fecha_solicitud = CURRENT_TIMESTAMP";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            stmt.setInt(2, idComunidad);
            stmt.setString(3, mensaje);

            boolean resultado = stmt.executeUpdate() > 0;

            if (resultado) {
                System.out.println("✅ Solicitud de membresía procesada: Usuario " + idUsuario + " → Comunidad " + idComunidad);
            }

            return resultado;

        } catch (SQLException e) {
            System.err.println("❌ Error al crear solicitud de membresía: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Verificar si un usuario tiene una solicitud pendiente para una comunidad
     */
    public boolean tieneSolicitudPendiente(int idUsuario, int idComunidad) {
        String sql = "SELECT COUNT(*) FROM comunidad_solicitudes WHERE id_usuario = ? AND id_comunidad = ? AND estado = 'pendiente'";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            stmt.setInt(2, idComunidad);

            ResultSet rs = stmt.executeQuery();
            return rs.next() && rs.getInt(1) > 0;

        } catch (SQLException e) {
            System.err.println("❌ Error al verificar solicitud pendiente: " + e.getMessage());
            return false;
        }
    }

    /**
     * Obtener el estado de la solicitud de un usuario para una comunidad
     */
    public String getEstadoSolicitud(int idUsuario, int idComunidad) {
        String sql = "SELECT estado FROM comunidad_solicitudes WHERE id_usuario = ? AND id_comunidad = ? ORDER BY fecha_solicitud DESC LIMIT 1";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            stmt.setInt(2, idComunidad);

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getString("estado");
            }

            return null; // No tiene solicitud

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener estado de solicitud: " + e.getMessage());
            return null;
        }
    }

    /**
     * Obtener todas las solicitudes pendientes para una comunidad
     */
    public List<SolicitudMembresia> obtenerSolicitudesPendientes(int idComunidad) {
        List<SolicitudMembresia> solicitudes = new ArrayList<>();
        String sql = "SELECT s.*, "
                + "u.username as username_usuario, u.nombre_completo as nombre_usuario, u.avatar as avatar_usuario, u.email as email_usuario, "
                + "a.username as username_admin, a.nombre_completo as nombre_admin "
                + "FROM comunidad_solicitudes s "
                + "JOIN usuarios u ON s.id_usuario = u.id "
                + "LEFT JOIN usuarios a ON s.id_admin_respuesta = a.id "
                + "WHERE s.id_comunidad = ? AND s.estado = 'pendiente' "
                + "ORDER BY s.fecha_solicitud ASC";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idComunidad);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                SolicitudMembresia solicitud = mapearSolicitudConAdmin(rs);
                solicitudes.add(solicitud);
            }

            System.out.println("✅ Obtenidas " + solicitudes.size() + " solicitudes pendientes para comunidad " + idComunidad);

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener solicitudes pendientes: " + e.getMessage());
            e.printStackTrace();
        }

        return solicitudes;
    }

    /**
     * Obtener todas las solicitudes para una comunidad (todas las estados)
     */
// ⭐ MÉTODO ESPECÍFICO PARA HISTORIAL COMPLETO
    public List<SolicitudMembresia> obtenerHistorialCompleto(int idComunidad) {
        List<SolicitudMembresia> solicitudes = new ArrayList<>();
        String sql = "SELECT s.*, "
                + "u.username as username_usuario, u.nombre_completo as nombre_usuario, u.avatar as avatar_usuario, u.email as email_usuario, "
                + "a.username as username_admin, a.nombre_completo as nombre_admin, "
                + "c.nombre as nombre_comunidad, c.comunidad_username as username_comunidad "
                + "FROM comunidad_solicitudes s "
                + "JOIN usuarios u ON s.id_usuario = u.id "
                + "LEFT JOIN usuarios a ON s.id_admin_respuesta = a.id "
                + "JOIN comunidades c ON s.id_comunidad = c.id_comunidad "
                + "WHERE s.id_comunidad = ? "
                + "ORDER BY s.fecha_solicitud DESC";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idComunidad);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                SolicitudMembresia solicitud = mapearHistorialCompleto(rs);
                solicitudes.add(solicitud);
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener historial completo: " + e.getMessage());
            e.printStackTrace();
        }

        return solicitudes;
    }

// ⭐ MÉTODO SIMPLIFICADO PARA OTRAS CONSULTAS
    public List<SolicitudMembresia> obtenerTodasLasSolicitudes(int idComunidad) {
        List<SolicitudMembresia> solicitudes = new ArrayList<>();
        String sql = "SELECT s.*, "
                + "u.username as username_usuario, u.nombre_completo as nombre_usuario, u.avatar as avatar_usuario, u.email as email_usuario, "
                + "a.username as username_admin, a.nombre_completo as nombre_admin, "
                + "c.nombre as nombre_comunidad, c.comunidad_username as username_comunidad "
                + "FROM comunidad_solicitudes s "
                + "JOIN usuarios u ON s.id_usuario = u.id "
                + "LEFT JOIN usuarios a ON s.id_admin_respuesta = a.id "
                + "JOIN comunidades c ON s.id_comunidad = c.id_comunidad "
                + "WHERE s.id_comunidad = ? "
                + "ORDER BY s.fecha_solicitud DESC";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idComunidad);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                SolicitudMembresia solicitud = mapearSolicitudMembresiaCompleta(rs);
                solicitudes.add(solicitud);
            }

            System.out.println("✅ Obtenidas " + solicitudes.size() + " solicitudes totales para comunidad " + idComunidad);

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener todas las solicitudes: " + e.getMessage());
            e.printStackTrace();
        }

        return solicitudes;
    }

// ⭐ MAPEO PARA HISTORIAL COMPLETO
    private SolicitudMembresia mapearHistorialCompleto(ResultSet rs) throws SQLException {
        SolicitudMembresia solicitud = mapearSolicitudMembresia(rs);

        // Datos del admin
        solicitud.setUsernameAdmin(rs.getString("username_admin"));
        solicitud.setNombreCompletoAdmin(rs.getString("nombre_admin"));

        // Datos de la comunidad
        solicitud.setNombreComunidad(rs.getString("nombre_comunidad"));
        solicitud.setUsernameComunidad(rs.getString("username_comunidad"));

        // ID admin respuesta
        int idAdminRespuesta = rs.getInt("id_admin_respuesta");
        if (!rs.wasNull()) {
            solicitud.setIdAdminRespuesta(idAdminRespuesta);
        }

        solicitud.setMensajeRespuesta(rs.getString("mensaje_respuesta"));

        return solicitud;
    }

// ⭐ MAPEO SIN DATOS DE COMUNIDAD
    private SolicitudMembresia mapearSolicitudConAdmin(ResultSet rs) throws SQLException {
        SolicitudMembresia solicitud = mapearSolicitudMembresia(rs);

        // Solo datos del admin
        solicitud.setUsernameAdmin(rs.getString("username_admin"));
        solicitud.setNombreCompletoAdmin(rs.getString("nombre_admin"));

        int idAdminRespuesta = rs.getInt("id_admin_respuesta");
        if (!rs.wasNull()) {
            solicitud.setIdAdminRespuesta(idAdminRespuesta);
        }

        solicitud.setMensajeRespuesta(rs.getString("mensaje_respuesta"));

        return solicitud;
    }

    /**
     * Responder a una solicitud de membresía (aprobar o rechazar)
     */
    public boolean responderSolicitud(int idSolicitud, int idAdmin, String estado, String mensajeRespuesta) {
        Connection conn = null;
        try {
            conn = Conexion.getConexion();
            conn.setAutoCommit(false); // Iniciar transacción

            // ⭐ 1. OBTENER DATOS DE LA SOLICITUD PRIMERO (CON LA MISMA CONEXIÓN)
            int idUsuario = 0;
            int idComunidad = 0;

            String sqlSelect = "SELECT id_usuario, id_comunidad FROM comunidad_solicitudes WHERE id_solicitud = ?";
            try (PreparedStatement stmtSelect = conn.prepareStatement(sqlSelect)) {
                stmtSelect.setInt(1, idSolicitud);
                ResultSet rs = stmtSelect.executeQuery();

                if (rs.next()) {
                    idUsuario = rs.getInt("id_usuario");
                    idComunidad = rs.getInt("id_comunidad");
                } else {
                    // Solicitud no encontrada
                    conn.rollback();
                    return false;
                }
            }

            // ⭐ 2. ACTUALIZAR LA SOLICITUD
            String sqlUpdate = "UPDATE comunidad_solicitudes SET estado = ?, id_admin_respuesta = ?, "
                    + "mensaje_respuesta = ?, fecha_respuesta = CURRENT_TIMESTAMP WHERE id_solicitud = ?";

            try (PreparedStatement stmt = conn.prepareStatement(sqlUpdate)) {
                stmt.setString(1, estado);
                stmt.setInt(2, idAdmin);
                stmt.setString(3, mensajeRespuesta);
                stmt.setInt(4, idSolicitud);

                int filas = stmt.executeUpdate();
                if (filas == 0) {
                    conn.rollback();
                    return false;
                }
            }

            // ⭐ 3. SI FUE APROBADA, AGREGAR COMO MIEMBRO (CON LA MISMA CONEXIÓN)
            if ("aprobada".equals(estado)) {
                boolean agregado = agregarMiembroAprobado(conn, idUsuario, idComunidad);
                if (!agregado) {
                    conn.rollback();
                    return false;
                }
            }

            conn.commit();
            System.out.println("✅ Solicitud " + idSolicitud + " respondida: " + estado);
            return true;

        } catch (SQLException e) {
            System.err.println("❌ Error al responder solicitud: " + e.getMessage());
            e.printStackTrace();
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Obtener una solicitud específica por ID
     */
    public SolicitudMembresia obtenerSolicitudPorId(int idSolicitud) {
        String sql = "SELECT s.*, "
                + "u.username as username_usuario, u.nombre_completo as nombre_usuario, u.avatar as avatar_usuario, u.email as email_usuario, "
                + "a.username as username_admin, a.nombre_completo as nombre_admin, "
                + // ⭐ AGREGADO
                "c.nombre as nombre_comunidad, c.comunidad_username as username_comunidad "
                + "FROM comunidad_solicitudes s "
                + "JOIN usuarios u ON s.id_usuario = u.id "
                + "LEFT JOIN usuarios a ON s.id_admin_respuesta = a.id "
                + // ⭐ AGREGADO
                "JOIN comunidades c ON s.id_comunidad = c.id_comunidad "
                + "WHERE s.id_solicitud = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idSolicitud);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return mapearSolicitudMembresiaCompleta(rs);
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener solicitud por ID: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Agregar un miembro aprobado a la comunidad
     */
    private boolean agregarMiembroAprobado(Connection conn, int idUsuario, int idComunidad) throws SQLException {
        String sqlCheck = "SELECT COUNT(*) FROM comunidad_miembros WHERE id_usuario = ? AND id_comunidad = ?";
        try (PreparedStatement stmtCheck = conn.prepareStatement(sqlCheck)) {
            stmtCheck.setInt(1, idUsuario);
            stmtCheck.setInt(2, idComunidad);

            ResultSet rs = stmtCheck.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                System.out.println("⚠️ Usuario " + idUsuario + " ya es miembro de comunidad " + idComunidad);
                return true;
            }
        }

        // ⭐ AGREGAR COMO MIEMBRO
        String sql = "INSERT INTO comunidad_miembros (id_comunidad, id_usuario, rol, fecha_union) VALUES (?, ?, 'seguidor', CURRENT_TIMESTAMP)";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idComunidad);
            stmt.setInt(2, idUsuario);

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Contar solicitudes pendientes para una comunidad
     */
    public int contarSolicitudesPendientes(int idComunidad) {
        String sql = "SELECT COUNT(*) FROM comunidad_solicitudes WHERE id_comunidad = ? AND estado = 'pendiente'";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idComunidad);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al contar solicitudes pendientes: " + e.getMessage());
        }

        return 0;
    }

    /**
     * Cancelar una solicitud pendiente (por parte del usuario)
     */
    public boolean cancelarSolicitud(int idUsuario, int idComunidad) {
        String sql = "DELETE FROM comunidad_solicitudes WHERE id_usuario = ? AND id_comunidad = ? AND estado = 'pendiente'";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            stmt.setInt(2, idComunidad);

            boolean cancelada = stmt.executeUpdate() > 0;

            if (cancelada) {
                System.out.println("✅ Solicitud cancelada: Usuario " + idUsuario + " → Comunidad " + idComunidad);
            }

            return cancelada;

        } catch (SQLException e) {
            System.err.println("❌ Error al cancelar solicitud: " + e.getMessage());
            return false;
        }
    }

    public int contarComunidadesSeguidas(int idUsuario) {
        String sql = "SELECT COUNT(*) FROM comunidad_miembros WHERE id_usuario = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("👥 Usuario " + idUsuario + " sigue " + count + " comunidades");
                return count;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al contar comunidades seguidas: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Contar solicitudes de membresía enviadas por un usuario
     */
    public int contarSolicitudesUsuario(int idUsuario) {
        String sql = "SELECT COUNT(*) FROM comunidad_solicitudes WHERE id_usuario = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("📝 Usuario " + idUsuario + " ha enviado " + count + " solicitudes");
                return count;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al contar solicitudes del usuario: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Contar solicitudes aprobadas de un usuario
     */
    public int contarSolicitudesAprobadas(int idUsuario) {
        String sql = "SELECT COUNT(*) FROM comunidad_solicitudes WHERE id_usuario = ? AND estado = 'aprobada'";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("✅ Usuario " + idUsuario + " tiene " + count + " solicitudes aprobadas");
                return count;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al contar solicitudes aprobadas: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Contar comunidades donde el usuario es administrador
     */
    public int contarComunidadesAdmin(int idUsuario) {
        String sql = "SELECT COUNT(*) FROM comunidad_miembros WHERE id_usuario = ? AND rol = 'admin'";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("🛡️ Usuario " + idUsuario + " es admin en " + count + " comunidades");
                return count;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al contar comunidades admin: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * BONUS: Contar solicitudes rechazadas de un usuario
     */
    public int contarSolicitudesRechazadas(int idUsuario) {
        String sql = "SELECT COUNT(*) FROM comunidad_solicitudes WHERE id_usuario = ? AND estado = 'rechazada'";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("❌ Usuario " + idUsuario + " tiene " + count + " solicitudes rechazadas");
                return count;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al contar solicitudes rechazadas: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * BONUS: Contar comunidades creadas por el usuario
     */
    public int contarComunidadesCreadas(int idUsuario) {
        String sql = "SELECT COUNT(*) FROM comunidades WHERE id_creador = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("🏗️ Usuario " + idUsuario + " ha creado " + count + " comunidades");
                return count;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al contar comunidades creadas: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }
// ============= MÉTODOS AUXILIARES PARA MAPEO =============
    // ============= MÉTODOS NECESARIOS PARA ComunidadDAO =============

    public List<Comunidad> buscarEnDescripcion(String termino) {
        List<Comunidad> comunidades = new ArrayList<>();

        String sql = "SELECT c.*, u.username as username_creador, u.nombre_completo as nombre_creador, u.avatar as avatar_creador "
                + "FROM comunidades c "
                + "LEFT JOIN usuarios u ON c.id_creador = u.id "
                + "WHERE LOWER(c.descripcion) LIKE LOWER(?) "
                + "ORDER BY c.seguidores_count DESC LIMIT 10";

        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, "%" + termino + "%");
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                comunidades.add(mapearComunidad(rs));
            }

            System.out.println("📝 Búsqueda en descripción: " + termino + 
                              " - Encontradas: " + comunidades.size());

        } catch (SQLException e) {
            System.err.println("❌ Error buscar en descripción: " + e.getMessage());
            e.printStackTrace();
        }

        return comunidades;
    }

    public List<Comunidad> buscarPorUsername(String termino) {
        List<Comunidad> comunidades = new ArrayList<>();
        String cleanTermino = termino.startsWith("@") ? termino.substring(1) : termino;

        String sql = "SELECT c.*, u.username as username_creador, u.nombre_completo as nombre_creador, u.avatar as avatar_creador "
                + "FROM comunidades c "
                + "LEFT JOIN usuarios u ON c.id_creador = u.id "
                + "WHERE c.comunidad_username LIKE ? "
                + "ORDER BY c.seguidores_count DESC LIMIT 10";

        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, "%" + cleanTermino + "%");
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                comunidades.add(mapearComunidad(rs));
            }

            System.out.println("🔍 Búsqueda por username: " + cleanTermino + 
                              " - Encontradas: " + comunidades.size());

        } catch (SQLException e) {
            System.err.println("❌ Error buscar comunidad por username: " + e.getMessage());
            e.printStackTrace();
        }

        return comunidades;
    }

    /**
     * Buscar comunidades en descripción
     */
    public List<Comunidad> buscarComunidadEnDescripcion(String termino) {
        List<Comunidad> comunidades = new ArrayList<>();
        String sql = "SELECT c.*, u.username as username_creador, u.nombre_completo as nombre_creador "
                + "FROM comunidades c "
                + "LEFT JOIN usuarios u ON c.id_creador = u.id "
                + "WHERE c.descripcion LIKE ? "
                + "ORDER BY c.seguidores_count DESC LIMIT 10";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, "%" + termino + "%");
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                comunidades.add(mapearComunidad(rs));
            }

        } catch (SQLException e) {
            System.err.println("❌ Error buscar en descripción: " + e.getMessage());
            e.printStackTrace();
        }

        return comunidades;
    }

    /**
     * Mapear ResultSet a SolicitudMembresia (básico)
     */
    private SolicitudMembresia mapearSolicitudMembresia(ResultSet rs) throws SQLException {
        SolicitudMembresia solicitud = new SolicitudMembresia();

        // Campos básicos de la solicitud
        solicitud.setIdSolicitud(rs.getInt("id_solicitud"));
        solicitud.setIdComunidad(rs.getInt("id_comunidad"));
        solicitud.setIdUsuario(rs.getInt("id_usuario"));
        solicitud.setEstado(rs.getString("estado"));
        solicitud.setMensajeSolicitud(rs.getString("mensaje_solicitud"));

        // Fechas
        Timestamp fechaSolicitud = rs.getTimestamp("fecha_solicitud");
        if (fechaSolicitud != null) {
            solicitud.setFechaSolicitud(fechaSolicitud.toLocalDateTime());
        }

        Timestamp fechaRespuesta = rs.getTimestamp("fecha_respuesta");
        if (fechaRespuesta != null) {
            solicitud.setFechaRespuesta(fechaRespuesta.toLocalDateTime());
        }

        // Datos del usuario solicitante (siempre presentes)
        solicitud.setUsernameUsuario(rs.getString("username_usuario"));
        solicitud.setNombreCompletoUsuario(rs.getString("nombre_usuario"));
        solicitud.setAvatarUsuario(rs.getString("avatar_usuario"));
        solicitud.setEmailUsuario(rs.getString("email_usuario"));

        // ⭐ DATOS DEL ADMIN (PUEDEN SER NULL EN SOLICITUDES PENDIENTES)
        String usernameAdmin = rs.getString("username_admin");
        if (usernameAdmin != null && !rs.wasNull()) {
            solicitud.setUsernameAdmin(usernameAdmin);
        }

        String nombreAdmin = rs.getString("nombre_admin");
        if (nombreAdmin != null && !rs.wasNull()) {
            solicitud.setNombreCompletoAdmin(nombreAdmin);
        }

        // ID admin respuesta (puede ser NULL)
        int idAdminRespuesta = rs.getInt("id_admin_respuesta");
        if (!rs.wasNull()) {
            solicitud.setIdAdminRespuesta(idAdminRespuesta);
        }

        // Mensaje de respuesta (puede ser NULL)
        String mensajeRespuesta = rs.getString("mensaje_respuesta");
        if (mensajeRespuesta != null && !rs.wasNull()) {
            solicitud.setMensajeRespuesta(mensajeRespuesta);
        }

        return solicitud;
    }

    /**
     * Mapear ResultSet a SolicitudMembresia (completo con admin y comunidad)
     */
    private SolicitudMembresia mapearSolicitudMembresiaCompleta(ResultSet rs) throws SQLException {
        SolicitudMembresia solicitud = mapearSolicitudMembresia(rs);

        // Datos adicionales del admin
        solicitud.setUsernameAdmin(rs.getString("username_admin"));
        solicitud.setNombreCompletoAdmin(rs.getString("nombre_admin"));

        // Datos de la comunidad
        solicitud.setNombreComunidad(rs.getString("nombre_comunidad"));
        solicitud.setUsernameComunidad(rs.getString("username_comunidad"));

        // ID admin respuesta
        int idAdminRespuesta = rs.getInt("id_admin_respuesta");
        if (!rs.wasNull()) {
            solicitud.setIdAdminRespuesta(idAdminRespuesta);
        }

        solicitud.setMensajeRespuesta(rs.getString("mensaje_respuesta"));

        return solicitud;
    }
}
