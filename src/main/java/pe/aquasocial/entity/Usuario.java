/*
 * Modelo Usuario actualizado con campos para gestión de perfil
 * Compatible con PerfilDAO y sistema de fechas
 */
package pe.aquasocial.entity;

import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 * Entidad Usuario con campos adicionales para gestión de perfil
 */
public class Usuario {
    
    // Atributos principales
    private int id;
    private String username;
    private String nombreCompleto;
    private String password;
    private String email;
    private String rol;
    private String avatar;
    private boolean verificado;
    private boolean privilegio;
    private boolean baneado;
    private boolean solicitoVerificacion;
    private String telefono;
    private int intentosFallidos;
    private Timestamp bloqueHasta;
    private Timestamp fechaRegistro;
    
    private LocalDateTime fechaCreacion;
    private LocalDateTime ultimoAcceso;
    private LocalDateTime fechaActualizacion;
    private boolean notificacionesEmail;
    private boolean perfilPrivado;
    private boolean activo;
    private String bio; // Descripción del usuario
    
    // Constructores
    public Usuario() {
        this.activo = true;
        this.notificacionesEmail = true;
        this.perfilPrivado = false;
        this.fechaCreacion = LocalDateTime.now();
    }
    
    public Usuario(String username, String nombreCompleto, String email, String password) {
        this();
        this.username = username;
        this.nombreCompleto = nombreCompleto;
        this.email = email;
        this.password = password;
    }
    
    // Getters y Setters existentes
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getNombreCompleto() {
        return nombreCompleto;
    }

    public void setNombreCompleto(String nombreCompleto) {
        this.nombreCompleto = nombreCompleto;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public boolean isVerificado() {
        return verificado;
    }

    public void setVerificado(boolean verificado) {
        this.verificado = verificado;
    }

    public boolean isPrivilegio() {
        return privilegio;
    }

    public void setPrivilegio(boolean privilegio) {
        this.privilegio = privilegio;
    }

    public boolean isBaneado() {
        return baneado;
    }

    public void setBaneado(boolean baneado) {
        this.baneado = baneado;
    }

    public boolean isSolicitoVerificacion() {
        return solicitoVerificacion;
    }

    public void setSolicitoVerificacion(boolean solicitoVerificacion) {
        this.solicitoVerificacion = solicitoVerificacion;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public int getIntentosFallidos() {
        return intentosFallidos;
    }

    public void setIntentosFallidos(int intentosFallidos) {
        this.intentosFallidos = intentosFallidos;
    }

    public Timestamp getBloqueHasta() {
        return bloqueHasta;
    }

    public void setBloqueHasta(Timestamp bloqueHasta) {
        this.bloqueHasta = bloqueHasta;
    }

    public Timestamp getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(Timestamp fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }
    
    // ⭐ NUEVOS GETTERS Y SETTERS PARA PERFIL
    
    /**
     * Obtener fecha de creación de la cuenta
     */
    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }

    /**
     * Establecer fecha de creación de la cuenta
     */
    public void setFechaCreacion(LocalDateTime fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    /**
     * Obtener fecha del último acceso
     */
    public LocalDateTime getUltimoAcceso() {
        return ultimoAcceso;
    }

    /**
     * Establecer fecha del último acceso
     */
    public void setUltimoAcceso(LocalDateTime ultimoAcceso) {
        this.ultimoAcceso = ultimoAcceso;
    }

    /**
     * Obtener fecha de última actualización del perfil
     */
    public LocalDateTime getFechaActualizacion() {
        return fechaActualizacion;
    }

    /**
     * Establecer fecha de última actualización del perfil
     */
    public void setFechaActualizacion(LocalDateTime fechaActualizacion) {
        this.fechaActualizacion = fechaActualizacion;
    }

    /**
     * Verificar si el usuario tiene notificaciones por email habilitadas
     */
    public boolean isNotificacionesEmail() {
        return notificacionesEmail;
    }

    /**
     * Establecer preferencia de notificaciones por email
     */
    public void setNotificacionesEmail(boolean notificacionesEmail) {
        this.notificacionesEmail = notificacionesEmail;
    }

    /**
     * Verificar si el perfil del usuario es privado
     */
    public boolean isPerfilPrivado() {
        return perfilPrivado;
    }

    /**
     * Establecer privacidad del perfil
     */
    public void setPerfilPrivado(boolean perfilPrivado) {
        this.perfilPrivado = perfilPrivado;
    }

    /**
     * Verificar si el usuario está activo
     */
    public boolean isActivo() {
        return activo;
    }

    /**
     * Establecer estado activo del usuario
     */
    public void setActivo(boolean activo) {
        this.activo = activo;
    }

    /**
     * Obtener biografía/descripción del usuario
     */
    public String getBio() {
        return bio;
    }

    /**
     * Establecer biografía/descripción del usuario
     */
    public void setBio(String bio) {
        this.bio = bio;
    }
    
    // ⭐ MÉTODOS DE CONVENIENCIA PARA COMPATIBILIDAD
    
    /**
     * Obtener fecha de creación como Timestamp (compatibilidad)
     */
    public Timestamp getFechaCreacionTimestamp() {
        return fechaCreacion != null ? Timestamp.valueOf(fechaCreacion) : null;
    }
    
    /**
     * Establecer fecha de creación desde Timestamp (compatibilidad)
     */
    public void setFechaCreacionTimestamp(Timestamp timestamp) {
        this.fechaCreacion = timestamp != null ? timestamp.toLocalDateTime() : null;
    }
    
    /**
     * Obtener último acceso como Timestamp (compatibilidad)
     */
    public Timestamp getUltimoAccesoTimestamp() {
        return ultimoAcceso != null ? Timestamp.valueOf(ultimoAcceso) : null;
    }
    
    /**
     * Establecer último acceso desde Timestamp (compatibilidad)
     */
    public void setUltimoAccesoTimestamp(Timestamp timestamp) {
        this.ultimoAcceso = timestamp != null ? timestamp.toLocalDateTime() : null;
    }
    
    // ⭐ MÉTODOS UTILITARIOS
    
    /**
     * Verificar si el usuario está verificado y activo
     */
    public boolean estaVerificadoYActivo() {
        return verificado && activo && !baneado;
    }
    
    /**
     * Obtener iniciales del nombre para avatar por defecto
     */
    public String getIniciales() {
        if (nombreCompleto == null || nombreCompleto.trim().isEmpty()) {
            return username != null && !username.isEmpty() ? 
                   username.substring(0, 1).toUpperCase() : "U";
        }
        
        String[] partes = nombreCompleto.trim().split("\\s+");
        if (partes.length >= 2) {
            return (partes[0].substring(0, 1) + partes[1].substring(0, 1)).toUpperCase();
        } else {
            return partes[0].substring(0, 1).toUpperCase();
        }
    }
    
    /**
     * Verificar si tiene avatar personalizado
     */
    public boolean tieneAvatarPersonalizado() {
        return avatar != null && !avatar.trim().isEmpty();
    }
    
    /**
     * Obtener URL del avatar o generar uno por defecto
     */
    public String getAvatarODefecto() {
        return tieneAvatarPersonalizado() ? avatar : generarAvatarDefecto();
    }
    
    /**
     * Generar URL de avatar por defecto basado en iniciales
     */
    private String generarAvatarDefecto() {
        // Podrías usar un servicio como UI Avatars o similar
        String iniciales = getIniciales();
        return "https://ui-avatars.com/api/?name=" + iniciales + "&background=007bff&color=fff&size=128";
    }
    
    /**
     * Verificar si puede recibir notificaciones
     */
    public boolean puedeRecibirNotificaciones() {
        return activo && !baneado && notificacionesEmail;
    }
    
    /**
     * Obtener nombre para mostrar (nombre completo o username)
     */
    public String getNombreParaMostrar() {
        return (nombreCompleto != null && !nombreCompleto.trim().isEmpty()) ? 
               nombreCompleto : username;
    }
    
    // Métodos toString, equals y hashCode
    @Override
    public String toString() {
        return "Usuario{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", nombreCompleto='" + nombreCompleto + '\'' +
                ", email='" + email + '\'' +
                ", verificado=" + verificado +
                ", activo=" + activo +
                ", fechaCreacion=" + fechaCreacion +
                '}';
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        
        Usuario usuario = (Usuario) obj;
        return id == usuario.id;
    }

    @Override
    public int hashCode() {
        return Integer.hashCode(id);
    }
}