/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.aquasocial.dao;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import pe.aquasocial.dao.IPublicacionDAO;
import pe.aquasocial.entity.Publicacion;
import pe.aquasocial.util.Conexion;

/**
 *
 * @author Home
 */
public class PublicacionDAO implements IPublicacionDAO {

    @Override
    public boolean crear(Publicacion publicacion) {
        String sql = "INSERT INTO publicaciones (id_usuario, texto, imagen_url, permite_donacion, esta_aprobado, fecha_publicacion, id_comunidad) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, publicacion.getIdUsuario());
            stmt.setString(2, publicacion.getTexto());
            stmt.setString(3, publicacion.getImagenUrl());
            stmt.setBoolean(4, publicacion.isPermiteDonacion());
            stmt.setBoolean(5, publicacion.isEstaAprobado());
            stmt.setTimestamp(6, Timestamp.valueOf(publicacion.getFechaPublicacion()));

            if (publicacion.getIdComunidad() != null) {
                stmt.setInt(7, publicacion.getIdComunidad());
            } else {
                stmt.setNull(7, Types.INTEGER); // Para publicaciones del feed principal
            }

            int filasAfectadas = stmt.executeUpdate();

            if (filasAfectadas > 0) {
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    publicacion.setIdPublicacion(rs.getInt(1));
                }
                System.out.println("✅ Publicación creada con ID: " + publicacion.getIdPublicacion());
                return true;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al crear publicación: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public Publicacion obtenerPorId(int idPublicacion) {
        String sql = "SELECT p.*, u.nombre_completo, u.username, u.avatar FROM publicaciones p "
                + "LEFT JOIN usuarios u ON p.id_usuario = u.id "
                + "WHERE p.id_publicacion = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idPublicacion);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return mapearPublicacionBasica(rs);
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener publicación por ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Publicacion> obtenerTodas() {
        List<Publicacion> publicaciones = new ArrayList<>();
        String sql = "SELECT p.*, u.nombre_completo,u.username, u.avatar FROM publicaciones p "
                + "LEFT JOIN usuarios u ON p.id_usuario = u.id "
                + "ORDER BY p.fecha_publicacion DESC";

        try (Connection conn = Conexion.getConexion(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                publicaciones.add(mapearPublicacionBasica(rs));
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener todas las publicaciones: " + e.getMessage());
            e.printStackTrace();
        }
        return publicaciones;
    }

    @Override
    public boolean actualizar(Publicacion publicacion) {
        String sql = "UPDATE publicaciones SET texto = ?, imagen_url = ?, permite_donacion = ?, esta_aprobado = ? WHERE id_publicacion = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, publicacion.getTexto());
            stmt.setString(2, publicacion.getImagenUrl());
            stmt.setBoolean(3, publicacion.isPermiteDonacion());
            stmt.setBoolean(4, publicacion.isEstaAprobado());
            stmt.setInt(5, publicacion.getIdPublicacion());

            int filasAfectadas = stmt.executeUpdate();
            System.out.println("✅ Publicación actualizada: " + filasAfectadas + " filas afectadas");
            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar publicación: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean eliminar(int idPublicacion) {
        String sql = "DELETE FROM publicaciones WHERE id_publicacion = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idPublicacion);
            int filasAfectadas = stmt.executeUpdate();

            System.out.println("✅ Publicación eliminada: " + filasAfectadas + " filas afectadas");
            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.err.println("❌ Error al eliminar publicación: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public List<Publicacion> obtenerPublicacionesHome(int idUsuarioActual, Integer idComunidad) {
        List<Publicacion> publicaciones = new ArrayList<>();

        // Consulta modificada para incluir filtro opcional por comunidad
        StringBuilder sqlBuilder = new StringBuilder();
        sqlBuilder.append("SELECT ")
                .append("p.id_publicacion, p.id_usuario, p.texto, p.imagen_url, p.permite_donacion, ")
                .append("p.esta_aprobado, p.fecha_publicacion, p.id_comunidad, ")
                .append("u.username as nombre_usuario, u.nombre_completo as nombre_completo, u.avatar as avatar_usuario, ")
                .append("c.nombre as nombre_comunidad, ")
                .append("COUNT(DISTINCT l.id_like) as cantidad_likes, ")
                .append("COUNT(DISTINCT co.id_comentario) as cantidad_comentarios, ")
                .append("COALESCE(SUM(i.cantidad), 0) as total_donaciones, ")
                .append("CASE WHEN ul.id_like IS NOT NULL THEN TRUE ELSE FALSE END as usuario_dio_like ")
                .append("FROM publicaciones p ")
                .append("LEFT JOIN usuarios u ON p.id_usuario = u.id ")
                .append("LEFT JOIN comunidades c ON p.id_comunidad = c.id_comunidad ")
                .append("LEFT JOIN likes l ON p.id_publicacion = l.id_publicacion ")
                .append("LEFT JOIN comentarios co ON p.id_publicacion = co.id_publicacion ")
                .append("LEFT JOIN ingresos i ON p.id_publicacion = i.id_publicacion AND i.estado = 'Completado' ")
                .append("LEFT JOIN likes ul ON p.id_publicacion = ul.id_publicacion AND ul.id_usuario = ? ")
                .append("WHERE p.esta_aprobado = TRUE ");

        // Filtro opcional por comunidad
        if (idComunidad != null) {
            sqlBuilder.append("AND p.id_comunidad = ? ");
        }

        sqlBuilder.append("GROUP BY p.id_publicacion, p.id_usuario, p.texto, p.imagen_url, p.permite_donacion, ")
                .append("p.esta_aprobado, p.fecha_publicacion, p.id_comunidad, u.username, u.nombre_completo, u.avatar, ")
                .append("c.nombre, ul.id_like ")
                .append("ORDER BY p.fecha_publicacion DESC");

        String sql = sqlBuilder.toString();

        System.out.println("🔍 Ejecutando consulta con idUsuarioActual: " + idUsuarioActual
                + (idComunidad != null ? ", idComunidad: " + idComunidad : ", todas las comunidades"));

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            // Verificar conexión
            if (conn == null) {
                System.out.println("❌ ERROR: No se pudo obtener conexión a la base de datos");
                return publicaciones;
            }

            stmt.setInt(1, idUsuarioActual);

            // Agregar parámetro de comunidad si es necesario
            if (idComunidad != null) {
                stmt.setInt(2, idComunidad);
            }

            ResultSet rs = stmt.executeQuery();

            int contador = 0;
            while (rs.next()) {
                contador++;
                System.out.println("📄 Procesando publicación " + contador + " - ID: " + rs.getInt("id_publicacion"));

                Publicacion pub = mapearPublicacionCompleta(rs);
                publicaciones.add(pub);
            }

            String tipoFeed = idComunidad != null ? "comunidad " + idComunidad : "feed principal";
            System.out.println("✅ Obtenidas " + publicaciones.size() + " publicaciones para " + tipoFeed);

        } catch (SQLException e) {
            System.err.println("❌ Error SQL: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("❌ Error general: " + e.getMessage());
            e.printStackTrace();
        }

        return publicaciones;
    }

    /**
     * Método de conveniencia para mantener compatibilidad con código existente
     */
    public List<Publicacion> obtenerPublicacionesHome(int idUsuarioActual) {
        return obtenerPublicacionesHome(idUsuarioActual, null); // null = todas las publicaciones
    }

    /**
     * Obtener publicaciones de una comunidad específica
     */
    public List<Publicacion> obtenerPorComunidad(int idComunidad, int idUsuarioActual) {
        return obtenerPublicacionesHome(idUsuarioActual, idComunidad);
    }

    /**
     * Verificar si usuario puede publicar en comunidad específica
     */
    public boolean puedePublicarEnComunidad(int idUsuario, int idComunidad) {
        try {
            ComunidadDAO comunidadDAO = new ComunidadDAO();

            // Puede publicar si es admin de la comunidad
            boolean esAdmin = comunidadDAO.esAdminDeComunidad(idUsuario, idComunidad);

            if (esAdmin) {
                System.out.println("✅ Usuario " + idUsuario + " puede publicar en comunidad " + idComunidad + " (es admin)");
            } else {
                System.out.println("❌ Usuario " + idUsuario + " NO puede publicar en comunidad " + idComunidad + " (no es admin)");
            }

            return esAdmin;

        } catch (Exception e) {
            System.err.println("❌ Error verificando permisos de publicación: " + e.getMessage());
            return false;
        }
    }

    /**
     * Contar publicaciones por comunidad
     */
    public int contarPublicacionesPorComunidad(int idComunidad) {
        String sql = "SELECT COUNT(*) FROM publicaciones WHERE id_comunidad = ? AND esta_aprobado = TRUE";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idComunidad);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("📊 Comunidad " + idComunidad + " tiene " + count + " publicaciones");
                return count;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al contar publicaciones por comunidad: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Obtener publicaciones recientes de comunidades seguidas por un usuario
     */
    public List<Publicacion> obtenerPublicacionesComunidadesSeguidas(int idUsuario) {
        List<Publicacion> publicaciones = new ArrayList<>();

        String sql = "SELECT p.*, u.username as nombre_usuario, u.nombre_completo, u.avatar as avatar_usuario, "
                + "c.nombre as nombre_comunidad, "
                + "COUNT(DISTINCT l.id_like) as cantidad_likes, "
                + "COUNT(DISTINCT co.id_comentario) as cantidad_comentarios, "
                + "COALESCE(SUM(i.cantidad), 0) as total_donaciones, "
                + "CASE WHEN ul.id_like IS NOT NULL THEN TRUE ELSE FALSE END as usuario_dio_like "
                + "FROM publicaciones p "
                + "LEFT JOIN usuarios u ON p.id_usuario = u.id "
                + "LEFT JOIN comunidades c ON p.id_comunidad = c.id_comunidad "
                + "INNER JOIN comunidad_miembros cm ON p.id_comunidad = cm.id_comunidad "
                + "LEFT JOIN likes l ON p.id_publicacion = l.id_publicacion "
                + "LEFT JOIN comentarios co ON p.id_publicacion = co.id_publicacion "
                + "LEFT JOIN ingresos i ON p.id_publicacion = i.id_publicacion AND i.estado = 'Completado' "
                + "LEFT JOIN likes ul ON p.id_publicacion = ul.id_publicacion AND ul.id_usuario = ? "
                + "WHERE cm.id_usuario = ? AND p.esta_aprobado = TRUE AND p.id_comunidad IS NOT NULL "
                + "GROUP BY p.id_publicacion, p.id_usuario, p.texto, p.imagen_url, p.permite_donacion, "
                + "p.esta_aprobado, p.fecha_publicacion, p.id_comunidad, u.username, u.nombre_completo, "
                + "u.avatar, c.nombre, ul.id_like "
                + "ORDER BY p.fecha_publicacion DESC "
                + "LIMIT 20";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            stmt.setInt(2, idUsuario);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                publicaciones.add(mapearPublicacionCompleta(rs));
            }

            System.out.println("📱 Obtenidas " + publicaciones.size() + " publicaciones de comunidades seguidas por usuario " + idUsuario);

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener publicaciones de comunidades seguidas: " + e.getMessage());
            e.printStackTrace();
        }

        return publicaciones;
    }

    /**
     * MODIFICAR tu método mapearPublicacionCompleta existente para incluir
     * comunidad Agregar estas líneas al final de tu método actual:
     */
    private Publicacion mapearPublicacionCompleta(ResultSet rs) throws SQLException {
        Publicacion pub = new Publicacion();

        try {
            // Tu código existente...
            pub.setIdPublicacion(rs.getInt("id_publicacion"));
            pub.setIdUsuario(rs.getInt("id_usuario"));
            pub.setTexto(rs.getString("texto"));
            pub.setImagenUrl(rs.getString("imagen_url"));
            pub.setPermiteDonacion(rs.getBoolean("permite_donacion"));
            pub.setEstaAprobado(rs.getBoolean("esta_aprobado"));

            // Convertir Timestamp a LocalDateTime
            Timestamp timestamp = rs.getTimestamp("fecha_publicacion");
            if (timestamp != null) {
                pub.setFechaPublicacion(timestamp.toLocalDateTime());
            }

            pub.setNombreUsuario("@" + rs.getString("nombre_usuario"));
            pub.setAvatarUsuario(rs.getString("avatar_usuario"));
            pub.setNombreCompleto(rs.getString("nombre_completo"));

            pub.setCantidadLikes(rs.getInt("cantidad_likes"));
            pub.setCantidadComentarios(rs.getInt("cantidad_comentarios"));
            pub.setTotalDonaciones(rs.getDouble("total_donaciones"));
            pub.setUsuarioDioLike(rs.getBoolean("usuario_dio_like"));

            // ===== AGREGAR ESTAS LÍNEAS NUEVAS =====
            // Datos de la comunidad (si la publicación pertenece a una)
            try {
                int idComunidad = rs.getInt("id_comunidad");
                if (!rs.wasNull()) {
                    // Si tienes campos en tu clase Publicacion para comunidad, agrégalos:
                    pub.setIdComunidad(idComunidad);
                    pub.setNombreComunidad(rs.getString("nombre_comunidad"));

                    System.out.println("📂 Publicación " + pub.getIdPublicacion() + " pertenece a comunidad: " + rs.getString("nombre_comunidad"));
                }
            } catch (SQLException e) {
                // Campos de comunidad no disponibles en esta consulta
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al mapear publicación: " + e.getMessage());
            throw e;
        }

        return pub;
    }

    @Override
    public List<Publicacion> obtenerPorUsuario(int idUsuario) {
        List<Publicacion> publicaciones = new ArrayList<>();
        String sql = "SELECT p.*, u.nombre_completo, u.username, u.avatar FROM publicaciones p "
                + "LEFT JOIN usuarios u ON p.id_usuario = u.id "
                + "WHERE p.id_usuario = ? ORDER BY p.fecha_publicacion DESC";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                publicaciones.add(mapearPublicacionBasica(rs));
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener publicaciones por usuario: " + e.getMessage());
            e.printStackTrace();
        }
        return publicaciones;
    }

    @Override
    public List<Publicacion> obtenerAprobadas() {
        List<Publicacion> publicaciones = new ArrayList<>();
        String sql = "SELECT p.*, u.nombre_completo,u.username, u.avatar FROM publicaciones p "
                + "LEFT JOIN usuarios u ON p.id_usuario = u.id "
                + "WHERE p.esta_aprobado = TRUE ORDER BY p.fecha_publicacion DESC";

        try (Connection conn = Conexion.getConexion(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                publicaciones.add(mapearPublicacionBasica(rs));
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener publicaciones aprobadas: " + e.getMessage());
            e.printStackTrace();
        }
        return publicaciones;
    }

    @Override
    public List<Publicacion> obtenerPendientesAprobacion() {
        List<Publicacion> publicaciones = new ArrayList<>();
        String sql = "SELECT p.*,u.nombre_completo, u.username, u.avatar FROM publicaciones p "
                + "LEFT JOIN usuarios u ON p.id_usuario = u.id "
                + "WHERE p.esta_aprobado = FALSE ORDER BY p.fecha_publicacion ASC";

        try (Connection conn = Conexion.getConexion(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                publicaciones.add(mapearPublicacionBasica(rs));
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener publicaciones pendientes: " + e.getMessage());
            e.printStackTrace();
        }
        return publicaciones;
    }

    @Override
    public List<Publicacion> obtenerQuePermiteDonacion() {
        List<Publicacion> publicaciones = new ArrayList<>();
        String sql = "SELECT p.*, u.nombre_completo,u.username, u.avatar FROM publicaciones p "
                + "LEFT JOIN usuarios u ON p.id_usuario = u.id "
                + "WHERE p.permite_donacion = TRUE AND p.esta_aprobado = TRUE "
                + "ORDER BY p.fecha_publicacion DESC";

        try (Connection conn = Conexion.getConexion(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                publicaciones.add(mapearPublicacionBasica(rs));
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener publicaciones que permiten donación: " + e.getMessage());
            e.printStackTrace();
        }
        return publicaciones;
    }
    public List<Publicacion> buscarPorTexto(String termino) {
        List<Publicacion> publicaciones = new ArrayList<>();
        String sql = "SELECT p.*, u.username, u.nombre_completo, u.avatar, u.verificado, " +
                    "COALESCE(l.cantidad_likes, 0) as cantidad_likes, " +
                    "COALESCE(c.cantidad_comentarios, 0) as cantidad_comentarios " +
                    "FROM publicaciones p " +
                    "LEFT JOIN usuarios u ON p.id_usuario = u.id " +
                    "LEFT JOIN (SELECT id_publicacion, COUNT(*) as cantidad_likes FROM likes GROUP BY id_publicacion) l " +
                    "    ON p.id_publicacion = l.id_publicacion " +
                    "LEFT JOIN (SELECT id_publicacion, COUNT(*) as cantidad_comentarios FROM comentarios GROUP BY id_publicacion) c " +
                    "    ON p.id_publicacion = c.id_publicacion " +
                    "WHERE p.esta_aprobado = TRUE " +
                    "AND (LOWER(p.texto) LIKE LOWER(?) OR LOWER(u.nombre_completo) LIKE LOWER(?)) " +
                    "ORDER BY p.fecha_publicacion DESC " +
                    "LIMIT 15";

        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            String searchTerm = "%" + termino + "%";
            stmt.setString(1, searchTerm);
            stmt.setString(2, searchTerm);

            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                publicaciones.add(mapearPublicacionBasica(rs));
            }

            System.out.println("🔍 Búsqueda en publicaciones: " + termino + 
                              " - Encontradas: " + publicaciones.size());

        } catch (SQLException e) {
            System.err.println("❌ Error al buscar publicaciones por texto: " + e.getMessage());
            e.printStackTrace();
        }

        return publicaciones;
    }
    @Override
    public boolean aprobar(int idPublicacion) {
        String sql = "UPDATE publicaciones SET esta_aprobado = TRUE WHERE id_publicacion = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idPublicacion);
            int filasAfectadas = stmt.executeUpdate();

            System.out.println("✅ Publicación aprobada: " + filasAfectadas + " filas afectadas");
            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.err.println("❌ Error al aprobar publicación: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean rechazar(int idPublicacion) {
        // Rechazar = eliminar la publicación
        return eliminar(idPublicacion);
    }

    @Override
    public int contarPorUsuario(int idUsuario) {
        String sql = "SELECT COUNT(*) FROM publicaciones WHERE id_usuario = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al contar publicaciones por usuario: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public List<Publicacion> obtenerRecientes(int limite) {
        List<Publicacion> publicaciones = new ArrayList<>();
        String sql = "SELECT p.*, u.nombre_completo,u.username, u.avatar FROM publicaciones p "
                + "LEFT JOIN usuarios u ON p.id_usuario = u.id "
                + "WHERE p.esta_aprobado = TRUE "
                + "ORDER BY p.fecha_publicacion DESC LIMIT ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, limite);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                publicaciones.add(mapearPublicacionBasica(rs));
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener publicaciones recientes: " + e.getMessage());
            e.printStackTrace();
        }
        return publicaciones;
    }

    // ========== MÉTODOS AUXILIARES ==========
    private Publicacion mapearPublicacionBasica(ResultSet rs) throws SQLException {
        Publicacion pub = new Publicacion();
        pub.setIdPublicacion(rs.getInt("id_publicacion"));
        pub.setIdUsuario(rs.getInt("id_usuario"));
        pub.setTexto(rs.getString("texto"));
        pub.setImagenUrl(rs.getString("imagen_url"));
        pub.setPermiteDonacion(rs.getBoolean("permite_donacion"));
        pub.setEstaAprobado(rs.getBoolean("esta_aprobado"));
        pub.setCantidadLikes(rs.getInt("cantidad_likes"));
        pub.setCantidadComentarios(rs.getInt("cantidad_comentarios"));
        Timestamp timestamp = rs.getTimestamp("fecha_publicacion");
        if (timestamp != null) {
            pub.setFechaPublicacion(timestamp.toLocalDateTime());
        }

        // Datos del usuario
        pub.setNombreUsuario("@" + rs.getString("username"));
        pub.setNombreCompleto(rs.getString("nombre_completo"));
        pub.setAvatarUsuario(rs.getString("avatar"));

        return pub;
    }
}
