/*
 * Interfaz para DAO de Comunidades
 * Define los métodos que debe implementar ComunidadDAO
 */
package pe.aquasocial.dao;

import java.util.List;
import pe.aquasocial.entity.Comunidad;
import pe.aquasocial.entity.ComunidadMiembro;

public interface IComunidadDAO {
    
    // ============= CRUD BÁSICO =============
    
    /**
     * Crear nueva comunidad
     * @param comunidad Objeto comunidad a crear
     * @return true si se creó exitosamente
     */
    boolean crear(Comunidad comunidad);
    
    /**
     * Obtener comunidad por ID
     * @param idComunidad ID de la comunidad
     * @return Objeto Comunidad o null si no existe
     */
    Comunidad obtenerPorId(int idComunidad);
    
    /**
     * Obtener todas las comunidades públicas
     * @return Lista de comunidades
     */
    List<Comunidad> obtenerTodas();
    
    /**
     * Actualizar datos de comunidad
     * @param comunidad Objeto con datos actualizados
     * @return true si se actualizó exitosamente
     */
    boolean actualizar(Comunidad comunidad);
    
    /**
     * Eliminar comunidad
     * @param idComunidad ID de la comunidad a eliminar
     * @return true si se eliminó exitosamente
     */
    boolean eliminar(int idComunidad);
    
    // ============= GESTIÓN DE MEMBRESÍAS =============
    
    /**
     * Agregar miembro a comunidad con rol específico
     * @param idComunidad ID de la comunidad
     * @param idUsuario ID del usuario
     * @param rol Rol del usuario (seguidor/admin)
     * @return true si se agregó exitosamente
     */
    boolean agregarMiembro(int idComunidad, int idUsuario, String rol);
    
    /**
     * Usuario sigue una comunidad
     * @param idUsuario ID del usuario
     * @param idComunidad ID de la comunidad
     * @return true si comenzó a seguir exitosamente
     */
    boolean seguirComunidad(int idUsuario, int idComunidad);
    
    /**
     * Usuario deja de seguir una comunidad
     * @param idUsuario ID del usuario
     * @param idComunidad ID de la comunidad
     * @return true si dejó de seguir exitosamente
     */
    boolean dejarDeSeguir(int idUsuario, int idComunidad);
    
    /**
     * Promover seguidor a administrador
     * @param idUsuario ID del usuario a promover
     * @param idComunidad ID de la comunidad
     * @return true si se promovió exitosamente
     */
    boolean promoverAAdmin(int idUsuario, int idComunidad);
    
    /**
     * Degradar administrador a seguidor
     * @param idUsuario ID del usuario a degradar
     * @param idComunidad ID de la comunidad
     * @return true si se degradó exitosamente
     */
    boolean degradarAdmin(int idUsuario, int idComunidad);
    
    // ============= VERIFICACIÓN DE PERMISOS =============
    
    /**
     * Verificar si usuario es miembro de comunidad
     * @param idUsuario ID del usuario
     * @param idComunidad ID de la comunidad
     * @return true si es miembro
     */
    boolean esMiembroDeComunidad(int idUsuario, int idComunidad);
    
    /**
     * Verificar si usuario es administrador de comunidad
     * @param idUsuario ID del usuario
     * @param idComunidad ID de la comunidad
     * @return true si es admin
     */
    boolean esAdminDeComunidad(int idUsuario, int idComunidad);
    
    /**
     * Verificar si usuario es creador de comunidad
     * @param idUsuario ID del usuario
     * @param idComunidad ID de la comunidad
     * @return true si es creador
     */
    boolean esCreadorDeComunidad(int idUsuario, int idComunidad);
    
    /**
     * Verificar si usuario es admin de alguna comunidad
     * @param idUsuario ID del usuario
     * @return true si es admin de al menos una comunidad
     */
    boolean esAdminDeAlgunaComunidad(int idUsuario);
    
    // ============= CONSULTAS ESPECÍFICAS =============
    
    /**
     * Obtener comunidades que sigue un usuario
     * @param idUsuario ID del usuario
     * @return Lista de comunidades seguidas
     */
    List<Comunidad> obtenerComunidadesSeguidas(int idUsuario);
    
    /**
     * Obtener comunidades que administra un usuario
     * @param idUsuario ID del usuario
     * @return Lista de comunidades administradas
     */
    List<Comunidad> obtenerComunidadesQueAdministra(int idUsuario);
    
    /**
     * Obtener todos los miembros de una comunidad
     * @param idComunidad ID de la comunidad
     * @return Lista de miembros
     */
    List<ComunidadMiembro> obtenerMiembrosPorComunidad(int idComunidad);
    
    /**
     * Buscar comunidades por nombre
     * @param nombre Término de búsqueda
     * @return Lista de comunidades que coinciden
     */
    List<Comunidad> buscarPorNombre(String nombre);
    
    // ============= UTILIDADES =============
    
    /**
     * Actualizar contador de seguidores de una comunidad
     * @param idComunidad ID de la comunidad
     */
    void actualizarContadorSeguidores(int idComunidad);
    
    /**
     * Actualizar contador de publicaciones de una comunidad
     * @param idComunidad ID de la comunidad
     */
    void actualizarContadorPublicaciones(int idComunidad);
}