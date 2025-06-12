/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.aquasocial.dao;

import java.util.List;
import pe.aquasocial.entity.Comentario;

public interface IComentarioDAO {
    // Operaciones CRUD básicas
    boolean crear(Comentario comentario);
    Comentario obtenerPorId(int idComentario);
    List<Comentario> obtenerTodos();
    boolean actualizar(Comentario comentario);
    boolean eliminar(int idComentario);
    
    // Operaciones específicas del negocio
    List<Comentario> obtenerPorPublicacion(int idPublicacion);
    List<Comentario> obtenerPorUsuario(int idUsuario);
    int contarPorPublicacion(int idPublicacion);
    int contarPorUsuario(int idUsuario);
    List<Comentario> obtenerRecientes(int limite);
    boolean eliminarPorPublicacion(int idPublicacion);
    List<Comentario> buscarPorTexto(String texto);
}