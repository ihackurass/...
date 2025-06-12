/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.aquasocial.dao;

/**
 *
 * @author Home
 */
import java.util.LinkedList;
import java.util.List;
import pe.aquasocial.entity.Publicacion;

// IPublicacionDAO.java
public interface IPublicacionDAO {
    // Operaciones CRUD básicas
    boolean crear(Publicacion publicacion);
    Publicacion obtenerPorId(int idPublicacion);
    List<Publicacion> obtenerTodas();
    boolean actualizar(Publicacion publicacion);
    boolean eliminar(int idPublicacion);
    
    // Operaciones específicas del negocio
    List<Publicacion> obtenerPublicacionesHome(int idUsuarioActual);
    List<Publicacion> obtenerPorUsuario(int idUsuario);
    List<Publicacion> obtenerAprobadas();
    List<Publicacion> obtenerPendientesAprobacion();
    List<Publicacion> obtenerQuePermiteDonacion();
    boolean aprobar(int idPublicacion);
    boolean rechazar(int idPublicacion);
    int contarPorUsuario(int idUsuario);
    List<Publicacion> obtenerRecientes(int limite);
}