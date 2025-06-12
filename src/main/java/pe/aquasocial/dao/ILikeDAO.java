/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.aquasocial.dao;

import java.util.List;
import pe.aquasocial.entity.Like;

public interface ILikeDAO {
    // Operaciones CRUD básicas
    boolean crear(Like like);
    Like obtenerPorId(int idLike);
    List<Like> obtenerTodos();
    boolean eliminar(int idLike);
    
    // Operaciones específicas del negocio
    int contarPorPublicacion(int idPublicacion);
    boolean usuarioYaDioLike(int idPublicacion, int idUsuario);
    boolean darLike(int idPublicacion, int idUsuario);
    boolean quitarLike(int idPublicacion, int idUsuario);
    List<Like> obtenerPorPublicacion(int idPublicacion);
    List<Like> obtenerPorUsuario(int idUsuario);
    boolean eliminarPorPublicacionYUsuario(int idPublicacion, int idUsuario);
}