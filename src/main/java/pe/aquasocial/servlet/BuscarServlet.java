/*
 * Servlet para manejar búsquedas globales de usuarios y comunidades
 * Procesa búsquedas y redirige a la página de resultados
 */
package pe.aquasocial.servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import pe.aquasocial.dao.UsuarioDAO;
import pe.aquasocial.dao.ComunidadDAO;
import pe.aquasocial.entity.Usuario;
import pe.aquasocial.entity.Comunidad;
import pe.aquasocial.util.SessionUtil;

@WebServlet(name = "BuscarServlet", urlPatterns = {"/BuscarServlet"})
public class BuscarServlet extends HttpServlet {

    private UsuarioDAO usuarioDAO;
    private ComunidadDAO comunidadDAO;

    @Override
    public void init() throws ServletException {
        try {
            usuarioDAO = new UsuarioDAO();
            comunidadDAO = new ComunidadDAO();
            System.out.println("✅ BuscarServlet inicializado correctamente");
        } catch (Exception e) {
            System.err.println("❌ Error al inicializar BuscarServlet: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Error al inicializar servlet", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String terminoBusqueda = request.getParameter("q");
        String tabActiva = request.getParameter("tab");
        
        // Validar parámetros
        if (terminoBusqueda == null) {
            terminoBusqueda = "";
        }
        terminoBusqueda = terminoBusqueda.trim();
        
        if (tabActiva == null || tabActiva.trim().isEmpty()) {
            tabActiva = "todo";
        }
        
        // Listas de resultados
        List<Usuario> usuarios = new ArrayList<>();
        List<Comunidad> comunidades = new ArrayList<>();
        
        try {
            // Solo buscar si hay término de búsqueda
            if (!terminoBusqueda.isEmpty() && terminoBusqueda.length() >= 2) {
                
                // Buscar según la pestaña activa
                switch (tabActiva) {
                    case "usuarios":
                        usuarios = buscarUsuarios(terminoBusqueda);
                        break;
                    case "comunidades":
                        comunidades = buscarComunidades(terminoBusqueda);
                        break;
                    case "todo":
                    default:
                        usuarios = buscarUsuarios(terminoBusqueda);
                        comunidades = buscarComunidades(terminoBusqueda);
                        break;
                }
                
                // Guardar en historial si el usuario está logueado
                Usuario usuarioActual = SessionUtil.getLoggedUser(request);
                if (usuarioActual != null) {
                    guardarEnHistorial(usuarioActual.getId(), terminoBusqueda, tabActiva, 
                                     usuarios.size() + comunidades.size());
                }
                
                System.out.println("🔍 Búsqueda realizada: '" + terminoBusqueda + "' - " + 
                                 usuarios.size() + " usuarios, " + comunidades.size() + " comunidades");
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error en búsqueda: " + e.getMessage());
            e.printStackTrace();
            // Continuar con listas vacías en caso de error
        }
        
        // Enviar resultados a la JSP
        request.setAttribute("usuarios", usuarios);
        request.setAttribute("comunidades", comunidades);
        request.setAttribute("terminoBusqueda", terminoBusqueda);
        request.setAttribute("tabActiva", tabActiva);
        
        // Forward a la página de búsqueda
        request.getRequestDispatcher("/views/buscar.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirigir POST a GET para mantener URL limpia
        doGet(request, response);
    }

    /**
     * Buscar usuarios por término
     */
    private List<Usuario> buscarUsuarios(String termino) {
        List<Usuario> resultados = new ArrayList<>();
        
        try {
            // Buscar por diferentes criterios con prioridad
            List<Usuario> exactos = usuarioDAO.buscarPorUsernameExacto(termino);
            List<Usuario> nombreCompleto = usuarioDAO.buscarPorNombreCompleto(termino);
            List<Usuario> username = usuarioDAO.buscarPorUsername(termino);
            List<Usuario> contenido = usuarioDAO.buscarEnBio(termino);
            
            // Combinar resultados evitando duplicados
            resultados.addAll(exactos);
            
            for (Usuario usuario : nombreCompleto) {
                if (!contieneDuplicado(resultados, usuario)) {
                    resultados.add(usuario);
                }
            }
            
            for (Usuario usuario : username) {
                if (!contieneDuplicado(resultados, usuario)) {
                    resultados.add(usuario);
                }
            }
            
            for (Usuario usuario : contenido) {
                if (!contieneDuplicado(resultados, usuario)) {
                    resultados.add(usuario);
                }
            }
            
            // Limitar resultados
            if (resultados.size() > 20) {
                resultados = resultados.subList(0, 20);
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error al buscar usuarios: " + e.getMessage());
            e.printStackTrace();
        }
        
        return resultados;
    }

    /**
     * Buscar comunidades por término
     */
    private List<Comunidad> buscarComunidades(String termino) {
        List<Comunidad> resultados = new ArrayList<>();
        
        try {
            // Buscar por diferentes criterios con prioridad
            List<Comunidad> exactos = comunidadDAO.buscarPorUsernameExacto(termino);
            List<Comunidad> nombre = comunidadDAO.buscarPorNombre(termino);
            List<Comunidad> username = comunidadDAO.buscarPorUsername(termino);
            List<Comunidad> descripcion = comunidadDAO.buscarEnDescripcion(termino);
            
            // Combinar resultados evitando duplicados
            resultados.addAll(exactos);
            
            for (Comunidad comunidad : nombre) {
                if (!contieneDuplicadoComunidad(resultados, comunidad)) {
                    resultados.add(comunidad);
                }
            }
            
            for (Comunidad comunidad : username) {
                if (!contieneDuplicadoComunidad(resultados, comunidad)) {
                    resultados.add(comunidad);
                }
            }
            
            for (Comunidad comunidad : descripcion) {
                if (!contieneDuplicadoComunidad(resultados, comunidad)) {
                    resultados.add(comunidad);
                }
            }
            
            // Limitar resultados
            if (resultados.size() > 20) {
                resultados = resultados.subList(0, 20);
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error al buscar comunidades: " + e.getMessage());
            e.printStackTrace();
        }
        
        return resultados;
    }

    /**
     * Verificar si ya existe un usuario en la lista
     */
    private boolean contieneDuplicado(List<Usuario> lista, Usuario usuario) {
        return lista.stream().anyMatch(u -> u.getId() == usuario.getId());
    }

    /**
     * Verificar si ya existe una comunidad en la lista
     */
    private boolean contieneDuplicadoComunidad(List<Comunidad> lista, Comunidad comunidad) {
        return lista.stream().anyMatch(c -> c.getIdComunidad() == comunidad.getIdComunidad());
    }

    /**
     * Guardar búsqueda en historial (preparado para Phase 2)
     */
    private void guardarEnHistorial(int idUsuario, String termino, String categoria, int resultados) {
        try {
            // TODO: Implementar en Phase 2 - Historial
            System.out.println("📝 Guardando en historial: Usuario " + idUsuario + 
                             " buscó '" + termino + "' en " + categoria + 
                             " (" + resultados + " resultados)");
            
            /*
            String sql = "INSERT INTO historial_busquedas (id_usuario, termino_busqueda, categoria, resultados_encontrados) VALUES (?, ?, ?, ?)";
            // ... implementar inserción en BD
            */
            
        } catch (Exception e) {
            System.err.println("❌ Error al guardar historial: " + e.getMessage());
            // No fallar la búsqueda por error en historial
        }
    }
}
