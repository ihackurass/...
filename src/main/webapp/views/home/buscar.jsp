<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="pe.aquasocial.entity.Usuario"%>
<%@page import="pe.aquasocial.entity.Comunidad"%>

<%
    String terminoBusqueda = request.getParameter("q");
    String tabActiva = request.getParameter("tab");
    
    if (terminoBusqueda == null) terminoBusqueda = "";
    if (tabActiva == null) tabActiva = "todo";
    
    // Obtener resultados (se implementará en el servlet)
    List<Usuario> usuarios = (List<Usuario>) request.getAttribute("usuarios");
    List<Comunidad> comunidades = (List<Comunidad>) request.getAttribute("comunidades");
    
    if (usuarios == null) usuarios = new java.util.ArrayList<>();
    if (comunidades == null) comunidades = new java.util.ArrayList<>();
    
    int totalResultados = usuarios.size() + comunidades.size();
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
        
        .tab-btn:hover:not(.active) {
            color: #1da1f2;
            background: rgba(29, 161, 242, 0.05);
        }
        
        .sidebar {
            background: white;
            border-radius: 15px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            height: fit-content;
            position: sticky;
            top: 20px;
        }
        
        .sidebar-title {
            font-size: 1.1rem;
            font-weight: 700;
            color: #14171a;
            margin-bottom: 15px;
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
        
        .recent-item:last-child {
            border-bottom: none;
        }
        
        .recent-link {
            color: #1da1f2;
            text-decoration: none;
            font-size: 14px;
            transition: color 0.3s ease;
        }
        
        .recent-link:hover {
            color: #0c85d0;
            text-decoration: underline;
        }
        
        .recent-time {
            color: #657786;
            font-size: 12px;
            margin-left: 10px;
        }
        
        .results-container {
            background: white;
            border-radius: 15px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .results-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid #f1f3f4;
        }
        
        .results-count {
            color: #657786;
            font-size: 14px;
        }
        
        .result-item {
            padding: 15px 0;
            border-bottom: 1px solid #f1f3f4;
            transition: background 0.3s ease;
        }
        
        .result-item:hover {
            background: #f7f9fa;
            margin: 0 -20px;
            padding: 15px 20px;
            border-radius: 10px;
        }
        
        .result-item:last-child {
            border-bottom: none;
        }
        
        .user-result {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .user-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: linear-gradient(135deg, #1da1f2, #0084b4);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 700;
            font-size: 1.2rem;
            flex-shrink: 0;
        }
        
        .user-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 50%;
        }
        
        .user-info {
            flex: 1;
        }
        
        .user-name {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 3px;
        }
        
        .user-name h6 {
            margin: 0;
            font-weight: 700;
            color: #14171a;
            font-size: 15px;
        }
        
        .verified-badge {
            color: #1da1f2;
            font-size: 16px;
        }
        
        .username {
            color: #657786;
            font-size: 14px;
            margin-bottom: 5px;
        }
        
        .user-bio {
            color: #14171a;
            font-size: 14px;
            line-height: 1.4;
        }
        
        .community-result {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .community-avatar {
            width: 50px;
            height: 50px;
            border-radius: 10px;
            background: linear-gradient(135deg, #28a745, #20c997);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 700;
            font-size: 1.2rem;
            flex-shrink: 0;
        }
        
        .community-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 10px;
        }
        
        .community-info {
            flex: 1;
        }
        
        .community-name {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 3px;
        }
        
        .community-name h6 {
            margin: 0;
            font-weight: 700;
            color: #14171a;
            font-size: 15px;
        }
        
        .community-username {
            color: #657786;
            font-size: 14px;
            margin-bottom: 3px;
        }
        
        .community-meta {
            display: flex;
            align-items: center;
            gap: 15px;
            color: #657786;
            font-size: 13px;
        }
        
        .community-description {
            color: #14171a;
            font-size: 14px;
            line-height: 1.4;
            margin-top: 5px;
        }
        
        .no-results {
            text-align: center;
            padding: 60px 20px;
            color: #657786;
        }
        
        .no-results i {
            font-size: 4rem;
            margin-bottom: 20px;
            opacity: 0.3;
        }
        
        .no-results h3 {
            margin-bottom: 10px;
            color: #14171a;
        }
        
        .no-results p {
            font-size: 16px;
            line-height: 1.5;
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
        
        @media (max-width: 768px) {
            .main-container {
                grid-template-columns: 1fr;
                padding: 15px;
                gap: 20px;
            }
            
            .sidebar {
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
                                   placeholder="Buscar usuarios, comunidades..."
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
                    </div>
                </div>
                
                <!-- Sidebar -->
                <div class="sidebar">
                    <div class="sidebar-title">Búsquedas recientes</div>
                    <ul class="recent-searches" id="recentSearches">
                        <!-- Se carga dinámicamente -->
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
                                    Sin resultados para "<%= terminoBusqueda %>"
                                <% } %>
                            </div>
                        </div>
                        
                        <div id="resultsContent">
                            <% if (totalResultados > 0) { %>
                                
                                <!-- Mostrar usuarios si tab es 'todo' o 'usuarios' -->
                                <% if (("todo".equals(tabActiva) || "usuarios".equals(tabActiva)) && !usuarios.isEmpty()) { %>
                                    <% for (Usuario usuario : usuarios) { %>
                                        <div class="result-item">
                                            <div class="user-result">
                                                <div class="user-avatar">
                                                    <% 
                                                        String avatarUsuario = usuario.getAvatar();
                                                        boolean tieneAvatarUsuario = avatarUsuario != null && 
                                                                                   !avatarUsuario.trim().isEmpty() && 
                                                                                   !avatarUsuario.equals("default.png");
                                                    %>
                                                    <% if (tieneAvatarUsuario) { %>
                                                        <img src="<%= avatarUsuario %>" alt="<%= usuario.getNombreCompleto() %>">
                                                    <% } else { %>
                                                        <%= usuario.getNombreCompleto().substring(0,1).toUpperCase() %>
                                                    <% } %>
                                                </div>
                                                <div class="user-info">
                                                    <div class="user-name">
                                                        <h6><%= usuario.getNombreCompleto() %></h6>
                                                        <% if (usuario.isVerificado()) { %>
                                                            <i class="fas fa-check-circle verified-badge"></i>
                                                        <% } %>
                                                    </div>
                                                    <div class="username">@<%= usuario.getUsername() %></div>
                                                    <% if (usuario.getBio() != null && !usuario.getBio().trim().isEmpty()) { %>
                                                        <div class="user-bio"><%= usuario.getBio() %></div>
                                                    <% } %>
                                                </div>
                                            </div>
                                        </div>
                                    <% } %>
                                <% } %>
                                
                                <!-- Mostrar comunidades si tab es 'todo' o 'comunidades' -->
                                <% if (("todo".equals(tabActiva) || "comunidades".equals(tabActiva)) && !comunidades.isEmpty()) { %>
                                    <% for (Comunidad comunidad : comunidades) { %>
                                        <div class="result-item">
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
                                                        <%= comunidad.getNombre().substring(0,1).toUpperCase() %>
                                                    <% } %>
                                                </div>
                                                <div class="community-info">
                                                    <div class="community-name">
                                                        <h6><%= comunidad.getNombre() %></h6>
                                                        <!-- Las comunidades no tienen verificación por ahora -->
                                                    </div>
                                                    <% if (comunidad.getUsername() != null) { %>
                                                        <div class="community-username">@<%= comunidad.getUsername() %></div>
                                                    <% } %>
                                                    <div class="community-meta">
                                                        <span><%= comunidad.getSeguidoresCount() %> miembros</span>
                                                        <span>•</span>
                                                        <span><%= comunidad.isEsPublica() ? "Pública" : "Privada" %></span>
                                                    </div>
                                                    <% if (comunidad.getDescripcion() != null && !comunidad.getDescripcion().trim().isEmpty()) { %>
                                                        <div class="community-description">
                                                            <%= comunidad.getDescripcion().length() > 100 ? 
                                                               comunidad.getDescripcion().substring(0, 100) + "..." : 
                                                               comunidad.getDescripcion() %>
                                                        </div>
                                                    <% } %>
                                                </div>
                                            </div>
                                        </div>
                                    <% } %>
                                <% } %>
                                
                            <% } else { %>
                                <!-- Sin resultados -->
                                <div class="no-results">
                                    <i class="fas fa-search"></i>
                                    <h3>No se encontraron resultados</h3>
                                    <p>Intenta con otros términos de búsqueda o revisa la ortografía.</p>
                                </div>
                            <% } %>
                        </div>
                        
                    <% } else { %>
                        <!-- Sin término de búsqueda -->
                        <div class="no-results">
                            <i class="fas fa-search"></i>
                            <h3>Busca usuarios y comunidades</h3>
                            <p>Descubre personas interesantes y comunidades que te gusten en AquaSocial.</p>
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
            const termino = document.getElementById('searchMainInput').value.trim();
            
            if (termino.length < 2) {
                alert('Ingresa al menos 2 caracteres para buscar');
                return;
            }
            
            window.location.href = 'buscar.jsp?q=' + encodeURIComponent(termino);
        }
        
        // Cambiar pestañas
        function cambiarTab(tab) {
            const termino = '<%= terminoBusqueda %>';
            if (termino) {
                window.location.href = 'buscar.jsp?q=' + encodeURIComponent(termino) + '&tab=' + tab;
            }
        }
        
        // Cargar búsquedas recientes del localStorage
        function cargarBusquedasRecientes() {
            const recientes = JSON.parse(localStorage.getItem('busquedasRecientes') || '[]');
            const container = document.getElementById('recentSearches');
            
            if (recientes.length === 0) {
                container.innerHTML = '<li class="recent-item"><span class="recent-link">No hay búsquedas recientes</span></li>';
                return;
            }
            
            container.innerHTML = '';
            recientes.slice(0, 5).forEach(busqueda => {
                const li = document.createElement('li');
                li.className = 'recent-item';
                li.innerHTML = `
                    <a href="buscar.jsp?q=${encodeURIComponent(busqueda.termino)}" class="recent-link">
                        ${busqueda.termino}
                    </a>
                    <span class="recent-time">${busqueda.tiempo}</span>
                `;
                container.appendChild(li);
            });
        }
        
        // Guardar búsqueda en localStorage
        function guardarBusqueda(termino) {
            if (!termino || termino.length < 2) return;
            
            const recientes = JSON.parse(localStorage.getItem('busquedasRecientes') || '[]');
            
            // Remover si ya existe
            const index = recientes.findIndex(b => b.termino.toLowerCase() === termino.toLowerCase());
            if (index > -1) {
                recientes.splice(index, 1);
            }
            
            // Agregar al inicio
            recientes.unshift({
                termino: termino,
                tiempo: formatearTiempo(new Date()),
                fecha: new Date().toISOString()
            });
            
            // Mantener solo las últimas 10
            if (recientes.length > 10) {
                recientes.pop();
            }
            
            localStorage.setItem('busquedasRecientes', JSON.stringify(recientes));
        }
        
        // Formatear tiempo relativo
        function formatearTiempo(fecha) {
            const ahora = new Date();
            const diff = ahora - fecha;
            const minutos = Math.floor(diff / 60000);
            const horas = Math.floor(minutos / 60);
            const dias = Math.floor(horas / 24);
            
            if (minutos < 1) return 'ahora';
            if (minutos < 60) return `hace ${minutos}m`;
            if (horas < 24) return `hace ${horas}h`;
            if (dias < 7) return `hace ${dias}d`;
            return fecha.toLocaleDateString();
        }
        
        // Al cargar la página
        document.addEventListener('DOMContentLoaded', function() {
            cargarBusquedasRecientes();
            
            // Guardar búsqueda actual si existe
            const termino = '<%= terminoBusqueda %>';
            if (termino && termino.length >= 2) {
                guardarBusqueda(termino);
            }
            
            // Auto-focus en el input de búsqueda
            const searchInput = document.getElementById('searchMainInput');
            if (searchInput && !termino) {
                searchInput.focus();
            }
        });
        
        // Atajos de teclado
        document.addEventListener('keydown', function(e) {
            // Ctrl/Cmd + K para enfocar búsqueda
            if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
                e.preventDefault();
                document.getElementById('searchMainInput').focus();
            }
        });
        
        console.log('🔍 Página de búsqueda cargada. Término: "<%= terminoBusqueda %>"');
    </script>
</body>
</html>