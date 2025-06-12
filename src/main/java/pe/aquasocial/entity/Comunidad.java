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
    private String descripcion;
    private String imagenUrl;
    private int idCreador;
    private LocalDateTime fechaCreacion;
    private boolean esPublica;
    private int seguidoresCount;
    private int publicacionesCount;
    
    // Datos adicionales para vistas (no en BD)
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
    
    public Comunidad(int idComunidad, String nombre, String descripcion, String imagenUrl, 
                     int idCreador, boolean esPublica) {
        this(nombre, descripcion, idCreador);
        this.idComunidad = idComunidad;
        this.imagenUrl = imagenUrl;
        this.esPublica = esPublica;
    }
    
    // Getters y Setters
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
    
    // Datos adicionales para vistas
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
    
    // Métodos de utilidad
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
                return "Hoy";
            } else if (dias == 1) {
                return "Ayer";
            } else if (dias < 7) {
                return "hace " + dias + " días";
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
    
    // Override toString para debugging
    @Override
    public String toString() {
        return "Comunidad{" +
                "idComunidad=" + idComunidad +
                ", nombre='" + nombre + '\'' +
                ", creador=" + idCreador +
                ", seguidores=" + seguidoresCount +
                ", publicaciones=" + publicacionesCount +
                ", esPublica=" + esPublica +
                '}';
    }
    
    // Override equals y hashCode
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