/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.aquasocial.entity;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Publicacion {

    private int idPublicacion;
    private int idUsuario;
    private String nombreUsuario;
    private String NombreCompleto;
    private String avatarUsuario;
    private String texto;
    private String imagenUrl;
    private boolean permiteDonacion;
    private boolean estaAprobado;
    private LocalDateTime fechaPublicacion;
    private int cantidadLikes;
    private int cantidadComentarios;
    private double totalDonaciones;
    private boolean usuarioDioLike;
    private Integer idComunidad;
    private String nombreComunidad;

    // Constructor vacío
    public Publicacion() {
        this.fechaPublicacion = LocalDateTime.now();
        this.estaAprobado = false;
        this.cantidadLikes = 0;
        this.cantidadComentarios = 0;
        this.totalDonaciones = 0.0;
        this.usuarioDioLike = false;
    }

    // Constructor para crear publicación
    public Publicacion(int idUsuario, String texto, boolean permiteDonacion) {
        this();
        this.idUsuario = idUsuario;
        this.texto = texto;
        this.permiteDonacion = permiteDonacion;
    }

    // Getters y Setters
    public int getIdPublicacion() {
        return idPublicacion;
    }

    public void setIdPublicacion(int idPublicacion) {
        this.idPublicacion = idPublicacion;
    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    public String getNombreUsuario() {
        return nombreUsuario;
    }

    public void setNombreUsuario(String nombreUsuario) {
        this.nombreUsuario = nombreUsuario;
    }

    public String getNombreCompleto() {
        return NombreCompleto;
    }

    public void setNombreCompleto(String NombreCompleto) {
        this.NombreCompleto = NombreCompleto;
    }

    public String getAvatarUsuario() {
        return avatarUsuario;
    }

    public void setAvatarUsuario(String avatarUsuario) {
        this.avatarUsuario = avatarUsuario;
    }

    public String getTexto() {
        return texto;
    }

    public void setTexto(String texto) {
        this.texto = texto;
    }

    public String getImagenUrl() {
        return imagenUrl;
    }

    public void setImagenUrl(String imagenUrl) {
        this.imagenUrl = imagenUrl;
    }

    public boolean isPermiteDonacion() {
        return permiteDonacion;
    }

    public void setPermiteDonacion(boolean permiteDonacion) {
        this.permiteDonacion = permiteDonacion;
    }

    public boolean isEstaAprobado() {
        return estaAprobado;
    }

    public void setEstaAprobado(boolean estaAprobado) {
        this.estaAprobado = estaAprobado;
    }

    public LocalDateTime getFechaPublicacion() {
        return fechaPublicacion;
    }

    public void setFechaPublicacion(LocalDateTime fechaPublicacion) {
        this.fechaPublicacion = fechaPublicacion;
    }

    public int getCantidadLikes() {
        return cantidadLikes;
    }

    public void setCantidadLikes(int cantidadLikes) {
        this.cantidadLikes = cantidadLikes;
    }

    public int getCantidadComentarios() {
        return cantidadComentarios;
    }

    public void setCantidadComentarios(int cantidadComentarios) {
        this.cantidadComentarios = cantidadComentarios;
    }

    public double getTotalDonaciones() {
        return totalDonaciones;
    }

    public void setTotalDonaciones(double totalDonaciones) {
        this.totalDonaciones = totalDonaciones;
    }

    public boolean isUsuarioDioLike() {
        return usuarioDioLike;
    }

    public void setUsuarioDioLike(boolean usuarioDioLike) {
        this.usuarioDioLike = usuarioDioLike;
    }

    public Integer getIdComunidad() {
        return idComunidad;
    }

    public void setIdComunidad(Integer idComunidad) {
        this.idComunidad = idComunidad;
    }

    public String getNombreComunidad() {
        return nombreComunidad;
    }

    public void setNombreComunidad(String nombreComunidad) {
        this.nombreComunidad = nombreComunidad;
    }

    public boolean esDeComunidad() {
        return idComunidad != null && idComunidad > 0;
    }

    // Métodos de utilidad
    public String getFechaFormateada() {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        return fechaPublicacion.format(formatter);
    }

    public String getTiempoTranscurrido() {
        LocalDateTime ahora = LocalDateTime.now();
        long minutos = java.time.Duration.between(fechaPublicacion, ahora).toMinutes();

        if (minutos < 1) {
            return "ahora";
        }
        if (minutos < 60) {
            return "hace " + minutos + " min";
        }

        long horas = minutos / 60;
        if (horas < 24) {
            return "hace " + horas + " h";
        }

        long dias = horas / 24;
        return "hace " + dias + " d";
    }

    @Override
    public String toString() {
        return "Publicacion{"
                + "idPublicacion=" + idPublicacion
                + ", nombreUsuario='" + nombreUsuario + '\''
                + ", texto='" + texto + '\''
                + ", likes=" + cantidadLikes
                + ", comentarios=" + cantidadComentarios
                + '}';
    }
}
