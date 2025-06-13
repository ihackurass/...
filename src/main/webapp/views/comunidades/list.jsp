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
        color: #555;
        font-size: 14px;
        margin-bottom: 15px;
        line-height: 1.4;
        min-height: 35px;
    }

    .community-stats {
        display: flex;
        justify-content: space-between;
        margin-bottom: 15px;
        padding: 8px;
        background: #f8f9fa;
        border-radius: 6px;
        font-size: 12px;
        color: #666;
    }

    .stat-item {
        text-align: center;
        flex: 1;
    }

    .stat-item .stat-number {
        display: block;
        font-weight: bold;
        color: #007bff;
        font-size: 14px;
        margin-bottom: 2px;
    }

    .stat-item .stat-label {
        font-size: 10px;
        text-transform: uppercase;
    }

    .community-actions {
        display: flex;
        gap: 8px;
    }

    .btn-action {
        flex: 1;
        padding: 8px 12px;
        border: none;
        border-radius: 5px;
        font-size: 12px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.3s ease;
        text-decoration: none;
        text-align: center;
        display: inline-block;
    }

    .btn-primary {
        background: #007bff;
        color: white;
    }

    .btn-primary:hover {
        background: #0056b3;
        color: white;
        text-decoration: none;
        transform: translateY(-1px);
    }

    .btn-success {
        background: #28a745;
        color: white;
    }

    .btn-success:hover {
        background: #1e7e34;
    }

    .btn-danger {
        background: #dc3545;
        color: white;
    }

    .btn-danger:hover {
        background: #c82333;
    }

    .btn-warning {
        background: #ffc107;
        color: #333;
    }

    .btn-warning:hover {
        background: #e0a800;
        color: #333;
        text-decoration: none;
    }

    .empty-state {
        text-align: center;
        padding: 60px 20px;
        color: #666;
    }

    .empty-state i {
        font-size: 48px;
        margin-bottom: 20px;
        opacity: 0.3;
        color: #007bff;
    }

    .empty-state h3 {
        font-size: 20px;
        margin-bottom: 15px;
        color: #333;
    }

    .empty-state p {
        font-size: 14px;
        margin-bottom: 25px;
        line-height: 1.5;
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
                                        (<%= totalComunidades %> 
                                        <%= "myCommunities".equals(tipoVista) ? "seguidas" : 
                                            "managedCommunities".equals(tipoVista) ? "administradas" : "encontradas" %>)
                                    </span>
                                </h2>
                                <p class="subtitle"><%= descripcion %></p>
                            </div>
                            
                            <!-- Búsqueda (solo en "todas") -->
                            <% if ("all".equals(tipoVista) || tipoVista == null) { %>
                                <form method="get" action="ComunidadServlet" class="search-container">
                                    <input type="hidden" name="action" value="search">
                                    <input type="text" 
                                           name="q" 
                                           placeholder="Buscar comunidades..."
                                           value="<%= searchQuery != null ? searchQuery : "" %>">
                                    <button type="submit">
                                        <i class="fas fa-search"></i>
                                    </button>
                                </form>
                            <% } else { %>
                                <div style="text-align: right;">
                                    <a href="ComunidadServlet" class="btn-action btn-primary">
                                        <i class="fas fa-search me-1"></i>Explorar Más
                                    </a>
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

                        <!-- Estadísticas (solo para mis comunidades y administradas) -->
                        <% if (("myCommunities".equals(tipoVista) || "managedCommunities".equals(tipoVista)) && 
                               comunidades != null && !comunidades.isEmpty()) { %>
                            <div class="stats-summary">
                                <div class="stat-box">
                                    <span class="stat-number"><%= totalComunidades %></span>
                                    <span class="stat-label">
                                        <%= "myCommunities".equals(tipoVista) ? "Seguidas" : "Administradas" %>
                                    </span>
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


                        <!-- Mensaje de búsqueda -->
                        <% if (searchQuery != null && !searchQuery.trim().isEmpty()) { %>
                            <div style="margin-bottom: 15px; padding: 10px; background: #e3f2fd; border-radius: 5px; border-left: 4px solid #2196f3;">
                                <strong>Resultados para:</strong> "<%= searchQuery %>"
                            </div>
                        <% } %>

                        <!-- Grid de comunidades -->
                        <% if (comunidades != null && !comunidades.isEmpty()) { %>
                            <div class="community-grid">
                                <% for (Comunidad comunidad : comunidades) { %>
                                    <div class="community-card">
                                        <!-- Badge de privacidad (solo en "todas") -->
                                        <% if ("all".equals(tipoVista) || tipoVista == null) { %>
                                            <div class="privacy-badge <%= comunidad.isEsPublica() ? "badge-public" : "badge-private" %>">
                                                <% if (comunidad.isEsPublica()) { %>
                                                    <i class="fas fa-globe"></i> Pública
                                                <% } else { %>
                                                    <i class="fas fa-lock"></i> Privada
                                                <% } %>
                                            </div>
                                        <% } %>

                                        <!-- Badge de rol (en mis comunidades y administradas) -->
                                        <% if (("myCommunities".equals(tipoVista) || "managedCommunities".equals(tipoVista)) && usuarioActual != null) { %>
                                            <div class="role-badge 
                                                <%= comunidad.isUsuarioEsCreador() ? "role-creator" : 
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
                                                <%= comunidad.getNombre().substring(0,1).toUpperCase() %>
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
                                                            comunidad.getFechaCreacion().getYear() : "2024" %>
                                                    </div>
                                                <% } %>
                                            </div>
                                        </div>

                                        <div class="community-description">
                                            <% if (comunidad.getDescripcion() != null && !comunidad.getDescripcion().trim().isEmpty()) { %>
                                                <% if (comunidad.getDescripcion().length() > 80) { %>
                                                    <%= comunidad.getDescripcion().substring(0, 80) %>...
                                                <% } else { %>
                                                    <%= comunidad.getDescripcion() %>
                                                <% } %>
                                            <% } else { %>
                                                <em style="color: #999;">Sin descripción disponible</em>
                                            <% } %>
                                        </div>

                                        <div class="community-stats">
                                            <div class="stat-item">
                                                <span class="stat-number"><%= comunidad.getSeguidoresCount() %></span>
                                                <span class="stat-label">Miembros</span>
                                            </div>
                                            <div class="stat-item">
                                                <span class="stat-number"><%= comunidad.getPublicacionesCount() %></span>
                                                <span class="stat-label">Posts</span>
                                            </div>
                                            <div class="stat-item">
                                                <span class="stat-number">
                                                    <%= comunidad.getFechaCreacion() != null ? 
                                                        comunidad.getFechaCreacion().getYear() : "2024" %>
                                                </span>
                                                <span class="stat-label">Creada</span>
                                            </div>
                                        </div>

                                        <!-- Acciones dinámicas -->
                                        <div class="community-actions">
                                            <a href="ComunidadServlet?action=view&id=<%= comunidad.getIdComunidad() %>" 
                                               class="btn-action btn-primary">
                                                <i class="fas fa-eye"></i> Ver
                                            </a>

                                            <% if (usuarioActual != null) { %>
                                                <!-- Acciones para comunidades que sigue -->
                                                <% if (comunidad.isUsuarioEsSeguidor()) { %>
                                                    <% if (comunidad.isUsuarioEsCreador() || comunidad.isUsuarioEsAdmin()) { %>
                                                        <a href="ComunidadServlet?action=edit&id=<%= comunidad.getIdComunidad() %>" 
                                                           class="btn-action btn-warning">
                                                            <i class="fas fa-edit"></i> Editar
                                                        </a>
                                                    <% } %>
                                                    
                                                    <% if (!comunidad.isUsuarioEsCreador()) { %>
                                                        <form method="post" action="ComunidadServlet" style="flex: 1;">
                                                            <input type="hidden" name="action" value="leave">
                                                            <input type="hidden" name="id" value="<%= comunidad.getIdComunidad() %>">
                                                            <button type="submit" class="btn-action btn-danger" style="width: 100%;">
                                                                <i class="fas fa-sign-out-alt"></i> Salir
                                                            </button>
                                                        </form>
                                                    <% } %>
                                                <% } else { %>
                                                    <!-- Acción para unirse -->
                                                    <form method="post" action="ComunidadServlet" style="flex: 1;">
                                                        <input type="hidden" name="action" value="join">
                                                        <input type="hidden" name="id" value="<%= comunidad.getIdComunidad() %>">
                                                        <button type="submit" class="btn-action btn-success" style="width: 100%;">
                                                            <i class="fas fa-plus"></i> Unirse
                                                        </button>
                                                    </form>
                                                <% } %>
                                            <% } %>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                        <% } else { %>
                            <!-- Estado vacío dinámico -->
                            <div class="empty-state">
                                <% if ("myCommunities".equals(tipoVista)) { %>
                                    <i class="fas fa-heart-broken"></i>
                                    <h3>No sigues ninguna comunidad aún</h3>
                                    <p>¡Explora y únete a comunidades que te interesen!</p>
                                    <a href="ComunidadServlet" class="btn-action btn-primary" style="margin-right: 10px;">
                                        <i class="fas fa-search"></i> Explorar Comunidades
                                    </a>
                                    <a href="#" onclick="abrirModalCrear()" class="btn-action btn-warning">
                                        <i class="fas fa-plus"></i> Crear Mi Primera Comunidad
                                    </a>
                                <% } else if ("managedCommunities".equals(tipoVista)) { %>
                                    <i class="fas fa-crown"></i>
                                    <h3>No administras ninguna comunidad</h3>
                                    <p>Crea tu primera comunidad y conviértete en líder</p>
                                    <a href="#" onclick="abrirModalCrear()" class="btn-action btn-primary">
                                        <i class="fas fa-plus"></i> Crear Mi Primera Comunidad
                                    </a>
                                <% } else { %>
                                    <i class="fas fa-users"></i>
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
        // Confirmación para salir de comunidad
        document.querySelectorAll('form[action*="ComunidadServlet"] button[type="submit"]').forEach(button => {
            if (button.textContent.includes('Salir')) {
                button.closest('form').addEventListener('submit', function(e) {
                    if (!confirm('¿Estás seguro de que quieres salir de esta comunidad?')) {
                        e.preventDefault();
                    }
                });
            }
        });

        // Hover effects para las tarjetas
        document.querySelectorAll('.community-card').forEach(card => {
            card.addEventListener('mouseenter', function() {
                this.style.borderColor = '#007bff';
            });
            card.addEventListener('mouseleave', function() {
                this.style.borderColor = '#e0e0e0';
            });
        });

        // Auto-focus en campo de búsqueda (solo en vista "todas")
        const searchInput = document.querySelector('input[name="q"]');
        if (searchInput && !searchInput.value) {
            searchInput.focus();
        }

        // Función para abrir modal de crear comunidad (placeholder)
        function abrirModalCrear() {
            // TODO: Implementar modal para crear comunidad
            alert('Modal de crear comunidad se implementará con AJAX');
        }

        // Animaciones de entrada para las tarjetas
        document.addEventListener('DOMContentLoaded', function() {
            const cards = document.querySelectorAll('.community-card');
            cards.forEach((card, index) => {
                card.style.opacity = '0';
                card.style.transform = 'translateY(20px)';
                
                setTimeout(() => {
                    card.style.transition = 'all 0.5s ease';
                    card.style.opacity = '1';
                    card.style.transform = 'translateY(0)';
                }, index * 100);
            });
        });
    </script>
</body>

</html>