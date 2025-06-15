<%-- 
    Document   : requests
    Created on : Gestión de Solicitudes de Membresía
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
    Boolean esCreador = (Boolean) request.getAttribute("esCreador");
    Boolean esAdmin = (Boolean) request.getAttribute("esAdmin");
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
    
    if (solicitudes == null) solicitudes = new java.util.ArrayList<>();
    if (esCreador == null) esCreador = false;
    if (esAdmin == null) esAdmin = false;
%>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Solicitudes - <%= comunidad != null ? comunidad.getNombre() : "Comunidad" %></title>
    <jsp:include page="/components/css_imports.jsp" />
    
    <style>
        .main-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header-section {
            background: linear-gradient(135deg, #6f42c1, #007bff);
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
        
        .requests-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 20px;
        }
        
        .requests-title h1 {
            margin: 0;
            font-size: 2rem;
            font-weight: 600;
        }
        
        .requests-stats {
            display: flex;
            gap: 20px;
        }
        
        .stat-item {
            text-align: center;
            background: rgba(255,255,255,0.1);
            padding: 15px;
            border-radius: 10px;
            min-width: 80px;
        }
        
        .stat-number {
            display: block;
            font-size: 1.5rem;
            font-weight: 700;
        }
        
        .stat-label {
            font-size: 0.875rem;
            opacity: 0.9;
        }
        
        .content-section {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }
        
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f8f9fa;
        }
        
        .section-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: #495057;
        }
        
        .filter-tabs {
            display: flex;
            gap: 10px;
        }
        
        .tab-btn {
            padding: 8px 16px;
            border: 2px solid #e9ecef;
            background: white;
            color: #6c757d;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 14px;
            font-weight: 600;
        }
        
        .tab-btn.active {
            background: #007bff;
            color: white;
            border-color: #007bff;
        }
        
        .tab-btn:hover {
            border-color: #007bff;
            color: #007bff;
        }
        
        .tab-btn.active:hover {
            color: white;
        }
        
        .requests-grid {
            display: grid;
            gap: 20px;
        }
        
        .request-card {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 20px;
            border-left: 4px solid #ffc107;
            transition: all 0.3s ease;
        }
        
        .request-card:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            transform: translateY(-2px);
        }
        
        .request-card.approved {
            border-left-color: #28a745;
        }
        
        .request-card.rejected {
            border-left-color: #dc3545;
        }
        
        .request-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 15px;
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .user-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: linear-gradient(135deg, #007bff, #6610f2);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 700;
            font-size: 1.2rem;
        }
        
        .user-details h5 {
            margin: 0;
            font-weight: 600;
            color: #333;
        }
        
        .user-details .username {
            color: #6c757d;
            font-size: 14px;
        }
        
        .request-status {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .status-pendiente {
            background: #fff3cd;
            color: #856404;
        }
        
        .status-aprobada {
            background: #d4edda;
            color: #155724;
        }
        
        .status-rechazada {
            background: #f8d7da;
            color: #721c24;
        }
        
        .request-message {
            background: white;
            padding: 15px;
            border-radius: 8px;
            margin: 15px 0;
            border: 1px solid #e9ecef;
        }
        
        .request-message h6 {
            margin: 0 0 10px 0;
            color: #495057;
            font-weight: 600;
        }
        
        .request-message p {
            margin: 0;
            color: #6c757d;
            line-height: 1.5;
        }
        
        .request-date {
            font-size: 12px;
            color: #999;
            margin-bottom: 10px;
        }
        
        .request-actions {
            display: flex;
            gap: 10px;
            margin-top: 15px;
            flex-wrap: wrap;
        }
        
        .btn-action {
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        
        .btn-approve {
            background: #28a745;
            color: white;
        }
        
        .btn-approve:hover {
            background: #218838;
        }
        
        .btn-reject {
            background: #dc3545;
            color: white;
        }
        
        .btn-reject:hover {
            background: #c82333;
        }
        
        .btn-view {
            background: #17a2b8;
            color: white;
        }
        
        .btn-view:hover {
            background: #138496;
        }
        
        .no-requests {
            text-align: center;
            padding: 60px 20px;
            color: #6c757d;
        }
        
        .no-requests i {
            font-size: 4rem;
            margin-bottom: 20px;
            opacity: 0.5;
        }
        
        .response-section {
            background: #e9ecef;
            border-radius: 8px;
            padding: 15px;
            margin-top: 15px;
        }
        
        .response-header {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 10px;
        }
        
        .response-admin {
            font-weight: 600;
            color: #495057;
        }
        
        .response-date {
            font-size: 12px;
            color: #6c757d;
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
        
        @media (max-width: 768px) {
            .main-container {
                padding: 15px;
            }
            
            .requests-header {
                flex-direction: column;
                align-items: stretch;
            }
            
            .requests-stats {
                justify-content: center;
            }
            
            .section-header {
                flex-direction: column;
                align-items: stretch;
                gap: 15px;
            }
            
            .filter-tabs {
                justify-content: center;
                flex-wrap: wrap;
            }
            
            .user-info {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
        }
    .btn-with-icon {
        display: inline-flex;
        align-items: center;
        gap: 8px;
    }

    .btn-with-icon i {
        font-size: 0.9em;
        flex-shrink: 0; /* Evita que el icono se comprima */
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
                            <span>Solicitudes</span>
                        </nav>
                        
                        <div class="requests-header">
                            <div class="requests-title">
                                <h1><i class="fas fa-clipboard-list"></i> Gestión de Solicitudes</h1>
                                <p style="margin: 5px 0 0 0; opacity: 0.9;">
                                    <%= comunidad.getNombre() %>
                                </p>
                            </div>
                            
                            <div class="requests-stats">
                                <div class="stat-item">
                                    <span class="stat-number"><%= solicitudes.size() %></span>
                                    <span class="stat-label">Total</span>
                                </div>
                                <div class="stat-item">
                                    <span class="stat-number">
                                        <%= solicitudes.stream().mapToInt(s -> s.esPendiente() ? 1 : 0).sum() %>
                                    </span>
                                    <span class="stat-label">Pendientes</span>
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
                            <i class="fas fa-inbox"></i>
                            Solicitudes Pendientes
                            <span style="font-weight: 400; color: #6c757d; font-size: 1rem;">(<%= solicitudes.size() %>)</span>
                        </div>

                        <!-- Sin filtros, solo botón para ver historial -->
                        <div class="action-buttons">
                            <% if (esCreador) { %>
                                <a href="ComunidadServlet?action=manageRequests&id=<%= comunidad.getIdComunidad() %>" 
                                   class="btn btn-outline-secondary">
                                    <i class="fas fa-history"></i> Ver Historial Completo
                                </a>
                            <% } %>
                        </div>
                    </div>
                    
                    <!-- Grid de solicitudes -->
                    <% if (!solicitudes.isEmpty()) { %>
                        <div class="requests-grid" id="requestsGrid">
                            <% 
                                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
                                for (SolicitudMembresia solicitud : solicitudes) { 
                            %>
                                <div class="request-card <%= solicitud.getEstado() %>" data-status="<%= solicitud.getEstado() %>">
                                    <!-- Header de la solicitud -->
                                    <div class="request-header">
                                        <div class="user-info">
                                            <div class="user-avatar">
                                                <%= solicitud.getUsernameUsuario() != null ? 
                                                    solicitud.getUsernameUsuario().substring(0,1).toUpperCase() : "U" %>
                                            </div>
                                            <div class="user-details">
                                                <h5><%= solicitud.getNombreCompletoUsuario() != null ? 
                                                        solicitud.getNombreCompletoUsuario() : "Usuario" %></h5>
                                                <div class="username">@<%= solicitud.getUsernameUsuario() != null ? 
                                                                          solicitud.getUsernameUsuario() : "username" %></div>
                                            </div>
                                        </div>
                                        
                                        <div class="request-status status-<%= solicitud.getEstado() %>">
                                            <%= solicitud.getEstadoDisplay() %>
                                        </div>
                                    </div>
                                    
                                    <!-- Fecha de solicitud -->
                                    <div class="request-date">
                                        <i class="fas fa-calendar"></i>
                                        Solicitado el <%= solicitud.getFechaSolicitud() != null ? 
                                                         solicitud.getFechaSolicitud().format(formatter) : "Fecha no disponible" %>
                                    </div>
                                    
                                    <!-- Mensaje del usuario -->
                                    <% if (solicitud.getMensajeSolicitud() != null && !solicitud.getMensajeSolicitud().trim().isEmpty()) { %>
                                        <div class="request-message">
                                            <h6><i class="fas fa-comment"></i> Mensaje del solicitante:</h6>
                                            <p><%= solicitud.getMensajeSolicitud() %></p>
                                        </div>
                                    <% } %>
                                    
                                    <!-- Respuesta del admin (si existe) -->
                                    <% if (solicitud.tieneRespuesta()) { %>
                                        <div class="response-section">
                                            <div class="response-header">
                                                <i class="fas fa-reply"></i>
                                                <span class="response-admin">
                                                    Respondido por @<%= solicitud.getUsernameAdmin() != null ? 
                                                                       solicitud.getUsernameAdmin() : "admin" %>
                                                </span>
                                                <span class="response-date">
                                                    el <%= solicitud.getFechaRespuesta() != null ? 
                                                           solicitud.getFechaRespuesta().format(formatter) : "fecha no disponible" %>
                                                </span>
                                            </div>
                                            <% if (solicitud.getMensajeRespuesta() != null && !solicitud.getMensajeRespuesta().trim().isEmpty()) { %>
                                                <p style="margin: 0; color: #495057;"><%= solicitud.getMensajeRespuesta() %></p>
                                            <% } %>
                                        </div>
                                    <% } %>
                                    
                                    <!-- Acciones (solo para solicitudes pendientes) -->
                                    <% if (solicitud.esPendiente()) { %>
                                        <div class="request-actions">
                                            <button class="btn-action btn-approve" 
                                                    onclick="aprobarSolicitud(<%= solicitud.getIdSolicitud() %>, '<%= solicitud.getUsernameUsuario() %>')">
                                                <i class="fas fa-check"></i> Aprobar
                                            </button>
                                            <button class="btn-action btn-reject" 
                                                    onclick="rechazarSolicitud(<%= solicitud.getIdSolicitud() %>, '<%= solicitud.getUsernameUsuario() %>')">
                                                <i class="fas fa-times"></i> Rechazar
                                            </button>
                                            <% if (solicitud.getEmailUsuario() != null) { %>
                                                <a href="mailto:<%= solicitud.getEmailUsuario() %>" class="btn-action btn-view">
                                                    <i class="fas fa-envelope"></i> Contactar
                                                </a>
                                            <% } %>
                                        </div>
                                    <% } else { %>
                                        <!-- Solicitud ya procesada -->
                                        <div class="request-actions">
                                            <button class="btn-action btn-view" 
                                                    onclick="verDetallesSolicitud(<%= solicitud.getIdSolicitud() %>)">
                                                <i class="fas fa-eye"></i> Ver Detalles
                                            </button>
                                        </div>
                                    <% } %>
                                </div>
                            <% } %>
                        </div>
                    <% } else { %>
                        <!-- Sin solicitudes -->
                        <div class="no-requests">
                            <i class="fas fa-inbox"></i>
                            <h3>No hay solicitudes</h3>
                            <p>Cuando los usuarios soliciten unirse a tu comunidad privada, aparecerán aquí.</p>
                            <a href="ComunidadServlet?action=view&id=<%= comunidad.getIdComunidad() %>" 
                               class="btn btn-primary" 
                               style="display: inline-flex; align-items: center; text-decoration: none;">
                                Volver a la Comunidad
                            </a>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </main>
    
    <!-- Modal para responder solicitud -->
    <div class="modal fade" id="responderModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header" id="modalHeader">
                    <h5 class="modal-title" id="modalTitle">
                        <i class="fas fa-reply"></i> Responder Solicitud
                    </h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="text-center mb-3">
                        <div class="user-avatar" style="margin: 0 auto;" id="modalUserAvatar">U</div>
                        <h5 id="modalUserName" style="margin: 10px 0 5px 0;">Usuario</h5>
                        <p class="text-muted" id="modalUserUsername">@username</p>
                    </div>
                    
                    <div class="form-group">
                        <label for="mensajeRespuesta">
                            <strong>Mensaje para el usuario (opcional):</strong>
                        </label>
                        <textarea class="form-control" 
                                  id="mensajeRespuesta" 
                                  rows="4" 
                                  maxlength="500"
                                  placeholder="Explica el motivo de tu decisión..."></textarea>
                        <small class="form-text text-muted">
                            <span id="contadorRespuesta">0</span>/500 caracteres
                        </small>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">
                        <i class="fas fa-times"></i> Cancelar
                    </button>
                    <button type="button" class="btn" id="btnConfirmarRespuesta">
                        <i class="fas fa-check"></i> Confirmar
                    </button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Scripts -->
    <jsp:include page="/components/js_imports.jsp" />
    
    <script>
        let solicitudActual = null;
        let accionActual = null;
        
        $(document).ready(function() {
            initializeModal();
        });
        
        function initializeModal() {
            // Contador de caracteres
            $('#mensajeRespuesta').on('input', function() {
                const length = $(this).val().length;
                $('#contadorRespuesta').text(length);
                
                if (length > 450) {
                    $('#contadorRespuesta').addClass('text-warning');
                } else if (length > 480) {
                    $('#contadorRespuesta').removeClass('text-warning').addClass('text-danger');
                } else {
                    $('#contadorRespuesta').removeClass('text-warning text-danger');
                }
            });
            
            // Limpiar modal al cerrar
            $('#responderModal').on('hidden.bs.modal', function() {
                $('#mensajeRespuesta').val('');
                $('#contadorRespuesta').text('0').removeClass('text-warning text-danger');
                solicitudActual = null;
                accionActual = null;
            });
            
            // Manejar confirmación
            $('#btnConfirmarRespuesta').on('click', function() {
                if (solicitudActual && accionActual) {
                    const mensaje = $('#mensajeRespuesta').val();
                    procesarRespuesta(solicitudActual.id, accionActual, mensaje);
                }
            });
        }
        
        function aprobarSolicitud(idSolicitud, username) {
            solicitudActual = { id: idSolicitud, username: username };
            accionActual = 'aprobar';
            
            // Configurar modal para aprobación
            $('#modalTitle').html('<i class="fas fa-check-circle text-success"></i> Aprobar Solicitud');
            $('#modalHeader').removeClass('bg-danger').addClass('bg-success text-white');
            $('#modalUserAvatar').text(username.substring(0,1).toUpperCase());
            $('#modalUserName').text('Aprobar solicitud de');
            $('#modalUserUsername').text('@' + username);
            $('#btnConfirmarRespuesta').removeClass('btn-danger').addClass('btn-success')
                                      .html('<i class="fas fa-check"></i> Aprobar');
            
            $('#mensajeRespuesta').attr('placeholder', '¡Bienvenido/a a la comunidad! Puedes mencionar las reglas o dar la bienvenida...');
            
            $('#responderModal').modal('show');
        }
        
        function rechazarSolicitud(idSolicitud, username) {
            solicitudActual = { id: idSolicitud, username: username };
            accionActual = 'rechazar';
            
            // Configurar modal para rechazo
            $('#modalTitle').html('<i class="fas fa-times-circle text-danger"></i> Rechazar Solicitud');
            $('#modalHeader').removeClass('bg-success').addClass('bg-danger text-white');
            $('#modalUserAvatar').text(username.substring(0,1).toUpperCase());
            $('#modalUserName').text('Rechazar solicitud de');
            $('#modalUserUsername').text('@' + username);
            $('#btnConfirmarRespuesta').removeClass('btn-success').addClass('btn-danger')
                                      .html('<i class="fas fa-times"></i> Rechazar');
            
            $('#mensajeRespuesta').attr('placeholder', 'Explica el motivo del rechazo de manera respetuosa...');
            
            $('#responderModal').modal('show');
        }
        
        function procesarRespuesta(idSolicitud, accion, mensaje) {
            console.log('🔄 Procesando respuesta:', { idSolicitud, accion, mensaje: mensaje.substring(0, 50) + '...' });
            
            // Deshabilitar botón
            $('#btnConfirmarRespuesta').prop('disabled', true)
                                      .html('<i class="fas fa-spinner fa-spin"></i> Procesando...');
            
            $.ajax({
                url: 'ComunidadServlet',
                type: 'POST',
                data: {
                    action: 'respondRequest',
                    idSolicitud: idSolicitud,
                    accion: accion,
                    mensajeRespuesta: mensaje
                },
                dataType: 'json',
                success: function(response) {
                    $('#btnConfirmarRespuesta').prop('disabled', false);
                    
                    if (response.success) {
                        $('#responderModal').modal('hide');
                        showSuccess(response.message);
                        
                        // Recargar página para mostrar cambios
                        setTimeout(() => {
                            location.reload();
                        }, 1500);
                    } else {
                        showError(response.message);
                        $('#btnConfirmarRespuesta').html(
                            accion === 'aprobar' ? 
                            '<i class="fas fa-check"></i> Aprobar' : 
                            '<i class="fas fa-times"></i> Rechazar'
                        );
                    }
                },
                error: function() {
                    $('#btnConfirmarRespuesta').prop('disabled', false)
                                              .html(
                                                  accion === 'aprobar' ? 
                                                  '<i class="fas fa-check"></i> Aprobar' : 
                                                  '<i class="fas fa-times"></i> Rechazar'
                                              );
                    showError('Error de conexión al procesar la respuesta');
                }
            });
        }
        
        function verDetallesSolicitud(idSolicitud) {
            // TODO: Implementar vista de detalles completos
            console.log('👁️ Ver detalles de solicitud:', idSolicitud);
            showInfo('Funcionalidad de detalles en desarrollo');
        }
        
        // Sistema de notificaciones (reutilizable)
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
    </script>
</body>
</html>