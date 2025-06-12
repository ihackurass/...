/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.aquasocial.entity;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Comentario {
    private int idComentario;
    private int idPublicacion;
    private int idUsuario;
    private String nombreUsuario;
    private String usernameUsuario;
    private String avatarUsuario;
    private String contenido;
    private LocalDateTime fechaComentario;
    
    // Constructor vacío
    public Comentario() {
        this.fechaComentario = LocalDateTime.now();
    }
    
    // Constructor con parámetros principales
    public Comentario(int idPublicacion, int idUsuario, String contenido) {
        this();
        this.idPublicacion = idPublicacion;
        this.idUsuario = idUsuario;
        this.contenido = contenido;
    }
    
    // Getters y Setters
    public int getIdComentario() { return idComentario; }
    public void setIdComentario(int idComentario) { this.idComentario = idComentario; }
    
    public int getIdPublicacion() { return idPublicacion; }
    public void setIdPublicacion(int idPublicacion) { this.idPublicacion = idPublicacion; }
    
    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }
    
    public String getNombreUsuario() { return nombreUsuario; }
    public void setNombreUsuario(String nombreUsuario) { this.nombreUsuario = nombreUsuario; }
    
    public String getUsernameUsuario() { return usernameUsuario; }
    public void setUsernameUsuario(String usernameUsuario) { this.usernameUsuario = usernameUsuario; }
    
    public String getAvatarUsuario() { return avatarUsuario; }
    public void setAvatarUsuario(String avatarUsuario) { this.avatarUsuario = avatarUsuario; }
    
    public String getContenido() { return contenido; }
    public void setContenido(String contenido) { this.contenido = contenido; }
    
    public LocalDateTime getFechaComentario() { return fechaComentario; }
    public void setFechaComentario(LocalDateTime fechaComentario) { this.fechaComentario = fechaComentario; }
    
    // Métodos de utilidad
    public String getHoraFormateada() {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm a");
        return fechaComentario.format(formatter);
    }
    
    public String getFechaFormateada() {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        return fechaComentario.format(formatter);
    }
    
    public String getTiempoTranscurrido() {
        LocalDateTime ahora = LocalDateTime.now();
        long minutos = java.time.Duration.between(fechaComentario, ahora).toMinutes();
        
        if (minutos < 1) return "ahora";
        if (minutos < 60) return "hace " + minutos + " min";
        
        long horas = minutos / 60;
        if (horas < 24) return "hace " + horas + " h";
        
        long dias = horas / 24;
        return "hace " + dias + " d";
    }
    
    @Override
    public String toString() {
        return "Comentario{" +
                "idComentario=" + idComentario +
                ", idPublicacion=" + idPublicacion +
                ", nombreUsuario='" + nombreUsuario + '\'' +
                ", contenido='" + contenido + '\'' +
                ", fechaComentario=" + fechaComentario +
                '}';
    }
}