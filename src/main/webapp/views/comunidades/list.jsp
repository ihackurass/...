<%-- 
    Document   : list
    Created on : Lista Dinámica de Comunidades
    Author     : Rodrigo
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="pe.aquasocial.entity.Comunidad"%>
<%@page import="pe.aquasocial.entity.Usuario"%>

<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuarioLogueado");
    List<Comunidad> comunidades = (List<Comunidad>) request.getAttribute("comunidades");
    Integer totalComunidades = (Integer) request.getAttribute("totalComunidades");
    String searchQuery = (String) request.getAttribute("searchQuery");
    String error = (String) request.getAttribute("error");
    
    // Determinar tipo de vista
    String tipoVista = request.getParameter("action");
    if (tipoVista == null) tipoVista = "all";
    
    // Configurar título y descripción según el tipo
    String titulo = "Todas las Comunidades";
    String descripcion = "Explora y encuentra comunidades que te interesen";
    String icono = "fas fa-globe";
    
    if ("myCommunities".equals(tipoVista)) {
        titulo = "Mis Comunidades";
        descripcion = "Comunidades en las que participas activamente";
        icono = "fas fa-heart";
    } else if ("managedCommunities".equals(tipoVista)) {
        titulo = "Comunidades que Administro";
        descripcion = "Comunidades bajo tu gestión y control";
        icono = "fas fa-crown";
    }
    
    if (totalComunidades == null) totalComunidades = 0;
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= titulo %></title>
    <jsp:include page="/components/css_imports.jsp" />
</head>

<style>
    .container {
        margin-bottom: 30px;
        background-color: #ffffff;
        border-radius: 10px;
        padding: 20px;
        box-shadow: 0 15px 50px rgba(0, 0, 0, 0.2);
        border: 1px solid #ddd;
    }

    .section-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
        border-bottom: 2px solid #007bff;
        padding-bottom: 15px;
    }

    .section-header h2 {
        font-size: 24px;
        color: #007bff;
        margin: 0;
    }

    .section-header .subtitle {
        margin: 5px 0 0 0;
        color: #666;
        font-size: 14px;
    }

    /* Búsqueda mejorada con filtros */
    .search-filter-container {
        display: flex;
        gap: 15px;
        align-items: center;
        flex-wrap: wrap;
    }

    .search-box {
        position: relative;
        flex: 1;
        min-width: 250px;
    }

    .search-box input {
        padding: 10px 15px 10px 40px;
        border: 2px solid #e9ecef;
        border-radius: 25px;
        width: 100%;
        font-size: 14px;
        transition: border-color 0.3s ease;
    }

    .search-box input:focus {
        border-color: #007bff;
        outline: none;
        box-shadow: 0 0 0 0.2rem rgba(0,123,255,0.25);
    }

    .search-box i {
        position: absolute;
        left: 15px;
        top: 50%;
        transform: translateY(-50%);
        color: #6c757d;
    }

    .filter-dropdown {
        padding: 10px 15px;
        border: 2px solid #e9ecef;
        border-radius: 25px;
        background: white;
        font-size: 14px;
        min-width: 150px;
        transition: border-color 0.3s ease;
    }

    .filter-dropdown:focus {
        border-color: #007bff;
        outline: none;
    }

    .clear-filters-btn {
        background: #dc3545;
        color: white;
        border: none;
        padding: 10px 15px;
        border-radius: 25px;
        font-size: 14px;
        cursor: pointer;
        transition: all 0.3s ease;
        display: none;
    }

    .clear-filters-btn:hover {
        background: #c82333;
        transform: translateY(-1px);
    }

    .search-container {
        display: flex;
        align-items: center;
        gap: 5px;
    }

    .search-container input[type="text"] {
        padding: 10px;
        font-size: 16px;
        border: 1px solid #ccc;
        border-radius: 5px 0 0 5px;
        width: 250px;
    }

    .search-container button {
        background: #007bff;
        border: 1px solid #007bff;
        padding: 10px 15px;
        cursor: pointer;
        border-radius: 0 5px 5px 0;
        color: white;
        font-size: 16px;
    }

    .search-container button:hover {
        background: #0056b3;
    }

    /* Filtros de navegación */
    .filter-tabs {
        display: flex;
        gap: 10px;
        margin-bottom: 20px;
        border-bottom: 1px solid #ddd;
        padding-bottom: 15px;
    }

    .filter-tab {
        padding: 10px 20px;
        background: #f8f9fa;
        border: 1px solid #ddd;
        border-radius: 25px;
        text-decoration: none;
        color: #666;
        font-size: 14px;
        font-weight: 500;
        transition: all 0.3s ease;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .filter-tab:hover {
        background: #e9ecef;
        color: #495057;
        text-decoration: none;
    }

    .filter-tab.active {
        background: #007bff;
        color: white;
        border-color: #007bff;
        text-decoration: none;
    }

    /* Estadísticas para mis comunidades */
    .stats-summary {
        display: flex;
        gap: 20px;
        margin-bottom: 25px;
        padding: 15px;
        background: linear-gradient(135deg, #f8f9fa, #e9ecef);
        border-radius: 10px;
        border: 1px solid #dee2e6;
    }

    .stat-box {
        text-align: center;
        flex: 1;
    }

    .stat-number {
        display: block;
        font-size: 24px;
        font-weight: bold;
        color: #007bff;
        margin-bottom: 5px;
    }

    .stat-label {
        font-size: 12px;
        color: #666;
        font-weight: 500;
        text-transform: uppercase;
    }

    /* Grid de comunidades */
    .community-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
        gap: 20px;
        margin-top: 20px;
    }

    .community-card {
        background: white;
        border: 1px solid #e0e0e0;
        border-radius: 12px;
        padding: 20px;
        transition: all 0.3s ease;
        position: relative;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }

    .community-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 25px rgba(0,123,255,0.15);
        border-color: #007bff;
    }

    .community-header {
        display: flex;
        align-items: center;
        margin-bottom: 15px;
    }

    .community-avatar {
        width: 50px;
        height: 50px;
        border-radius: 50%;
        background: linear-gradient(135deg, #007bff, #28a745);
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-size: 1.2rem;
        font-weight: bold;
        margin-right: 15px;
        box-shadow: 0 3px 10px rgba(0,123,255,0.3);
    }

    .community-info h3 {
        margin: 0 0 5px 0;
        font-size: 16px;
        color: #333;
        font-weight: 600;
    }

    .community-handle {
        font-size: 12px;
        color: #666;
        margin-bottom: 5px;
    }

    .role-badge {
        position: absolute;
        top: 15px;
        right: 15px;
        padding: 4px 8px;
        border-radius: 10px;
        font-size: 10px;
        font-weight: 600;
        text-transform: uppercase;
    }

    .role-creator {
        background: #ffc107;
        color: #333;
    }

    .role-admin {
        background: #17a2b8;
        color: white;
    }

    .role-member {
        background: #28a745;
        color: white;
    }

    .privacy-badge {
        position: absolute;
        top: 15px;
        left: 15px;
        font-size: 10px;
        padding: 3px 6px;
        border-radius: 8px;
    }

    .badge-public {
        background: #28a745;
        color: white;
    }

    .badge-private {
        background: #ffc107;
        color: #333;
    }

    .community-description {
        color: #666;
        font-size: 13px;
        line-height: 1.4;
        margin-bottom: 15px;
        display: -webkit-box;
        -webkit-line-clamp: 3;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }

    .community-stats {
        display: flex;
        gap: 15px;
        margin-bottom: 15px;
        font-size: 12px;
        color: #999;
    }

    .stat-item {
        display: flex;
        align-items: center;
        gap: 4px;
    }

    .community-actions {
        display: flex;
        gap: 8px;
    }

    .btn-action {
        padding: 8px 15px;
        border: none;
        border-radius: 5px;
        font-size: 12px;
        font-weight: 600;
        text-decoration: none;
        cursor: pointer;
        transition: all 0.3s ease;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        flex: 1;
        justify-content: center;
    }

    .btn-primary {
        background: #007bff;
        color: white;
    }

    .btn-primary:hover {
        background: #0056b3;
        color: white;
        text-decoration: none;
    }

    .btn-success {
        background: #28a745;
        color: white;
    }

    .btn-success:hover {
        background: #1e7e34;
        color: white;
        text-decoration: none;
    }

    .btn-danger {
        background: #dc3545;
        color: white;
    }

    .btn-danger:hover {
        background: #c82333;
        color: white;
        text-decoration: none;
    }

    .btn-secondary {
        background: #6c757d;
        color: white;
    }

    .btn-secondary:hover {
        background: #545b62;
        color: white;
        text-decoration: none;
    }

    .quick-actions {
        background: #f8f9fa;
        padding: 15px;
        border-radius: 10px;
        margin-bottom: 20px;
        border: 1px solid #e9ecef;
    }

    .quick-actions h4 {
        margin: 0 0 10px 0;
        font-size: 14px;
        color: #495057;
    }

    .quick-action-btns {
        display: flex;
        gap: 8px;
        flex-wrap: wrap;
    }

    .quick-btn {
        padding: 6px 12px;
        background: white;
        border: 1px solid #ddd;
        border-radius: 15px;
        text-decoration: none;
        color: #495057;
        font-size: 12px;
        transition: all 0.3s ease;
    }

    .quick-btn:hover {
        background: #007bff;
        color: white;
        text-decoration: none;
        border-color: #007bff;
    }

    .create-btn {
        position: fixed;
        bottom: 30px;
        right: 30px;
        width: 60px;
        height: 60px;
        border-radius: 50%;
        background: #007bff;
        color: white;
        border: none;
        font-size: 24px;
        cursor: pointer;
        box-shadow: 0 4px 12px rgba(0,123,255,0.3);
        transition: all 0.3s ease;
        z-index: 1000;
    }

    .create-btn:hover {
        transform: scale(1.1);
        box-shadow: 0 6px 20px rgba(0,123,255,0.4);
    }

    .join-date {
        font-size: 11px;
        color: #999;
        font-style: italic;
    }

    /* Contador de resultados */
    .results-counter {
        background: #e3f2fd;
        padding: 10px 15px;
        border-radius: 8px;
        margin-bottom: 15px;
        font-size: 14px;
        color: #1976d2;
        border-left: 4px solid #2196f3;
        display: none;
    }

    /* Estado sin resultados */
    .no-results {
        text-align: center;
        padding: 40px 20px;
        color: #6c757d;
        display: none;
    }

    .no-results i {
        font-size: 3rem;
        margin-bottom: 15px;
        opacity: 0.5;
    }

    @media (max-width: 768px) {
        .search-filter-container {
            flex-direction: column;
            align-items: stretch;
        }
        
        .search-box {
            min-width: auto;
        }
        
        .community-grid {
            grid-template-columns: 1fr;
        }
        
        .filter-tabs {
            flex-wrap: wrap;
        }
    }
</style>

<body>
    <!-- Sidebar Izquierdo -->
    <jsp:include page="/components/sidebar.jsp" />

    <!-- Main -->
    <main>
        <div class="site-section">
            <div class="container">
                <div class="row">
                    <div class="col-md-12">
                        <!-- Header dinámico -->
                        <div class="section-header">
                            <div>
                                <h2>
                                    <i class="<%= icono %> me-2"></i>
                                    <%= titulo %>
                                    <span style="font-size: 14px; color: #666; font-weight: normal;">
                                        (<span id="totalComunidades"><%= totalComunidades %></span> 
                                        <%= "myCommunities".equals(tipoVista) ? "seguidas" : 
                                            "managedCommunities".equals(tipoVista) ? "administradas" : "encontradas" %>)
                                    </span>
                                </h2>
                                <p class="subtitle"><%= descripcion %></p>
                            </div>
                            
                            <!-- Búsqueda mejorada con filtros (solo en "todas") -->
                            <% if ("all".equals(tipoVista) || tipoVista == null) { %>
                                <div class="search-filter-container">
                                    <div class="search-box">
                                        <i class="fas fa-search"></i>
                                        <input type="text" id="searchCommunities" placeholder="Buscar comunidades..." value="<%= searchQuery != null ? searchQuery : "" %>">
                                    </div>
                                    <select class="filter-dropdown" id="filterPrivacy">
                                        <option value="">Todas las comunidades</option>
                                        <option value="public">Solo públicas</option>
                                        <option value="private">Solo privadas</option>
                                    </select>
                                    <select class="filter-dropdown" id="filterRole">
                                        <option value="">Todos los roles</option>
                                        <% if (usuarioActual != null) { %>
                                            <option value="creator">Soy creador</option>
                                            <option value="admin">Soy admin</option>
                                            <option value="member">Soy miembro</option>
                                            <option value="not-member">No soy miembro</option>
                                        <% } %>
                                    </select>
                                    <button class="clear-filters-btn" id="clearFilters">
                                        <i class="fas fa-times"></i> Limpiar
                                    </button>
                                </div>
                            <% } else { %>
                                <!-- Búsqueda simple para mis comunidades -->
                                <div class="search-filter-container">
                                    <div class="search-box">
                                        <i class="fas fa-search"></i>
                                        <input type="text" id="searchCommunities" placeholder="Buscar en mis comunidades...">
                                    </div>
                                    <button class="clear-filters-btn" id="clearFilters">
                                        <i class="fas fa-times"></i> Limpiar
                                    </button>
                                </div>
                            <% } %>
                        </div>

                        <!-- Mensaje de error -->
                        <% if (error != null) { %>
                            <div class="alert alert-danger">
                                <i class="fas fa-exclamation-triangle me-2"></i>
                                <%= error %>
                            </div>
                        <% } %>

                        <!-- Filtros de navegación -->
                        <div class="filter-tabs">
                            <a href="ComunidadServlet" 
                               class="filter-tab <%= ("all".equals(tipoVista) || tipoVista == null) ? "active" : "" %>">
                                <i class="fas fa-globe"></i>Todas las Comunidades
                            </a>
                            <% if (usuarioActual != null) { %>
                                <a href="ComunidadServlet?action=myCommunities" 
                                   class="filter-tab <%= "myCommunities".equals(tipoVista) ? "active" : "" %>">
                                    <i class="fas fa-heart"></i>Mis Comunidades
                                </a>
                                <a href="ComunidadServlet?action=managedCommunities" 
                                   class="filter-tab <%= "managedCommunities".equals(tipoVista) ? "active" : "" %>">
                                    <i class="fas fa-crown"></i>Que Administro
                                </a>
                            <% } %>
                        </div>

                        <!-- Estadísticas para mis comunidades y administradas -->
                        <% if ("myCommunities".equals(tipoVista) || "managedCommunities".equals(tipoVista)) { %>
                            <div class="stats-summary">
                                <div class="stat-box">
                                    <span class="stat-number"><%= totalComunidades %></span>
                                    <span class="stat-label"><%= "myCommunities".equals(tipoVista) ? "Seguidas" : "Administradas" %></span>
                                </div>
                                <div class="stat-box">
                                    <span class="stat-number">
                                        <%
                                            int administradas = 0;
                                            for (Comunidad c : comunidades) {
                                                if (c.isUsuarioEsAdmin() || c.isUsuarioEsCreador()) {
                                                    administradas++;
                                                }
                                            }
                                        %>
                                        <%= administradas %>
                                    </span>
                                    <span class="stat-label">Con Privilegios</span>
                                </div>
                                <div class="stat-box">
                                    <span class="stat-number">
                                        <%
                                            int totalMiembros = 0;
                                            for (Comunidad c : comunidades) {
                                                totalMiembros += c.getSeguidoresCount();
                                            }
                                        %>
                                        <%= totalMiembros %>
                                    </span>
                                    <span class="stat-label">Total Miembros</span>
                                </div>
                            </div>
                        <% } %>

                        <!-- Contador de resultados filtrados -->
                        <div class="results-counter" id="resultsCounter">
                            Mostrando <span id="filteredCount">0</span> de <%= totalComunidades %> comunidades
                        </div>

                        <!-- Grid de comunidades -->
                        <% if (comunidades != null && !comunidades.isEmpty()) { %>
                            <div class="community-grid" id="communityGrid">
                                <% for (Comunidad comunidad : comunidades) { %>
                                    <div class="community-card" 
                                         data-name="<%= comunidad.getNombre().toLowerCase() %>"
                                         data-handle="<%= comunidad.getUsername() != null ? comunidad.getUsername().toLowerCase() : "" %>"
                                         data-description="<%= comunidad.getDescripcion() != null ? comunidad.getDescripcion().toLowerCase() : "" %>"
                                         data-privacy="<%= comunidad.isEsPublica() ? "public" : "private" %>"
                                         data-role="<%= comunidad.isUsuarioEsCreador() ? "creator" : 
                                                       comunidad.isUsuarioEsAdmin() ? "admin" : 
                                                       comunidad.isUsuarioEsSeguidor() ? "member" : "not-member" %>">
                                        
                                        <!-- Badge de privacidad (solo en "todas") -->
                                        <% if ("all".equals(tipoVista) || tipoVista == null) { %>
                                            <div class="privacy-badge <%= comunidad.isEsPublica() ? "badge-public" : "badge-private" %>">
                                                <%= comunidad.isEsPublica() ? "Pública" : "Privada" %>
                                            </div>
                                        <% } %>

                                        <!-- Badge de rol (solo en "mis comunidades" y "que administro") -->
                                        <% if (!"all".equals(tipoVista) && tipoVista != null) { %>
                                            <div class="role-badge <%= comunidad.isUsuarioEsCreador() ? "role-creator" : 
                                                    comunidad.isUsuarioEsAdmin() ? "role-admin" : "role-member" %>">
                                                <% if (comunidad.isUsuarioEsCreador()) { %>
                                                    <i class="fas fa-crown"></i> Creador
                                                <% } else if (comunidad.isUsuarioEsAdmin()) { %>
                                                    <i class="fas fa-shield-alt"></i> Admin
                                                <% } else { %>
                                                    <i class="fas fa-user"></i>
                                                <% } %>
                                            </div>
                                        <% } %>

                                        <!-- Header de la comunidad -->
                                        <div class="community-header">
                                            <div class="community-avatar">
                                                <% 
                                                    String imagenUrl = comunidad.getImagenUrl();
                                                    String nombreComunidad = comunidad.getNombre();

                                                    boolean tieneImagenPersonalizada = imagenUrl != null && 
                                                                                      !imagenUrl.trim().isEmpty() && 
                                                                                      !imagenUrl.equals("default.png") &&
                                                                                      !imagenUrl.endsWith("default.png");
                                                %>

                                                <% if (tieneImagenPersonalizada) { %>
                                                    <img src="<%= imagenUrl %>" alt="<%= nombreComunidad %>" 
                                                         style="width: 100%; height: 100%; object-fit: cover; border-radius: inherit;">
                                                <% } else { %>
                                                    <%= nombreComunidad != null ? nombreComunidad.substring(0,1).toUpperCase() : "C" %>
                                                <% } %>
                                            </div>
                                            <div class="community-info">
                                                <h3><%= comunidad.getNombre() %></h3>
                                                <% if (comunidad.getUsername() != null && !comunidad.getUsername().trim().isEmpty()) { %>
                                                    <div class="community-handle">@<%= comunidad.getUsername() %></div>
                                                <% } else { %>
                                                    <div class="community-handle">Sin username</div>
                                                <% } %>
                                                <% if ("myCommunities".equals(tipoVista)) { %>
                                                    <div class="join-date">
                                                        <i class="fas fa-calendar"></i>
                                                        Miembro desde <%= comunidad.getFechaCreacion() != null ? 
                                                            new java.text.SimpleDateFormat("dd/MM/yyyy").format(
                                                                java.sql.Timestamp.valueOf(comunidad.getFechaCreacion())) : "fecha desconocida" %>
                                                    </div>
                                                <% } %>
                                            </div>
                                        </div>

                                        <!-- Descripción -->
                                        <div class="community-description">
                                            <%= comunidad.getDescripcion() != null ? comunidad.getDescripcion() : "Sin descripción disponible" %>
                                        </div>

                                        <!-- Estadísticas -->
                                        <div class="community-stats">
                                            <div class="stat-item">
                                                <i class="fas fa-users"></i>
                                                <%= comunidad.getSeguidoresCount() %> miembros
                                            </div>
                                            <div class="stat-item">
                                                <i class="fas fa-newspaper"></i>
                                                <%= comunidad.getPublicacionesCount() %> posts
                                            </div>
                                        </div>

                                        <!-- Acciones -->
                                        <div class="community-actions">
                                            <!-- Botón para ver -->
                                            <a href="ComunidadServlet?action=view&id=<%= comunidad.getIdComunidad() %>" 
                                               class="btn-action btn-primary">
                                                <i class="fas fa-eye"></i> Ver
                                            </a>

                                            <% if (usuarioActual != null) { %>
                                                <% if (comunidad.isUsuarioEsSeguidor()) { %>
                                                    <!-- Opciones para miembros -->
                                                    <% if (comunidad.isUsuarioEsCreador()) { %>
                                                        <a href="ComunidadServlet?action=edit&id=<%= comunidad.getIdComunidad() %>" 
                                                           class="btn-action btn-secondary">
                                                            <i class="fas fa-edit"></i> Editar
                                                        </a>
                                                    <% } %>
                                                    
                                                    <% if (!comunidad.isUsuarioEsCreador()) { %>
                                                        <button class="btn-action btn-danger" style="width: 100%;" 
                                                                onclick="confirmarSalirComunidad(<%= comunidad.getIdComunidad() %>, '<%= comunidad.getNombre().replace("'", "\\'") %>')">
                                                            <i class="fas fa-sign-out-alt"></i> Salir
                                                        </button>
                                                    <% } %>
                                                <% } else { %>
                                                    <!-- Acción para unirse -->
                                                    <button class="btn-action btn-success" style="width: 100%;" 
                                                            onclick="confirmarUnirseComunidad(<%= comunidad.getIdComunidad() %>, '<%= comunidad.getNombre().replace("'", "\\'") %>', <%= comunidad.isEsPublica() %>)">
                                                        <i class="fas fa-plus"></i> Unirse
                                                    </button>
                                                <% } %>
                                            <% } %>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                            
                            <!-- Mensaje cuando no hay resultados del filtro -->
                            <div class="no-results" id="noResults">
                                <i class="fas fa-search"></i>
                                <h3>No se encontraron comunidades</h3>
                                <p>Intenta ajustar los filtros de búsqueda</p>
                            </div>
                            
                        <% } else { %>
                            <div style="text-align: center; padding: 60px 20px; color: #6c757d;">
                                <% if ("myCommunities".equals(tipoVista)) { %>
                                    <i class="fas fa-heart" style="font-size: 4rem; margin-bottom: 20px; opacity: 0.5;"></i>
                                    <h3>No sigues ninguna comunidad</h3>
                                    <p>Explora comunidades y únete a las que te interesen</p>
                                    <a href="ComunidadServlet" class="btn-action btn-primary">
                                        <i class="fas fa-search"></i> Explorar Comunidades
                                    </a>
                                <% } else if ("managedCommunities".equals(tipoVista)) { %>
                                    <i class="fas fa-crown" style="font-size: 4rem; margin-bottom: 20px; opacity: 0.5;"></i>
                                    <h3>No administras ninguna comunidad</h3>
                                    <p>Crea tu primera comunidad y conviértete en líder</p>
                                    <a href="#" onclick="abrirModalCrear()" class="btn-action btn-primary">
                                        <i class="fas fa-plus"></i> Crear Mi Primera Comunidad
                                    </a>
                                <% } else { %>
                                    <i class="fas fa-users" style="font-size: 4rem; margin-bottom: 20px; opacity: 0.5;"></i>
                                    <h3>
                                        <% if (searchQuery != null && !searchQuery.trim().isEmpty()) { %>
                                            No se encontraron comunidades
                                        <% } else { %>
                                            No hay comunidades disponibles
                                        <% } %>
                                    </h3>
                                    <p>
                                        <% if (searchQuery != null && !searchQuery.trim().isEmpty()) { %>
                                            Intenta con otros términos de búsqueda
                                        <% } else { %>
                                            ¡Sé el primero en crear una comunidad!
                                        <% } %>
                                    </p>
                                    <% if (usuarioActual != null) { %>
                                        <a href="#" onclick="abrirModalCrear()" class="btn-action btn-primary">
                                            <i class="fas fa-plus"></i> Crear Comunidad
                                        </a>
                                    <% } %>
                                <% } %>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <!-- Botón flotante para crear (solo si está logueado) -->
    <% if (usuarioActual != null) { %>
        <button onclick="abrirModalCrear()" class="create-btn" title="Crear Nueva Comunidad">
            <i class="fas fa-plus"></i>
        </button>
    <% } %>

    <jsp:include page="/components/js_imports.jsp" />

    <script>
        $(document).ready(function() {
            const totalComunidades = <%= totalComunidades %>;
            
            // Funcionalidad de búsqueda y filtros en tiempo real
            $('#searchCommunities').on('input', function() {
                filterCommunities();
            });
            
            $('#filterPrivacy').on('change', function() {
                filterCommunities();
            });
            
            $('#filterRole').on('change', function() {
                filterCommunities();
            });
            
            // Botón limpiar filtros
            $('#clearFilters').on('click', function() {
                $('#searchCommunities').val('');
                $('#filterPrivacy').val('');
                $('#filterRole').val('');
                filterCommunities();
                $(this).hide();
            });

            function filterCommunities() {
                const searchTerm = $('#searchCommunities').val().toLowerCase();
                const selectedPrivacy = $('#filterPrivacy').val();
                const selectedRole = $('#filterRole').val();

                let visibleCount = 0;
                let hasActiveFilters = searchTerm !== '' || selectedPrivacy !== '' || selectedRole !== '';

                $('.community-card').each(function() {
                    const $card = $(this);

                    function getTextData(attr) {
                        const value = $card.data(attr);
                        if (value === null || value === undefined) {
                            return '';
                        }
                        return String(value).toLowerCase();
                    }

                    const name = getTextData('name');
                    const handle = getTextData('handle');
                    const description = getTextData('description');
                    const privacy = String($card.data('privacy') || '');
                    const role = String($card.data('role') || '');

                    // Filtro de búsqueda
                    const matchesSearch = searchTerm === '' || 
                        name.includes(searchTerm) || 
                        handle.includes(searchTerm) || 
                        description.includes(searchTerm);

                    // Filtro de privacidad
                    const matchesPrivacy = selectedPrivacy === '' || privacy === selectedPrivacy;

                    // Filtro de rol
                    const matchesRole = selectedRole === '' || role === selectedRole;

                    if (matchesSearch && matchesPrivacy && matchesRole) {
                        $card.show();
                        visibleCount++;
                    } else {
                        $card.hide();
                    }
                });

                // ... resto del código igual ...
            }
            // Función para abrir modal de crear (placeholder)
            window.abrirModalCrear = function() {
                // Redireccionar a página de crear o abrir modal
                window.location.href = 'ComunidadServlet?action=create';
            };
            
            // Función para confirmar unirse a comunidad
            window.confirmarUnirseComunidad = function(idComunidad, nombreComunidad, esPublica) {
                var tituloModal = esPublica ? 'Unirse a Comunidad Pública' : 'Solicitar Unirse a Comunidad';
                var mensaje = esPublica ? 
                    'Te unirás inmediatamente a esta comunidad y podrás participar en sus discusiones.' : 
                    'Enviarás una solicitud para unirte a esta comunidad privada. Deberás esperar la aprobación de un administrador.';
                var btnTexto = esPublica ? 'Unirse Ahora' : 'Enviar Solicitud';
                var btnColor = esPublica ? 'btn-success' : 'btn-info';
                var iconoModal = esPublica ? 'fas fa-users' : 'fas fa-paper-plane';
                
                var modalHtml = '<div class="modal fade" id="modalUnirse" tabindex="-1" role="dialog">' +
                    '<div class="modal-dialog modal-dialog-centered" role="document">' +
                        '<div class="modal-content">' +
                            '<div class="modal-header bg-primary text-white">' +
                                '<h5 class="modal-title">' +
                                    '<i class="' + iconoModal + '"></i> ' + tituloModal +
                                '</h5>' +
                                '<button type="button" class="close text-white" data-dismiss="modal">' +
                                    '<span>&times;</span>' +
                                '</button>' +
                            '</div>' +
                            '<div class="modal-body">' +
                                '<p class="mb-3">' +
                                    '¿Quieres unirte a <strong>' + escapeHtml(nombreComunidad) + '</strong>?' +
                                '</p>' +
                                '<div class="alert alert-info">' +
                                    '<i class="fas fa-info-circle"></i> ' + mensaje +
                                '</div>' +
                            '</div>' +
                            '<div class="modal-footer">' +
                                '<button type="button" class="btn btn-secondary" data-dismiss="modal">' +
                                    '<i class="fas fa-times"></i> Cancelar' +
                                '</button>' +
                                '<button type="button" class="btn ' + btnColor + '" id="btnConfirmarUnion">' +
                                    '<i class="' + iconoModal + '"></i> ' + btnTexto +
                                '</button>' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                '</div>';
                
                // Remover modal anterior si existe
                $('#modalUnirse').remove();
                
                // Agregar nuevo modal al DOM
                $('body').append(modalHtml);
                
                // Mostrar modal
                $('#modalUnirse').modal('show');
                
                // Manejar confirmación
                $('#btnConfirmarUnion').off('click').on('click', function() {
                    var $btn = $(this);
                    var originalText = $btn.html();
                    
                    // Mostrar loading
                    $btn.html('<i class="fas fa-spinner fa-spin"></i> Procesando...');
                    $btn.prop('disabled', true);
                    
                    $.ajax({
                        url: 'ComunidadServlet',
                        type: 'POST',
                        data: {
                            action: 'join',
                            idComunidad: idComunidad
                        },
                        success: function(response) {
                            $('#modalUnirse').modal('hide');
                            if (response.success) {
                                showSuccess(response.message);
                                
                                // Actualizar la tarjeta de la comunidad
                                setTimeout(function() {
                                    location.reload();
                                }, 1500);
                            } else {
                                showError(response.message || 'Error al unirse a la comunidad');
                            }
                        },
                        error: function() {
                            $('#modalUnirse').modal('hide');
                            showError('Error de conexión al unirse a la comunidad');
                        },
                        complete: function() {
                            $btn.html(originalText);
                            $btn.prop('disabled', false);
                        }
                    });
                });
            };
            
            // Función para confirmar salir de comunidad
            window.confirmarSalirComunidad = function(idComunidad, nombreComunidad) {
                var modalHtml = '<div class="modal fade" id="modalSalir" tabindex="-1" role="dialog">' +
                    '<div class="modal-dialog modal-dialog-centered" role="document">' +
                        '<div class="modal-content">' +
                            '<div class="modal-header bg-warning text-dark">' +
                                '<h5 class="modal-title">' +
                                    '<i class="fas fa-sign-out-alt"></i> Salir de Comunidad' +
                                '</h5>' +
                                '<button type="button" class="close" data-dismiss="modal">' +
                                    '<span>&times;</span>' +
                                '</button>' +
                            '</div>' +
                            '<div class="modal-body">' +
                                '<p class="mb-3">' +
                                    '¿Estás seguro de que deseas salir de <strong>' + escapeHtml(nombreComunidad) + '</strong>?' +
                                '</p>' +
                                '<div class="alert alert-warning">' +
                                    '<i class="fas fa-exclamation-triangle"></i> ' +
                                    'Perderás acceso a las publicaciones y deberás solicitar unirte nuevamente para volver.' +
                                '</div>' +
                            '</div>' +
                            '<div class="modal-footer">' +
                                '<button type="button" class="btn btn-secondary" data-dismiss="modal">' +
                                    '<i class="fas fa-times"></i> Cancelar' +
                                '</button>' +
                                '<button type="button" class="btn btn-warning" id="btnConfirmarSalida">' +
                                    '<i class="fas fa-sign-out-alt"></i> Salir de Comunidad' +
                                '</button>' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                '</div>';
                
                // Remover modal anterior si existe
                $('#modalSalir').remove();
                
                // Agregar nuevo modal al DOM
                $('body').append(modalHtml);
                
                // Mostrar modal
                $('#modalSalir').modal('show');
                
                // Manejar confirmación
                $('#btnConfirmarSalida').off('click').on('click', function() {
                    var $btn = $(this);
                    var originalText = $btn.html();
                    
                    // Mostrar loading
                    $btn.html('<i class="fas fa-spinner fa-spin"></i> Procesando...');
                    $btn.prop('disabled', true);
                    
                    $.ajax({
                        url: 'ComunidadServlet',
                        type: 'POST',
                        data: {
                            action: 'leave',
                            idComunidad: idComunidad
                        },
                        success: function(response) {
                            $('#modalSalir').modal('hide');
                            if (response.success) {
                                showSuccess(response.message);
                                
                                // Actualizar la tarjeta de la comunidad
                                setTimeout(function() {
                                    location.reload();
                                }, 1500);
                            } else {
                                showError(response.message || 'Error al salir de la comunidad');
                            }
                        },
                        error: function() {
                            $('#modalSalir').modal('hide');
                            showError('Error de conexión al salir de la comunidad');
                        },
                        complete: function() {
                            $btn.html(originalText);
                            $btn.prop('disabled', false);
                        }
                    });
                });
            };
            
            // Función para escapar HTML
            function escapeHtml(text) {
                var map = {
                    '&': '&amp;',
                    '<': '&lt;',
                    '>': '&gt;',
                    '"': '&quot;',
                    "'": '&#039;'
                };
                return text.replace(/[&<>"']/g, function(m) { return map[m]; });
            }
            
            // Animación de entrada para las tarjetas
            $('.community-card').each(function(index) {
                $(this).css('opacity', '0');
                $(this).delay(index * 50).animate({
                    opacity: 1
                }, 300);
            });
        });


            // ========== FUNCIONES DE UTILIDAD ==========
            function showNotification(message, type, duration) {
                duration = duration || 4000; // Default 4 segundos

                // Configuración por tipo
                var config = {
                    success: {
                        icon: 'fa-check-circle',
                        bgColor: '#28a745',
                        textColor: '#fff',
                        title: '¡Éxito!'
                    },
                    error: {
                        icon: 'fa-exclamation-triangle',
                        bgColor: '#dc3545',
                        textColor: '#fff',
                        title: 'Error'
                    },
                    warning: {
                        icon: 'fa-exclamation-circle',
                        bgColor: '#ffc107',
                        textColor: '#212529',
                        title: 'Atención'
                    },
                    info: {
                        icon: 'fa-info-circle',
                        bgColor: '#17a2b8',
                        textColor: '#fff',
                        title: 'Información'
                    }
                };

                var setting = config[type] || config.info;
                var toastId = 'toast-' + Date.now();

                // Crear contenedor de toasts si no existe
                if ($('#toast-container').length === 0) {
                    $('body').append(
                        '<div id="toast-container" style="' +
                            'position: fixed;' +
                            'top: 20px;' +
                            'right: 20px;' +
                            'z-index: 9999;' +
                            'max-width: 350px;' +
                        '"></div>'
                    );
                }

                // Crear el toast
                var toast = 
                    '<div id="' + toastId + '" class="toast-notification" style="' +
                        'background: ' + setting.bgColor + ';' +
                        'color: ' + setting.textColor + ';' +
                        'border-radius: 8px;' +
                        'box-shadow: 0 4px 12px rgba(0,0,0,0.15);' +
                        'margin-bottom: 10px;' +
                        'overflow: hidden;' +
                        'transform: translateX(100%);' +
                        'transition: all 0.3s ease;' +
                        'position: relative;' +
                    '">' +
                        '<!-- Barra de progreso -->' +
                        '<div class="toast-progress" style="' +
                            'position: absolute;' +
                            'top: 0;' +
                            'left: 0;' +
                            'height: 3px;' +
                            'background: rgba(255,255,255,0.3);' +
                            'width: 100%;' +
                            'transform-origin: left;' +
                            'animation: toastProgress ' + duration + 'ms linear forwards;' +
                        '"></div>' +

                        '<!-- Contenido -->' +
                        '<div style="' +
                            'padding: 16px;' +
                            'display: flex;' +
                            'align-items: center;' +
                            'gap: 12px;' +
                        '">' +
                            '<!-- Icono -->' +
                            '<div style="' +
                                'width: 40px;' +
                                'height: 40px;' +
                                'border-radius: 50%;' +
                                'background: rgba(255,255,255,0.2);' +
                                'display: flex;' +
                                'align-items: center;' +
                                'justify-content: center;' +
                                'flex-shrink: 0;' +
                            '">' +
                                '<i class="fas ' + setting.icon + '" style="font-size: 18px;"></i>' +
                            '</div>' +

                            '<!-- Texto -->' +
                            '<div style="flex: 1; min-width: 0;">' +
                                '<div style="' +
                                    'font-weight: 600;' +
                                    'font-size: 14px;' +
                                    'margin-bottom: 2px;' +
                                '">' + setting.title + '</div>' +
                                '<div style="' +
                                    'font-size: 13px;' +
                                    'opacity: 0.9;' +
                                    'word-wrap: break-word;' +
                                '">' + message + '</div>' +
                            '</div>' +

                            '<!-- Botón cerrar -->' +
                            '<button class="toast-close" style="' +
                                'background: none;' +
                                'border: none;' +
                                'color: inherit;' +
                                'font-size: 18px;' +
                                'opacity: 0.7;' +
                                'cursor: pointer;' +
                                'padding: 4px;' +
                                'border-radius: 4px;' +
                                'transition: opacity 0.2s ease;' +
                            '" onclick="closeToast(\'' + toastId + '\')">' +
                                '<i class="fas fa-times"></i>' +
                            '</button>' +
                        '</div>' +
                    '</div>';

                // Agregar al contenedor
                $('#toast-container').append(toast);

                // Animar entrada
                setTimeout(function() {
                    $('#' + toastId).css('transform', 'translateX(0)');
                }, 10);

                // Auto-cerrar
                setTimeout(function() {
                    closeToast(toastId);
                }, duration);

                // Agregar hover para pausar
                $('#' + toastId)
                    .on('mouseenter', function() {
                        $(this).find('.toast-progress').css('animation-play-state', 'paused');
                    })
                    .on('mouseleave', function() {
                        $(this).find('.toast-progress').css('animation-play-state', 'running');
                    });
            }

            /**
             * Cerrar toast específico
             */
            function closeToast(toastId) {
                var toast = $('#' + toastId);
                if (toast.length) {
                    toast.css({
                        'transform': 'translateX(100%)',
                        'opacity': '0'
                    });

                    setTimeout(function() {
                        toast.remove();

                        // Remover contenedor si está vacío
                        if ($('#toast-container .toast-notification').length === 0) {
                            $('#toast-container').remove();
                        }
                    }, 300);
                }
            }

            /**
             * Limpiar todos los toasts
             */
            function clearAllToasts() {
                $('.toast-notification').each(function() {
                    var id = $(this).attr('id');
                    if (id) {
                        closeToast(id);
                    }
                });
            }
        function showSuccess(message) { showNotification(message, 'success'); }
        function showError(message) { showNotification(message, 'error'); }
    </script>
</body>
</html>