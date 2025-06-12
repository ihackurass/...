/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.aquasocial.dao;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import pe.aquasocial.dao.IIngresoDAO;
import pe.aquasocial.entity.Ingreso;
import pe.aquasocial.entity.Ingreso;
import pe.aquasocial.util.Conexion;

public class IngresoDAO implements IIngresoDAO {

    @Override
    public boolean crear(Ingreso ingreso) {
        String sql = "INSERT INTO ingresos (id_donador, id_creador, id_publicacion, cantidad, fecha_hora, estado, metodo_pago, referencia_pago,mensaje) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, ingreso.getIdDonador());
            stmt.setInt(2, ingreso.getIdCreador());

            // idPublicacion puede ser null
            if (ingreso.getIdPublicacion() > 0) {
                stmt.setInt(3, ingreso.getIdPublicacion());
            } else {
                stmt.setNull(3, Types.INTEGER);
            }

            stmt.setDouble(4, ingreso.getCantidad());
            stmt.setTimestamp(5, Timestamp.valueOf(ingreso.getFechaHora()));
            stmt.setString(6, ingreso.getEstado());
            stmt.setString(7, ingreso.getMetodoPago());
            stmt.setString(8, ingreso.getReferenciaPago());
            stmt.setString(9, ingreso.getMensaje());

            int filasAfectadas = stmt.executeUpdate();

            if (filasAfectadas > 0) {
                // Obtener el ID generado
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    ingreso.setIdIngreso(rs.getInt(1));
                }
                System.out.println("✅ Ingreso creado con ID: " + ingreso.getIdIngreso()
                        + " - $" + ingreso.getCantidad() + " (" + ingreso.getEstado() + ")");
                return true;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al crear ingreso: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public Ingreso obtenerPorId(int idIngreso) {
        String sql = "SELECT i.*, "
                + "ud.username as donador_username, ud.avatar as donador_avatar, "
                + "uc.username as creador_username, uc.avatar as creador_avatar, "
                + "p.texto as publicacion_texto "
                + "FROM ingresos i "
                + "LEFT JOIN usuarios ud ON i.id_donador = ud.id "
                + "LEFT JOIN usuarios uc ON i.id_creador = uc.id "
                + "LEFT JOIN publicaciones p ON i.id_publicacion = p.id_publicacion "
                + "WHERE i.id_ingreso = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idIngreso);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return mapearIngreso(rs);
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener ingreso por ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Ingreso> obtenerTodos() {
        List<Ingreso> ingresos = new ArrayList<>();
        String sql = "SELECT i.*, "
                + "ud.username as donador_username, ud.avatar as donador_avatar, "
                + "uc.username as creador_username, uc.avatar as creador_avatar, "
                + "p.texto as publicacion_texto "
                + "FROM ingresos i "
                + "LEFT JOIN usuarios ud ON i.id_donador = ud.id "
                + "LEFT JOIN usuarios uc ON i.id_creador = uc.id "
                + "LEFT JOIN publicaciones p ON i.id_publicacion = p.id_publicacion "
                + "ORDER BY i.fecha_hora DESC";

        try (Connection conn = Conexion.getConexion(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                ingresos.add(mapearIngreso(rs));
            }

            System.out.println("📋 Obtenidos " + ingresos.size() + " ingresos totales");

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener todos los ingresos: " + e.getMessage());
            e.printStackTrace();
        }
        return ingresos;
    }

    @Override
    public boolean actualizar(Ingreso ingreso) {
        String sql = "UPDATE ingresos SET estado = ?, metodo_pago = ?, referencia_pago = ? WHERE id_ingreso = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, ingreso.getEstado());
            stmt.setString(2, ingreso.getMetodoPago());
            stmt.setString(3, ingreso.getReferenciaPago());
            stmt.setInt(4, ingreso.getIdIngreso());

            int filasAfectadas = stmt.executeUpdate();
            System.out.println("✅ Ingreso actualizado: " + filasAfectadas + " filas afectadas");
            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar ingreso: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean eliminar(int idIngreso) {
        String sql = "DELETE FROM ingresos WHERE id_ingreso = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idIngreso);
            int filasAfectadas = stmt.executeUpdate();

            System.out.println("✅ Ingreso eliminado: " + filasAfectadas + " filas afectadas");
            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.err.println("❌ Error al eliminar ingreso: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public List<Ingreso> obtenerPorPublicacion(int idPublicacion) {
        List<Ingreso> ingresos = new ArrayList<>();
        String sql = "SELECT i.*, "
                + "ud.username as donador_username, ud.avatar as donador_avatar, "
                + "uc.username as creador_username, uc.avatar as creador_avatar, "
                + "p.texto as publicacion_texto "
                + "FROM ingresos i "
                + "LEFT JOIN usuarios ud ON i.id_donador = ud.id "
                + "LEFT JOIN usuarios uc ON i.id_creador = uc.id "
                + "LEFT JOIN publicaciones p ON i.id_publicacion = p.id_publicacion "
                + "WHERE i.id_publicacion = ? "
                + "ORDER BY i.fecha_hora DESC";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idPublicacion);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                ingresos.add(mapearIngreso(rs));
            }

            System.out.println("💰 Obtenidos " + ingresos.size() + " ingresos para publicación " + idPublicacion);

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener ingresos por publicación: " + e.getMessage());
            e.printStackTrace();
        }
        return ingresos;
    }

    @Override
    public List<Ingreso> obtenerPorDonador(int idDonador) {
        List<Ingreso> ingresos = new ArrayList<>();
        String sql = "SELECT i.*, "
                + "ud.username as donador_username, ud.avatar as donador_avatar, "
                + "uc.username as creador_username, uc.avatar as creador_avatar, "
                + "p.texto as publicacion_texto "
                + "FROM ingresos i "
                + "LEFT JOIN usuarios ud ON i.id_donador = ud.id "
                + "LEFT JOIN usuarios uc ON i.id_creador = uc.id "
                + "LEFT JOIN publicaciones p ON i.id_publicacion = p.id_publicacion "
                + "WHERE i.id_donador = ? "
                + "ORDER BY i.fecha_hora DESC";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idDonador);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                ingresos.add(mapearIngreso(rs));
            }

            System.out.println("👤 Usuario " + idDonador + " ha hecho " + ingresos.size() + " donaciones");

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener ingresos por donador: " + e.getMessage());
            e.printStackTrace();
        }
        return ingresos;
    }

    @Override
    public List<Ingreso> obtenerPorCreador(int idCreador) {
        List<Ingreso> ingresos = new ArrayList<>();
        String sql = "SELECT i.*, "
                + "ud.username as donador_username, ud.avatar as donador_avatar, "
                + "uc.username as creador_username, uc.avatar as creador_avatar, "
                + "p.texto as publicacion_texto "
                + "FROM ingresos i "
                + "LEFT JOIN usuarios ud ON i.id_donador = ud.id "
                + "LEFT JOIN usuarios uc ON i.id_creador = uc.id "
                + "LEFT JOIN publicaciones p ON i.id_publicacion = p.id_publicacion "
                + "WHERE i.id_creador = ? "
                + "ORDER BY i.fecha_hora DESC";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idCreador);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                ingresos.add(mapearIngreso(rs));
            }

            System.out.println("💸 Usuario " + idCreador + " ha recibido " + ingresos.size() + " donaciones");

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener ingresos por creador: " + e.getMessage());
            e.printStackTrace();
        }
        return ingresos;
    }

    @Override
    public List<Ingreso> obtenerPorEstado(String estado) {
        List<Ingreso> ingresos = new ArrayList<>();
        String sql = "SELECT i.*, "
                + "ud.username as donador_username, ud.avatar as donador_avatar, "
                + "uc.username as creador_username, uc.avatar as creador_avatar, "
                + "p.texto as publicacion_texto "
                + "FROM ingresos i "
                + "LEFT JOIN usuarios ud ON i.id_donador = ud.id "
                + "LEFT JOIN usuarios uc ON i.id_creador = uc.id "
                + "LEFT JOIN publicaciones p ON i.id_publicacion = p.id_publicacion "
                + "WHERE i.estado = ? "
                + "ORDER BY i.fecha_hora DESC";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, estado);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                ingresos.add(mapearIngreso(rs));
            }

            System.out.println("📊 Obtenidos " + ingresos.size() + " ingresos con estado: " + estado);

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener ingresos por estado: " + e.getMessage());
            e.printStackTrace();
        }
        return ingresos;
    }

    @Override
    public double totalRecibidoPorUsuario(int idUsuario) {
        String sql = "SELECT COALESCE(SUM(cantidad), 0) FROM ingresos WHERE id_creador = ? AND estado = 'Completado'";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                double total = rs.getDouble(1);
                System.out.println("💰 Usuario " + idUsuario + " ha recibido un total de: $" + String.format("%.2f", total));
                return total;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al calcular total recibido por usuario: " + e.getMessage());
            e.printStackTrace();
        }
        return 0.0;
    }

    @Override
    public double totalDonadoPorUsuario(int idUsuario) {
        String sql = "SELECT COALESCE(SUM(cantidad), 0) FROM ingresos WHERE id_donador = ? AND estado = 'Completado'";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                double total = rs.getDouble(1);
                System.out.println("💸 Usuario " + idUsuario + " ha donado un total de: $" + String.format("%.2f", total));
                return total;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al calcular total donado por usuario: " + e.getMessage());
            e.printStackTrace();
        }
        return 0.0;
    }

    @Override
    public double totalPorPublicacion(int idPublicacion) {
        String sql = "SELECT COALESCE(SUM(cantidad), 0) FROM ingresos WHERE id_publicacion = ? AND estado = 'Completado'";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idPublicacion);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                double total = rs.getDouble(1);
                System.out.println("📊 Publicación " + idPublicacion + " ha recaudado: $" + String.format("%.2f", total));
                return total;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al calcular total por publicación: " + e.getMessage());
            e.printStackTrace();
        }
        return 0.0;
    }

    @Override
    public List<Ingreso> obtenerRecientes(int limite) {
        List<Ingreso> ingresos = new ArrayList<>();
        String sql = "SELECT i.*, "
                + "ud.username as donador_username, ud.avatar as donador_avatar, "
                + "uc.username as creador_username, uc.avatar as creador_avatar, "
                + "p.texto as publicacion_texto "
                + "FROM ingresos i "
                + "LEFT JOIN usuarios ud ON i.id_donador = ud.id "
                + "LEFT JOIN usuarios uc ON i.id_creador = uc.id "
                + "LEFT JOIN publicaciones p ON i.id_publicacion = p.id_publicacion "
                + "WHERE i.estado = 'Completado' "
                + "ORDER BY i.fecha_hora DESC "
                + "LIMIT ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, limite);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                ingresos.add(mapearIngreso(rs));
            }

            System.out.println("🕒 Obtenidos " + ingresos.size() + " ingresos recientes completados");

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener ingresos recientes: " + e.getMessage());
            e.printStackTrace();
        }
        return ingresos;
    }

    @Override
    public boolean cambiarEstado(int idIngreso, String nuevoEstado) {
        String sql = "UPDATE ingresos SET estado = ? WHERE id_ingreso = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, nuevoEstado);
            stmt.setInt(2, idIngreso);

            int filasAfectadas = stmt.executeUpdate();
            if (filasAfectadas > 0) {
                System.out.println("🔄 Estado de ingreso " + idIngreso + " cambiado a: " + nuevoEstado);
                return true;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al cambiar estado de ingreso: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public List<Ingreso> obtenerPorMetodoPago(String metodoPago) {
        List<Ingreso> ingresos = new ArrayList<>();
        String sql = "SELECT i.*, "
                + "ud.username as donador_username, ud.avatar as donador_avatar, "
                + "uc.username as creador_username, uc.avatar as creador_avatar, "
                + "p.texto as publicacion_texto "
                + "FROM ingresos i "
                + "LEFT JOIN usuarios ud ON i.id_donador = ud.id "
                + "LEFT JOIN usuarios uc ON i.id_creador = uc.id "
                + "LEFT JOIN publicaciones p ON i.id_publicacion = p.id_publicacion "
                + "WHERE i.metodo_pago = ? "
                + "ORDER BY i.fecha_hora DESC";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, metodoPago);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                ingresos.add(mapearIngreso(rs));
            }

            System.out.println("💳 Obtenidos " + ingresos.size() + " ingresos con método: " + metodoPago);

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener ingresos por método de pago: " + e.getMessage());
            e.printStackTrace();
        }
        return ingresos;
    }

    // ========== MÉTODOS AUXILIARES ==========
    private Ingreso mapearIngreso(ResultSet rs) throws SQLException {
        Ingreso ingreso = new Ingreso();
        ingreso.setIdIngreso(rs.getInt("id_ingreso"));
        ingreso.setIdDonador(rs.getInt("id_donador"));
        ingreso.setIdCreador(rs.getInt("id_creador"));

        // id_publicacion puede ser null
        int idPublicacion = rs.getInt("id_publicacion");
        if (!rs.wasNull()) {
            ingreso.setIdPublicacion(idPublicacion);
        }

        ingreso.setCantidad(rs.getDouble("cantidad"));
        ingreso.setEstado(rs.getString("estado"));
        ingreso.setMetodoPago(rs.getString("metodo_pago"));
        ingreso.setReferenciaPago(rs.getString("referencia_pago"));
        ingreso.setMensaje(rs.getString("mensaje")); // ✅ AGREGADO: mapeo del mensaje

        Timestamp timestamp = rs.getTimestamp("fecha_hora");
        if (timestamp != null) {
            ingreso.setFechaHora(timestamp.toLocalDateTime());
        }

        // Datos del donador
        String donadorUsername = rs.getString("donador_username");
        if (donadorUsername != null) {
            ingreso.setNombreDonador(donadorUsername);
            ingreso.setUsernameDonador("@" + donadorUsername);
            ingreso.setAvatarDonador(rs.getString("donador_avatar"));
        } else {
            ingreso.setNombreDonador("Usuario eliminado");
            ingreso.setUsernameDonador("@eliminado");
            ingreso.setAvatarDonador("assets/images/avatars/default.png");
        }

        // Datos del creador
        String creadorUsername = rs.getString("creador_username");
        if (creadorUsername != null) {
            ingreso.setNombreCreador(creadorUsername);
            ingreso.setUsernameCreador("@" + creadorUsername);
            ingreso.setAvatarCreador(rs.getString("creador_avatar"));
        } else {
            ingreso.setNombreCreador("Usuario eliminado");
            ingreso.setUsernameCreador("@eliminado");
            ingreso.setAvatarCreador("assets/images/avatars/default.png");
        }

        // Datos de la publicación
        ingreso.setTextoPublicacion(rs.getString("publicacion_texto"));

        return ingreso;
    }

    // ========== MÉTODOS ADICIONALES PARA ESTADÍSTICAS ==========
    public double totalIngresosSistema() {
        String sql = "SELECT COALESCE(SUM(cantidad), 0) FROM ingresos WHERE estado = 'Completado'";

        try (Connection conn = Conexion.getConexion(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                double total = rs.getDouble(1);
                System.out.println("💰 Total de ingresos del sistema: $" + String.format("%.2f", total));
                return total;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al calcular total de ingresos del sistema: " + e.getMessage());
            e.printStackTrace();
        }
        return 0.0;
    }

    public List<Object[]> obtenerTopDonadores(int limite) {
        List<Object[]> donadores = new ArrayList<>();
        String sql = "SELECT u.id, u.username, u.avatar, COALESCE(SUM(i.cantidad), 0) as total_donado, COUNT(i.id_ingreso) as total_donaciones "
                + "FROM usuarios u "
                + "LEFT JOIN ingresos i ON u.id = i.id_donador AND i.estado = 'Completado' "
                + "GROUP BY u.id, u.username, u.avatar "
                + "HAVING total_donado > 0 "
                + "ORDER BY total_donado DESC "
                + "LIMIT ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, limite);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Object[] datos = {
                    rs.getInt("id"),
                    rs.getString("username"),
                    rs.getString("avatar"),
                    rs.getDouble("total_donado"),
                    rs.getInt("total_donaciones")
                };
                donadores.add(datos);
            }

            System.out.println("🏆 Obtenidos top " + donadores.size() + " donadores");

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener top donadores: " + e.getMessage());
            e.printStackTrace();
        }
        return donadores;
    }

    public List<Object[]> obtenerTopCreadores(int limite) {
        List<Object[]> creadores = new ArrayList<>();
        String sql = "SELECT u.id, u.username, u.avatar, COALESCE(SUM(i.cantidad), 0) as total_recibido, COUNT(i.id_ingreso) as total_ingresos "
                + "FROM usuarios u "
                + "LEFT JOIN ingresos i ON u.id = i.id_creador AND i.estado = 'Completado' "
                + "GROUP BY u.id, u.username, u.avatar "
                + "HAVING total_recibido > 0 "
                + "ORDER BY total_recibido DESC "
                + "LIMIT ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, limite);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Object[] datos = {
                    rs.getInt("id"),
                    rs.getString("username"),
                    rs.getString("avatar"),
                    rs.getDouble("total_recibido"),
                    rs.getInt("total_ingresos")
                };
                creadores.add(datos);
            }

            System.out.println("🌟 Obtenidos top " + creadores.size() + " creadores que más han recibido");

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener top creadores: " + e.getMessage());
            e.printStackTrace();
        }
        return creadores;
    }

    public List<Object[]> obtenerPublicacionesMasRecaudadoras(int limite) {
        List<Object[]> publicaciones = new ArrayList<>();
        String sql = "SELECT p.id_publicacion, p.texto, u.username, COALESCE(SUM(i.cantidad), 0) as total_recaudado, COUNT(i.id_ingreso) as total_donaciones "
                + "FROM publicaciones p "
                + "LEFT JOIN usuarios u ON p.id_usuario = u.id "
                + "LEFT JOIN ingresos i ON p.id_publicacion = i.id_publicacion AND i.estado = 'Completado' "
                + "WHERE p.permite_donacion = TRUE AND p.esta_aprobado = TRUE "
                + "GROUP BY p.id_publicacion, p.texto, u.username "
                + "HAVING total_recaudado > 0 "
                + "ORDER BY total_recaudado DESC "
                + "LIMIT ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, limite);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Object[] datos = {
                    rs.getInt("id_publicacion"),
                    rs.getString("texto"),
                    rs.getString("username"),
                    rs.getDouble("total_recaudado"),
                    rs.getInt("total_donaciones")
                };
                publicaciones.add(datos);
            }

            System.out.println("💸 Obtenidas top " + publicaciones.size() + " publicaciones que más han recaudado");

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener publicaciones más recaudadoras: " + e.getMessage());
            e.printStackTrace();
        }
        return publicaciones;
    }

    public List<Object[]> obtenerEstadisticasPorMetodoPago() {
        List<Object[]> estadisticas = new ArrayList<>();
        String sql = "SELECT metodo_pago, COUNT(*) as cantidad_transacciones, COALESCE(SUM(cantidad), 0) as total_monto "
                + "FROM ingresos "
                + "WHERE estado = 'Completado' AND metodo_pago IS NOT NULL "
                + "GROUP BY metodo_pago "
                + "ORDER BY total_monto DESC";

        try (Connection conn = Conexion.getConexion(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Object[] datos = {
                    rs.getString("metodo_pago"),
                    rs.getInt("cantidad_transacciones"),
                    rs.getDouble("total_monto")
                };
                estadisticas.add(datos);
            }

            System.out.println("📊 Obtenidas estadísticas de " + estadisticas.size() + " métodos de pago");

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener estadísticas por método de pago: " + e.getMessage());
            e.printStackTrace();
        }
        return estadisticas;
    }

    public int contarIngresosPorEstado(String estado) {
        String sql = "SELECT COUNT(*) FROM ingresos WHERE estado = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, estado);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                int contador = rs.getInt(1);
                System.out.println("📊 Ingresos con estado '" + estado + "': " + contador);
                return contador;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al contar ingresos por estado: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    // Método para procesar un ingreso pendiente (simular procesamiento de pago)
    public boolean procesarIngresoPendiente(int idIngreso, String referenciaPago) {
        String sql = "UPDATE ingresos SET estado = 'Completado', referencia_pago = ? WHERE id_ingreso = ? AND estado = 'Pendiente'";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, referenciaPago);
            stmt.setInt(2, idIngreso);

            int filasAfectadas = stmt.executeUpdate();
            if (filasAfectadas > 0) {
                System.out.println("✅ Ingreso " + idIngreso + " procesado exitosamente con referencia: " + referenciaPago);
                return true;
            } else {
                System.out.println("⚠️ No se pudo procesar el ingreso " + idIngreso + " (puede que no esté pendiente)");
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al procesar ingreso pendiente: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // Método para cancelar un ingreso
    public boolean cancelarIngreso(int idIngreso, String motivo) {
        String sql = "UPDATE ingresos SET estado = 'Cancelado', referencia_pago = ? WHERE id_ingreso = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, "Cancelado: " + motivo);
            stmt.setInt(2, idIngreso);

            int filasAfectadas = stmt.executeUpdate();
            if (filasAfectadas > 0) {
                System.out.println("❌ Ingreso " + idIngreso + " cancelado: " + motivo);
                return true;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al cancelar ingreso: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean existePorReferenciaPago(String referenciaPago) {
        String sql = "SELECT COUNT(*) FROM ingresos WHERE referencia_pago = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, referenciaPago);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                int count = rs.getInt(1);
                boolean existe = count > 0;

                if (existe) {
                    System.out.println("⚠️ Ya existe donación con referencia: " + referenciaPago);
                }

                return existe;
            }

            return false;

        } catch (SQLException e) {
            System.err.println("❌ Error verificando referencia de pago: " + e.getMessage());
            e.printStackTrace();
            return false; // En caso de error, asumir que no existe (mejor duplicado que perdido)
        }
    }

    /**
     * Obtener ingreso por referencia de pago
     */
    @Override
    public Ingreso obtenerPorReferenciaPago(String referenciaPago) {
        String sql = "SELECT i.*, "
                + "ud.username as donador_username, ud.avatar as donador_avatar, "
                + "uc.username as creador_username, uc.avatar as creador_avatar, "
                + "p.texto as publicacion_texto "
                + "FROM ingresos i "
                + "LEFT JOIN usuarios ud ON i.id_donador = ud.id "
                + "LEFT JOIN usuarios uc ON i.id_creador = uc.id "
                + "LEFT JOIN publicaciones p ON i.id_publicacion = p.id_publicacion "
                + "WHERE i.referencia_pago = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, referenciaPago);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                Ingreso ingreso = mapearIngreso(rs);
                System.out.println("💰 Ingreso encontrado por referencia: " + referenciaPago
                        + " - $" + ingreso.getCantidadFormateada());
                return ingreso;
            }

            System.out.println("🔍 No se encontró ingreso con referencia: " + referenciaPago);
            return null;

        } catch (SQLException e) {
            System.err.println("❌ Error obteniendo ingreso por referencia: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
}
