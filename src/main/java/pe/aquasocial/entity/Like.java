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

public class Like {
    private int idLike;
    private int idPublicacion;
    private int idUsuario;
    private LocalDateTime fechaLike;
    
    // Constructor vacío
    public Like() {
        this.fechaLike = LocalDateTime.now();
    }
    
    // Constructor con parámetros
    public Like(int idPublicacion, int idUsuario) {
        this();
        this.idPublicacion = idPublicacion;
        this.idUsuario = idUsuario;
    }
    
    // Getters y Setters
    public int getIdLike() { return idLike; }
    public void setIdLike(int idLike) { this.idLike = idLike; }
    
    public int getIdPublicacion() { return idPublicacion; }
    public void setIdPublicacion(int idPublicacion) { this.idPublicacion = idPublicacion; }
    
    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }
    
    public LocalDateTime getFechaLike() { return fechaLike; }
    public void setFechaLike(LocalDateTime fechaLike) { this.fechaLike = fechaLike; }
    
    @Override
    public String toString() {
        return "Like{" +
                "idLike=" + idLike +
                ", idPublicacion=" + idPublicacion +
                ", idUsuario=" + idUsuario +
                ", fechaLike=" + fechaLike +
                '}';
    }
}
