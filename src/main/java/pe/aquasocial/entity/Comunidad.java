/*
 * Clase Modelo Comunidad para el sistema de comunidades
 * Compatible con agua_bendita_db
 */
package pe.aquasocial.entity;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Comunidad {
    
    // Atributos principales
    private int idComunidad;
    private String nombre;
    private String username;
    private String descripcion;
    private String imagenUrl;
    private int idCreador;
    private LocalDateTime fechaCreacion;
    private boolean esPublica;
    private int seguidoresCount;
    private int publicacionesCount;
    
    private String nombreCreador;
    private String usernameCreador;
    private String avatarCreador;
    private boolean usuarioEsSeguidor;
    private boolean usuarioEsAdmin;
    private boolean usuarioEsCreador;
    
    // Constructores
    public Comunidad() {
        this.fechaCreacion = LocalDateTime.now();
        this.esPublica = true;
        this.seguidoresCount = 0;
        this.publicacionesCount = 0;
    }
    
    public Comunidad(String nombre, String descripcion, int idCreador) {
        this();
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.idCreador = idCreador;
    }
    
    public Comunidad(String nombre, String username, String descripcion, int idCreador) {
        this(nombre, descripcion, idCreador);
        this.username = username;
    }
    
    public Comunidad(int idComunidad, String nombre, String username, String descripcion, String imagenUrl, 
                     int idCreador, boolean esPublica) {
        this(nombre, username, descripcion, idCreador);
        this.idComunidad = idComunidad;
        this.imagenUrl = imagenUrl;
        this.esPublica = esPublica;
    }
    
    // Getters y Setters básicos
    public int getIdComunidad() {
        return idComunidad;
    }
    
    public void setIdComunidad(int idComunidad) {
        this.idComunidad = idComunidad;
    }
    
    public String getNombre() {
        return nombre;
    }
    
    public void setNombre(String nombre) {
        this.nombre = nombre;
    }
    
    // ⭐ NUEVO: Getter y Setter para username
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getDescripcion() {
        return descripcion;
    }
    
    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }
    
    public String getImagenUrl() {
        return imagenUrl;
    }
    
    public void setImagenUrl(String imagenUrl) {
        this.imagenUrl = imagenUrl;
    }
    
    public int getIdCreador() {
        return idCreador;
    }
    
    public void setIdCreador(int idCreador) {
        this.idCreador = idCreador;
    }
    
    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }
    
    public void setFechaCreacion(LocalDateTime fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }
    
    public boolean isEsPublica() {
        return esPublica;
    }
    
    public void setEsPublica(boolean esPublica) {
        this.esPublica = esPublica;
    }
    
    public int getSeguidoresCount() {
        return seguidoresCount;
    }
    
    public void setSeguidoresCount(int seguidoresCount) {
        this.seguidoresCount = seguidoresCount;
    }
    
    public int getPublicacionesCount() {
        return publicacionesCount;
    }
    
    public void setPublicacionesCount(int publicacionesCount) {
        this.publicacionesCount = publicacionesCount;
    }
    
    // Getters y Setters para datos adicionales
    public String getNombreCreador() {
        return nombreCreador;
    }
    
    public void setNombreCreador(String nombreCreador) {
        this.nombreCreador = nombreCreador;
    }
    
    public String getUsernameCreador() {
        return usernameCreador;
    }
    
    public void setUsernameCreador(String usernameCreador) {
        this.usernameCreador = usernameCreador;
    }
    
    public String getAvatarCreador() {
        return avatarCreador;
    }
    
    public void setAvatarCreador(String avatarCreador) {
        this.avatarCreador = avatarCreador;
    }
    
    public boolean isUsuarioEsSeguidor() {
        return usuarioEsSeguidor;
    }
    
    public void setUsuarioEsSeguidor(boolean usuarioEsSeguidor) {
        this.usuarioEsSeguidor = usuarioEsSeguidor;
    }
    
    public boolean isUsuarioEsAdmin() {
        return usuarioEsAdmin;
    }
    
    public void setUsuarioEsAdmin(boolean usuarioEsAdmin) {
        this.usuarioEsAdmin = usuarioEsAdmin;
    }
    
    public boolean isUsuarioEsCreador() {
        return usuarioEsCreador;
    }
    
    public void setUsuarioEsCreador(boolean usuarioEsCreador) {
        this.usuarioEsCreador = usuarioEsCreador;
    }
    
    // ⭐ NUEVOS: Métodos utilitarios para username
    public String getUsernameCompleto() {
        return username != null ? "@" + username : "";
    }
    
    public String getUsernameSeguro() {
        if (username == null || username.trim().isEmpty()) {
            return "comunidad_" + idComunidad;
        }
        return username;
    }
    
    public boolean esUsernameValido() {
        return username != null && 
               username.trim().length() >= 3 && 
               username.trim().length() <= 50 &&
               username.matches("^[a-zA-Z0-9_]+$");
    }
    
    // Métodos utilitarios existentes (mantenidos)
    public String getFechaCreacionFormateada() {
        if (fechaCreacion != null) {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            return fechaCreacion.format(formatter);
        }
        return "";
    }
    
    public String getTiempoTranscurrido() {
        if (fechaCreacion != null) {
            LocalDateTime ahora = LocalDateTime.now();
            long dias = java.time.Duration.between(fechaCreacion, ahora).toDays();
            
            if (dias == 0) {
                long horas = java.time.Duration.between(fechaCreacion, ahora).toHours();
                if (horas == 0) {
                    long minutos = java.time.Duration.between(fechaCreacion, ahora).toMinutes();
                    return "hace " + minutos + " min";
                }
                return "hace " + horas + " h";
            } else if (dias < 7) {
                return "hace " + dias + " día" + (dias > 1 ? "s" : "");
            } else if (dias < 30) {
                long semanas = dias / 7;
                return "hace " + semanas + " semana" + (semanas > 1 ? "s" : "");
            } else if (dias < 365) {
                long meses = dias / 30;
                return "hace " + meses + " mes" + (meses > 1 ? "es" : "");
            } else {
                long años = dias / 365;
                return "hace " + años + " año" + (años > 1 ? "s" : "");
            }
        }
        return "";
    }
    
    public String getImagenUrlSegura() {
        if (imagenUrl == null || imagenUrl.trim().isEmpty() || imagenUrl.equals("null")) {
            return "assets/images/comunidades/default.jpg";
        }
        return imagenUrl;
    }
    
    public String getDescripcionCorta() {
        if (descripcion == null) return "";
        if (descripcion.length() <= 100) return descripcion;
        return descripcion.substring(0, 97) + "...";
    }
    
    // Métodos para validación
    public boolean esNombreValido() {
        return nombre != null && 
               nombre.trim().length() >= 3 && 
               nombre.trim().length() <= 100;
    }
    
    public boolean esDescripcionValida() {
        return descripcion != null && 
               descripcion.trim().length() >= 10 && 
               descripcion.trim().length() <= 1000;
    }
    
    // ⭐ NUEVO: Método de validación completa
    public boolean esValidaParaCrear() {
        return esNombreValido() && 
               esDescripcionValida() && 
               esUsernameValido() &&
               idCreador > 0;
    }
    
    // Override toString para debugging (actualizado)
    @Override
    public String toString() {
        return "Comunidad{" +
                "idComunidad=" + idComunidad +
                ", nombre='" + nombre + '\'' +
                ", username='" + username + '\'' +
                ", creador=" + idCreador +
                ", seguidores=" + seguidoresCount +
                ", publicaciones=" + publicacionesCount +
                ", esPublica=" + esPublica +
                '}';
    }
    
    // Override equals y hashCode (sin cambios)
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        
        Comunidad comunidad = (Comunidad) obj;
        return idComunidad == comunidad.idComunidad;
    }
    
    @Override
    public int hashCode() {
        return Integer.hashCode(idComunidad);
    }
}