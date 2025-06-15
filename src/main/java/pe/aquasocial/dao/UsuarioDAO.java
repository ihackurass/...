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
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;
import org.mindrot.jbcrypt.BCrypt;
import pe.aquasocial.entity.Comunidad;

import pe.aquasocial.entity.Usuario;
import pe.aquasocial.util.Conexion;

/**
 *
 * @author Rodrigo
 */
public class UsuarioDAO implements DAO<Usuario>, IPerfilDAO {

    private static final String EMAIL_PATTERN
            = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";

    private static final Pattern EMAIL_REGEX = Pattern.compile(EMAIL_PATTERN);

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
        String sql = "UPDATE usuarios SET nombre_completo = ?, email = ?, password = ?, rol = ?, verificado = ?, privilegio = ?, baneado = ? WHERE id = ?";
        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, usuario.getNombreCompleto());
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

    @Override
    public boolean actualizarInformacion(Usuario usuario) {
        String sql = "UPDATE usuarios SET nombre_completo = ?, email = ?, fecha_actualizacion = CURRENT_TIMESTAMP WHERE id = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, usuario.getNombreCompleto().trim());
            stmt.setString(2, usuario.getEmail().trim().toLowerCase());
            stmt.setInt(3, usuario.getId());

            boolean actualizado = stmt.executeUpdate() > 0;

            if (actualizado) {
                System.out.println("✅ Información actualizada para usuario ID: " + usuario.getId());
            }

            return actualizado;

        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar información: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean existeEmail(String email) {
        String sql = "SELECT COUNT(*) FROM usuarios WHERE LOWER(email) = LOWER(?)";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email.trim());
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al verificar email: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean existeEmailOtroUsuario(String email, int idUsuarioExcluir) {
        String sql = "SELECT COUNT(*) FROM usuarios WHERE LOWER(email) = LOWER(?) AND id != ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email.trim());
            stmt.setInt(2, idUsuarioExcluir);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al verificar email de otro usuario: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    // ============= GESTIÓN DE CONTRASEÑAS =============
    @Override
    public boolean verificarPassword(int idUsuario, String passwordActual) {
        String sql = "SELECT password FROM usuarios WHERE id = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                String hashedPassword = rs.getString("password");
                return BCrypt.checkpw(passwordActual, hashedPassword);
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al verificar password: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean cambiarPassword(int idUsuario, String nuevaPassword) {
        String sql = "UPDATE usuarios SET password = ?, fecha_actualizacion = CURRENT_TIMESTAMP WHERE id = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            // Encriptar nueva contraseña
            String hashedPassword = BCrypt.hashpw(nuevaPassword, BCrypt.gensalt(12));

            stmt.setString(1, hashedPassword);
            stmt.setInt(2, idUsuario);

            boolean cambiado = stmt.executeUpdate() > 0;

            if (cambiado) {
                System.out.println("🔒 Contraseña cambiada para usuario ID: " + idUsuario);
            }

            return cambiado;

        } catch (SQLException e) {
            System.err.println("❌ Error al cambiar password: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public String obtenerHashPassword(int idUsuario) {
        String sql = "SELECT password FROM usuarios WHERE id = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getString("password");
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener hash password: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    // ============= GESTIÓN DE AVATARES =============
    @Override
    public boolean actualizarAvatar(int idUsuario, String avatarUrl) {
        String sql = "UPDATE usuarios SET avatar = ?, fecha_actualizacion = CURRENT_TIMESTAMP WHERE id = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, avatarUrl);
            stmt.setInt(2, idUsuario);

            boolean actualizado = stmt.executeUpdate() > 0;

            if (actualizado) {
                System.out.println("🖼️ Avatar actualizado para usuario ID: " + idUsuario);
            }

            return actualizado;

        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar avatar: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public String obtenerAvatarActual(int idUsuario) {
        String sql = "SELECT avatar FROM usuarios WHERE id = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getString("avatar");
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener avatar actual: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public boolean eliminarAvatar(int idUsuario) {
        return actualizarAvatar(idUsuario, null);
    }

    // ============= ESTADÍSTICAS DEL USUARIO =============
    @Override
    public Map<String, Integer> obtenerEstadisticasCompletas(int idUsuario) {
        Map<String, Integer> estadisticas = new HashMap<>();

        estadisticas.put("comunidadesSeguidas", contarComunidadesSeguidas(idUsuario));
        estadisticas.put("solicitudesEnviadas", contarSolicitudesEnviadas(idUsuario));
        estadisticas.put("solicitudesAprobadas", contarSolicitudesAprobadas(idUsuario));
        estadisticas.put("solicitudesRechazadas", contarSolicitudesRechazadas(idUsuario));
        estadisticas.put("solicitudesPendientes", contarSolicitudesPendientes(idUsuario));
        estadisticas.put("comunidadesAdmin", contarComunidadesAdmin(idUsuario));
        estadisticas.put("comunidadesCreadas", contarComunidadesCreadas(idUsuario));

        System.out.println("📊 Estadísticas completas obtenidas para usuario ID: " + idUsuario);
        return estadisticas;
    }

    @Override
    public int contarComunidadesSeguidas(int idUsuario) {
        String sql = "SELECT COUNT(*) FROM comunidad_miembros WHERE id_usuario = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al contar comunidades seguidas: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    @Override
    public int contarSolicitudesEnviadas(int idUsuario) {
        String sql = "SELECT COUNT(*) FROM comunidad_solicitudes WHERE id_usuario = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al contar solicitudes enviadas: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    @Override
    public int contarSolicitudesAprobadas(int idUsuario) {
        String sql = "SELECT COUNT(*) FROM comunidad_solicitudes WHERE id_usuario = ? AND estado = 'aprobada'";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al contar solicitudes aprobadas: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    @Override
    public int contarSolicitudesRechazadas(int idUsuario) {
        String sql = "SELECT COUNT(*) FROM comunidad_solicitudes WHERE id_usuario = ? AND estado = 'rechazada'";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al contar solicitudes rechazadas: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    @Override
    public int contarSolicitudesPendientes(int idUsuario) {
        String sql = "SELECT COUNT(*) FROM comunidad_solicitudes WHERE id_usuario = ? AND estado = 'pendiente'";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al contar solicitudes pendientes: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    @Override
    public int contarComunidadesAdmin(int idUsuario) {
        String sql = "SELECT COUNT(*) FROM comunidad_miembros WHERE id_usuario = ? AND rol = 'admin'";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al contar comunidades admin: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    @Override
    public int contarComunidadesCreadas(int idUsuario) {
        String sql = "SELECT COUNT(*) FROM comunidades WHERE id_creador = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al contar comunidades creadas: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    // ============= INFORMACIÓN ADICIONAL =============
    @Override
    public LocalDateTime obtenerUltimoAcceso(int idUsuario) {
        String sql = "SELECT ultimo_acceso FROM usuarios WHERE id = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                Timestamp timestamp = rs.getTimestamp("ultimo_acceso");
                return timestamp != null ? timestamp.toLocalDateTime() : null;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener último acceso: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public boolean actualizarUltimoAcceso(int idUsuario) {
        String sql = "UPDATE usuarios SET ultimo_acceso = CURRENT_TIMESTAMP WHERE id = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            return stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar último acceso: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean estaVerificado(int idUsuario) {
        String sql = "SELECT verificado FROM usuarios WHERE id = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getBoolean("verificado");
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al verificar estado: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public Usuario obtenerUsuarioCompleto(int idUsuario) {
        String sql = "SELECT * FROM usuarios WHERE id = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return mapearUsuario(rs);
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener usuario completo: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    // ============= MÉTODOS DE CONFIGURACIÓN =============
    @Override
    public boolean actualizarConfiguracionNotificaciones(int idUsuario, boolean notificacionesEmail) {
        String sql = "UPDATE usuarios SET notificaciones_email = ? WHERE id = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setBoolean(1, notificacionesEmail);
            stmt.setInt(2, idUsuario);

            return stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar configuración notificaciones: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean obtenerConfiguracionNotificaciones(int idUsuario) {
        String sql = "SELECT notificaciones_email FROM usuarios WHERE id = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getBoolean("notificaciones_email");
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener configuración notificaciones: " + e.getMessage());
            e.printStackTrace();
        }

        return true; // Por defecto habilitadas
    }

    @Override
    public boolean actualizarPrivacidadPerfil(int idUsuario, boolean perfilPrivado) {
        String sql = "UPDATE usuarios SET perfil_privado = ? WHERE id = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setBoolean(1, perfilPrivado);
            stmt.setInt(2, idUsuario);

            return stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar privacidad perfil: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean esPerfilPrivado(int idUsuario) {
        String sql = "SELECT perfil_privado FROM usuarios WHERE id = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getBoolean("perfil_privado");
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al verificar privacidad perfil: " + e.getMessage());
            e.printStackTrace();
        }

        return false; // Por defecto público
    }

    public boolean crearSolicitudVerificacion(int idUsuario, String motivo, String categoria,
            String documentoUrl, String enlaces) {
        String sql = "INSERT INTO solicitudes_verificacion (id_usuario, motivo, categoria, documento_url, enlaces_adicionales) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            stmt.setString(2, motivo);
            stmt.setString(3, categoria);
            stmt.setString(4, documentoUrl);
            stmt.setString(5, enlaces);

            return stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("❌ Error al crear solicitud de verificación: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean marcarSolicitudVerificacion(int idUsuario) {
        String sql = "UPDATE usuarios SET solicito_verificacion = true WHERE id = ?";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            return stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("❌ Error al marcar solicitud de verificación: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Buscar usuario por username exacto (para @usuario)
     */
    public List<Usuario> buscarPorUsernameExacto(String username) {
        List<Usuario> usuarios = new ArrayList<>();
        String cleanUsername = username.startsWith("@") ? username.substring(1) : username;

        String sql = "SELECT * FROM usuarios WHERE username = ? AND baneado = false ORDER BY verificado DESC";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, cleanUsername);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                usuarios.add(mapearUsuario(rs));
            }

        } catch (SQLException e) {
            System.err.println("❌ Error buscar username exacto: " + e.getMessage());
            e.printStackTrace();
        }

        return usuarios;
    }

    /**
     * Buscar usuarios por nombre completo
     */
    public List<Usuario> buscarPorNombreCompleto(String termino) {
        List<Usuario> usuarios = new ArrayList<>();
        String sql = "SELECT * FROM usuarios WHERE nombre_completo LIKE ? AND baneado = false "
                + "ORDER BY verificado DESC, nombre_completo ASC LIMIT 10";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, "%" + termino + "%");
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                usuarios.add(mapearUsuario(rs));
            }

        } catch (SQLException e) {
            System.err.println("❌ Error buscar por nombre: " + e.getMessage());
            e.printStackTrace();
        }

        return usuarios;
    }

    /**
     * Buscar usuarios por username (que contenga)
     */
    public List<Usuario> buscarPorUsername(String termino) {
        List<Usuario> usuarios = new ArrayList<>();
        String cleanTermino = termino.startsWith("@") ? termino.substring(1) : termino;

        String sql = "SELECT * FROM usuarios WHERE username LIKE ? AND baneado = false "
                + "ORDER BY verificado DESC, username ASC LIMIT 10";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, "%" + cleanTermino + "%");
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                usuarios.add(mapearUsuario(rs));
            }

        } catch (SQLException e) {
            System.err.println("❌ Error buscar por username: " + e.getMessage());
            e.printStackTrace();
        }

        return usuarios;
    }

    /**
     * Buscar usuarios en biografía
     */
    public List<Usuario> buscarEnBio(String termino) {
        List<Usuario> usuarios = new ArrayList<>();
        String sql = "SELECT * FROM usuarios WHERE bio LIKE ? AND baneado = false " +
                    "ORDER BY verificado DESC LIMIT 10";

        try (Connection conn = Conexion.getConexion(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, "%" + termino + "%");
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                usuarios.add(mapearUsuario(rs));
            }

        } catch (SQLException e) {
            System.err.println("❌ Error buscar en bio: " + e.getMessage());
            e.printStackTrace();
        }

        return usuarios; // ← Esta línea faltaba
    }


    // ============= MÉTODOS DE VALIDACIÓN =============

    @Override
    public boolean validarUsuarioActivo(int idUsuario) {
        String sql = "SELECT COUNT(*) FROM usuarios WHERE id = ? AND baneado = false";

        try (Connection conn = Conexion.getConexion(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idUsuario);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al validar usuario activo: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean validarFormatoEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }

        return EMAIL_REGEX.matcher(email.trim()).matches();
    }

    @Override
    public boolean validarFortalezaPassword(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }

        // Criterios mínimos:
        // - Al menos 8 caracteres
        // - Al menos una letra
        // - Al menos un número
        boolean tieneLetra = password.matches(".*[a-zA-Z].*");
        boolean tieneNumero = password.matches(".*\\d.*");

        return tieneLetra && tieneNumero;
    }

    // ============= MÉTODOS AUXILIARES =============
    /**
     * Mapear ResultSet a objeto Usuario
     */
    private Usuario mapearUsuario(ResultSet rs) throws SQLException {
        Usuario usuario = new Usuario();

        usuario.setId(rs.getInt("id"));
        usuario.setUsername(rs.getString("username"));
        usuario.setNombreCompleto(rs.getString("nombre_completo"));
        usuario.setEmail(rs.getString("email"));
        usuario.setPassword(rs.getString("password"));
        usuario.setAvatar(rs.getString("avatar"));
        usuario.setVerificado(rs.getBoolean("verificado"));
        usuario.setPrivilegio(rs.getBoolean("privilegio"));

        Timestamp ultimoAcceso = rs.getTimestamp("ultimo_acceso");
        if (ultimoAcceso != null) {
            usuario.setUltimoAcceso(ultimoAcceso.toLocalDateTime());
        }

        return usuario;
    }
// 🔧 CORRECCIÓN 4: Agregar método faltante mapearComunidad

    private Comunidad mapearComunidad(ResultSet rs) throws SQLException {
        Comunidad comunidad = new Comunidad();

        // Campos principales de la tabla comunidades
        comunidad.setIdComunidad(rs.getInt("id"));
        comunidad.setNombre(rs.getString("nombre"));
        comunidad.setUsername(rs.getString("comunidad_username")); // o "username" según tu BD
        comunidad.setDescripcion(rs.getString("descripcion"));
        comunidad.setImagenUrl(rs.getString("imagen_url"));
        comunidad.setIdCreador(rs.getInt("id_creador"));
        comunidad.setEsPublica(rs.getBoolean("es_publica"));
        comunidad.setSeguidoresCount(rs.getInt("seguidores_count"));
        comunidad.setPublicacionesCount(rs.getInt("publicaciones_count"));

        // Campos adicionales del JOIN con usuarios
        try {
            comunidad.setUsernameCreador(rs.getString("username_creador"));
            comunidad.setNombreCreador(rs.getString("nombre_creador"));
        } catch (SQLException e) {
            // Campos opcionales del JOIN, pueden no estar disponibles
        }

        return comunidad;
    }
}
