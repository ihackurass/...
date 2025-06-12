/*
 * Clase Modelo ComunidadMiembro para gestión de membresías
 * Compatible con agua_bendita_db
 */
package pe.aquasocial.entity;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class ComunidadMiembro {
    
    // Atributos principales
    private int idMembresia;
    private int idComunidad;
    private int idUsuario;
    private String rol; // "seguidor" o "admin"
    private LocalDateTime fechaUnion;
    
    // Datos adicionales para vistas (no en BD)
    private String nombreUsuario;
    private String usernameUsuario;
    private String nombreCompletoUsuario;
    private String avatarUsuario;
    private String nombreComunidad;
    private String emailUsuario;
    private boolean usuarioVerificado;
    private boolean usuarioPrivilegiado;
    
    // Constantes para roles
    public static final String ROL_SEGUIDOR = "seguidor";
    public static final String ROL_ADMIN = "admin";
    
    // Constructores
    public ComunidadMiembro() {
        this.fechaUnion = LocalDateTime.now();
        this.rol = ROL_SEGUIDOR;
    }
    
    public ComunidadMiembro(int idComunidad, int idUsuario) {
        this();
        this.idComunidad = idComunidad;
        this.idUsuario = idUsuario;
    }
    
    public ComunidadMiembro(int idComunidad, int idUsuario, String rol) {
        this(idComunidad, idUsuario);
        this.rol = rol;
    }
    
    public ComunidadMiembro(int idMembresia, int idComunidad, int idUsuario, String rol, LocalDateTime fechaUnion) {
        this.idMembresia = idMembresia;
        this.idComunidad = idComunidad;
        this.idUsuario = idUsuario;
        this.rol = rol;
        this.fechaUnion = fechaUnion;
    }
    
    // Getters y Setters
    public int getIdMembresia() {
        return idMembresia;
    }
    
    public void setIdMembresia(int idMembresia) {
        this.idMembresia = idMembresia;
    }
    
    public int getIdComunidad() {
        return idComunidad;
    }
    
    public void setIdComunidad(int idComunidad) {
        this.idComunidad = idComunidad;
    }
    
    public int getIdUsuario() {
        return idUsuario;
    }
    
    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }
    
    public String getRol() {
        return rol;
    }
    
    public void setRol(String rol) {
        this.rol = rol;
    }
    
    public LocalDateTime getFechaUnion() {
        return fechaUnion;
    }
    
    public void setFechaUnion(LocalDateTime fechaUnion) {
        this.fechaUnion = fechaUnion;
    }
    
    // Datos adicionales para vistas
    public String getNombreUsuario() {
        return nombreUsuario;
    }
    
    public void setNombreUsuario(String nombreUsuario) {
        this.nombreUsuario = nombreUsuario;
    }
    
    public String getUsernameUsuario() {
        return usernameUsuario;
    }
    
    public void setUsernameUsuario(String usernameUsuario) {
        this.usernameUsuario = usernameUsuario;
    }
    
    public String getNombreCompletoUsuario() {
        return nombreCompletoUsuario;
    }
    
    public void setNombreCompletoUsuario(String nombreCompletoUsuario) {
        this.nombreCompletoUsuario = nombreCompletoUsuario;
    }
    
    public String getAvatarUsuario() {
        return avatarUsuario;
    }
    
    public void setAvatarUsuario(String avatarUsuario) {
        this.avatarUsuario = avatarUsuario;
    }
    
    public String getNombreComunidad() {
        return nombreComunidad;
    }
    
    public void setNombreComunidad(String nombreComunidad) {
        this.nombreComunidad = nombreComunidad;
    }
    
    public String getEmailUsuario() {
        return emailUsuario;
    }
    
    public void setEmailUsuario(String emailUsuario) {
        this.emailUsuario = emailUsuario;
    }
    
    public boolean isUsuarioVerificado() {
        return usuarioVerificado;
    }
    
    public void setUsuarioVerificado(boolean usuarioVerificado) {
        this.usuarioVerificado = usuarioVerificado;
    }
    
    public boolean isUsuarioPrivilegiado() {
        return usuarioPrivilegiado;
    }
    
    public void setUsuarioPrivilegiado(boolean usuarioPrivilegiado) {
        this.usuarioPrivilegiado = usuarioPrivilegiado;
    }
    
    // Métodos de utilidad para roles
    public boolean esAdmin() {
        return ROL_ADMIN.equals(rol);
    }
    
    public boolean esSeguidor() {
        return ROL_SEGUIDOR.equals(rol);
    }
    
    public void promoverAAdmin() {
        this.rol = ROL_ADMIN;
    }
    
    public void degradarASeguidor() {
        this.rol = ROL_SEGUIDOR;
    }
    
    // Métodos de utilidad para fechas
    public String getFechaUnionFormateada() {
        if (fechaUnion != null) {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
            return fechaUnion.format(formatter);
        }
        return "";
    }
    
    public String getFechaUnionCorta() {
        if (fechaUnion != null) {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            return fechaUnion.format(formatter);
        }
        return "";
    }
    
    public String getTiempoComoMiembro() {
        if (fechaUnion != null) {
            LocalDateTime ahora = LocalDateTime.now();
            long dias = java.time.Duration.between(fechaUnion, ahora).toDays();
            
            if (dias == 0) {
                return "Se unió hoy";
            } else if (dias == 1) {
                return "Se unió ayer";
            } else if (dias < 7) {
                return "Miembro desde hace " + dias + " días";
            } else if (dias < 30) {
                long semanas = dias / 7;
                return "Miembro desde hace " + semanas + " semana" + (semanas > 1 ? "s" : "");
            } else if (dias < 365) {
                long meses = dias / 30;
                return "Miembro desde hace " + meses + " mes" + (meses > 1 ? "es" : "");
            } else {
                long años = dias / 365;
                return "Miembro desde hace " + años + " año" + (años > 1 ? "s" : "");
            }
        }
        return "";
    }
    
    // Métodos de utilidad para UI
    public String getAvatarUsuarioSeguro() {
        if (avatarUsuario == null || avatarUsuario.trim().isEmpty() || avatarUsuario.equals("null")) {
            return "assets/images/avatars/default.png";
        }
        return avatarUsuario;
    }
    
    public String getUsernameUsuarioFormateado() {
        if (usernameUsuario != null && !usernameUsuario.startsWith("@")) {
            return "@" + usernameUsuario;
        }
        return usernameUsuario != null ? usernameUsuario : "";
    }
    
    public String getNombreCompletoOUsername() {
        if (nombreCompletoUsuario != null && !nombreCompletoUsuario.trim().isEmpty()) {
            return nombreCompletoUsuario;
        }
        return nombreUsuario != null ? nombreUsuario : "Usuario";
    }
    
    public String getRolFormateado() {
        switch (rol) {
            case ROL_ADMIN:
                return "Administrador";
            case ROL_SEGUIDOR:
                return "Seguidor";
            default:
                return "Miembro";
        }
    }
    
    public String getRolIcono() {
        switch (rol) {
            case ROL_ADMIN:
                return "🛡️";
            case ROL_SEGUIDOR:
                return "👤";
            default:
                return "❓";
        }
    }
    
    // Métodos para validación
    public boolean esRolValido() {
        return ROL_SEGUIDOR.equals(rol) || ROL_ADMIN.equals(rol);
    }
    
    public boolean puedeSerPromovido() {
        return esSeguidor();
    }
    
    public boolean puedeSerDegradado() {
        return esAdmin();
    }
    
    // Override toString para debugging
    @Override
    public String toString() {
        return "ComunidadMiembro{" +
                "idMembresia=" + idMembresia +
                ", idComunidad=" + idComunidad +
                ", idUsuario=" + idUsuario +
                ", nombreUsuario='" + nombreUsuario + '\'' +
                ", rol='" + rol + '\'' +
                ", fechaUnion=" + fechaUnion +
                '}';
    }
    
    // Override equals y hashCode
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        
        ComunidadMiembro that = (ComunidadMiembro) obj;
        return idMembresia == that.idMembresia;
    }
    
    @Override
    public int hashCode() {
        return Integer.hashCode(idMembresia);
    }
}