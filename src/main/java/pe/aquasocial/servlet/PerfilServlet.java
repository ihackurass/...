/*
 * Servlet para gestión del perfil de usuario
 * Funcionalidades: Actualizar información, cambiar contraseña, avatar y estadísticas
 */
package pe.aquasocial.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import com.google.gson.Gson;
import pe.aquasocial.dao.UsuarioDAO;
import pe.aquasocial.dao.ComunidadDAO;
import pe.aquasocial.entity.Usuario;
import pe.aquasocial.util.SessionUtil;

@WebServlet(name = "PerfilServlet", urlPatterns = {"/PerfilServlet"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
    maxFileSize = 1024 * 1024 * 2,       // 2 MB
    maxRequestSize = 1024 * 1024 * 5     // 5 MB
)
public class PerfilServlet extends HttpServlet {

    private UsuarioDAO usuarioDAO;
    private ComunidadDAO comunidadDAO;
    private Gson gson;
    
    // Directorio para subir avatares
    private static final String UPLOAD_DIR = "assets/images/avatars/";
    private static final String[] ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png"};

    @Override
    public void init() throws ServletException {
        try {
            usuarioDAO = new UsuarioDAO();
            comunidadDAO = new ComunidadDAO();
            gson = new Gson();
            System.out.println("✅ PerfilServlet inicializado correctamente");
        } catch (Exception e) {
            System.err.println("❌ Error al inicializar PerfilServlet: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Error al inicializar servlet", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if (action == null) {
            // Mostrar página de perfil
            request.getRequestDispatcher("/views/user/mi-perfil.jsp").forward(request, response);
            return;
        }
        
        try {
            switch (action) {
                case "getStats":
                    obtenerEstadisticas(request, response);
                    break;
                default:
                    request.getRequestDispatcher("/views/user/mi-perfil.jsp").forward(request, response);
                    break;
            }
        } catch (Exception e) {
            System.err.println("❌ Error en GET PerfilServlet: " + e.getMessage());
            e.printStackTrace();
            enviarErrorJSON(response, "Error interno del servidor");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if (action == null) {
            enviarErrorJSON(response, "Acción no especificada");
            return;
        }
        
        try {
            switch (action) {
                case "updateInfo":
                    actualizarInformacion(request, response);
                    break;
                case "changePassword":
                    cambiarPassword(request, response);
                    break;
                case "changeAvatar":
                    cambiarAvatar(request, response);
                    break;
                default:
                    enviarErrorJSON(response, "Acción no válida");
                    break;
            }
        } catch (Exception e) {
            System.err.println("❌ Error en POST PerfilServlet: " + e.getMessage());
            e.printStackTrace();
            enviarErrorJSON(response, "Error interno del servidor");
        }
    }

    /**
     * Obtener estadísticas del usuario
     */
    private void obtenerEstadisticas(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        Usuario usuario = SessionUtil.getLoggedUser(request);
        if (usuario == null) {
            enviarErrorJSON(response, "Usuario no autenticado");
            return;
        }
        
        try {
            Map<String, Object> stats = new HashMap<>();
            
            // Comunidades que sigue
            int comunidadesSeguidas = comunidadDAO.contarComunidadesSeguidas(usuario.getId());
            stats.put("comunidadesSeguidas", comunidadesSeguidas);
            
            // Solicitudes enviadas
            int solicitudesEnviadas = comunidadDAO.contarSolicitudesUsuario(usuario.getId());
            stats.put("solicitudesEnviadas", solicitudesEnviadas);
            
            // Solicitudes aprobadas
            int solicitudesAprobadas = comunidadDAO.contarSolicitudesAprobadas(usuario.getId());
            stats.put("solicitudesAprobadas", solicitudesAprobadas);
            
            // Comunidades donde es admin
            int comunidadesAdmin = comunidadDAO.contarComunidadesAdmin(usuario.getId());
            stats.put("comunidadesAdmin", comunidadesAdmin);
            
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", true);
            responseData.put("stats", stats);
            
            enviarJSON(response, responseData);
            
            System.out.println("📊 Estadísticas obtenidas para usuario: " + usuario.getId());
            
        } catch (Exception e) {
            System.err.println("❌ Error al obtener estadísticas: " + e.getMessage());
            e.printStackTrace();
            enviarErrorJSON(response, "Error al cargar estadísticas");
        }
    }

    /**
     * Actualizar información personal del usuario
     */
    private void actualizarInformacion(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        Usuario usuario = SessionUtil.getLoggedUser(request);
        if (usuario == null) {
            enviarErrorJSON(response, "Usuario no autenticado");
            return;
        }
        
        String nombreCompleto = request.getParameter("nombreCompleto");
        String email = request.getParameter("email");
        String bio = request.getParameter("bio");
        
        // Validaciones básicas
        if (nombreCompleto == null || nombreCompleto.trim().isEmpty()) {
            enviarErrorJSON(response, "El nombre completo es obligatorio");
            return;
        }
        
        if (email == null || email.trim().isEmpty()) {
            enviarErrorJSON(response, "El email es obligatorio");
            return;
        }
        
        if (!isValidEmail(email)) {
            enviarErrorJSON(response, "El formato del email no es válido");
            return;
        }
        
        try {
            // Verificar si el email ya existe (excepto el del usuario actual)
            if (usuarioDAO.existeEmail(email.trim()) && !email.trim().equals(usuario.getEmail())) {
                enviarErrorJSON(response, "Este email ya está en uso por otro usuario");
                return;
            }
            
            // Actualizar datos
            usuario.setNombreCompleto(nombreCompleto.trim());
            usuario.setEmail(email.trim());
            
            boolean actualizado = usuarioDAO.actualizar(usuario);
            
            if (actualizado) {
                // Actualizar sesión
                SessionUtil.updateUserSession(request, usuario);
                
                Map<String, Object> responseData = new HashMap<>();
                responseData.put("success", true);
                responseData.put("message", "Información actualizada exitosamente");
                
                enviarJSON(response, responseData);
                
                System.out.println("✅ Información actualizada para usuario: " + usuario.getId());
                
            } else {
                enviarErrorJSON(response, "Error al actualizar la información");
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error al actualizar información: " + e.getMessage());
            e.printStackTrace();
            enviarErrorJSON(response, "Error interno al actualizar información");
        }
    }

    /**
     * Cambiar contraseña del usuario
     */
    private void cambiarPassword(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        Usuario usuario = SessionUtil.getLoggedUser(request);
        if (usuario == null) {
            enviarErrorJSON(response, "Usuario no autenticado");
            return;
        }
        
        String passwordActual = request.getParameter("passwordActual");
        String passwordNueva = request.getParameter("passwordNueva");
        
        // Validaciones
        if (passwordActual == null || passwordActual.trim().isEmpty()) {
            enviarErrorJSON(response, "La contraseña actual es obligatoria");
            return;
        }
        
        if (passwordNueva == null || passwordNueva.trim().isEmpty()) {
            enviarErrorJSON(response, "La nueva contraseña es obligatoria");
            return;
        }
        
        if (passwordNueva.length() < 8) {
            enviarErrorJSON(response, "La nueva contraseña debe tener al menos 8 caracteres");
            return;
        }
        
        try {
            // Verificar contraseña actual
            if (!usuarioDAO.verificarPassword(usuario.getId(), passwordActual)) {
                enviarErrorJSON(response, "La contraseña actual es incorrecta");
                return;
            }
            
            // Cambiar contraseña
            boolean cambiada = usuarioDAO.cambiarPassword(usuario.getId(), passwordNueva);
            
            if (cambiada) {
                Map<String, Object> responseData = new HashMap<>();
                responseData.put("success", true);
                responseData.put("message", "Contraseña cambiada exitosamente");
                
                enviarJSON(response, responseData);
                
                System.out.println("🔒 Contraseña cambiada para usuario: " + usuario.getId());
                
            } else {
                enviarErrorJSON(response, "Error al cambiar la contraseña");
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error al cambiar contraseña: " + e.getMessage());
            e.printStackTrace();
            enviarErrorJSON(response, "Error interno al cambiar contraseña");
        }
    }

    /**
     * Cambiar avatar del usuario
     */
    private void cambiarAvatar(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        
        Usuario usuario = SessionUtil.getLoggedUser(request);
        if (usuario == null) {
            enviarErrorJSON(response, "Usuario no autenticado");
            return;
        }
        
        try {
            // Obtener el archivo subido
            Part filePart = request.getPart("avatar");
            
            if (filePart == null || filePart.getSize() == 0) {
                enviarErrorJSON(response, "No se ha seleccionado ningún archivo");
                return;
            }
            
            String fileName = getFileName(filePart);
            
            // Validar extensión
            if (!isValidImageFile(fileName)) {
                enviarErrorJSON(response, "Formato de archivo no válido. Use JPG, JPEG o PNG");
                return;
            }
            
            // Validar tamaño (2MB máximo)
            if (filePart.getSize() > 2 * 1024 * 1024) {
                enviarErrorJSON(response, "El archivo es demasiado grande. Máximo 2MB");
                return;
            }
            
            // Generar nombre único
            String extension = fileName.substring(fileName.lastIndexOf("."));
            String uniqueFileName = "avatar_" + usuario.getId() + "_" + System.currentTimeMillis() + extension;
            
            // Crear directorio si no existe
            String uploadPath = getServletContext().getRealPath("") + UPLOAD_DIR;
            Path uploadDir = Paths.get(uploadPath);
            if (!Files.exists(uploadDir)) {
                Files.createDirectories(uploadDir);
            }
            
            // Guardar archivo
            Path filePath = uploadDir.resolve(uniqueFileName);
            Files.copy(filePart.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            
            // Actualizar URL en base de datos
            String avatarUrl = UPLOAD_DIR + uniqueFileName;
            boolean actualizado = usuarioDAO.actualizarAvatar(usuario.getId(), avatarUrl);
            
            if (actualizado) {
                // Actualizar objeto usuario y sesión
                usuario.setAvatar(avatarUrl);
                SessionUtil.updateUserSession(request, usuario);
                
                Map<String, Object> responseData = new HashMap<>();
                responseData.put("success", true);
                responseData.put("message", "Avatar actualizado exitosamente");
                responseData.put("avatarUrl", avatarUrl);
                
                enviarJSON(response, responseData);
                
                System.out.println("🖼️ Avatar actualizado para usuario: " + usuario.getId());
                
            } else {
                // Eliminar archivo si falló la actualización en BD
                Files.deleteIfExists(filePath);
                enviarErrorJSON(response, "Error al actualizar el avatar en la base de datos");
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error al cambiar avatar: " + e.getMessage());
            e.printStackTrace();
            enviarErrorJSON(response, "Error interno al cambiar avatar");
        }
    }

    // ============= MÉTODOS AUXILIARES =============

    /**
     * Obtener nombre del archivo de un Part
     */
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        String[] tokens = contentDisposition.split(";");
        
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }

    /**
     * Validar si es un archivo de imagen válido
     */
    private boolean isValidImageFile(String fileName) {
        if (fileName == null || fileName.trim().isEmpty()) {
            return false;
        }
        
        String lowerFileName = fileName.toLowerCase();
        for (String ext : ALLOWED_EXTENSIONS) {
            if (lowerFileName.endsWith(ext)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Validar formato de email
     */
    private boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }
        
        String emailRegex = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";
        return email.matches(emailRegex);
    }

    /**
     * Enviar respuesta JSON exitosa
     */
    private void enviarJSON(HttpServletResponse response, Object data) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try (PrintWriter out = response.getWriter()) {
            out.write(gson.toJson(data));
        }
    }

    /**
     * Enviar respuesta JSON de error
     */
    private void enviarErrorJSON(HttpServletResponse response, String message) throws IOException {
        Map<String, Object> errorData = new HashMap<>();
        errorData.put("success", false);
        errorData.put("message", message);
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try (PrintWriter out = response.getWriter()) {
            out.write(gson.toJson(errorData));
        }
    }
}