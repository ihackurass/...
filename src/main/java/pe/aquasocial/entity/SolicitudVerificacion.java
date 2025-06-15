/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.aquasocial.entity;

import java.time.LocalDateTime;

/**
 *
 * @author Home
 */
public class SolicitudVerificacion {
    private int id;
    private int idUsuario;
    private String motivo;
    private String categoria;
    private String documentoUrl;
    private String enlacesAdicionales;
    private String estado; // 'pendiente', 'aprobada', 'rechazada'
    private LocalDateTime fechaSolicitud;
    private LocalDateTime fechaRespuesta;
    private String mensajeAdmin;
    
    // Datos del usuario (para JOIN)
    private String usernameUsuario;
    private String nombreCompletoUsuario;
    private String emailUsuario;
    private String avatarUsuario;
    
    // Constructores
    public SolicitudVerificacion() {}
    
    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }
    
    public String getMotivo() { return motivo; }
    public void setMotivo(String motivo) { this.motivo = motivo; }
    
    public String getCategoria() { return categoria; }
    public void setCategoria(String categoria) { this.categoria = categoria; }
    
    public String getDocumentoUrl() { return documentoUrl; }
    public void setDocumentoUrl(String documentoUrl) { this.documentoUrl = documentoUrl; }
    
    public String getEnlacesAdicionales() { return enlacesAdicionales; }
    public void setEnlacesAdicionales(String enlacesAdicionales) { this.enlacesAdicionales = enlacesAdicionales; }
    
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    
    public LocalDateTime getFechaSolicitud() { return fechaSolicitud; }
    public void setFechaSolicitud(LocalDateTime fechaSolicitud) { this.fechaSolicitud = fechaSolicitud; }
    
    public LocalDateTime getFechaRespuesta() { return fechaRespuesta; }
    public void setFechaRespuesta(LocalDateTime fechaRespuesta) { this.fechaRespuesta = fechaRespuesta; }
    
    public String getMensajeAdmin() { return mensajeAdmin; }
    public void setMensajeAdmin(String mensajeAdmin) { this.mensajeAdmin = mensajeAdmin; }
    
    public String getUsernameUsuario() { return usernameUsuario; }
    public void setUsernameUsuario(String usernameUsuario) { this.usernameUsuario = usernameUsuario; }
    
    public String getNombreCompletoUsuario() { return nombreCompletoUsuario; }
    public void setNombreCompletoUsuario(String nombreCompletoUsuario) { this.nombreCompletoUsuario = nombreCompletoUsuario; }
    
    public String getEmailUsuario() { return emailUsuario; }
    public void setEmailUsuario(String emailUsuario) { this.emailUsuario = emailUsuario; }
    
    public String getAvatarUsuario() { return avatarUsuario; }
    public void setAvatarUsuario(String avatarUsuario) { this.avatarUsuario = avatarUsuario; }
    
    // Métodos utilitarios
    public boolean esPendiente() { return "pendiente".equals(estado); }
    public boolean esAprobada() { return "aprobada".equals(estado); }
    public boolean esRechazada() { return "rechazada".equals(estado); }
}