package pe.aquasocial.entity;

import java.time.LocalDateTime;

/**
 * Entidad que representa una solicitud de membresía a una comunidad privada
 */
public class SolicitudMembresia {
    
    private int idSolicitud;
    private int idComunidad;
    private int idUsuario;
    private LocalDateTime fechaSolicitud;
    private String estado; // 'pendiente', 'aprobada', 'rechazada'
    private String mensajeSolicitud;
    private LocalDateTime fechaRespuesta;
    private Integer idAdminRespuesta;
    private String mensajeRespuesta;
    
    private String usernameUsuario;
    private String nombreCompletoUsuario;
    private String avatarUsuario;
    private String emailUsuario;
    
    private String usernameAdmin;
    private String nombreCompletoAdmin;
    
    private String nombreComunidad;
    private String usernameComunidad;
    
    // Constructores
    public SolicitudMembresia() {}
    
    public SolicitudMembresia(int idComunidad, int idUsuario, String mensajeSolicitud) {
        this.idComunidad = idComunidad;
        this.idUsuario = idUsuario;
        this.mensajeSolicitud = mensajeSolicitud;
        this.estado = "pendiente";
        this.fechaSolicitud = LocalDateTime.now();
    }
    
    // Getters y Setters
    public int getIdSolicitud() {
        return idSolicitud;
    }
    
    public void setIdSolicitud(int idSolicitud) {
        this.idSolicitud = idSolicitud;
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
    
    public LocalDateTime getFechaSolicitud() {
        return fechaSolicitud;
    }
    
    public void setFechaSolicitud(LocalDateTime fechaSolicitud) {
        this.fechaSolicitud = fechaSolicitud;
    }
    
    public String getEstado() {
        return estado;
    }
    
    public void setEstado(String estado) {
        this.estado = estado;
    }
    
    public String getMensajeSolicitud() {
        return mensajeSolicitud;
    }
    
    public void setMensajeSolicitud(String mensajeSolicitud) {
        this.mensajeSolicitud = mensajeSolicitud;
    }
    
    public LocalDateTime getFechaRespuesta() {
        return fechaRespuesta;
    }
    
    public void setFechaRespuesta(LocalDateTime fechaRespuesta) {
        this.fechaRespuesta = fechaRespuesta;
    }
    
    public Integer getIdAdminRespuesta() {
        return idAdminRespuesta;
    }
    
    public void setIdAdminRespuesta(Integer idAdminRespuesta) {
        this.idAdminRespuesta = idAdminRespuesta;
    }
    
    public String getMensajeRespuesta() {
        return mensajeRespuesta;
    }
    
    public void setMensajeRespuesta(String mensajeRespuesta) {
        this.mensajeRespuesta = mensajeRespuesta;
    }
    
    // Datos del usuario solicitante
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
    
    public String getEmailUsuario() {
        return emailUsuario;
    }
    
    public void setEmailUsuario(String emailUsuario) {
        this.emailUsuario = emailUsuario;
    }
    
    // Datos del admin
    public String getUsernameAdmin() {
        return usernameAdmin;
    }
    
    public void setUsernameAdmin(String usernameAdmin) {
        this.usernameAdmin = usernameAdmin;
    }
    
    public String getNombreCompletoAdmin() {
        return nombreCompletoAdmin;
    }
    
    public void setNombreCompletoAdmin(String nombreCompletoAdmin) {
        this.nombreCompletoAdmin = nombreCompletoAdmin;
    }
    
    // Datos de la comunidad
    public String getNombreComunidad() {
        return nombreComunidad;
    }
    
    public void setNombreComunidad(String nombreComunidad) {
        this.nombreComunidad = nombreComunidad;
    }
    
    public String getUsernameComunidad() {
        return usernameComunidad;
    }
    
    public void setUsernameComunidad(String usernameComunidad) {
        this.usernameComunidad = usernameComunidad;
    }
    
    // Métodos de utilidad
    public boolean esPendiente() {
        return "pendiente".equals(this.estado);
    }
    
    public boolean esAprobada() {
        return "aprobada".equals(this.estado);
    }
    
    public boolean esRechazada() {
        return "rechazada".equals(this.estado);
    }
    
    public String getEstadoDisplay() {
        switch (this.estado) {
            case "pendiente":
                return "Pendiente";
            case "aprobada":
                return "Aprobada";
            case "rechazada":
                return "Rechazada";
            default:
                return "Desconocido";
        }
    }
    
    public String getEstadoColorClass() {
        switch (this.estado) {
            case "pendiente":
                return "warning";
            case "aprobada":
                return "success";
            case "rechazada":
                return "danger";
            default:
                return "secondary";
        }
    }
    
    public boolean tieneRespuesta() {
        return fechaRespuesta != null;
    }
    
    @Override
    public String toString() {
        return "SolicitudMembresia{" +
                "idSolicitud=" + idSolicitud +
                ", idComunidad=" + idComunidad +
                ", idUsuario=" + idUsuario +
                ", estado='" + estado + '\'' +
                ", fechaSolicitud=" + fechaSolicitud +
                ", usernameUsuario='" + usernameUsuario + '\'' +
                ", nombreComunidad='" + nombreComunidad + '\'' +
                '}';
    }
}