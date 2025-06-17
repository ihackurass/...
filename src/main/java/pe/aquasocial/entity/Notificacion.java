/*
 * Entidad Notificacion para el sistema de notificaciones
 * Representa una notificación enviada a un usuario
 */
package pe.aquasocial.entity;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.Duration;

public class Notificacion {
    
    // ===== ATRIBUTOS PRINCIPALES =====
    private int idNotificacion;
    private int idUsuarioDestino;
    private Integer idUsuarioOrigen; // Puede ser null para notificaciones del sistema
    private String tipo;
    private String subtipo;
    private String titulo;
    private String mensaje;
    private String datosAdicionales; // JSON como String
    private String icono;
    private String color;
    private boolean esLeida;
    private boolean esImportante;
    private LocalDateTime fechaCreacion;
    private LocalDateTime fechaLeida;
    
    // ===== DATOS ADICIONALES DEL JOIN =====
    private String nombreUsuarioOrigen;
    private String avatarUsuarioOrigen;
    
    // ===== CONSTRUCTORES =====
    
    public Notificacion() {
        this.fechaCreacion = LocalDateTime.now();
        this.esLeida = false;
        this.esImportante = false;
        this.icono = "fa-bell";
        this.color = "primary";
    }
    
    public Notificacion(int idUsuarioDestino, String tipo, String subtipo, String titulo, String mensaje) {
        this();
        this.idUsuarioDestino = idUsuarioDestino;
        this.tipo = tipo;
        this.subtipo = subtipo;
        this.titulo = titulo;
        this.mensaje = mensaje;
    }
    
    // ===== GETTERS Y SETTERS =====
    
    public int getIdNotificacion() {
        return idNotificacion;
    }
    
    public void setIdNotificacion(int idNotificacion) {
        this.idNotificacion = idNotificacion;
    }
    
    public int getIdUsuarioDestino() {
        return idUsuarioDestino;
    }
    
    public void setIdUsuarioDestino(int idUsuarioDestino) {
        this.idUsuarioDestino = idUsuarioDestino;
    }
    
    public Integer getIdUsuarioOrigen() {
        return idUsuarioOrigen;
    }
    
    public void setIdUsuarioOrigen(Integer idUsuarioOrigen) {
        this.idUsuarioOrigen = idUsuarioOrigen;
    }
    
    public String getTipo() {
        return tipo;
    }
    
    public void setTipo(String tipo) {
        this.tipo = tipo;
    }
    
    public String getSubtipo() {
        return subtipo;
    }
    
    public void setSubtipo(String subtipo) {
        this.subtipo = subtipo;
    }
    
    public String getTitulo() {
        return titulo;
    }
    
    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }
    
    public String getMensaje() {
        return mensaje;
    }
    
    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }
    
    public String getDatosAdicionales() {
        return datosAdicionales;
    }
    
    public void setDatosAdicionales(String datosAdicionales) {
        this.datosAdicionales = datosAdicionales;
    }
    
    public String getIcono() {
        return icono;
    }
    
    public void setIcono(String icono) {
        this.icono = icono;
    }
    
    public String getColor() {
        return color;
    }
    
    public void setColor(String color) {
        this.color = color;
    }
    
    public boolean isEsLeida() {
        return esLeida;
    }
    
    public void setEsLeida(boolean esLeida) {
        this.esLeida = esLeida;
    }
    
    public boolean isEsImportante() {
        return esImportante;
    }
    
    public void setEsImportante(boolean esImportante) {
        this.esImportante = esImportante;
    }
    
    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }
    
    public void setFechaCreacion(LocalDateTime fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }
    
    public LocalDateTime getFechaLeida() {
        return fechaLeida;
    }
    
    public void setFechaLeida(LocalDateTime fechaLeida) {
        this.fechaLeida = fechaLeida;
    }
    
    public String getNombreUsuarioOrigen() {
        return nombreUsuarioOrigen;
    }
    
    public void setNombreUsuarioOrigen(String nombreUsuarioOrigen) {
        this.nombreUsuarioOrigen = nombreUsuarioOrigen;
    }
    
    public String getAvatarUsuarioOrigen() {
        return avatarUsuarioOrigen;
    }
    
    public void setAvatarUsuarioOrigen(String avatarUsuarioOrigen) {
        this.avatarUsuarioOrigen = avatarUsuarioOrigen;
    }
    
    // ===== MÉTODOS DE UTILIDAD =====
    
    /**
     * Obtener tiempo transcurrido desde la creación
     */
    public String getTiempoTranscurrido() {
        if (fechaCreacion == null) return "Fecha desconocida";
        
        LocalDateTime ahora = LocalDateTime.now();
        Duration duracion = Duration.between(fechaCreacion, ahora);
        
        long minutos = duracion.toMinutes();
        long horas = duracion.toHours();
        long dias = duracion.toDays();
        
        if (minutos < 1) {
            return "ahora mismo";
        } else if (minutos < 60) {
            return "hace " + minutos + " min";
        } else if (horas < 24) {
            return "hace " + horas + " h";
        } else if (dias < 7) {
            return "hace " + dias + " día" + (dias > 1 ? "s" : "");
        } else {
            return fechaCreacion.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
        }
    }
    
    /**
     * Obtener fecha formateada
     */
    public String getFechaFormateada() {
        if (fechaCreacion == null) return "";
        return fechaCreacion.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }
    
    /**
     * Verificar si es una notificación del sistema
     */
    public boolean esDeSistema() {
        return idUsuarioOrigen == null || "sistema".equals(tipo);
    }
    
    /**
     * Obtener clase CSS para el color
     */
    public String getClaseColor() {
        switch (color.toLowerCase()) {
            case "success": return "text-success";
            case "warning": return "text-warning";
            case "danger": return "text-danger";
            case "info": return "text-info";
            case "primary":
            default: return "text-primary";
        }
    }
    
    /**
     * Obtener clase CSS para el fondo de la notificación
     */
    public String getClaseFondo() {
        if (!esLeida) {
            return "bg-light border-left-primary"; // No leída
        }
        return ""; // Leída
    }
    
    /**
     * Obtener nombre del usuario origen o "Sistema"
     */
    public String getNombreOrigenDisplay() {
        if (esDeSistema()) {
            return "Sistema";
        }
        return nombreUsuarioOrigen != null ? nombreUsuarioOrigen : "Usuario";
    }
    
    /**
     * Verificar si la notificación es reciente (menos de 24 horas)
     */
    public boolean esReciente() {
        if (fechaCreacion == null) return false;
        return Duration.between(fechaCreacion, LocalDateTime.now()).toHours() < 24;
    }
    
    /**
     * Marcar como leída
     */
    public void marcarComoLeida() {
        this.esLeida = true;
        this.fechaLeida = LocalDateTime.now();
    }
    
    // ===== CONSTANTES PARA TIPOS =====
    
    public static class Tipos {
        public static final String COMUNIDAD = "comunidad";
        public static final String PUBLICACION = "publicacion";
        public static final String SOCIAL = "social";
        public static final String SISTEMA = "sistema";
        public static final String DONACION = "donacion";
    }
    
    public static class Subtipos {
        // Comunidad
        public static final String NUEVA_SOLICITUD = "nueva_solicitud";
        public static final String SOLICITUD_APROBADA = "solicitud_aprobada";
        public static final String SOLICITUD_RECHAZADA = "solicitud_rechazada";
        public static final String PROMOVIDO_ADMIN = "promovido_admin";
        public static final String NUEVA_PUBLICACION_COMUNIDAD = "nueva_publicacion_comunidad";
        
        // Publicación
        public static final String LIKE_RECIBIDO = "like_recibido";
        public static final String COMENTARIO_RECIBIDO = "comentario_recibido";
        public static final String MENCIONADO = "mencionado";
        public static final String PUBLICACION_APROBADA = "publicacion_aprobada";
        public static final String PUBLICACION_RECHAZADA = "publicacion_rechazada";
        
        // Social
        public static final String NUEVO_SEGUIDOR = "nuevo_seguidor";
        public static final String USUARIO_PUBLICO = "usuario_publico";
        
        // Sistema
        public static final String CUENTA_VERIFICADA = "cuenta_verificada";
        public static final String VERIFICACION_RECHAZADA = "verificacion_rechazada";
        public static final String BIENVENIDA = "bienvenida";
        public static final String MANTENIMIENTO = "mantenimiento";
        
        // Donación
        public static final String DONACION_RECIBIDA = "donacion_recibida";
        public static final String DONACION_PROCESADA = "donacion_procesada";
    }
    
    public static class Colores {
        public static final String PRIMARY = "primary";
        public static final String SUCCESS = "success";
        public static final String WARNING = "warning";
        public static final String DANGER = "danger";
        public static final String INFO = "info";
    }
    
    // ===== TOSTRING PARA DEBUGGING =====
    
    @Override
    public String toString() {
        return "Notificacion{" +
                "id=" + idNotificacion +
                ", destino=" + idUsuarioDestino +
                ", tipo='" + tipo + '\'' +
                ", subtipo='" + subtipo + '\'' +
                ", titulo='" + titulo + '\'' +
                ", leida=" + esLeida +
                ", fecha=" + fechaCreacion +
                '}';
    }
}