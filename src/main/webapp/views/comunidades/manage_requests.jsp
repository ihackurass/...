<%-- 
    Document   : manage_requests
    Created on : Gestión Completa de Solicitudes (Historial)
    Author     : Sistema
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="pe.aquasocial.entity.Comunidad"%>
<%@page import="pe.aquasocial.entity.Usuario"%>
<%@page import="pe.aquasocial.entity.SolicitudMembresia"%>
<%@page import="java.time.format.DateTimeFormatter"%>

<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuarioLogueado");
    Comunidad comunidad = (Comunidad) request.getAttribute("comunidad");
    List<SolicitudMembresia> solicitudes = (List<SolicitudMembresia>) request.getAttribute("solicitudes");
    Boolean esHistorial = (Boolean) request.getAttribute("esHistorial");
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
    
    if (solicitudes == null) solicitudes = new java.util.ArrayList<>();
    if (esHistorial == null) esHistorial = false;
%>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Historial de Solicitudes - <%= comunidad != null ? comunidad.getNombre() : "Comunidad" %></title>
    <jsp:include page="/components/css_imports.jsp" />
    
    <style>
        .main-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header-section {
            background: linear-gradient(135deg, #6f42c1, #e83e8c);
            color: white;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
        }
        
        .header-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0,0,0,0.1);
            z-index: 1;
        }
        
        .header-content {
            position: relative;
            z-index: 2;
        }
        
        .breadcrumb-custom {
            background: none;
            padding: 0;
            margin-bottom: 20px;
        }
        
        .breadcrumb-custom a {
            color: rgba(255,255,255,0.8);
            text-decoration: none;
        }
        
        .breadcrumb-custom a:hover {
            color: white;
            text-decoration: underline;
        }
        
        .header-title {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 20px;
        }
        
        .title-section h1 {
            margin: 0;
            font-size: 2rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .stats-overview {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 15px;
            margin-top: 20px;
        }
        
        .stat-card {
            background: rgba(255,255,255,0.1);
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            backdrop-filter: blur(10px);
        }
        
        .stat-number {
            display: block;
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 5px;
        }
        
        .stat-label {
            font-size: 0.875rem;
            opacity: 0.9;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .content-section {
            background: white;
            border-radius: 15px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .content-header {
            background: #f8f9fa;
            padding: 25px 30px;
            border-bottom: 1px solid #e9ecef;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }
        
        .content-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: #495057;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .filter-controls {
            display: flex;
            gap: 15px;
            align-items: center;
            flex-wrap: wrap;
        }
        
        .search-box {
            position: relative;
        }
        
        .search-box input {
            padding: 8px 35px 8px 15px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 14px;
            width: 250px;
            transition: border-color 0.3s ease;
        }
        
        .search-box input:focus {
            outline: none;
            border-color: #007bff;
        }
        
        .search-box i {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #6c757d;
        }
        
        .filter-select {
            padding: 8px 12px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 14px;
            background: white;
            cursor: pointer;
        }
        
        .filter-tabs {
            display: flex;
            gap: 5px;
            background: white;
            padding: 5px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .tab-btn {
            padding: 10px 20px;
            border: none;
            background: transparent;
            color: #6c757d;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 14px;
            font-weight: 600;
            white-space: nowrap;
        }
        
        .tab-btn.active {
            background: #007bff;
            color: white;
            box-shadow: 0 2px 8px rgba(0,123,255,0.3);
        }
        
        .tab-btn:hover:not(.active) {
            background: rgba(0,123,255,0.1);
            color: #007bff;
        }
        
        .requests-container {
            padding: 30px;
        }
        
        .requests-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        
        .requests-table th {
            background: #f8f9fa;
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: #495057;
            border-bottom: 2px solid #e9ecef;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .requests-table td {
            padding: 15px;
            border-bottom: 1px solid #f1f3f4;
            vertical-align: top;
        }
        
        .requests-table tbody tr {
            transition: background-color 0.2s ease;
        }
        
        .requests-table tbody tr:hover {
            background: #f8f9fa;
        }
        
        .user-cell {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, #007bff, #6610f2);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 700;
            font-size: 1rem;
            flex-shrink: 0;
        }
        
        .user-info h6 {
            margin: 0 0 2px 0;
            font-weight: 600;
            color: #333;
            font-size: 14px;
        }
        
        .user-info .username {
            color: #6c757d;
            font-size: 12px;
        }
        
        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .status-pendiente {
            background: #fff3cd;
            color: #856404;
            border: 1px solid #ffeaa7;
        }
        
        .status-aprobada {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .status-rechazada {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .message-cell {
            max-width: 250px;
            word-wrap: break-word;
        }
        
        .message-text {
            font-size: 13px;
            color: #495057;
            line-height: 1.4;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        
        .expand-message {
            color: #007bff;
            cursor: pointer;
            font-size: 11px;
            text-decoration: underline;
            margin-top: 5px;
        }
        
        .date-cell {
            font-size: 12px;
            color: #6c757d;
            white-space: nowrap;
        }
        
        .admin-cell {
            font-size: 12px;
        }
        
        .admin-name {
            font-weight: 600;
            color: #495057;
        }
        
        .admin-username {
            color: #6c757d;
        }
        
        .actions-cell {
            white-space: nowrap;
        }
        
        .btn-action {
            padding: 6px 12px;
            border: none;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-right: 5px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        
        .btn-view {
            background: #17a2b8;
            color: white;
        }
        
        .btn-view:hover {
            background: #138496;
        }
        
        .btn-contact {
            background: #6c757d;
            color: white;
        }
        
        .btn-contact:hover {
            background: #5a6268;
        }
        
        .no-requests {
            text-align: center;
            padding: 80px 20px;
            color: #6c757d;
        }
        
        .no-requests i {
            font-size: 5rem;
            margin-bottom: 20px;
            opacity: 0.3;
        }
        
        .no-requests h3 {
            margin-bottom: 15px;
            color: #495057;
        }
        
        .export-controls {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        
        .btn-export {
            padding: 8px 16px;
            border: 2px solid #28a745;
            background: transparent;
            color: #28a745;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        
        .btn-export:hover {
            background: #28a745;
            color: white;
        }
        
        .alert-custom {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .pagination-container {
            display: flex;
            justify-content: center;
            margin-top: 30px;
        }
        
        .pagination {
            display: flex;
            gap: 5px;
        }
        
        .page-btn {
            padding: 8px 12px;
            border: 1px solid #dee2e6;
            background: white;
            color: #007bff;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.3s ease;
        }
        
        .page-btn:hover {
            background: #e9ecef;
        }
        
        .page-btn.active {
            background: #007bff;
            color: white;
            border-color: #007bff;
        }
        
        @media (max-width: 768px) {
            .main-container {
                padding: 15px;
            }
            
            .header-title {
                flex-direction: column;
                align-items: stretch;
            }
            
            .stats-overview {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .content-header {
                flex-direction: column;
                align-items: stretch;
            }
            
            .filter-controls {
                justify-content: center;
                flex-wrap: wrap;
            }
            
            .search-box input {
                width: 200px;
            }
            
            .requests-table {
                font-size: 12px;
            }
            
            .requests-table th,
            .requests-table td {
                padding: 10px 8px;
            }
            
            .filter-tabs {
                flex-wrap: wrap;
                justify-content: center;
            }
            
            .tab-btn {
                font-size: 12px;
                padding: 8px 12px;
            }
        }
        
        @media (max-width: 480px) {
            .requests-table {
                display: block;
                overflow-x: auto;
                white-space: nowrap;
            }
            
            .user-cell {
                min-width: 150px;
            }
            
            .message-cell {
                min-width: 200px;
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
                <!-- Header -->
                <div class="header-section">
                    <div class="header-content">
                        <!-- Breadcrumb -->
                        <nav class="breadcrumb-custom">
                            <a href="ComunidadServlet">Comunidades</a> &gt; 
                            <a href="ComunidadServlet?action=view&id=<%= comunidad.getIdComunidad() %>">
                                <%= comunidad.getNombre() %>
                            </a> &gt; 
                            <span>Historial de Solicitudes</span>
                        </nav>
                        
                        <div class="header-title">
                            <div class="title-section">
                                <h1>
                                    <i class="fas fa-history"></i>
                                    Historial de Solicitudes
                                </h1>
                                <p style="margin: 5px 0 0 0; opacity: 0.9; font-size: 1.1rem;">
                                    <%= comunidad.getNombre() %>
                                </p>
                            </div>
                            
                            <div class="export-controls">
                                <a href="ComunidadServlet?action=requests&id=<%= comunidad.getIdComunidad() %>" 
                                   class="btn-export">
                                    <i class="fas fa-arrow-left"></i> Solo Pendientes
                                </a>
                                <button class="btn-export" onclick="exportarCSV()">
                                    <i class="fas fa-download"></i> Exportar CSV
                                </button>
                            </div>
                        </div>
                        
                        <!-- Estadísticas -->
                        <div class="stats-overview">
                            <div class="stat-card">
                                <span class="stat-number"><%= solicitudes.size() %></span>
                                <span class="stat-label">Total</span>
                            </div>
                            <div class="stat-card">
                                <span class="stat-number">
                                    <%= solicitudes.stream().mapToInt(s -> s.esPendiente() ? 1 : 0).sum() %>
                                </span>
                                <span class="stat-label">Pendientes</span>
                            </div>
                            <div class="stat-card">
                                <span class="stat-number">
                                    <%= solicitudes.stream().mapToInt(s -> s.esAprobada() ? 1 : 0).sum() %>
                                </span>
                                <span class="stat-label">Aprobadas</span>
                            </div>
                            <div class="stat-card">
                                <span class="stat-number">
                                    <%= solicitudes.stream().mapToInt(s -> s.esRechazada() ? 1 : 0).sum() %>
                                </span>
                                <span class="stat-label">Rechazadas</span>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Contenido principal -->
                <div class="content-section">
                    <!-- Mensajes de estado -->
                    <% if (success != null) { %>
                        <div class="alert-custom alert-success">
                            <i class="fas fa-check-circle"></i>
                            <%= success %>
                        </div>
                    <% } %>
                    
                    <% if (error != null) { %>
                        <div class="alert-custom alert-error">
                            <i class="fas fa-exclamation-triangle"></i>
                            <%= error %>
                        </div>
                    <% } %>
                    
                    <!-- Header del contenido -->
                    <div class="content-header">
                        <div class="content-title">
                            <i class="fas fa-table"></i>
                            Registro Completo de Solicitudes
                        </div>
                        
                        <div class="filter-controls">
                            <!-- Búsqueda -->
                            <div class="search-box">
                                <input type="text" id="searchRequests" placeholder="Buscar por usuario...">
                                <i class="fas fa-search"></i>
                            </div>
                            
                            <!-- Filtros -->
                            <div class="filter-tabs">
                                <button class="tab-btn active" data-filter="all">
                                    Todas (<%= solicitudes.size() %>)
                                </button>
                                <button class="tab-btn" data-filter="pendiente">
                                    Pendientes (<%= solicitudes.stream().mapToInt(s -> s.esPendiente() ? 1 : 0).sum() %>)
                                </button>
                                <button class="tab-btn" data-filter="aprobada">
                                    Aprobadas (<%= solicitudes.stream().mapToInt(s -> s.esAprobada() ? 1 : 0).sum() %>)
                                </button>
                                <button class="tab-btn" data-filter="rechazada">
                                    Rechazadas (<%= solicitudes.stream().mapToInt(s -> s.esRechazada() ? 1 : 0).sum() %>)
                                </button>
                            </div>
                            
                            <!-- Filtro por fecha -->
                            <select class="filter-select" id="dateFilter">
                                <option value="">Todas las fechas</option>
                                <option value="today">Hoy</option>
                                <option value="week">Esta semana</option>
                                <option value="month">Este mes</option>
                                <option value="quarter">Este trimestre</option>
                            </select>
                        </div>
                    </div>
                    
                    <!-- Tabla de solicitudes -->
                    <div class="requests-container">
                        <% if (!solicitudes.isEmpty()) { %>
                            <table class="requests-table" id="requestsTable">
                                <thead>
                                    <tr>
                                        <th>Usuario</th>
                                        <th>Estado</th>
                                        <th>Mensaje</th>
                                        <th>Fecha Solicitud</th>
                                        <th>Respondido Por</th>
                                        <th>Fecha Respuesta</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% 
                                        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
                                        for (SolicitudMembresia solicitud : solicitudes) { 
                                    %>
                                        <tr class="request-row" 
                                            data-status="<%= solicitud.getEstado() %>"
                                            data-user="<%= solicitud.getUsernameUsuario() != null ? solicitud.getUsernameUsuario().toLowerCase() : "" %>"
                                            data-date="<%= solicitud.getFechaSolicitud() != null ? solicitud.getFechaSolicitud().toString() : "" %>">
                                            
                                            <!-- Usuario -->
                                            <td class="user-cell">
                                                <div class="user-avatar">
                                                    <%= solicitud.getUsernameUsuario() != null ? 
                                                        solicitud.getUsernameUsuario().substring(0,1).toUpperCase() : "U" %>
                                                </div>
                                                <div class="user-info">
                                                    <h6><%= solicitud.getNombreCompletoUsuario() != null ? 
                                                            solicitud.getNombreCompletoUsuario() : "Usuario" %></h6>
                                                    <div class="username">@<%= solicitud.getUsernameUsuario() != null ? 
                                                                              solicitud.getUsernameUsuario() : "username" %></div>
                                                </div>
                                            </td>
                                            
                                            <!-- Estado -->
                                            <td>
                                                <span class="status-badge status-<%= solicitud.getEstado() %>">
                                                    <%= solicitud.getEstadoDisplay() %>
                                                </span>
                                            </td>
                                            
                                            <!-- Mensaje -->
                                            <td class="message-cell">
                                                <% if (solicitud.getMensajeSolicitud() != null && !solicitud.getMensajeSolicitud().trim().isEmpty()) { %>
                                                    <div class="message-text" id="msg-<%= solicitud.getIdSolicitud() %>">
                                                        <%= solicitud.getMensajeSolicitud() %>
                                                    </div>
                                                    <% if (solicitud.getMensajeSolicitud().length() > 100) { %>
                                                        <div class="expand-message" onclick="toggleMessage(<%= solicitud.getIdSolicitud() %>)">
                                                            Ver más
                                                        </div>
                                                    <% } %>
                                                <% } else { %>
                                                    <span class="text-muted">Sin mensaje</span>
                                                <% } %>
                                            </td>
                                            
                                            <!-- Fecha Solicitud -->
                                            <td class="date-cell">
                                                <i class="fas fa-calendar" style="margin-right: 5px;"></i>
                                                <%= solicitud.getFechaSolicitud() != null ? 
                                                   solicitud.getFechaSolicitud().format(formatter) : "No disponible" %>
                                            </td>
                                            
                                            <!-- Admin que respondió -->
                                            <td class="admin-cell">
                                                <% if (solicitud.tieneRespuesta() && solicitud.getUsernameAdmin() != null) { %>
                                                    <div class="admin-name">
                                                        <%= solicitud.getNombreCompletoAdmin() != null ? 
                                                           solicitud.getNombreCompletoAdmin() : "Admin" %>
                                                    </div>
                                                    <div class="admin-username">@<%= solicitud.getUsernameAdmin() %></div>
                                                <% } else { %>
                                                    <span class="text-muted">-</span>
                                                <% } %>
                                            </td>
                                            
                                            <!-- Fecha Respuesta -->
                                            <td class="date-cell">
                                                <% if (solicitud.getFechaRespuesta() != null) { %>
                                                    <i class="fas fa-reply" style="margin-right: 5px;"></i>
                                                    <%= solicitud.getFechaRespuesta().format(formatter) %>
                                                <% } else { %>
                                                    <span class="text-muted">-</span>
                                                <% } %>
                                            </td>
                                            
                                            <!-- Acciones -->
                                            <td class="actions-cell">
                                                <button class="btn-action btn-view" 
                                                        onclick="verDetallesSolicitud(<%= solicitud.getIdSolicitud() %>)">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <% if (solicitud.getEmailUsuario() != null) { %>
                                                    <a href="mailto:<%= solicitud.getEmailUsuario() %>" 
                                                       class="btn-action btn-contact">
                                                        <i class="fas fa-envelope"></i>
                                                    </a>
                                                <% } %>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                            
                            <!-- Paginación (si es necesaria) -->
                            <div class="pagination-container" id="paginationContainer" style="display: none;">
                                <div class="pagination" id="pagination">
                                    <!-- Se genera dinámicamente con JavaScript -->
                                </div>
                            </div>
                            
                        <% } else { %>
                            <!-- Sin solicitudes -->
                            <div class="no-requests">
                                <i class="fas fa-inbox"></i>
                                <h3>No hay solicitudes registradas</h3>
                                <p>Cuando los usuarios soliciten unirse a tu comunidad, aparecerán en este historial.</p>
                                <a href="ComunidadServlet?action=view&id=<%= comunidad.getIdComunidad() %>" 
                                   class="btn btn-primary" 
                                   style="display: inline-flex; align-items: center; text-decoration: none;">
                                    <i class="fas fa-arrow-left" style="margin-right: 8px; font-size: 1em; vertical-align: baseline;"></i>
                                    Volver a la Comunidad
                                </a>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </main>
    
    <!-- Scripts -->
    <jsp:include page="/components/js_imports.jsp" />
    
    <script>
        $(document).ready(function() {
            initializeFilters();
            initializeSearch();
        });
        
        function initializeFilters() {
            // Filtros por estado
            $('.tab-btn').on('click', function() {
                const filter = $(this).data('filter');
                
                $('.tab-btn').removeClass('active');
                $(this).addClass('active');
                
                filterRequests();
            });
            
            // Filtro por fecha
            $('#dateFilter').on('change', function() {
                filterRequests();
            });
        }
        
        function initializeSearch() {
            $('#searchRequests').on('input', function() {
                filterRequests();
            });
        }
        
        function filterRequests() {
            const statusFilter = $('.tab-btn.active').data('filter');
            const searchTerm = $('#searchRequests').val().toLowerCase();
            const dateFilter = $('#dateFilter').val();
            
            let visibleCount = 0;
            
            $('.request-row').each(function() {
                const $row = $(this);
                const status = $row.data('status');
                const user = $row.data('user');
                const dateStr = $row.data('date');
                
                // Filtro por estado
                const matchesStatus = statusFilter === 'all' || status === statusFilter;
                
                // Filtro por búsqueda
                const matchesSearch = searchTerm === '' || user.includes(searchTerm);
                
                // Filtro por fecha (implementación básica)
                let matchesDate = true;
                if (dateFilter && dateStr) {
                    const requestDate = new Date(dateStr);
                    const now = new Date();
                    
                    switch (dateFilter) {
                        case 'today':
                            matchesDate = requestDate.toDateString() === now.toDateString();
                            break;
                        case 'week':
                            const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
                            matchesDate = requestDate >= weekAgo;
                            break;
                        case 'month':
                            const monthAgo = new Date(now.getFullYear(), now.getMonth() - 1, now.getDate());
                            matchesDate = requestDate >= monthAgo;
                            break;
                        case 'quarter':
                            const quarterAgo = new Date(now.getFullYear(), now.getMonth() - 3, now.getDate());
                            matchesDate = requestDate >= quarterAgo;
                            break;
                    }
                }
                
                if (matchesStatus && matchesSearch && matchesDate) {
                    $row.show();
                    visibleCount++;
                } else {
                    $row.hide();
                }
            });
            
            // Actualizar contador en pestañas activas
            console.log('Mostrando ' + visibleCount + ' solicitudes');
        }
        
        function toggleMessage(idSolicitud) {
            const messageElement = $('#msg-' + idSolicitud);
            const expandButton = messageElement.next('.expand-message');
            
            if (messageElement.css('-webkit-line-clamp') === '3') {
                messageElement.css('-webkit-line-clamp', 'none');
                expandButton.text('Ver menos');
            } else {
                messageElement.css('-webkit-line-clamp', '3');
                expandButton.text('Ver más');
            }
        }
        
        function verDetallesSolicitud(idSolicitud) {
            console.log('👁️ Cargando detalles de solicitud:', idSolicitud);
            
            // Buscar los datos de la solicitud en la tabla
            var $row = $('.request-row').filter(function() {
                return $(this).find('[onclick*="' + idSolicitud + '"]').length > 0;
            });
            
            if ($row.length === 0) {
                showError('No se encontraron los datos de la solicitud');
                return;
            }
            
            // Extraer datos de la fila
            var userData = $row.find('.user-info h6').text();
            var userEmail = $row.find('.user-info .username').text();
            var userAvatar = $row.find('.user-avatar').text();
            var status = $row.find('.status-badge').text().trim();
            var statusClass = $row.find('.status-badge').attr('class').split(' ').find(function(c) { 
                return c.indexOf('status-') === 0; 
            });
            var message = $row.find('.message-text').text() || 'Sin mensaje';
            var requestDate = $row.find('.date-cell').first().text().replace(/\s+/g, ' ').trim();
            var adminName = $row.find('.admin-name').text() || null;
            var adminUsername = $row.find('.admin-username').text() || null;
            var responseDate = $row.find('.date-cell').last().text().replace(/\s+/g, ' ').trim();
            var hasResponse = adminName && adminName !== '-';
            
            // Construir el modal
            var modalHtml = '<div class="modal fade" id="detallesModal" tabindex="-1" role="dialog" aria-hidden="true">' +
                '<div class="modal-dialog modal-lg modal-dialog-centered" role="document">' +
                    '<div class="modal-content">' +
                        '<!-- Header -->' +
                        '<div class="modal-header bg-info text-white">' +
                            '<h5 class="modal-title">' +
                                '<i class="fas fa-eye"></i> Detalles de Solicitud' +
                            '</h5>' +
                            '<button type="button" class="close text-white" data-dismiss="modal" style="opacity: 0.8;">' +
                                '<span>&times;</span>' +
                            '</button>' +
                        '</div>' +
                        
                        '<!-- Body -->' +
                        '<div class="modal-body">' +
                            '<!-- Info del Usuario -->' +
                            '<div class="detail-section">' +
                                '<h6 class="section-title">' +
                                    '<i class="fas fa-user"></i> Información del Solicitante' +
                                '</h6>' +
                                '<div class="user-detail-card">' +
                                    '<div class="user-avatar-large">' + userAvatar + '</div>' +
                                    '<div class="user-detail-info">' +
                                        '<h5>' + userData + '</h5>' +
                                        '<p class="text-muted">' + userEmail + '</p>' +
                                        '<span class="status-badge ' + statusClass + '">' + status + '</span>' +
                                    '</div>' +
                                '</div>' +
                            '</div>' +
                            
                            '<!-- Mensaje de Solicitud -->' +
                            '<div class="detail-section">' +
                                '<h6 class="section-title">' +
                                    '<i class="fas fa-comment"></i> Mensaje de Solicitud' +
                                '</h6>' +
                                '<div class="message-detail-card">' +
                                    '<div class="message-content">' + message + '</div>' +
                                    '<div class="message-meta">' +
                                        '<i class="fas fa-calendar"></i> ' + requestDate +
                                    '</div>' +
                                '</div>' +
                            '</div>' +
                            
                            '<!-- Timeline -->' +
                            '<div class="detail-section">' +
                                '<h6 class="section-title">' +
                                    '<i class="fas fa-clock"></i> Cronología' +
                                '</h6>' +
                                '<div class="timeline">' +
                                    '<div class="timeline-item">' +
                                        '<div class="timeline-marker bg-primary"></div>' +
                                        '<div class="timeline-content">' +
                                            '<h6>Solicitud Enviada</h6>' +
                                            '<p>' + requestDate + '</p>' +
                                            '<small class="text-muted">El usuario envió su solicitud de membresía</small>' +
                                        '</div>' +
                                    '</div>';
            
            // Agregar timeline de respuesta
            if (hasResponse) {
                var markerClass = status === 'APROBADA' ? 'bg-success' : 'bg-danger';
                modalHtml += '<div class="timeline-item">' +
                                '<div class="timeline-marker ' + markerClass + '"></div>' +
                                '<div class="timeline-content">' +
                                    '<h6>Solicitud ' + status + '</h6>' +
                                    '<p>' + responseDate + '</p>' +
                                    '<small class="text-muted">Respondida por ' + adminName + ' (' + adminUsername + ')</small>' +
                                '</div>' +
                            '</div>';
            } else {
                modalHtml += '<div class="timeline-item">' +
                                '<div class="timeline-marker bg-warning"></div>' +
                                '<div class="timeline-content">' +
                                    '<h6>Pendiente de Revisión</h6>' +
                                    '<small class="text-muted">Esperando respuesta de los administradores</small>' +
                                '</div>' +
                            '</div>';
            }
            
            modalHtml += '</div>' +
                        '</div>' +
                        
                        '<!-- Acciones Rápidas -->' +
                        '<div class="detail-section">' +
                            '<h6 class="section-title">' +
                                '<i class="fas fa-tools"></i> Acciones Rápidas' +
                            '</h6>' +
                            '<div class="quick-actions">' +
                                '<a href="mailto:' + userEmail.replace('@', '') + '" class="btn btn-outline-primary btn-sm">' +
                                    '<i class="fas fa-envelope"></i> Enviar Email' +
                                '</a>' +
                                '<button class="btn btn-outline-secondary btn-sm" onclick="copiarDetalles(' + idSolicitud + ')">' +
                                    '<i class="fas fa-copy"></i> Copiar Info' +
                                '</button>';
            
            // Agregar botones de aprobación si está pendiente
            if (status === 'PENDIENTE') {
                modalHtml += '<button class="btn btn-success btn-sm" onclick="aprobarDesdeDetalle(' + idSolicitud + ')">' +
                                '<i class="fas fa-check"></i> Aprobar' +
                            '</button>' +
                            '<button class="btn btn-danger btn-sm" onclick="rechazarDesdeDetalle(' + idSolicitud + ')">' +
                                '<i class="fas fa-times"></i> Rechazar' +
                            '</button>';
            }
            
            modalHtml += '</div>' +
                        '</div>' +
                    '</div>' +
                    
                    '<!-- Footer -->' +
                    '<div class="modal-footer">' +
                        '<button type="button" class="btn btn-secondary" data-dismiss="modal">' +
                            '<i class="fas fa-times"></i> Cerrar' +
                        '</button>' +
                    '</div>' +
                '</div>' +
            '</div>' +
        '</div>';
            
            // Agregar estilos CSS
            var modalStyles = '<style>' +
                '.detail-section {' +
                    'margin-bottom: 25px;' +
                    'padding-bottom: 20px;' +
                    'border-bottom: 1px solid #f1f3f4;' +
                '}' +
                
                '.detail-section:last-child {' +
                    'border-bottom: none;' +
                    'margin-bottom: 0;' +
                '}' +
                
                '.section-title {' +
                    'color: #495057;' +
                    'font-weight: 600;' +
                    'margin-bottom: 15px;' +
                    'display: flex;' +
                    'align-items: center;' +
                    'gap: 8px;' +
                '}' +
                
                '.user-detail-card {' +
                    'display: flex;' +
                    'align-items: center;' +
                    'gap: 20px;' +
                    'padding: 20px;' +
                    'background: #f8f9fa;' +
                    'border-radius: 10px;' +
                '}' +
                
                '.user-avatar-large {' +
                    'width: 60px;' +
                    'height: 60px;' +
                    'border-radius: 50%;' +
                    'background: linear-gradient(135deg, #007bff, #6610f2);' +
                    'display: flex;' +
                    'align-items: center;' +
                    'justify-content: center;' +
                    'color: white;' +
                    'font-weight: 700;' +
                    'font-size: 1.5rem;' +
                    'flex-shrink: 0;' +
                '}' +
                
                '.user-detail-info h5 {' +
                    'margin: 0 0 5px 0;' +
                    'color: #333;' +
                '}' +
                
                '.user-detail-info p {' +
                    'margin: 0 0 10px 0;' +
                '}' +
                
                '.message-detail-card {' +
                    'background: #f8f9fa;' +
                    'border-radius: 10px;' +
                    'padding: 20px;' +
                    'border-left: 4px solid #007bff;' +
                '}' +
                
                '.message-content {' +
                    'font-size: 14px;' +
                    'line-height: 1.6;' +
                    'color: #333;' +
                    'margin-bottom: 10px;' +
                    'white-space: pre-wrap;' +
                '}' +
                
                '.message-meta {' +
                    'font-size: 12px;' +
                    'color: #6c757d;' +
                '}' +
                
                '.timeline {' +
                    'position: relative;' +
                    'padding-left: 30px;' +
                '}' +
                
                '.timeline::before {' +
                    'content: "";' +
                    'position: absolute;' +
                    'left: 10px;' +
                    'top: 0;' +
                    'bottom: 0;' +
                    'width: 2px;' +
                    'background: #e9ecef;' +
                '}' +
                
                '.timeline-item {' +
                    'position: relative;' +
                    'margin-bottom: 20px;' +
                '}' +
                
                '.timeline-marker {' +
                    'position: absolute;' +
                    'left: -25px;' +
                    'top: 5px;' +
                    'width: 12px;' +
                    'height: 12px;' +
                    'border-radius: 50%;' +
                    'border: 2px solid white;' +
                    'box-shadow: 0 0 0 2px #e9ecef;' +
                '}' +
                
                '.timeline-content h6 {' +
                    'margin: 0 0 5px 0;' +
                    'font-weight: 600;' +
                    'color: #333;' +
                '}' +
                
                '.timeline-content p {' +
                    'margin: 0 0 5px 0;' +
                    'font-size: 14px;' +
                    'color: #495057;' +
                '}' +
                
                '.quick-actions {' +
                    'display: flex;' +
                    'gap: 10px;' +
                    'flex-wrap: wrap;' +
                '}' +
                
                '.quick-actions .btn {' +
                    'font-size: 12px;' +
                '}' +
            '</style>';
            
            // Remover modal anterior si existe
            $('#detallesModal').remove();
            
            // Agregar estilos y modal al DOM
            if ($('#modal-details-styles').length === 0) {
                $('head').append('<div id="modal-details-styles">' + modalStyles + '</div>');
            }
            
            $('body').append(modalHtml);
            $('#detallesModal').modal('show');
            
            // Cleanup al cerrar
            $('#detallesModal').on('hidden.bs.modal', function() {
                $(this).remove();
            });
        }
        
        function copiarDetalles(idSolicitud) {
            var $row = $('.request-row').filter(function() {
                return $(this).find('[onclick*="' + idSolicitud + '"]').length > 0;
            });
            
            var userData = $row.find('.user-info h6').text();
            var userEmail = $row.find('.user-info .username').text();
            var status = $row.find('.status-badge').text().trim();
            var message = $row.find('.message-text').text() || 'Sin mensaje';
            var requestDate = $row.find('.date-cell').first().text().replace(/\s+/g, ' ').trim();
            
            var detalles = 'Solicitud de Membresía - ID: ' + idSolicitud + '\n' +
                '=======================================\n' +
                'Usuario: ' + userData + '\n' +
                'Email: ' + userEmail + '\n' +
                'Estado: ' + status + '\n' +
                'Fecha: ' + requestDate + '\n\n' +
                'Mensaje:\n' + message;
            
            if (navigator.clipboard && navigator.clipboard.writeText) {
                navigator.clipboard.writeText(detalles).then(function() {
                    showSuccess('Detalles copiados al portapapeles');
                }).catch(function() {
                    showError('No se pudo copiar al portapapeles');
                });
            } else {
                // Fallback para navegadores sin clipboard API
                var textArea = document.createElement('textarea');
                textArea.value = detalles;
                document.body.appendChild(textArea);
                textArea.select();
                try {
                    document.execCommand('copy');
                    showSuccess('Detalles copiados al portapapeles');
                } catch (err) {
                    showError('No se pudo copiar al portapapeles');
                }
                document.body.removeChild(textArea);
            }
        }
        
        function aprobarDesdeDetalle(idSolicitud) {
            $('#detallesModal').modal('hide');
            // Buscar el username desde la tabla para la función existente
            var $row = $('.request-row').filter(function() {
                return $(this).find('[onclick*="' + idSolicitud + '"]').length > 0;
            });
            var username = $row.find('.user-info .username').text().replace('@', '');
            aprobarSolicitud(idSolicitud, username);
        }
        
        function rechazarDesdeDetalle(idSolicitud) {
            $('#detallesModal').modal('hide');
            // Buscar el username desde la tabla para la función existente
            var $row = $('.request-row').filter(function() {
                return $(this).find('[onclick*="' + idSolicitud + '"]').length > 0;
            });
            var username = $row.find('.user-info .username').text().replace('@', '');
            rechazarSolicitud(idSolicitud, username);
        }
        
        function exportarCSV() {
            const rows = [];
            const headers = ['Usuario', 'Email', 'Estado', 'Mensaje', 'Fecha Solicitud', 'Respondido Por', 'Fecha Respuesta'];
            rows.push(headers);
            
            $('.request-row:visible').each(function() {
                const $row = $(this);
                const userData = $row.find('.user-info h6').text();
                const userEmail = $row.find('.user-info .username').text();
                const status = $row.find('.status-badge').text();
                const message = $row.find('.message-text').text() || 'Sin mensaje';
                const requestDate = $row.find('.date-cell').first().text().replace(/\s+/g, ' ').trim();
                const adminName = $row.find('.admin-name').text() || '-';
                const responseDate = $row.find('.date-cell').last().text().replace(/\s+/g, ' ').trim();
                
                rows.push([userData, userEmail, status, message, requestDate, adminName, responseDate]);
            });
            
            // Crear CSV
            const csvContent = rows.map(row => 
                row.map(field => '"' + String(field).replace(/"/g, '""') + '"').join(',')
            ).join('\n');
            
            // Descargar
            const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
            const link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = 'solicitudes_<%= comunidad.getNombre().replaceAll("[^a-zA-Z0-9]", "_") %>_' + 
                           new Date().toISOString().split('T')[0] + '.csv';
            link.click();
            
            showSuccess('Archivo CSV descargado exitosamente');
        }
        
        // Sistema de notificaciones
        function showNotification(message, type, duration) {
            duration = duration || 4000;
            
            var config = {
                success: { icon: 'fa-check-circle', bgColor: '#28a745', textColor: '#fff', title: '¡Éxito!' },
                error: { icon: 'fa-exclamation-triangle', bgColor: '#dc3545', textColor: '#fff', title: 'Error' },
                warning: { icon: 'fa-exclamation-circle', bgColor: '#ffc107', textColor: '#212529', title: 'Atención' },
                info: { icon: 'fa-info-circle', bgColor: '#17a2b8', textColor: '#fff', title: 'Información' }
            };
            
            var setting = config[type] || config.info;
            var toastId = 'toast-' + Date.now();
            
            if ($('#toast-container').length === 0) {
                $('body').append('<div id="toast-container" style="position: fixed; top: 20px; right: 20px; z-index: 9999; max-width: 350px;"></div>');
            }
            
            var toast = '<div id="' + toastId + '" class="toast-notification" style="background: ' + setting.bgColor + '; color: ' + setting.textColor + '; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); margin-bottom: 10px; overflow: hidden; transform: translateX(100%); transition: all 0.3s ease; position: relative;">' +
                '<div style="padding: 16px; display: flex; align-items: center; gap: 12px;">' +
                    '<div style="width: 40px; height: 40px; border-radius: 50%; background: rgba(255,255,255,0.2); display: flex; align-items: center; justify-content: center; flex-shrink: 0;">' +
                        '<i class="fas ' + setting.icon + '" style="font-size: 18px;"></i>' +
                    '</div>' +
                    '<div style="flex: 1; min-width: 0;">' +
                        '<div style="font-weight: 600; font-size: 14px; margin-bottom: 2px;">' + setting.title + '</div>' +
                        '<div style="font-size: 13px; opacity: 0.9; word-wrap: break-word;">' + message + '</div>' +
                    '</div>' +
                '</div>' +
            '</div>';
            
            $('#toast-container').append(toast);
            
            setTimeout(function() {
                $('#' + toastId).css('transform', 'translateX(0)');
            }, 10);
            
            setTimeout(function() {
                $('#' + toastId).css({ 'transform': 'translateX(100%)', 'opacity': '0' });
                setTimeout(function() {
                    $('#' + toastId).remove();
                    if ($('#toast-container .toast-notification').length === 0) {
                        $('#toast-container').remove();
                    }
                }, 300);
            }, duration);
        }
        
        function showSuccess(message) { showNotification(message, 'success'); }
        function showError(message) { showNotification(message, 'error'); }
        function showWarning(message) { showNotification(message, 'warning'); }
        function showInfo(message) { showNotification(message, 'info'); }
        
        // Atajos de teclado
        $(document).on('keydown', function(e) {
            // Ctrl + F para buscar
            if (e.ctrlKey && e.key === 'f') {
                e.preventDefault();
                $('#searchRequests').focus();
            }
            
            // ESC para limpiar búsqueda
            if (e.key === 'Escape') {
                $('#searchRequests').val('');
                $('#dateFilter').val('');
                $('.tab-btn[data-filter="all"]').click();
            }
        });
        
        // Mostrar estadísticas en consola (para debugging)
        console.log('📊 Estadísticas de solicitudes cargadas:', {
            total: <%= solicitudes.size() %>,
            pendientes: <%= solicitudes.stream().mapToInt(s -> s.esPendiente() ? 1 : 0).sum() %>,
            aprobadas: <%= solicitudes.stream().mapToInt(s -> s.esAprobada() ? 1 : 0).sum() %>,
            rechazadas: <%= solicitudes.stream().mapToInt(s -> s.esRechazada() ? 1 : 0).sum() %>
        });
    </script>
</body>
</html>