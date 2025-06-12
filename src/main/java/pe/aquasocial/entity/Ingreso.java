package pe.aquasocial.entity;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Ingreso {

    private int idIngreso;
    private int idDonador;
    private int idCreador;
    private int idPublicacion;
    private double cantidad;
    private LocalDateTime fechaHora;
    private String estado; // "Completado", "Pendiente", "Cancelado"
    private String metodoPago;
    private String referenciaPago;
    private String mensaje;

    // Datos adicionales para mostrar
    private String nombreDonador;
    private String usernameDonador;
    private String avatarDonador;
    private String nombreCreador;
    private String usernameCreador;
    private String avatarCreador;
    private String textoPublicacion;

    // Constructor vacío
    public Ingreso() {
        this.fechaHora = LocalDateTime.now();
        this.estado = "Pendiente";
    }

    // Constructor con parámetros principales
    public Ingreso(int idDonador, int idCreador, int idPublicacion, double cantidad) {
        this();
        this.idDonador = idDonador;
        this.idCreador = idCreador;
        this.idPublicacion = idPublicacion;
        this.cantidad = cantidad;
    }

    // Constructor completo
    public Ingreso(int idDonador, int idCreador, int idPublicacion, double cantidad,
            String metodoPago, String referenciaPago, String mensaje) {
        this(idDonador, idCreador, idPublicacion, cantidad);
        this.metodoPago = metodoPago;
        this.referenciaPago = referenciaPago;
        this.mensaje = mensaje;

        this.estado = "Completado"; // Si tiene referencia, está completado
    }

    // Getters y Setters
    public int getIdIngreso() {
        return idIngreso;
    }

    public void setIdIngreso(int idIngreso) {
        this.idIngreso = idIngreso;
    }

    public int getIdDonador() {
        return idDonador;
    }

    public void setIdDonador(int idDonador) {
        this.idDonador = idDonador;
    }

    public int getIdCreador() {
        return idCreador;
    }

    public void setIdCreador(int idCreador) {
        this.idCreador = idCreador;
    }

    public int getIdPublicacion() {
        return idPublicacion;
    }

    public void setIdPublicacion(int idPublicacion) {
        this.idPublicacion = idPublicacion;
    }

    public double getCantidad() {
        return cantidad;
    }

    public void setCantidad(double cantidad) {
        this.cantidad = cantidad;
    }

    public LocalDateTime getFechaHora() {
        return fechaHora;
    }

    public void setFechaHora(LocalDateTime fechaHora) {
        this.fechaHora = fechaHora;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getMetodoPago() {
        return metodoPago;
    }

    public void setMetodoPago(String metodoPago) {
        this.metodoPago = metodoPago;
    }

    public String getReferenciaPago() {
        return referenciaPago;
    }

    public void setReferenciaPago(String referenciaPago) {
        this.referenciaPago = referenciaPago;
    }

    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }

    // Datos adicionales
    public String getNombreDonador() {
        return nombreDonador;
    }

    public void setNombreDonador(String nombreDonador) {
        this.nombreDonador = nombreDonador;
    }

    public String getUsernameDonador() {
        return usernameDonador;
    }

    public void setUsernameDonador(String usernameDonador) {
        this.usernameDonador = usernameDonador;
    }

    public String getAvatarDonador() {
        return avatarDonador;
    }

    public void setAvatarDonador(String avatarDonador) {
        this.avatarDonador = avatarDonador;
    }

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

    public String getTextoPublicacion() {
        return textoPublicacion;
    }

    public void setTextoPublicacion(String textoPublicacion) {
        this.textoPublicacion = textoPublicacion;
    }

    // Métodos de utilidad
    public String getFechaFormateada() {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        return fechaHora.format(formatter);
    }

    public String getHoraFormateada() {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm a");
        return fechaHora.format(formatter);
    }

    public String getTiempoTranscurrido() {
        LocalDateTime ahora = LocalDateTime.now();
        long minutos = java.time.Duration.between(fechaHora, ahora).toMinutes();

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

    public String getCantidadFormateada() {
        return String.format("$%.2f", cantidad);
    }

    public boolean isCompletado() {
        return "Completado".equals(estado);
    }

    public boolean isPendiente() {
        return "Pendiente".equals(estado);
    }

    public boolean isCancelado() {
        return "Cancelado".equals(estado);
    }

    @Override
    public String toString() {
        return "Ingreso{"
                + "idIngreso=" + idIngreso
                + ", donador='" + nombreDonador + '\''
                + ", creador='" + nombreCreador + '\''
                + ", cantidad=" + getCantidadFormateada()
                + ", estado='" + estado + '\''
                + ", metodoPago='" + metodoPago + '\''
                + ", fechaHora=" + fechaHora
                + '}';
    }
}
