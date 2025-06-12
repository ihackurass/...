/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.aquasocial.dao;

import java.sql.SQLException;
import java.util.List;

/**
 *
 * @author Rodrigo
 * @param <T>
 */
public interface DAO<T> {
    int insertar(T t) throws SQLException;
    boolean actualizar(T t) throws SQLException;
    boolean eliminar(int id) throws SQLException;
    T obtenerPorId(int id) throws SQLException;
    List<T> obtenerTodos() throws SQLException; 
}