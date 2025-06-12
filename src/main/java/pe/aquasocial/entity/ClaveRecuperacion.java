/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.aquasocial.entity;

import java.sql.Timestamp;

/**
 *
 * @author Home
 */
public class ClaveRecuperacion {

    // Atributos
    private int id;
    private int usuarioId;
    private String claveSecreta;
    private Timestamp fechaCreacion;

    // Constructores
    public ClaveRecuperacion() {
    }

    public ClaveRecuperacion(int usuarioId, String claveSecreta) {
        this.usuarioId = usuarioId;
        this.claveSecreta = claveSecreta;
    }

    public ClaveRecuperacion(int id, int usuarioId, String claveSecreta, Timestamp fechaCreacion) {
        this.id = id;
        this.usuarioId = usuarioId;
        this.claveSecreta = claveSecreta;
        this.fechaCreacion = fechaCreacion;
    }

    // Getters y Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(int usuarioId) {
        this.usuarioId = usuarioId;
    }

    public String getClaveSecreta() {
        return claveSecreta;
    }

    public void setClaveSecreta(String claveSecreta) {
        this.claveSecreta = claveSecreta;
    }

    public Timestamp getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(Timestamp fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    // Métodos toString, equals y hashCode
    @Override
    public String toString() {
        return "ClaveRecuperacion{"
                + "id=" + id
                + ", usuarioId=" + usuarioId
                + ", claveSecreta='" + claveSecreta + '\''
                + ", fechaCreacion=" + fechaCreacion
                + '}';
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null || getClass() != obj.getClass()) {
            return false;
        }

        ClaveRecuperacion that = (ClaveRecuperacion) obj;
        return id == that.id;
    }

    @Override
    public int hashCode() {
        return Integer.hashCode(id);
    }
}
