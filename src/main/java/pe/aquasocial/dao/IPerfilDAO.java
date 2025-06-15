/*
 * Interfaz para la gestión del perfil de usuario
 * Define los métodos necesarios para actualizar información personal,
 * contraseñas, avatares y obtener estadísticas del usuario
 */
package pe.aquasocial.dao;

import pe.aquasocial.entity.Usuario;
import java.util.Map;

public interface IPerfilDAO {
    
    // ============= GESTIÓN DE INFORMACIÓN PERSONAL =============
    
    /**
     * Actualizar información básica del usuario
     * @param usuario Usuario con los datos actualizados
     * @return true si se actualizó correctamente, false en caso contrario
     */
    boolean actualizarInformacion(Usuario usuario);
    
    /**
     * Verificar si un email ya existe en la base de datos
     * @param email Email a verificar
     * @return true si el email ya existe, false en caso contrario
     */
    boolean existeEmail(String email);
    
    /**
     * Verificar si un email ya existe excluyendo un usuario específico
     * @param email Email a verificar
     * @param idUsuarioExcluir ID del usuario a excluir de la búsqueda
     * @return true si el email ya existe en otro usuario, false en caso contrario
     */
    boolean existeEmailOtroUsuario(String email, int idUsuarioExcluir);
    
    // ============= GESTIÓN DE CONTRASEÑAS =============
    
    /**
     * Verificar la contraseña actual del usuario
     * @param idUsuario ID del usuario
     * @param passwordActual Contraseña a verificar
     * @return true si la contraseña es correcta, false en caso contrario
     */
    boolean verificarPassword(int idUsuario, String passwordActual);
    
    /**
     * Cambiar la contraseña del usuario
     * @param idUsuario ID del usuario
     * @param nuevaPassword Nueva contraseña (se encriptará automáticamente)
     * @return true si se cambió correctamente, false en caso contrario
     */
    boolean cambiarPassword(int idUsuario, String nuevaPassword);
    
    /**
     * Obtener el hash de la contraseña actual (para validaciones adicionales)
     * @param idUsuario ID del usuario
     * @return Hash de la contraseña actual o null si no se encuentra
     */
    String obtenerHashPassword(int idUsuario);
    
    // ============= GESTIÓN DE AVATARES =============
    
    /**
     * Actualizar la URL del avatar del usuario
     * @param idUsuario ID del usuario
     * @param avatarUrl Nueva URL del avatar
     * @return true si se actualizó correctamente, false en caso contrario
     */
    boolean actualizarAvatar(int idUsuario, String avatarUrl);
    
    /**
     * Obtener la URL actual del avatar del usuario
     * @param idUsuario ID del usuario
     * @return URL del avatar actual o null si no tiene
     */
    String obtenerAvatarActual(int idUsuario);
    
    /**
     * Eliminar avatar del usuario (establecer como null)
     * @param idUsuario ID del usuario
     * @return true si se eliminó correctamente, false en caso contrario
     */
    boolean eliminarAvatar(int idUsuario);
    
    // ============= ESTADÍSTICAS DEL USUARIO =============
    
    /**
     * Obtener todas las estadísticas del usuario
     * @param idUsuario ID del usuario
     * @return Map con las estadísticas (comunidades_seguidas, solicitudes_enviadas, etc.)
     */
    Map<String, Integer> obtenerEstadisticasCompletas(int idUsuario);
    
    /**
     * Contar comunidades que sigue el usuario
     * @param idUsuario ID del usuario
     * @return Número de comunidades seguidas
     */
    int contarComunidadesSeguidas(int idUsuario);
    
    /**
     * Contar solicitudes de membresía enviadas por el usuario
     * @param idUsuario ID del usuario
     * @return Número total de solicitudes enviadas
     */
    int contarSolicitudesEnviadas(int idUsuario);
    
    /**
     * Contar solicitudes aprobadas del usuario
     * @param idUsuario ID del usuario
     * @return Número de solicitudes aprobadas
     */
    int contarSolicitudesAprobadas(int idUsuario);
    
    /**
     * Contar solicitudes rechazadas del usuario
     * @param idUsuario ID del usuario
     * @return Número de solicitudes rechazadas
     */
    int contarSolicitudesRechazadas(int idUsuario);
    
    /**
     * Contar solicitudes pendientes del usuario
     * @param idUsuario ID del usuario
     * @return Número de solicitudes pendientes
     */
    int contarSolicitudesPendientes(int idUsuario);
    
    /**
     * Contar comunidades donde el usuario es administrador
     * @param idUsuario ID del usuario
     * @return Número de comunidades donde es admin
     */
    int contarComunidadesAdmin(int idUsuario);
    
    /**
     * Contar comunidades creadas por el usuario
     * @param idUsuario ID del usuario
     * @return Número de comunidades creadas
     */
    int contarComunidadesCreadas(int idUsuario);
    
    // ============= INFORMACIÓN ADICIONAL =============
    
    /**
     * Obtener fecha del último acceso del usuario
     * @param idUsuario ID del usuario
     * @return Fecha del último acceso o null si no disponible
     */
    java.time.LocalDateTime obtenerUltimoAcceso(int idUsuario);
    
    /**
     * Actualizar fecha del último acceso del usuario
     * @param idUsuario ID del usuario
     * @return true si se actualizó correctamente, false en caso contrario
     */
    boolean actualizarUltimoAcceso(int idUsuario);
    
    /**
     * Verificar si el usuario está verificado
     * @param idUsuario ID del usuario
     * @return true si está verificado, false en caso contrario
     */
    boolean estaVerificado(int idUsuario);
    
    /**
     * Obtener información completa del usuario por ID
     * @param idUsuario ID del usuario
     * @return Usuario completo o null si no se encuentra
     */
    Usuario obtenerUsuarioCompleto(int idUsuario);
    
    // ============= MÉTODOS DE CONFIGURACIÓN =============
    
    /**
     * Actualizar configuración de notificaciones del usuario
     * @param idUsuario ID del usuario
     * @param notificacionesEmail true para recibir notificaciones por email
     * @return true si se actualizó correctamente, false en caso contrario
     */
    boolean actualizarConfiguracionNotificaciones(int idUsuario, boolean notificacionesEmail);
    
    /**
     * Obtener configuración de notificaciones del usuario
     * @param idUsuario ID del usuario
     * @return true si tiene notificaciones habilitadas, false en caso contrario
     */
    boolean obtenerConfiguracionNotificaciones(int idUsuario);
    
    /**
     * Actualizar preferencia de privacidad del perfil
     * @param idUsuario ID del usuario
     * @param perfilPrivado true para perfil privado, false para público
     * @return true si se actualizó correctamente, false en caso contrario
     */
    boolean actualizarPrivacidadPerfil(int idUsuario, boolean perfilPrivado);
    
    /**
     * Verificar si el perfil del usuario es privado
     * @param idUsuario ID del usuario
     * @return true si el perfil es privado, false en caso contrario
     */
    boolean esPerfilPrivado(int idUsuario);
    
    // ============= MÉTODOS DE VALIDACIÓN =============
    
    /**
     * Validar que el usuario existe y está activo
     * @param idUsuario ID del usuario
     * @return true si el usuario existe y está activo, false en caso contrario
     */
    boolean validarUsuarioActivo(int idUsuario);
    
    /**
     * Validar formato de email
     * @param email Email a validar
     * @return true si el formato es válido, false en caso contrario
     */
    boolean validarFormatoEmail(String email);
    
    /**
     * Validar fortaleza de contraseña
     * @param password Contraseña a validar
     * @return true si cumple los criterios mínimos, false en caso contrario
     */
    boolean validarFortalezaPassword(String password);
}