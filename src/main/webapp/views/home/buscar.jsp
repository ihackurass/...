<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="pe.aquasocial.entity.Usuario"%>
<%@page import="pe.aquasocial.entity.Comunidad"%>
<%@page import="pe.aquasocial.entity.Publicacion"%>

<%
    // Obtener parámetros de la request
    String terminoBusqueda = request.getParameter("q");
    String tabActiva = request.getParameter("tab");
    
    // Obtener resultados
    List<Usuario> usuarios = (List<Usuario>) request.getAttribute("usuarios");
    List<Comunidad> comunidades = (List<Comunidad>) request.getAttribute("comunidades");
    List<Publicacion> publicaciones = (List<Publicacion>) request.getAttribute("publicaciones");
    
    // Valores por defecto
    if (terminoBusqueda == null) terminoBusqueda = "";
    if (tabActiva == null) tabActiva = "todo";
    if (usuarios == null) usuarios = new java.util.ArrayList<>();
    if (comunidades == null) comunidades = new java.util.ArrayList<>();
    if (publicaciones == null) publicaciones = new java.util.ArrayList<>();
    
    // Calcular total de resultados
    int totalResultados = usuarios.size() + comunidades.size() + publicaciones.size();
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= terminoBusqueda.isEmpty() ? "Buscar" : terminoBusqueda + " - Buscar" %> | AquaSocial</title>
    <jsp:include page="/components/css_imports.jsp" />
    
    <style>
        .main-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            display: grid;
            grid-template-columns: 300px 1fr;
            gap: 30px;
        }
        
        .search-header {
            grid-column: 1 / -1;
            background: white;
            border-radius: 15px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        
        .search-main-input {
            width: 100%;
            padding: 15px 20px 15px 50px;
            border: 2px solid #e1e8ed;
            border-radius: 25px;
            font-size: 18px;
            background: #f7f9fa;
            transition: all 0.3s ease;
            outline: none;
        }
        
        .search-main-input:focus {
            background: white;
            border-color: #1da1f2;
            box-shadow: 0 0 0 3px rgba(29, 161, 242, 0.1);
        }
        
        .search-main-wrapper {
            position: relative;
        }
        
        .search-main-icon {
            position: absolute;
            left: 18px;
            top: 50%;
            transform: translateY(-50%);
            color: #657786;
            font-size: 18px;
        }
        
        .search-tabs {
            display: flex;
            border-bottom: 1px solid #e1e8ed;
            margin-top: 20px;
            gap: 5px;
        }
        
        .tab-btn {
            padding: 15px 20px;
            border: none;
            background: transparent;
            color: #657786;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            border-bottom: 3px solid transparent;
            font-size: 15px;
        }
        
        .tab-btn.active {
            color: #1da1f2;
            border-bottom-color: #1da1f2;
        }
        
        .tab-btn:hover {
            color: #1da1f2;
            background: rgba(29, 161, 242, 0.05);
        }
        
        .sidebar-h {
            background: white;
            border-radius: 15px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            height: fit-content;
        }
        
        .sidebar-title-h {
            font-weight: 700;
            font-size: 20px;
            margin-bottom: 15px;
            color: #14171a;
        }
        
        .recent-searches {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        
        .recent-item {
            padding: 10px 0;
            border-bottom: 1px solid #f1f3f4;
        }
        
        .recent-link {
            color: #1da1f2;
            text-decoration: none;
            font-weight: 500;
        }
        
        .recent-link:hover {
            text-decoration: underline;
        }
        
        .recent-time {
            color: #657786;
            font-size: 12px;
            float: right;
        }
        
        .results-container {
            background: white;
            border-radius: 15px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .results-header {
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid #e1e8ed;
        }
        
        .results-count {
            color: #657786;
            font-size: 14px;
        }
        
        .no-results {
            text-align: center;
            padding: 40px;
            color: #657786;
        }
        
        .loading {
            text-align: center;
            padding: 40px;
            color: #657786;
        }
        
        .loading i {
            font-size: 2rem;
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }
        
        /* ===== LAYOUT SEPARADO PARA "TODO" ===== */
        .results-container-todo {
            display: flex;
            flex-direction: column;
            gap: 30px;
            padding: 20px 0;
        }

        .results-section-separated {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border: 1px solid #e1e8ed;
        }

        .section-title-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f1f3f4;
        }

        .section-title {
            margin: 0;
            color: #14171a;
            font-weight: 700;
            font-size: 1.3rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .section-title i {
            color: #1da1f2;
        }

        .results-count {
            color: #657786;
            font-weight: 500;
            font-size: 1rem;
        }

        .results-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
        }

        .result-card {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }

        .result-card:hover {
            background: white;
            transform: translateY(-5px);
        }

        .card-avatar {
            margin-bottom: 15px;
        }

        .card-avatar img {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            object-fit: cover;
        }

        .avatar-placeholder {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: linear-gradient(135deg, #1da1f2, #14171a);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 700;
            font-size: 1.5rem;
            margin: 0 auto;
        }

        .comunidad-avatar {
            background: linear-gradient(135deg, #17a2b8, #007bff) !important;
        }

        .publicacion-avatar {
            background: linear-gradient(135deg, #28a745, #20c997) !important;
        }

        .card-info {
            text-align: center;
        }

        .card-name {
            margin: 0 0 5px 0;
            font-weight: 600;
            color: #14171a;
        }

        .card-username {
            color: #657786;
            margin: 0 0 8px 0;
            font-size: 0.9rem;
        }

        .card-meta {
            color: #657786;
            font-size: 0.8rem;
        }

        .card-preview {
            color: #495057;
            font-size: 0.85rem;
            line-height: 1.3;
            margin: 8px 0;
            text-align: left;
            background: rgba(0,0,0,0.03);
            padding: 8px;
            border-radius: 6px;
            border-left: 3px solid #28a745;
        }

        .card-stats {
            display: flex;
            justify-content: center;
            gap: 15px;
            color: #657786;
            font-size: 0.8rem;
            margin-top: 10px;
        }

        .card-stats span {
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .publicacion-card:hover {
            border-color: #28a745 !important;
            box-shadow: 0 8px 25px rgba(40, 167, 69, 0.15) !important;
        }

        .usuario-card:hover {
            border-color: #1da1f2 !important;
            box-shadow: 0 8px 25px rgba(29, 161, 242, 0.15) !important;
        }

        .comunidad-card:hover {
            border-color: #17a2b8 !important;
            box-shadow: 0 8px 25px rgba(23, 162, 184, 0.15) !important;
        }
        
        /* ===== ESTILOS PARA PESTAÑAS INDIVIDUALES ===== */
        .result-item {
            background: white;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 15px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border: 1px solid #e1e8ed;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .comunidad-result {
            border-left: 4px solid #17a2b8;
        }

        .comunidad-result:hover {
            background-color: #f8f9fa;
            transform: translateX(5px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .community-result {
            display: flex;
            align-items: center;
            width: 100%;
            gap: 15px;
        }

        .community-avatar {
            flex-shrink: 0;
            margin-left: 10px;
        }

        .community-avatar img {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            object-fit: cover;
        }
        
        .community-avatar .avatar-placeholder {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: linear-gradient(135deg, #17a2b8, #007bff);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 700;
            font-size: 1.2rem;
        }

        .community-info {
            flex: 1;
            min-width: 0;
        }

        .community-action {
            margin-left: auto;
            color: #6c757d;
            font-size: 1.2rem;
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .comunidad-result:hover .community-action {
            opacity: 1;
        }

        .community-meta i {
            margin-right: 4px;
            color: #6c757d;
        }

        .community-creator {
            margin-top: 5px;
        }

        .community-name {
            display: flex;
            align-items: center;
        }

        .community-name h6 {
            margin: 0;
            font-weight: 600;
        }

        .community-description {
            color: #495057;
            font-size: 0.9rem;
            line-height: 1.4;
            margin-top: 5px;
        }
        
        .publicacion-result {
            border-left: 4px solid #28a745;
        }

        .publicacion-result:hover {
            background-color: #f8f9fa;
            transform: translateX(5px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .publicacion-content {
            display: flex;
            flex-direction: column;
            width: 100%;
            gap: 10px;
            margin-left: 10px;
        }

        .post-header {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .post-avatar {
            flex-shrink: 0;
        }

        .post-avatar img {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
        }

        .post-info {
            flex: 1;
        }

        .post-user {
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .post-user h6 {
            margin: 0;
            font-weight: 600;
        }

        .post-meta {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #6c757d;
            font-size: 0.85rem;
        }

        .post-text {
            color: #495057;
            line-height: 1.4;
            margin: 5px 0;
        }

        .post-image-preview {
            border-radius: 8px;
            overflow: hidden;
            max-height: 150px;
        }

        .post-image-preview img {
            width: 100%;
            height: auto;
            object-fit: cover;
        }

        .post-stats {
            display: flex;
            gap: 15px;
            color: #6c757d;
            font-size: 0.9rem;
        }

        .post-stats span {
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .post-action {
            margin-left: auto;
            align-self: flex-end;
            margin-bottom: 5px;
            background: linear-gradient(135deg, #28a745, #20c997);
            color: white;
            border-radius: 50%;
            width: 36px;
            height: 36px;
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0;
            transition: all 0.3s ease;
            box-shadow: 0 2px 8px rgba(40, 167, 69, 0.3);
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }

        .post-action::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
            transition: left 0.6s;
        }

        .post-action:hover::before {
            left: 100%;
        }

        .post-action i {
            font-size: 14px;
            z-index: 1;
        }

        .post-action:hover {
            transform: scale(1.1);
            box-shadow: 0 4px 15px rgba(40, 167, 69, 0.4);
        }

        .action-tooltip {
            position: absolute;
            top: -35px;
            right: 0;
            background: #333;
            color: white;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 11px;
            white-space: nowrap;
            opacity: 0;
            transform: translateY(5px);
            transition: all 0.3s ease;
            pointer-events: none;
            z-index: 10;
        }

        .action-tooltip::after {
            content: '';
            position: absolute;
            top: 100%;
            right: 10px;
            border: 4px solid transparent;
            border-top-color: #333;
        }

        .post-action:hover .action-tooltip {
            opacity: 1;
            transform: translateY(0);
        }

        .publicacion-result:hover .post-action {
            opacity: 1;
        }
        
        /* ===== ESTILOS PARA USUARIOS ===== */
        .usuario-result {
            border-left: 4px solid #1da1f2;
        }

        .usuario-result:hover {
            background-color: #f8f9fa;
            transform: translateX(5px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .user-result {
            display: flex;
            align-items: center;
            width: 100%;
            gap: 15px;
        }

        .user-avatar {
            flex-shrink: 0;
            margin-left: 10px;
        }

        .user-avatar img {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            object-fit: cover;
        }
        
        .user-avatar .avatar-placeholder {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: linear-gradient(135deg, #1da1f2, #14171a);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 700;
            font-size: 1.2rem;
        }

        .user-info {
            flex: 1;
            min-width: 0;
        }

        .user-action {
            margin-left: auto;
            color: #6c757d;
            font-size: 1.2rem;
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .usuario-result:hover .user-action {
            opacity: 1;
        }

        .user-name {
            display: flex;
            align-items: center;
        }

        .user-name h6 {
            margin: 0;
            font-weight: 600;
        }

        .user-meta {
            color: #657786;
            font-size: 0.9rem;
            margin-top: 2px;
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }
        
        .user-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 0.75rem;
            padding: 2px 6px;
            border-radius: 12px;
            font-weight: 500;
        }
        
        .user-badge.verified {
            background: rgba(29, 161, 242, 0.1);
            color: #1da1f2;
        }
        
        .user-badge.privileged {
            background: rgba(255, 193, 7, 0.1);
            color: #ffc107;
        }

        .user-bio {
            color: #495057;
            font-size: 0.9rem;
            line-height: 1.4;
            margin-top: 8px;
            padding: 8px;
            background: rgba(29, 161, 242, 0.05);
            border-radius: 6px;
            border-left: 3px solid #1da1f2;
        }
        
        .user-extra-info {
            margin-top: 5px;
            font-size: 0.8rem;
            color: #657786;
        }
        
        .user-extra-info i {
            margin-right: 4px;
            width: 12px;
        }
        
        .user-phone, .user-joined {
            display: inline-block;
            margin-right: 15px;
        }
        
        @media (max-width: 768px) {
            .main-container {
                grid-template-columns: 1fr;
                padding: 15px;
                gap: 20px;
            }
            
            .sidebar-h {
                order: 2;
                position: static;
            }
            
            .search-tabs {
                flex-wrap: wrap;
            }
            
            .tab-btn {
                padding: 12px 15px;
                font-size: 14px;
            }
            
            .results-grid {
                grid-template-columns: 1fr;
            }
            
            .section-title-container {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
            
            .results-section-separated {
                padding: 20px 15px;
            }
        }
    </style>
</head>

<body>
    <!-- Sidebar -->
    <jsp:include page="/components/sidebar.jsp" />
    
    <!-- Main Content -->
    <main>
        <div class="site-section">
            <div class="main-container">
                
                <!-- Header de búsqueda -->
                <div class="search-header">
                    <form onsubmit="realizarBusquedaPrincipal(event)">
                        <div class="search-main-wrapper">
                            <i class="fas fa-search search-main-icon"></i>
                            <input type="text" 
                                   id="searchMainInput" 
                                   class="search-main-input" 
                                   placeholder="Buscar usuarios, comunidades, publicaciones..."
                                   value="<%= terminoBusqueda %>"
                                   autocomplete="off">
                        </div>
                    </form>
                    
                    <!-- Pestañas -->
                    <div class="search-tabs">
                        <button class="tab-btn <%= "todo".equals(tabActiva) ? "active" : "" %>" 
                                onclick="cambiarTab('todo')">
                            Todo 
                            <% if (totalResultados > 0) { %>
                                (<%= totalResultados %>)
                            <% } %>
                        </button>
                        <button class="tab-btn <%= "usuarios".equals(tabActiva) ? "active" : "" %>" 
                                onclick="cambiarTab('usuarios')">
                            Usuarios 
                            <% if (usuarios.size() > 0) { %>
                                (<%= usuarios.size() %>)
                            <% } %>
                        </button>
                        <button class="tab-btn <%= "comunidades".equals(tabActiva) ? "active" : "" %>" 
                                onclick="cambiarTab('comunidades')">
                            Comunidades 
                            <% if (comunidades.size() > 0) { %>
                                (<%= comunidades.size() %>)
                            <% } %>
                        </button>
                        <button class="tab-btn <%= "publicaciones".equals(tabActiva) ? "active" : "" %>" 
                                onclick="cambiarTab('publicaciones')">
                            Publicaciones 
                            <% if (publicaciones.size() > 0) { %>
                                (<%= publicaciones.size() %>)
                            <% } %>
                        </button>
                    </div>
                </div>
                
                <!-- Sidebar -->
                <div class="sidebar-h">
                    <div class="sidebar-title-h">Búsquedas recientes</div>
                    <ul class="recent-searches" id="recentSearches">
                        <li class="recent-item">
                            <span class="recent-link">No hay búsquedas recientes</span>
                        </li>
                    </ul>
                </div>
                
                <!-- Resultados -->
                <div class="results-container">
                    <% if (!terminoBusqueda.isEmpty()) { %>
                        <div class="results-header">
                            <div class="results-count">
                                <% if (totalResultados > 0) { %>
                                    <%= totalResultados %> resultado<%= totalResultados != 1 ? "s" : "" %> para "<%= terminoBusqueda %>"
                                <% } else { %>
                                    No se encontraron resultados para "<%= terminoBusqueda %>"
                                <% } %>
                            </div>
                        </div>
                        
                        <!-- ============ LAYOUT ESPECIAL PARA "TODO" ============ -->
                        <% if ("todo".equals(tabActiva)) { %>
                            <div class="results-container-todo">
                                
                                <!-- SECCIÓN DE USUARIOS -->
                                <% if (usuarios != null && !usuarios.isEmpty()) { %>
                                    <div class="results-section-separated">
                                        <div class="section-title-container">
                                            <h4 class="section-title">
                                                <i class="fas fa-user"></i>
                                                Usuarios
                                                <span class="results-count">(<%= usuarios.size() %>)</span>
                                            </h4>
                                            <% if (usuarios.size() >= 3) { %>
                                                <button class="btn btn-outline-primary btn-sm" onclick="cambiarTab('usuarios')">
                                                    Ver todos
                                                </button>
                                            <% } %>
                                        </div>
                                        
                                        <div class="results-grid">
                                            <% 
                                                int maxUsuarios = Math.min(3, usuarios.size());
                                                for (int i = 0; i < maxUsuarios; i++) {
                                                    Usuario usuario = usuarios.get(i);
                                            %>
                                                <div class="result-card usuario-card" 
                                                     onclick="verPerfilUsuario(<%= usuario.getId() %>)">
                                                    <div class="card-avatar">
                                                        <% if (usuario.getAvatar() != null && !usuario.getAvatar().isEmpty()) { %>
                                                            <img src="<%= usuario.getAvatar() %>" alt="<%= usuario.getNombreCompleto() %>">
                                                        <% } else { %>
                                                            <div class="avatar-placeholder">
                                                                <%= usuario.getNombreCompleto().substring(0,1).toUpperCase() %>
                                                            </div>
                                                        <% } %>
                                                    </div>
                                                    <div class="card-info">
                                                        <h6 class="card-name">
                                                            <%= usuario.getNombreCompleto() %>
                                                            <% if (usuario.isVerificado()) { %>
                                                                <i class="fas fa-check-circle text-primary ml-1" title="Verificado"></i>
                                                            <% } %>
                                                            <% if (usuario.isPrivilegio()) { %>
                                                                <i class="fas fa-star text-warning ml-1" title="Privilegiado"></i>
                                                            <% } %>
                                                        </h6>
                                                        <p class="card-username">
                                                            <%= usuario.getUsername() != null ? "@" + usuario.getUsername() : "Sin username" %>
                                                        </p>
                                                        <% if (usuario.getBio() != null && !usuario.getBio().trim().isEmpty()) { %>
                                                            <small class="card-meta">
                                                                <i class="fas fa-quote-left"></i> <%= usuario.getBio().length() > 50 ? usuario.getBio().substring(0, 50) + "..." : usuario.getBio() %>
                                                            </small>
                                                        <% } %>
                                                    </div>
                                                </div>
                                            <% } %>
                                        </div>
                                    </div>
                                <% } %>
                                
                                <!-- SECCIÓN DE COMUNIDADES -->
                                <% if (comunidades != null && !comunidades.isEmpty()) { %>
                                    <div class="results-section-separated">
                                        <div class="section-title-container">
                                            <h4 class="section-title">
                                                <i class="fas fa-users"></i>
                                                Comunidades
                                                <span class="results-count">(<%= comunidades.size() %>)</span>
                                            </h4>
                                            <% if (comunidades.size() >= 3) { %>
                                                <button class="btn btn-outline-primary btn-sm" onclick="cambiarTab('comunidades')">
                                                    Ver todas
                                                </button>
                                            <% } %>
                                        </div>
                                        
                                        <div class="results-grid">
                                            <% 
                                                int maxComunidades = Math.min(3, comunidades.size());
                                                for (int i = 0; i < maxComunidades; i++) {
                                                    Comunidad comunidad = comunidades.get(i);
                                            %>
                                                <div class="result-card comunidad-card" 
                                                     onclick="verPerfilComunidad(<%= comunidad.getIdComunidad() %>)">
                                                    <div class="card-avatar">
                                                        <% if (comunidad.getImagenUrl() != null && !comunidad.getImagenUrl().isEmpty()) { %>
                                                            <img src="<%= comunidad.getImagenUrl() %>" alt="<%= comunidad.getNombre() %>">
                                                        <% } else { %>
                                                            <div class="avatar-placeholder comunidad-avatar">
                                                                <%= comunidad.getNombre().substring(0,1).toUpperCase() %>
                                                            </div>
                                                        <% } %>
                                                    </div>
                                                    <div class="card-info">
                                                        <h6 class="card-name">
                                                            <%= comunidad.getNombre() %>
                                                            <% if (comunidad.isEsPublica()) { %>
                                                                <i class="fas fa-globe text-success ml-1" title="Pública"></i>
                                                            <% } else { %>
                                                                <i class="fas fa-lock text-warning ml-1" title="Privada"></i>
                                                            <% } %>
                                                        </h6>
                                                        <p class="card-username">
                                                            <%= comunidad.getUsername() != null ? "@" + comunidad.getUsername() : "Sin username" %>
                                                        </p>
                                                        <small class="card-meta">
                                                            <i class="fas fa-users"></i> <%= comunidad.getSeguidoresCount() %> miembros
                                                        </small>
                                                    </div>
                                                </div>
                                            <% } %>
                                        </div>
                                    </div>
                                <% } %>
                                
                                <!-- SECCIÓN DE PUBLICACIONES -->
                                <% if (publicaciones != null && !publicaciones.isEmpty()) { %>
                                    <div class="results-section-separated">
                                        <div class="section-title-container">
                                            <h4 class="section-title">
                                                <i class="fas fa-file-alt"></i>
                                                Publicaciones
                                                <span class="results-count">(<%= publicaciones.size() %>)</span>
                                            </h4>
                                            <% if (publicaciones.size() >= 3) { %>
                                                <button class="btn btn-outline-primary btn-sm" onclick="cambiarTab('publicaciones')">
                                                    Ver todas
                                                </button>
                                            <% } %>
                                        </div>
                                        
                                        <div class="results-grid">
                                            <% 
                                                int maxPublicaciones = Math.min(3, publicaciones.size());
                                                for (int i = 0; i < maxPublicaciones; i++) {
                                                    Publicacion publicacion = publicaciones.get(i);
                                            %>
                                                <div class="result-card publicacion-card" 
                                                     onclick="verPublicacionEnHome(<%= publicacion.getIdPublicacion() %>)">
                                                    <div class="card-avatar">
                                                        <% if (publicacion.getAvatarUsuario() != null && !publicacion.getAvatarUsuario().isEmpty()) { %>
                                                            <img src="<%= publicacion.getAvatarUsuario() %>" alt="<%= publicacion.getNombreCompleto() %>">
                                                        <% } else { %>
                                                            <div class="avatar-placeholder publicacion-avatar">
                                                                <%= publicacion.getNombreCompleto().substring(0,1).toUpperCase() %>
                                                            </div>
                                                        <% } %>
                                                    </div>
                                                    <div class="card-info">
                                                        <h6 class="card-name"><%= publicacion.getNombreCompleto() %></h6>
                                                        <p class="card-username">
                                                            <%= publicacion.getNombreUsuario() != null ? publicacion.getNombreUsuario() : "Sin username" %>
                                                        </p>
                                                        <div class="card-preview">
                                                            <%= publicacion.getTexto().length() > 60 ? 
                                                                publicacion.getTexto().substring(0, 60) + "..." : 
                                                                publicacion.getTexto() %>
                                                        </div>
                                                        <div class="card-stats">
                                                            <span><i class="fas fa-heart"></i> <%= publicacion.getCantidadLikes() %></span>
                                                            <span><i class="fas fa-comment"></i> <%= publicacion.getCantidadComentarios() %></span>
                                                        </div>
                                                    </div>
                                                </div>
                                            <% } %>
                                        </div>
                                    </div>
                                <% } %>
                                
                                <!-- MENSAJE SI NO HAY RESULTADOS -->
                                <% if ((usuarios == null || usuarios.isEmpty()) && 
                                       (comunidades == null || comunidades.isEmpty()) && 
                                       (publicaciones == null || publicaciones.isEmpty())) { %>
                                    <div class="no-results">
                                        <i class="fas fa-search fa-3x text-muted mb-3"></i>
                                        <h5>No se encontraron resultados</h5>
                                        <p class="text-muted">Intenta con otros términos de búsqueda</p>
                                    </div>
                                <% } %>
                            </div>
                            
                        <% } else { %>
                            <!-- ============ PESTAÑAS INDIVIDUALES ============ -->
                            
                            <!-- RESULTADOS DE USUARIOS -->
                            <% if (("usuarios".equals(tabActiva)) && !usuarios.isEmpty()) { %>
                                <% for (Usuario usuario : usuarios) { %>
                                    <div class="result-item usuario-result" 
                                         data-id-usuario="<%= usuario.getId() %>"
                                         onclick="verPerfilUsuario(<%= usuario.getId() %>)">
                                        <div class="user-result">
                                            <div class="user-avatar">
                                                <% if (usuario.getAvatar() != null && !usuario.getAvatar().isEmpty()) { %>
                                                    <img src="<%= usuario.getAvatar() %>" alt="<%= usuario.getNombreCompleto() %>">
                                                <% } else { %>
                                                    <div class="avatar-placeholder">
                                                        <%= usuario.getNombreCompleto().substring(0,1).toUpperCase() %>
                                                    </div>
                                                <% } %>
                                            </div>
                                            <div class="user-info">
                                                <div class="user-header">
                                                    <div class="user-name">
                                                        <h6><%= usuario.getNombreCompleto() %></h6>
                                                        <% if (usuario.isVerificado()) { %>
                                                            <i class="fas fa-check-circle text-primary ml-2" title="Usuario verificado"></i>
                                                        <% } %>
                                                    </div>
                                                    <div class="user-meta">
                                                        <span class="user-username">
                                                            <%= usuario.getUsername() != null ? "@" + usuario.getUsername() : "Sin username" %>
                                                        </span>
                                                        <% if (usuario.isVerificado()) { %>
                                                            <span class="user-badge verified">
                                                                <i class="fas fa-check-circle"></i> Verificado
                                                            </span>
                                                        <% } %>
                                                        <% if (usuario.isPrivilegio()) { %>
                                                            <span class="user-badge privileged">
                                                                <i class="fas fa-star"></i> Privilegiado
                                                            </span>
                                                        <% } %>
                                                    </div>
                                                    <% if (usuario.getTelefono() != null && !usuario.getTelefono().trim().isEmpty()) { %>
                                                        <div class="user-extra-info">
                                                            <span class="user-phone">
                                                                <i class="fas fa-phone"></i> <%= usuario.getTelefono() %>
                                                            </span>
                                                        </div>
                                                    <% } %>
                                                    <% if (usuario.getFechaRegistro() != null) { %>
                                                        <div class="user-extra-info">
                                                            <span class="user-joined">
                                                                <i class="fas fa-calendar"></i> 
                                                                Miembro desde <%= new java.text.SimpleDateFormat("MMM yyyy").format(usuario.getFechaRegistro()) %>
                                                            </span>
                                                        </div>
                                                    <% } %>
                                                </div>
                                                
                                                <% if (usuario.getBio() != null && !usuario.getBio().trim().isEmpty()) { %>
                                                    <div class="user-bio">
                                                        <%= usuario.getBio().length() > 100 ? 
                                                           usuario.getBio().substring(0, 100) + "..." : 
                                                           usuario.getBio() %>
                                                    </div>
                                                <% } %>
                                            </div>
                                            <div class="user-action">
                                                <i class="fas fa-chevron-right"></i>
                                            </div>
                                        </div>
                                    </div>
                                <% } %>
                            <% } %>
                            
                            <!-- RESULTADOS DE COMUNIDADES -->
                            <% if (("comunidades".equals(tabActiva)) && !comunidades.isEmpty()) { %>
                                <% for (Comunidad comunidad : comunidades) { %>
                                    <div class="result-item comunidad-result" 
                                         data-id-comunidad="<%= comunidad.getIdComunidad() %>"
                                         onclick="verPerfilComunidad(<%= comunidad.getIdComunidad() %>)">
                                        <div class="community-result">
                                            <div class="community-avatar">
                                                <% 
                                                    String imagenComunidad = comunidad.getImagenUrl();
                                                    boolean tieneImagenComunidad = imagenComunidad != null && 
                                                                                 !imagenComunidad.trim().isEmpty() && 
                                                                                 !imagenComunidad.equals("default.png");
                                                %>
                                                <% if (tieneImagenComunidad) { %>
                                                    <img src="<%= imagenComunidad %>" alt="<%= comunidad.getNombre() %>">
                                                <% } else { %>
                                                    <div class="avatar-placeholder comunidad-avatar">
                                                        <%= comunidad.getNombre().substring(0,1).toUpperCase() %>
                                                    </div>
                                                <% } %>
                                            </div>
                                            <div class="community-info">
                                                <div class="community-name">
                                                    <h6><%= comunidad.getNombre() %></h6>
                                                    <% if (comunidad.isEsPublica()) { %>
                                                        <i class="fas fa-globe text-success ml-2" title="Comunidad pública"></i>
                                                    <% } else { %>
                                                        <i class="fas fa-lock text-warning ml-2" title="Comunidad privada"></i>
                                                    <% } %>
                                                </div>
                                                <% if (comunidad.getUsername() != null) { %>
                                                    <div class="community-username">
                                                        @<%= comunidad.getUsername() %>
                                                    </div>
                                                <% } else { %>
                                                    <div class="community-username text-muted">
                                                        Sin username
                                                    </div>
                                                <% } %>
                                                <div class="community-meta">
                                                    <span><i class="fas fa-users"></i> <%= comunidad.getSeguidoresCount() %> miembros</span>
                                                    <span>•</span>
                                                    <span><%= comunidad.isEsPublica() ? "Pública" : "Privada" %></span>
                                                    <% if (comunidad.getPublicacionesCount() > 0) { %>
                                                        <span>•</span>
                                                        <span><%= comunidad.getPublicacionesCount() %> publicaciones</span>
                                                    <% } %>
                                                </div>
                                                <% if (comunidad.getDescripcion() != null && !comunidad.getDescripcion().trim().isEmpty()) { %>
                                                    <div class="community-description">
                                                        <%= comunidad.getDescripcion().length() > 100 ? 
                                                           comunidad.getDescripcion().substring(0, 100) + "..." : 
                                                           comunidad.getDescripcion() %>
                                                    </div>
                                                <% } %>
                                                <% if (comunidad.getNombreCreador() != null) { %>
                                                    <div class="community-creator">
                                                        <small class="text-muted">
                                                            <i class="fas fa-user-crown"></i> Creada por <%= comunidad.getNombreCreador() %>
                                                        </small>
                                                    </div>
                                                <% } %>
                                            </div>
                                            <div class="community-action">
                                                <i class="fas fa-chevron-right"></i>
                                            </div>
                                        </div>
                                    </div>
                                <% } %>
                            <% } %>
                            
                            <!-- RESULTADOS DE PUBLICACIONES -->
                            <% if (("publicaciones".equals(tabActiva)) && !publicaciones.isEmpty()) { %>
                                <% for (Publicacion publicacion : publicaciones) { %>
                                    <div class="result-item publicacion-result" 
                                         data-id-publicacion="<%= publicacion.getIdPublicacion() %>"
                                         onclick="verPublicacionEnHome(<%= publicacion.getIdPublicacion() %>)">
                                        
                                        <div class="publicacion-content">
                                            <div class="post-header">
                                                <div class="post-avatar">
                                                    <% if (publicacion.getAvatarUsuario() != null && !publicacion.getAvatarUsuario().isEmpty()) { %>
                                                        <img src="<%= publicacion.getAvatarUsuario() %>" alt="<%= publicacion.getNombreCompleto() %>">
                                                    <% } else { %>
                                                        <div class="avatar-placeholder">
                                                            <%= publicacion.getNombreCompleto() != null ? 
                                                                publicacion.getNombreCompleto().substring(0,1).toUpperCase() : "U" %>
                                                        </div>
                                                    <% } %>
                                                </div>
                                                
                                                <div class="post-info">
                                                    <div class="post-user">
                                                        <h6><%= publicacion.getNombreCompleto() %></h6>
                                                    </div>
                                                    <div class="post-meta">
                                                        <span class="post-username">
                                                            <%= publicacion.getNombreUsuario() != null ? "@" + publicacion.getNombreUsuario() : "Sin username" %>
                                                        </span>
                                                        <span>•</span>
                                                        <span class="post-time">
                                                            <%= publicacion.getTiempoTranscurrido() != null ? publicacion.getTiempoTranscurrido() : "Hace un momento" %>
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>
                                            
                                            <div class="post-text">
                                                <%= publicacion.getTexto().length() > 150 ? 
                                                    publicacion.getTexto().substring(0, 150) + "..." : 
                                                    publicacion.getTexto() %>
                                            </div>
                                            
                                            <% if (publicacion.getImagenUrl() != null && !publicacion.getImagenUrl().isEmpty()) { %>
                                                <div class="post-image-preview">
                                                    <img src="<%= publicacion.getImagenUrl() %>" alt="Imagen de publicación">
                                                </div>
                                            <% } %>
                                            
                                            <div class="post-stats">
                                                <span><i class="fas fa-heart"></i> <%= publicacion.getCantidadLikes() %></span>
                                                <span><i class="fas fa-comment"></i> <%= publicacion.getCantidadComentarios() %></span>
                                                <% if (publicacion.getTotalDonaciones() > 0) { %>
                                                    <span><i class="fas fa-gift"></i> $<%= publicacion.getTotalDonaciones() %></span>
                                                <% } %>
                                                <% if (publicacion.getNombreComunidad() != null) { %>
                                                    <span><i class="fas fa-users"></i> <%= publicacion.getNombreComunidad() %></span>
                                                <% } %>
                                            </div>
                                        </div>
                                        
                                        <div class="post-action">
                                            <i class="fas fa-external-link-alt"></i>
                                            <div class="action-tooltip">Ver publicación</div>
                                        </div>
                                    </div>
                                <% } %>
                            <% } %>
                            
                            <!-- MENSAJE SI NO HAY RESULTADOS EN PESTAÑAS INDIVIDUALES -->
                            <% if (("comunidades".equals(tabActiva) && comunidades.isEmpty()) || 
                                   ("publicaciones".equals(tabActiva) && publicaciones.isEmpty()) ||
                                   ("usuarios".equals(tabActiva) && usuarios.isEmpty())) { %>
                                <div class="no-results">
                                    <i class="fas fa-search fa-3x text-muted mb-3"></i>
                                    <h5>No se encontraron resultados</h5>
                                    <p class="text-muted">No hay <%= tabActiva %> que coincidan con "<%= terminoBusqueda %>"</p>
                                </div>
                            <% } %>
                        <% } %>
                        
                    <% } else { %>
                        <!-- Estado inicial sin búsqueda -->
                        <div class="no-results">
                            <i class="fas fa-search fa-3x text-muted mb-3"></i>
                            <h5>Busca en AquaSocial</h5>
                            <p class="text-muted">Encuentra usuarios, comunidades y publicaciones</p>
                        </div>
                    <% } %>
                </div>
                
            </div>
        </div>
    </main>
    
    <!-- Scripts -->
    <jsp:include page="/components/js_imports.jsp" />
    
    <script>
        // Función para búsqueda principal
        function realizarBusquedaPrincipal(event) {
            event.preventDefault();
            var termino = $('#searchMainInput').val().trim();
            
            if (termino.length < 2) {
                alert('Ingresa al menos 2 caracteres para buscar');
                return;
            }
            
            window.location.href = 'BuscarServlet?q=' + encodeURIComponent(termino);
        }
        
        // Cambiar pestañas
        function cambiarTab(tab) {
            var termino = '<%= terminoBusqueda %>';
            if (termino) {
                console.log('📑 Cambiando a tab: ' + tab);
                window.location.href = 'BuscarServlet?q=' + encodeURIComponent(termino) + '&tab=' + tab;
            }
        }
        
        // Función para redirigir a perfil de comunidad
        function verPerfilComunidad(idComunidad) {
            if (!idComunidad) {
                console.error('❌ ID de comunidad no válido');
                return;
            }
            
            console.log('🔗 Redirigiendo a comunidad ID: ' + idComunidad);
            window.location.href = 'ComunidadServlet?action=view&id=' + idComunidad;
        }
        
        // Función para redirigir a perfil de usuario
        function verPerfilUsuario(idUsuario) {
            if (!idUsuario) {
                console.error('❌ ID de usuario no válido');
                return;
            }
            
            console.log('👤 Redirigiendo a usuario ID: ' + idUsuario);
            window.location.href = 'PerfilServlet?id=' + idUsuario;
        }
        
        // Función para redirigir al home y hacer scroll a la publicación
        function verPublicacionEnHome(idPublicacion) {
            if (!idPublicacion) {
                console.error('❌ ID de publicación no válido');
                return;
            }
            
            console.log('📄 Redirigiendo a publicación ID: ' + idPublicacion);
            window.location.href = 'HomeServlet?scrollTo=' + idPublicacion + '#publicacion-' + idPublicacion;
        }
        
        // Cargar búsquedas recientes del localStorage
        function cargarBusquedasRecientes() {
            var recientes = JSON.parse(localStorage.getItem('busquedasRecientes') || '[]');
            var container = $('#recentSearches');
            
            if (recientes.length === 0) {
                container.html('<li class="recent-item"><span class="recent-link">No hay búsquedas recientes</span></li>');
                return;
            }
            
            container.html('');
            recientes.slice(0, 5).forEach(function(busqueda) {
                var li = $('<li class="recent-item"></li>');
                li.html('<a href="BuscarServlet?q=' + encodeURIComponent(busqueda.termino) + '" class="recent-link">' +
                       busqueda.termino +
                       '</a>' +
                       '<span class="recent-time">' + busqueda.tiempo + '</span>');
                container.append(li);
            });
        }
        
        // Guardar búsqueda en localStorage
        function guardarBusqueda(termino) {
            var recientes = JSON.parse(localStorage.getItem('busquedasRecientes') || '[]');
            var fecha = new Date();
            
            // Remover si ya existe
            recientes = recientes.filter(function(item) {
                return item.termino !== termino;
            });
            
            // Agregar al inicio
            recientes.unshift({
                termino: termino,
                fecha: fecha.toISOString(),
                tiempo: formatearTiempo(fecha)
            });
            
            // Mantener solo 10 búsquedas
            if (recientes.length > 10) {
                recientes = recientes.slice(0, 10);
            }
            
            localStorage.setItem('busquedasRecientes', JSON.stringify(recientes));
        }
        
        // Formatear tiempo relativo
        function formatearTiempo(fecha) {
            var ahora = new Date();
            var diff = ahora - fecha;
            var minutos = Math.floor(diff / 60000);
            var horas = Math.floor(minutos / 60);
            var dias = Math.floor(horas / 24);
            
            if (minutos < 1) return 'ahora';
            if (minutos < 60) return 'hace ' + minutos + 'm';
            if (horas < 24) return 'hace ' + horas + 'h';
            if (dias < 7) return 'hace ' + dias + 'd';
            return fecha.toLocaleDateString();
        }
        
        // Al cargar la página
        $(document).ready(function() {
            cargarBusquedasRecientes();
            
            // Guardar búsqueda actual si existe
            var termino = '<%= terminoBusqueda %>';
            if (termino && termino.length >= 2) {
                guardarBusqueda(termino);
            }
            
            // Auto-focus en el input de búsqueda
            if (!termino) {
                $('#searchMainInput').focus();
            }
            
            // Efectos hover mejorados
            $('.result-card').hover(
                function() {
                    $(this).addClass('hovered');
                },
                function() {
                    $(this).removeClass('hovered');
                }
            );
            
            console.log('🔍 Página de búsqueda cargada. Término: "' + termino + '"');
        });
        
        // Atajos de teclado
        $(document).on('keydown', function(e) {
            // Ctrl/Cmd + K para enfocar búsqueda
            if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
                e.preventDefault();
                $('#searchMainInput').focus();
            }
            
            // Enter en resultados
            if (e.key === 'Enter') {
                var $focused = $('.result-item:hover, .result-card:hover');
                if ($focused.length > 0) {
                    var idComunidad = $focused.data('id-comunidad');
                    var idPublicacion = $focused.data('id-publicacion');
                    var idUsuario = $focused.data('id-usuario');
                    
                    if (idComunidad) {
                        verPerfilComunidad(idComunidad);
                    } else if (idPublicacion) {
                        verPublicacionEnHome(idPublicacion);
                    } else if (idUsuario) {
                        verPerfilUsuario(idUsuario);
                    }
                }
            }
        });
        
    </script>
</body>
</html>