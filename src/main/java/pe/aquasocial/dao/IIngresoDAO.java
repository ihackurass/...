/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.aquasocial.dao;

import java.util.List;
import pe.aquasocial.entity.Ingreso;

public interface IIngresoDAO {

    // Operaciones CRUD básicas
    boolean crear(Ingreso ingreso);

    Ingreso obtenerPorId(int idIngreso);

    List<Ingreso> obtenerTodos();

    boolean actualizar(Ingreso ingreso);

    boolean eliminar(int idIngreso);

    // Operaciones específicas del negocio
    List<Ingreso> obtenerPorPublicacion(int idPublicacion);

    List<Ingreso> obtenerPorDonador(int idDonador);

    List<Ingreso> obtenerPorCreador(int idCreador);

    List<Ingreso> obtenerPorEstado(String estado);

    double totalRecibidoPorUsuario(int idUsuario);

    double totalDonadoPorUsuario(int idUsuario);

    double totalPorPublicacion(int idPublicacion);

    List<Ingreso> obtenerRecientes(int limite);

    boolean cambiarEstado(int idIngreso, String nuevoEstado);

    List<Ingreso> obtenerPorMetodoPago(String metodoPago);

    public boolean existePorReferenciaPago(String referenciaPago);

    public Ingreso obtenerPorReferenciaPago(String referenciaPago);
}
