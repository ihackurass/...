<%-- 
    Document   : members
    Created on : Lista de Miembros de Comunidad
    Author     : Sistema
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="pe.aquasocial.entity.Comunidad"%>
<%@page import="pe.aquasocial.entity.Usuario"%>
<%@page import="pe.aquasocial.entity.ComunidadMiembro"%>

<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuarioLogueado");
    Comunidad comunidad = (Comunidad) request.getAttribute("comunidad");
    List<ComunidadMiembro> miembros = (List<ComunidadMiembro>) request.getAttribute("miembros");
    Integer totalMiembros = (Integer) request.getAttribute("totalMiembros");
    Boolean esMiembro = (Boolean) request.getAttribute("esMiembro");
    Boolean esAdmin = (Boolean) request.getAttribute("esAdmin");
    Boolean esCreador = (Boolean) request.getAttribute("esCreador");
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
    
    if (totalMiembros == null) totalMiembros = 0;
    if (esMiembro == null) esMiembro = false;
    if (esAdmin == null) esAdmin = false;
    if (esCreador == null) esCreador = false;
%>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Miembros - <%= comunidad != null ? comunidad.getNombre() : "Comunidad" %></title>
    <jsp:include page="/components/css_imports.jsp" />
    
    <style>
        .main-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header-section {
            background: linear-gradient(135deg, #007bff, #28a745);
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
        
        .community-header {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        .community-avatar-large {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: rgba(255,255,255,0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2rem;
            font-weight: bold;
            border: 3px solid rgba(255,255,255,0.3);
        }
        
        .community-info h1 {
            margin: 0;
            font-size: 2rem;
            font-weight: 600;
        }
        
        .community-handle {
            opacity: 0.9;
            font-size: 1.1rem;
            margin: 5px 0;
        }
        
        .member-stats {
            display: flex;
            gap: 30px;
            margin-top: 15px;
        }
        
        .stat-item {
            text-align: center;
        }
        
        .stat-number {
            display: block;
            font-size: 1.5rem;
            font-weight: bold;
        }
        
        .stat-label {
            font-size: 0.9rem;
            opacity: 0.9;
        }
        
        .content-section {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            border: 1px solid #f0f0f0;
        }
        
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f8f9fa;
        }
        
        .section-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: #333;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .section-title i {
            color: #007bff;
        }
        
        .search-filter-bar {
            display: flex;
            gap: 15px;
            align-items: center;
        }
        
        .search-box {
            position: relative;
        }
        
        .search-box input {
            padding: 10px 15px 10px 40px;
            border: 2px solid #e9ecef;
            border-radius: 25px;
            width: 250px;
            font-size: 14px;
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
            min-width: 120px;
        }
        
        .filter-dropdown:focus {
            border-color: #007bff;
            outline: none;
        }
        
        .members-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 20px;
        }
        
        .member-card {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 20px;
            transition: all 0.3s ease;
            border: 2px solid transparent;
            position: relative;
        }
        
        .member-card:hover {
            background: #e9ecef;
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }
        
        .member-card.admin {
            border-color: #17a2b8;
            background: linear-gradient(135deg, #f8f9fa, #e3f2fd);
        }
        
        .member-header {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 15px;
        }
        
        .member-avatar {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: linear-gradient(135deg, #007bff, #28a745);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 1.2rem;
            position: relative;
        }
        
        .member-avatar.verified::after {
            content: '✓';
            position: absolute;
            bottom: -2px;
            right: -2px;
            background: #28a745;
            color: white;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            font-size: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 2px solid white;
        }
        
        .member-info h5 {
            margin: 0 0 5px 0;
            font-size: 1.1rem;
            color: #333;
            font-weight: 600;
        }
        
        .member-username {
            color: #6c757d;
            font-size: 0.9rem;
            margin-bottom: 5px;
        }
        
        .member-role {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 10px;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .role-admin {
            background: #17a2b8;
            color: white;
        }
        
        .role-seguidor {
            background: #28a745;
            color: white;
        }
        
        .member-details {
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #dee2e6;
        }
        
        .detail-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 8px;
            font-size: 0.9rem;
        }
        
        .detail-label {
            color: #6c757d;
            font-weight: 500;
        }
        
        .detail-value {
            color: #333;
            font-weight: 600;
        }
        
        .member-actions {
            margin-top: 15px;
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        
        .btn-action {
            padding: 6px 12px;
            border: none;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        
        .btn-promote {
            background: #17a2b8;
            color: white;
        }
        
        .btn-promote:hover {
            background: #138496;
        }
        
        .btn-demote {
            background: #ffc107;
            color: #333;
        }
        
        .btn-demote:hover {
            background: #e0a800;
        }
        
        .btn-remove {
            background: #dc3545;
            color: white;
        }
        
        .btn-remove:hover {
            background: #c82333;
        }
        
        .btn-message {
            background: #6c757d;
            color: white;
        }
        
        .btn-message:hover {
            background: #5a6268;
        }
        
        .no-members {
            text-align: center;
            padding: 60px 20px;
            color: #6c757d;
        }
        
        .no-members i {
            font-size: 4rem;
            margin-bottom: 20px;
            opacity: 0.5;
        }
        
        .no-members h3 {
            margin-bottom: 10px;
            color: #495057;
        }
        
        .alert-custom {
            padding: 15px 20px;
            border-radius: 10px;
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
            text-decoration: none;
            border-radius: 5px;
            transition: all 0.3s ease;
        }
        
        .page-btn:hover, .page-btn.active {
            background: #007bff;
            color: white;
            text-decoration: none;
        }
        
        @media (max-width: 768px) {
            .members-grid {
                grid-template-columns: 1fr;
            }
            
            .search-filter-bar {
                flex-direction: column;
                align-items: stretch;
            }
            
            .search-box input {
                width: 100%;
            }
            
            .member-stats {
                justify-content: center;
                gap: 20px;
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
                
                <!-- Header de la comunidad -->
                <div class="header-section">
                    <div class="header-content">
                        <!-- Breadcrumb -->
                        <nav class="breadcrumb-custom">
                            <a href="ComunidadServlet">Comunidades</a> &gt; 
                            <a href="ComunidadServlet?action=view&id=<%= comunidad != null ? comunidad.getIdComunidad() : "" %>">
                                <%= comunidad != null ? comunidad.getNombre() : "Comunidad" %>
                            </a> &gt; 
                            <span>Miembros</span>
                        </nav>
                        
                        <div class="community-header">
                            <div class="community-avatar-large">
                                <%= comunidad != null ? comunidad.getNombre().substring(0,1).toUpperCase() : "C" %>
                            </div>
                            <div class="community-info">
                                <h1><%= comunidad != null ? comunidad.getNombre() : "Comunidad" %></h1>
                                <% if (comunidad != null && comunidad.getUsername() != null && !comunidad.getUsername().trim().isEmpty()) { %>
                                    <div class="community-handle">@<%= comunidad.getUsername() %></div>
                                <% } %>
                                
                                <div class="member-stats">
                                    <div class="stat-item">
                                        <span class="stat-number"><%= totalMiembros %></span>
                                        <span class="stat-label">Miembros</span>
                                    </div>
                                    <div class="stat-item">
                                        <span class="stat-number">
                                            <% 
                                                int admins = 0;
                                                if (miembros != null) {
                                                    for (ComunidadMiembro m : miembros) {
                                                        if ("admin".equals(m.getRol())) {
                                                            admins++;
                                                        }
                                                    }
                                                }
                                            %>
                                            <%= admins %>
                                        </span>
                                        <span class="stat-label">Administradores</span>
                                    </div>
                                    <div class="stat-item">
                                        <span class="stat-number">
                                            <%= comunidad != null && comunidad.isEsPublica() ? "Pública" : "Privada" %>
                                        </span>
                                        <span class="stat-label">Privacidad</span>
                                    </div>
                                </div>
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
                    
                    <!-- Header de la sección -->
                    <div class="section-header">
                        <div class="section-title">
                            <i class="fas fa-users"></i>
                            Miembros de la Comunidad
                            <span style="font-weight: 400; color: #6c757d; font-size: 1rem;">(<%= totalMiembros %>)</span>
                        </div>
                        
                        <!-- Filtros y búsqueda -->
                        <div class="search-filter-bar">
                            <div class="search-box">
                                <i class="fas fa-search"></i>
                                <input type="text" id="searchMembers" placeholder="Buscar miembros...">
                            </div>
                            <select class="filter-dropdown" id="filterRole">
                                <option value="">Todos los roles</option>
                                <option value="admin">Administradores</option>
                                <option value="seguidor">Seguidores</option>
                            </select>
                        </div>
                    </div>
                    
                    <!-- Grid de miembros -->
                    <% if (miembros != null && !miembros.isEmpty()) { %>
                        <div class="members-grid" id="membersGrid">
                            <% for (ComunidadMiembro miembro : miembros) { %>
                                <div class="member-card <%= miembro.getRol() %>" data-role="<%= miembro.getRol() %>" data-name="<%= miembro.getNombreUsuario() != null ? miembro.getNombreUsuario().toLowerCase() : "" %>">
                                    
                                    <div class="member-header">
                                        <div class="member-avatar <%= miembro.isUsuarioVerificado() ? "verified" : "" %>">
                                            <%= miembro.getNombreUsuario() != null ? 
                                                miembro.getNombreUsuario().substring(0,1).toUpperCase() : "U" %>
                                        </div>
                                        <div class="member-info">
                                            <h5><%= miembro.getNombreCompletoUsuario() != null ? miembro.getNombreCompletoUsuario() : "Usuario" %></h5>
                                            <div class="member-username">@<%= miembro.getNombreUsuario() != null ? miembro.getNombreUsuario() : "usuario" %></div>
                                            <div class="member-role role-<%= miembro.getRol() %>">
                                                <% if ("admin".equals(miembro.getRol())) { %>
                                                    <i class="fas fa-shield-alt"></i>Admin
                                                <% } else { %>
                                                    <i class="fas fa-user"></i>Seguidor
                                                <% } %>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="member-details">
                                        <div class="detail-row">
                                            <span class="detail-label">Se unió:</span>
                                            <span class="detail-value">
                                                <% if (miembro.getFechaUnion() != null) { %>
                                                    <%= miembro.getFechaUnion().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")) %>
                                                <% } else { %>
                                                    Fecha desconocida
                                                <% } %>
                                            </span>
                                        </div>
                                        <div class="detail-row">
                                            <span class="detail-label">Estado:</span>
                                            <span class="detail-value">
                                                <% if (miembro.isUsuarioVerificado()) { %>
                                                    <i class="fas fa-check-circle text-success"></i> Verificado
                                                <% } else { %>
                                                    <i class="fas fa-clock text-warning"></i> No verificado
                                                <% } %>
                                            </span>
                                        </div>
                                        <% if (miembro.isUsuarioPrivilegiado()) { %>
                                            <div class="detail-row">
                                                <span class="detail-label">Privilegios:</span>
                                                <span class="detail-value">
                                                    <i class="fas fa-star text-warning"></i> Usuario privilegiado
                                                </span>
                                            </div>
                                        <% } %>
                                    </div>
                                    
                                    <!-- Acciones de administración -->
                                    <% if (usuarioActual != null && (esCreador || esAdmin) && 
                                           !miembro.getNombreUsuario().equals(usuarioActual.getUsername())) { %>
                                        <div class="member-actions">
                                            <% if (esCreador) { %>
                                                <% if ("seguidor".equals(miembro.getRol())) { %>
                                                    <button class="btn-action btn-promote" 
                                                            onclick="cambiarRol(<%= miembro.getIdUsuario() %>, 'admin')"
                                                            title="Promover a administrador">
                                                        <i class="fas fa-arrow-up"></i>Promover
                                                    </button>
                                                <% } else if ("admin".equals(miembro.getRol())) { %>
                                                    <button class="btn-action btn-demote" 
                                                            onclick="cambiarRol(<%= miembro.getIdUsuario() %>, 'seguidor')"
                                                            title="Degradar a seguidor">
                                                        <i class="fas fa-arrow-down"></i>Degradar
                                                    </button>
                                                <% } %>
                                                <button class="btn-action btn-remove" 
                                                        onclick="expulsarMiembro(<%= miembro.getIdUsuario() %>, '<%= miembro.getNombreUsuario() %>')"
                                                        title="Expulsar de la comunidad">
                                                    <i class="fas fa-user-times"></i>Expulsar
                                                </button>
                                            <% } else if (esAdmin && "seguidor".equals(miembro.getRol())) { %>
                                                <button class="btn-action btn-remove" 
                                                        onclick="expulsarMiembro(<%= miembro.getIdUsuario() %>, '<%= miembro.getNombreUsuario() %>')"
                                                        title="Expulsar de la comunidad">
                                                    <i class="fas fa-user-times"></i>Expulsar
                                                </button>
                                            <% } %>
                                            <button class="btn-action btn-message" 
                                                    onclick="enviarMensaje('<%= miembro.getNombreUsuario() %>')"
                                                    title="Enviar mensaje">
                                                <i class="fas fa-envelope"></i>Mensaje
                                            </button>
                                        </div>
                                    <% } %>
                                </div>
                            <% } %>
                        </div>
                        
                    <% } else { %>
                        <div class="no-members">
                            <i class="fas fa-users"></i>
                            <h3>No hay miembros para mostrar</h3>
                            <p>Esta comunidad aún no tiene miembros.</p>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </main>
    
    <jsp:include page="/components/js_imports.jsp" />
    
    <script>
        $(document).ready(function() {
            
            // Funcionalidad de búsqueda en tiempo real
            $('#searchMembers').on('input', function() {
                const searchTerm = $(this).val().toLowerCase();
                filterMembers();
            });
            
            // Filtro por rol
            $('#filterRole').on('change', function() {
                filterMembers();
            });
            
            function filterMembers() {
                const searchTerm = $('#searchMembers').val().toLowerCase();
                const selectedRole = $('#filterRole').val();
                
                $('.member-card').each(function() {
                    const memberName = $(this).data('name');
                    const memberRole = $(this).data('role');
                    
                    const matchesSearch = memberName.includes(searchTerm);
                    const matchesRole = selectedRole === '' || memberRole === selectedRole;
                    
                    if (matchesSearch && matchesRole) {
                        $(this).show();
                    } else {
                        $(this).hide();
                    }
                });
            }
        });
        
        // Funciones de administración
        function cambiarRol(idUsuario, nuevoRol) {
            const action = nuevoRol === 'admin' ? 'promover' : 'degradar';
            const tituloModal = nuevoRol === 'admin' ? 'Promover Usuario' : 'Degradar Administrador';
            const mensaje = nuevoRol === 'admin' ? 
                'Este usuario obtendrá permisos de administrador en la comunidad.' : 
                'Este administrador perderá sus permisos y se convertirá en seguidor.';
            const colorHeader = nuevoRol === 'admin' ? 'bg-info' : 'bg-warning';
            const iconoModal = nuevoRol === 'admin' ? 'fas fa-arrow-up' : 'fas fa-arrow-down';
            const btnTexto = nuevoRol === 'admin' ? 'Promover' : 'Degradar';
            const btnColor = nuevoRol === 'admin' ? 'btn-info' : 'btn-warning';
            
            var modalHtml = '<div class="modal fade" id="modalCambiarRol" tabindex="-1" role="dialog">' +
                '<div class="modal-dialog modal-dialog-centered" role="document">' +
                    '<div class="modal-content">' +
                        '<div class="modal-header ' + colorHeader + ' text-white">' +
                            '<h5 class="modal-title">' +
                                '<i class="' + iconoModal + '"></i> ' + tituloModal +
                            '</h5>' +
                            '<button type="button" class="close text-white" data-dismiss="modal">' +
                                '<span>&times;</span>' +
                            '</button>' +
                        '</div>' +
                        '<div class="modal-body">' +
                            '<p class="mb-3">' + mensaje + '</p>' +
                            '<div class="alert alert-info">' +
                                '<i class="fas fa-info-circle"></i> ' +
                                'Esta acción tomará efecto inmediatamente.' +
                            '</div>' +
                        '</div>' +
                        '<div class="modal-footer">' +
                            '<button type="button" class="btn btn-secondary" data-dismiss="modal">' +
                                '<i class="fas fa-times"></i> Cancelar' +
                            '</button>' +
                            '<button type="button" class="btn ' + btnColor + '" id="btnConfirmarCambio">' +
                                '<i class="' + iconoModal + '"></i> ' + btnTexto +
                            '</button>' +
                        '</div>' +
                    '</div>' +
                '</div>' +
            '</div>';
            
            // Remover modal anterior si existe
            $('#modalCambiarRol').remove();
            
            // Agregar nuevo modal al DOM
            $('body').append(modalHtml);
            
            // Mostrar modal
            $('#modalCambiarRol').modal('show');
            
            // Manejar confirmación
            $('#btnConfirmarCambio').off('click').on('click', function() {
                // Determinar la acción correcta según el rol
                var actionName = nuevoRol === 'admin' ? 'promoteAdmin' : 'demoteAdmin';
                
                $.ajax({
                    url: 'ComunidadServlet',
                    type: 'POST',
                    data: {
                        action: actionName,
                        idUsuario: idUsuario,
                        idComunidad: <%= comunidad != null ? comunidad.getIdComunidad() : 0 %>
                    },
                    success: function(response) {
                        $('#modalCambiarRol').modal('hide');
                        if (response.success) {
                            showSuccess('Rol actualizado correctamente');
                            setTimeout(() => location.reload(), 1500);
                        } else {
                            showError(response.message || 'Error al cambiar el rol');
                        }
                    },
                    error: function() {
                        $('#modalCambiarRol').modal('hide');
                        showError('error', 'Error de conexión');
                    }
                });
            });
        }
        
        function expulsarMiembro(idUsuario, nombreUsuario) {
            var modalHtml = '<div class="modal fade" id="modalExpulsarMiembro" tabindex="-1" role="dialog">' +
                '<div class="modal-dialog modal-dialog-centered" role="document">' +
                    '<div class="modal-content">' +
                        '<div class="modal-header bg-danger text-white">' +
                            '<h5 class="modal-title">' +
                                '<i class="fas fa-user-times"></i> Expulsar Miembro' +
                            '</h5>' +
                            '<button type="button" class="close text-white" data-dismiss="modal">' +
                                '<span>&times;</span>' +
                            '</button>' +
                        '</div>' +
                        '<div class="modal-body">' +
                            '<p class="mb-3">' +
                                '¿Estás seguro de que deseas expulsar a <strong>' + escapeHtml(nombreUsuario) + '</strong> de la comunidad?' +
                            '</p>' +
                            '<div class="alert alert-warning">' +
                                '<i class="fas fa-exclamation-triangle"></i> ' +
                                'El usuario perderá acceso inmediatamente y deberá solicitar unirse nuevamente.' +
                            '</div>' +
                        '</div>' +
                        '<div class="modal-footer">' +
                            '<button type="button" class="btn btn-secondary" data-dismiss="modal">' +
                                '<i class="fas fa-times"></i> Cancelar' +
                            '</button>' +
                            '<button type="button" class="btn btn-danger" id="btnConfirmarExpulsion">' +
                                '<i class="fas fa-user-times"></i> Expulsar' +
                            '</button>' +
                        '</div>' +
                    '</div>' +
                '</div>' +
            '</div>';
            
            // Remover modal anterior si existe
            $('#modalExpulsarMiembro').remove();
            
            // Agregar nuevo modal al DOM
            $('body').append(modalHtml);
            
            // Mostrar modal
            $('#modalExpulsarMiembro').modal('show');
            
            // Manejar confirmación
            $('#btnConfirmarExpulsion').off('click').on('click', function() {
                $.ajax({
                    url: 'ComunidadServlet',
                    type: 'POST',
                    data: {
                        action: 'removeMember',
                        idUsuario: idUsuario,
                        idComunidad: <%= comunidad != null ? comunidad.getIdComunidad() : 0 %>
                    },
                    success: function(response) {
                        $('#modalExpulsarMiembro').modal('hide');
                        if (response.success) {
                            showSuccess('Usuario expulsado correctamente');
                            setTimeout(() => location.reload(), 1500);
                        } else {
                            showError('error', response.message || 'Error al expulsar usuario');
                        }
                    },
                    error: function() {
                        $('#modalExpulsarMiembro').modal('hide');
                        showError('error', 'Error de conexión');
                    }
                });
            });
        }
        
        function enviarMensaje(nombreUsuario) {
            // Redireccionar al sistema de mensajes o abrir modal
            alert(`Funcionalidad de mensajes para ${nombreUsuario} próximamente`);
        }
        
        function escapeHtml(text) {
            const map = {
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#039;'
            };
            return text.replace(/[&<>"']/g, function(m) { return map[m]; });
        }

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