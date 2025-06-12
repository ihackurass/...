/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.aquasocial.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Conexion {
    
    // Configuración de la base de datos
    private static final String URL = "jdbc:mysql://localhost:3306/agua_bendita_db";
    private static final String USUARIO = "root";  // Cambiar por tu usuario
    private static final String PASSWORD = "";     // Cambiar por tu contraseña
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";
    
    // Conexión singleton
    private static Connection conexion = null;
    
    // Constructor privado para singleton
    private Conexion() {}
    
    // Método para obtener conexión
    public static Connection getConexion() {
        try {
            if (conexion == null || conexion.isClosed()) {
                // Cargar el driver
                Class.forName(DRIVER);
                
                // Establecer conexión
                conexion = DriverManager.getConnection(URL, USUARIO, PASSWORD);
                
                // Configurar conexión
                conexion.setAutoCommit(true);
                System.out.println("✅ Conexión establecida a la base de datos");
            }
        } catch (ClassNotFoundException e) {
            System.err.println("❌ Error: Driver MySQL no encontrado");
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("❌ Error al conectar a la base de datos");
            e.printStackTrace();
        }
        return conexion;
    }
    
    // Método para cerrar conexión
    public static void cerrarConexion() {
        try {
            if (conexion != null && !conexion.isClosed()) {
                conexion.close();
                System.out.println("🔒 Conexión cerrada");
            }
        } catch (SQLException e) {
            System.err.println("❌ Error al cerrar conexión");
            e.printStackTrace();
        }
    }
    
    // Método para probar conexión
    public static boolean probarConexion() {
        try {
            Connection conn = getConexion();
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            return false;
        }
    }
}