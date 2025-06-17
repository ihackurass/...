<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="pe.aquasocial.entity.Usuario" %>
<%@ page import="pe.aquasocial.entity.Publicacion" %>
<%@ page import="pe.aquasocial.entity.Comunidad" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="pe.aquasocial.util.SessionUtil" %>

<%
    Usuario usuarioLogueado = SessionUtil.getLoggedUser(request);
    Usuario usuarioPerfilado = (Usuario) request.getAttribute("usuarioPerfilado");
    Map<String, Object> estadisticas = (Map<String, Object>) request.getAttribute("estadisticas");
    
    if (usuarioPerfilado == null) {
        response.sendRedirect("BuscarServlet");
        return;
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Perfil de <%= usuarioPerfilado.getNombreCompleto() %> - AquaSocial</title>
    <%@ include file="/components/css_imports.jsp" %>
    
    <style>
        .perfil-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem 0;
            margin-bottom: 2rem;
        }
        
        .avatar-grande {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            border: 4px solid rgba(255,255,255,0.2);
            object-fit: cover;
        }
        
        .avatar-placeholder-grande {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background: rgba(255,255,255,0.2);
            border: 4px solid rgba(255,255,255,0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            font-weight: bold;
            color: white;
        }
        
        .info-usuario {
            margin-left: 2rem;
        }
        
        .verificado-badge {
            background: rgba(255,255,255,0.2);
            padding: 0.2rem 0.8rem;
            border-radius: 20px;
            font-size: 0.9rem;
            margin-left: 1rem;
        }
        
        .estadistica-card {
            background: white;
            border-radius: 10px;
            padding: 1.5rem;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }
        
        .estadistica-card:hover {
            transform: translateY(-5px);
        }
        
        .estadistica-numero {
            font-size: 2rem;
            font-weight: bold;
            color: #667eea;
        }
        
        .estadistica-label {
            color: #6c757d;
            font-size: 0.9rem;
        }
        
        .bio-section {
            background: white;
            border-radius: 10px;
            padding: 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
        }
        
        .accion-btn {
            border-radius: 25px;
            padding: 0.8rem 2rem;
            font-weight: 600;
            border: none;
            transition: all 0.3s ease;
        }
        
        .btn-seguir {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
        }
        
        .btn-seguir:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
            color: white;
        }
        
        .btn-mensaje {
            background: white;
            color: #667eea;
            border: 2px solid #667eea;
        }
        
        .btn-mensaje:hover {
            background: #667eea;
            color: white;
        }
        
        .back-btn {
            background: rgba(255,255,255,0.2);
            border: 2px solid rgba(255,255,255,0.3);
            color: white;
            border-radius: 25px;
            padding: 0.5rem 1.5rem;
            text-decoration: none;
            transition: all 0.3s ease;
        }
        
        .back-btn:hover {
            background: rgba(255,255,255,0.3);
            color: white;
            text-decoration: none;
        }
        
        /* ===== NUEVOS ESTILOS PARA ACTIVIDAD ===== */
        .actividad-item {
            transition: all 0.3s ease;
        }
        
        .actividad-item:hover {
            background: #e9ecef !important;
            transform: translateX(5px);
        }
        
        .actividad-icono {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(102, 126, 234, 0.1);
            border-radius: 50%;
        }
        
        .comunidad-mini {
            transition: all 0.3s ease;
        }
        
        .comunidad-mini:hover {
            background: #e9ecef !important;
            transform: translateX(3px);
        }
        
        .stat-box {
            transition: all 0.3s ease;
        }
        
        .stat-box:hover {
            background: #e9ecef !important;
            transform: scale(1.05);
        }
    </style>
</head>
<body>
    <%@ include file="/components/sidebar.jsp" %>
    
    <!-- Header del Perfil -->
    <div class="perfil-header">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-auto">
                    <a href="javascript:history.back()" class="back-btn">
                        <i class="fas fa-arrow-left"></i> Volver
                    </a>
                </div>
            </div>
            <div class="row align-items-center mt-3">
                <div class="col-auto">
                    <% if (usuarioPerfilado.getAvatar() != null && !usuarioPerfilado.getAvatar().isEmpty()) { %>
                        <img src="<%= usuarioPerfilado.getAvatar() %>" alt="Avatar" class="avatar-grande">
                    <% } else { %>
                        <div class="avatar-placeholder-grande">
                            <%= usuarioPerfilado.getNombreCompleto().substring(0,1).toUpperCase() %>
                        </div>
                    <% } %>
                </div>
                <div class="col info-usuario">
                    <div class="d-flex align-items-center">
                        <h1 class="h2 mb-0"><%= usuarioPerfilado.getNombreCompleto() %></h1>
                        <% if (usuarioPerfilado.isVerificado()) { %>
                            <span class="verificado-badge">
                                <i class="fas fa-check-circle"></i> Verificado
                            </span>
                        <% } %>
                    </div>
                    <p class="h5 mt-2 opacity-75">@<%= usuarioPerfilado.getUsername() %></p>
                    <% if (usuarioPerfilado.getEmail() != null) { %>
                        <p class="mt-2 opacity-75">
                            <i class="fas fa-envelope"></i> <%= usuarioPerfilado.getEmail() %>
                        </p>
                    <% } %>
                    
                    <!-- Botones de Acción -->
                    <% if (usuarioLogueado != null && usuarioLogueado.getId() != usuarioPerfilado.getId()) { %>
                        <div class="mt-3">
                            <!-- <button class="btn btn-seguir accion-btn me-3">
                                <i class="fas fa-user-plus"></i> Seguir
                            </button>
                            <button class="btn btn-mensaje accion-btn">
                                <i class="fas fa-envelope"></i> Mensaje
                            </button>-->
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
    
    <div class="container">
        <!-- Estadísticas -->
        <div class="row mb-4">
            <% if (estadisticas != null && estadisticas.get("comunidadesSeguidas") != null) { %>
                <div class="col-md-6 mb-3">
                    <div class="estadistica-card">
                        <div class="estadistica-numero"><%= estadisticas.get("comunidadesSeguidas") %></div>
                        <div class="estadistica-label">Comunidades Seguidas</div>
                    </div>
                </div>
            <% } %>
            
            <!-- ✅ CAMBIO 1: ACTUALIZAR LA TARJETA DE PUBLICACIONES -->
            <div class="col-md-6 mb-3">
                <div class="estadistica-card">
                    <div class="estadistica-numero">
                        <%= estadisticas != null && estadisticas.get("totalPublicaciones") != null ? 
                            estadisticas.get("totalPublicaciones") : 0 %>
                    </div>
                    <div class="estadistica-label">Publicaciones</div>
                </div>
            </div>
        </div>
        
        <!-- Biografía -->
        <% if (usuarioPerfilado.getBio() != null && !usuarioPerfilado.getBio().trim().isEmpty()) { %>
            <div class="bio-section">
                <h4><i class="fas fa-user"></i> Acerca de <%= usuarioPerfilado.getNombreCompleto() %></h4>
                <p class="mt-3 mb-0"><%= usuarioPerfilado.getBio() %></p>
            </div>
        <% } %>
        
        <!-- Sección de Actividad Reciente -->
        <div class="row">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h5><i class="fas fa-clock"></i> Actividad Reciente</h5>
                    </div>
                    <div class="card-body">
                        <%
                            Map<String, Object> actividadReciente = (Map<String, Object>) request.getAttribute("actividadReciente");
                            List<Publicacion> publicacionesRecientes = actividadReciente != null ? 
                                (List<Publicacion>) actividadReciente.get("publicacionesRecientes") : new ArrayList<>();
                            boolean tieneActividad = actividadReciente != null && 
                                (Boolean) actividadReciente.getOrDefault("tieneActividad", false);
                        %>
                        
                        <% if (tieneActividad && !publicacionesRecientes.isEmpty()) { %>
                            <!-- Publicaciones recientes -->
                            <% for (Publicacion pub : publicacionesRecientes) { %>
                                <div class="actividad-item mb-3 p-3" style="border-left: 4px solid #667eea; background: #f8f9fa; border-radius: 5px;">
                                    <div class="d-flex align-items-start">
                                        <div class="actividad-icono me-3">
                                            <i class="fas fa-edit text-primary" style="font-size: 1.2em;"></i>
                                        </div>
                                        <div class="actividad-contenido flex-grow-1">
                                            <div class="actividad-header d-flex justify-content-between align-items-start">
                                                <div>
                                                    <strong>Publicó en 
                                                        <% if (pub.getNombreComunidad() != null) { %>
                                                            <%= pub.getNombreComunidad() %>
                                                        <% } else { %>
                                                            El Feed Principal
                                                        <% } %>
                                                    </strong>
                                                </div>
                                                <small class="text-muted">
                                                    <% if (pub.getFechaPublicacion() != null) { %>
                                                        <%= java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm").format(pub.getFechaPublicacion()) %>
                                                    <% } %>
                                                </small>
                                            </div>
                                            
                                            <div class="actividad-texto mt-2">
                                                <p class="mb-2"><%= pub.getTexto() %></p>
                                                
                                                <% if (pub.getImagenUrl() != null && !pub.getImagenUrl().isEmpty()) { %>
                                                    <div class="actividad-imagen mb-2">
                                                        <img src="<%= pub.getImagenUrl() %>" alt="Imagen de publicación" 
                                                             style="max-width: 200px; max-height: 150px; border-radius: 8px; object-fit: cover;">
                                                    </div>
                                                <% } %>
                                                
                                                <div class="actividad-stats">
                                                    <span class="badge bg-light text-dark me-2">
                                                        <i class="fas fa-heart text-danger"></i> <%= pub.getCantidadLikes() %>
                                                    </span>
                                                    <span class="badge bg-light text-dark">
                                                        <i class="fas fa-comment text-primary"></i> <%= pub.getCantidadComentarios() %>
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            <% } %>
                            
                            <!-- Uniones a comunidades (solo para perfil propio) -->
                            <% if ((Boolean) request.getAttribute("esPerfilPropio") && 
                                   actividadReciente.get("unionesRecientes") != null) { %>
                                <%
                                    List<Map<String, Object>> unionesRecientes = 
                                        (List<Map<String, Object>>) actividadReciente.get("unionesRecientes");
                                %>
                                <% for (Map<String, Object> union : unionesRecientes) { %>
                                    <div class="actividad-item mb-3 p-3" style="border-left: 4px solid #28a745; background: #f8f9fa; border-radius: 5px;">
                                        <div class="d-flex align-items-start">
                                            <div class="actividad-icono me-3">
                                                <i class="fas fa-users text-success" style="font-size: 1.2em;"></i>
                                            </div>
                                            <div class="actividad-contenido flex-grow-1">
                                                <div class="actividad-header d-flex justify-content-between align-items-start">
                                                    <div>
                                                        <strong>Se unió a <%= union.get("nombreComunidad") %></strong>
                                                        <% if ("admin".equals(union.get("rol"))) { %>
                                                            <span class="badge bg-warning ms-2">Admin</span>
                                                        <% } %>
                                                    </div>
                                                    <small class="text-muted">
                                                        <% if (union.get("fechaUnion") != null) { %>
                                                            <%= java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy").format(
                                                                ((java.sql.Timestamp) union.get("fechaUnion")).toLocalDateTime()) %>
                                                        <% } %>
                                                    </small>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                <% } %>
                            <% } %>
                            
                        <% } else { %>
                            <!-- Sin actividad -->
                            <div class="text-center text-muted py-4">
                                <i class="fas fa-clock fa-3x mb-3"></i>
                                <h6>Sin actividad reciente</h6>
                                <p>Este usuario no ha realizado actividades públicas recientemente.</p>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
            
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">
                        <h5><i class="fas fa-users"></i> Comunidades</h5>
                    </div>
                    <div class="card-body">
                        <%
                            Map<String, Object> infoComunidades = actividadReciente != null ? 
                                (Map<String, Object>) actividadReciente.get("comunidades") : new HashMap<>();
                            
                            List<Comunidad> comunidadesSeguidas = infoComunidades.get("seguidas") != null ? 
                                (List<Comunidad>) infoComunidades.get("seguidas") : new ArrayList<>();
                            List<Comunidad> comunidadesAdministra = infoComunidades.get("administra") != null ? 
                                (List<Comunidad>) infoComunidades.get("administra") : new ArrayList<>();
                            
                            int totalSeguidas = infoComunidades.get("totalSeguidas") != null ? 
                                (Integer) infoComunidades.get("totalSeguidas") : 0;
                            int totalAdministra = infoComunidades.get("totalAdministra") != null ? 
                                (Integer) infoComunidades.get("totalAdministra") : 0;
                        %>
                        
                        <!-- Estadísticas de Comunidades -->
                        <div class="row text-center mb-3">
                            <div class="col-6">
                                <div class="stat-box p-2" style="background: #f8f9fa; border-radius: 8px;">
                                    <h6 class="text-primary mb-1"><%= totalSeguidas %></h6>
                                    <small class="text-muted">Sigue</small>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="stat-box p-2" style="background: #f8f9fa; border-radius: 8px;">
                                    <h6 class="text-success mb-1"><%= totalAdministra %></h6>
                                    <small class="text-muted">Administra</small>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Comunidades que Administra -->
                        <% if (!comunidadesAdministra.isEmpty()) { %>
                            <div class="mb-4">
                                <h6 class="text-success mb-2">
                                    <i class="fas fa-shield-alt"></i> Administra
                                </h6>
                                <% for (Comunidad comunidad : comunidadesAdministra) { %>
                                    <div class="comunidad-mini mb-2 p-2" 
                                         style="background: #f8f9fa; border-radius: 8px; border-left: 3px solid #28a745; cursor: pointer;"
                                         onclick="window.location.href='ComunidadServlet?action=view&id=<%= comunidad.getIdComunidad() %>';">
                                        <div class="d-flex align-items-center">
                                            <div class="comunidad-avatar me-2">
                                                <% if (comunidad.getImagenUrl() != null && !comunidad.getImagenUrl().isEmpty()) { %>
                                                    <img src="<%= comunidad.getImagenUrl() %>" alt="<%= comunidad.getNombre() %>"
                                                         style="width: 32px; height: 32px; border-radius: 50%; object-fit: cover;">
                                                <% } else { %>
                                                    <div style="width: 32px; height: 32px; border-radius: 50%; background: #28a745; 
                                                               display: flex; align-items: center; justify-content: center; color: white; font-size: 12px;">
                                                        <%= comunidad.getNombre().substring(0,1).toUpperCase() %>
                                                    </div>
                                                <% } %>
                                            </div>
                                            <div class="flex-grow-1">
                                                <div class="comunidad-nombre" style="font-size: 13px; font-weight: bold;">
                                                    <%= comunidad.getNombre() %>
                                                </div>
                                                <small class="text-muted">
                                                    <%= comunidad.getSeguidoresCount() %> miembros
                                                    <% if (!comunidad.isEsPublica()) { %>
                                                        • <i class="fas fa-lock" title="Privada"></i>
                                                    <% } %>
                                                </small>
                                            </div>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                        <% } %>
                        
                        <!-- Comunidades que Sigue -->
                        <% if (!comunidadesSeguidas.isEmpty()) { %>
                            <div class="mb-3">
                                <h6 class="text-primary mb-2">
                                    <i class="fas fa-heart"></i> Comunidades que sigue
                                </h6>
                                <% for (Comunidad comunidad : comunidadesSeguidas) { %>
                                    <div class="comunidad-mini mb-2 p-2" 
                                         style="background: #f8f9fa; border-radius: 8px; border-left: 3px solid #667eea; cursor: pointer;"
                                         onclick="window.location.href='ComunidadServlet?action=view&id=<%= comunidad.getIdComunidad() %>';">
                                        <div class="d-flex align-items-center">
                                            <div class="comunidad-avatar me-2">
                                                <% if (comunidad.getImagenUrl() != null && !comunidad.getImagenUrl().isEmpty()) { %>
                                                    <img src="<%= comunidad.getImagenUrl() %>" alt="<%= comunidad.getNombre() %>"
                                                         style="width: 28px; height: 28px; border-radius: 50%; object-fit: cover;">
                                                <% } else { %>
                                                    <div style="width: 28px; height: 28px; border-radius: 50%; background: #667eea; 
                                                               display: flex; align-items: center; justify-content: center; color: white; font-size: 11px;">
                                                        <%= comunidad.getNombre().substring(0,1).toUpperCase() %>
                                                    </div>
                                                <% } %>
                                            </div>
                                            <div class="flex-grow-1">
                                                <div class="comunidad-nombre" style="font-size: 12px; font-weight: 500;">
                                                    <%= comunidad.getNombre() %>
                                                </div>
                                                <small class="text-muted" style="font-size: 10px;">
                                                    <%= comunidad.getSeguidoresCount() %> miembros
                                                </small>
                                            </div>
                                        </div>
                                    </div>
                                <% } %>
                                
                                <!-- Ver más comunidades -->
                                <% if (totalSeguidas > 6) { %>
                                    <div class="text-center mt-2">
                                        <small class="text-muted">
                                            Y <%= totalSeguidas - 6 %> comunidades más...
                                        </small>
                                    </div>
                                <% } %>
                            </div>
                        <% } %>
                        
                        <!-- Información adicional solo para perfil propio -->
                        <% if ((Boolean) request.getAttribute("esPerfilPropio")) { %>
                            <%
                                int solicitudesPendientes = infoComunidades.get("solicitudesPendientes") != null ? 
                                    (Integer) infoComunidades.get("solicitudesPendientes") : 0;
                                int totalCreadas = infoComunidades.get("totalCreadas") != null ? 
                                    (Integer) infoComunidades.get("totalCreadas") : 0;
                            %>
                            
                            <div class="border-top pt-3 mt-3">
                                <h6 class="text-muted mb-2" style="font-size: 12px;">Tu Actividad</h6>
                                
                                <% if (totalCreadas > 0) { %>
                                    <div class="mb-2">
                                        <span class="badge bg-info">
                                            <i class="fas fa-plus-circle"></i> <%= totalCreadas %> creadas
                                        </span>
                                    </div>
                                <% } %>
                                
                                <% if (solicitudesPendientes > 0) { %>
                                    <div class="mb-2">
                                        <span class="badge bg-warning">
                                            <i class="fas fa-clock"></i> <%= solicitudesPendientes %> pendientes
                                        </span>
                                    </div>
                                <% } %>
                                
                                <div class="text-center mt-3">
                                    <a href="ComunidadServlet" class="btn btn-outline-primary btn-sm">
                                        <i class="fas fa-search"></i> Explorar más
                                    </a>
                                </div>
                            </div>
                        <% } %>
                        
                        <!-- Sin comunidades -->
                        <% if (comunidadesSeguidas.isEmpty() && comunidadesAdministra.isEmpty()) { %>
                            <div class="text-center text-muted py-3">
                                <i class="fas fa-users fa-2x mb-2"></i>
                                <h6>Sin comunidades</h6>
                                <% if ((Boolean) request.getAttribute("esPerfilPropio")) { %>
                                    <p class="small">¡Explora y únete a comunidades!</p>
                                    <a href="ComunidadServlet" class="btn btn-primary btn-sm">
                                        <i class="fas fa-search"></i> Explorar
                                    </a>
                                <% } else { %>
                                    <p class="small">Este usuario no sigue comunidades públicas.</p>
                                <% } %>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <%@ include file="/components/js_imports.jsp" %>
    
    <script>
        $(document).ready(function() {
            console.log('👤 Perfil de usuario cargado: <%= usuarioPerfilado.getUsername() %>');
            
            // ✅ CAMBIO 2: AGREGAR DEBUGGING PARA VERIFICAR QUE FUNCIONA
            <% if (estadisticas != null) { %>
                console.log('📊 Estadísticas cargadas:', {
                    publicaciones: <%= estadisticas.get("totalPublicaciones") != null ? estadisticas.get("totalPublicaciones") : 0 %>,
                    comunidades: <%= estadisticas.get("comunidadesSeguidas") != null ? estadisticas.get("comunidadesSeguidas") : 0 %>
                });
            <% } else { %>
                console.log('⚠️ No se cargaron estadísticas');
            <% } %>
            
            <% if (request.getAttribute("actividadReciente") != null) { %>
                console.log('⚡ Actividad reciente cargada');
            <% } else { %>
                console.log('⚠️ No se cargó actividad reciente');
            <% } %>
            
    </script>
</body>
</html>