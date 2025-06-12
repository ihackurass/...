/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.aquasocial.entity;

import java.sql.Timestamp;

/**
 *
 * @author Rodrigo
 */
public class Usuario {
    // Atributos
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

    // Getters y Setters
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
}