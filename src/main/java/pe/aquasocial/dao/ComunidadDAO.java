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
import pe.aquasocial.util.Conexion;

public class ComunidadDAO implements IComunidadDAO {

    // ============= CRUD BÁSICO DE COMUNIDADES =============
    /**
     * Crear nueva comunidad
     */
    public boolean crear(Comunidad comunidad) {
        String sql = "INSERT INTO comunidades (nombre, descripcion, imagen_url, id_creador, es_publica) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, comunidad.getNombre().trim());
            stmt.setString(2, comunidad.getDescripcion().trim());
            stmt.setString(3, comunidad.getImagenUrl());
            stmt.setInt(4, comunidad.getIdCreador());
            stmt.setBoolean(5, comunidad.isEsPublica());

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
                + "WHERE c.es_publica = TRUE "
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
                + "WHERE c.es_publica = TRUE AND LOWER(c.nombre) LIKE LOWER(?) "
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

    // ============= MÉTODOS AUXILIARES =============
    /**
     * Mapear ResultSet a objeto Comunidad
     */
    private Comunidad mapearComunidad(ResultSet rs) throws SQLException {
        Comunidad comunidad = new Comunidad();
        comunidad.setIdComunidad(rs.getInt("id_comunidad"));
        comunidad.setNombre(rs.getString("nombre"));
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
}
