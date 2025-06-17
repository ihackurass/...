<%-- 
    Document   : mi-perfil
    Created on : Perfil de Usuario Moderno
    Author     : Sistema
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="pe.aquasocial.entity.Usuario"%>
<%@page import="java.time.format.DateTimeFormatter"%>

<%
    Usuario usuario = (Usuario) session.getAttribute("usuarioLogueado");
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
    
    if (usuario == null) {
        response.sendRedirect("LoginServlet");
        return;
    }
%>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi Perfil - <%= usuario.getNombreCompleto() %></title>
    <jsp:include page="/components/css_imports.jsp" />
    
    <style>
        .main-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .profile-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 20px;
            padding: 40px;
            color: white;
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
        }
        
        .profile-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0,0,0,0.1);
            z-index: 1;
        }
        
        .profile-content {
            position: relative;
            z-index: 2;
            display: flex;
            align-items: center;
            gap: 30px;
        }
        
        .profile-avatar-container {
            position: relative;
        }
        
        .profile-avatar {
            width: 120px;
            height: 120px;
            margin: 0 auto;
            border-radius: 50%;
            overflow: hidden;
        }

        .avatar-with-image {
            /* Para cuando tiene imagen */
            background: transparent;
        }

        .avatar-with-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 50%;
        }

        .avatar-with-letter {
            /* Para cuando solo tiene letra */
            background: linear-gradient(135deg, #007bff, #6610f2);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 3rem;
            font-weight: 700;
            border: 4px solid rgba(255,255,255,0.3);
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }
        
        .profile-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 50%;
        }
        
        .avatar-edit-btn {
            position: absolute;
            bottom: 5px;
            right: 5px;
            width: 35px;
            height: 35px;
            border-radius: 50%;
            background: #007bff;
            border: 2px solid white;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.3s ease;
        }
        
        .avatar-edit-btn:hover {
            background: #0056b3;
            transform: scale(1.1);
        }
        
        .profile-info h1 {
            margin: 0 0 10px 0;
            font-size: 2.5rem;
            font-weight: 600;
        }
        
        .profile-username {
            font-size: 1.2rem;
            opacity: 0.9;
            margin-bottom: 15px;
        }
        
        .profile-stats {
            display: flex;
            gap: 30px;
        }
        
        .stat-item {
            text-align: center;
        }
        
        .stat-number {
            display: block;
            font-size: 1.8rem;
            font-weight: 700;
            margin-bottom: 5px;
        }
        
        .stat-label {
            font-size: 0.9rem;
            opacity: 0.8;
        }
        
        .profile-sections {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
        }
        
        .profile-card {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            border: 1px solid #f1f3f4;
        }
        
        .card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f8f9fa;
        }
        
        .card-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: #333;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .card-title i {
            color: #007bff;
        }
        
        .btn-edit {
            background: #007bff;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 12px;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .btn-edit:hover {
            background: #0056b3;
            transform: translateY(-1px);
        }
        
        .info-group {
            margin-bottom: 20px;
        }
        
        .info-label {
            font-size: 0.875rem;
            color: #6c757d;
            margin-bottom: 5px;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .info-value {
            font-size: 1rem;
            color: #333;
            padding: 10px 0;
            border-bottom: 1px solid #f1f3f4;
        }
        
        .info-value:last-child {
            border-bottom: none;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        
        .stat-card {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            border: 2px solid transparent;
            transition: all 0.3s ease;
        }
        
        .stat-card:hover {
            border-color: #007bff;
            transform: translateY(-2px);
        }
        
        .stat-card-number {
            font-size: 2rem;
            font-weight: 700;
            color: #007bff;
            margin-bottom: 5px;
        }
        
        .stat-card-label {
            font-size: 0.875rem;
            color: #6c757d;
            text-transform: uppercase;
            letter-spacing: 0.5px;
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
        
        /* Modal Styles */
        .modal-content {
            border-radius: 15px;
            border: none;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        }
        
        .modal-header {
            border-bottom: 2px solid #f8f9fa;
            padding: 20px 30px;
        }
        
        .modal-title {
            font-weight: 600;
            color: #333;
        }
        
        .modal-body {
            padding: 30px;
        }
        
        .form-group label {
            font-weight: 500;
            color: #495057;
            margin-bottom: 8px;
        }
        
        .form-control {
            border-radius: 8px;
            border: 2px solid #e9ecef;
            padding: 12px 15px;
            transition: border-color 0.3s ease;
        }
        
        .form-control:focus {
            border-color: #007bff;
            box-shadow: 0 0 0 0.2rem rgba(0,123,255,0.25);
        }
        .form-control select,
        select.form-control {
            padding: 12px 15px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 14px;
            background: white;
            cursor: pointer;

            /* Centrado vertical del texto */
            line-height: 1.5;
            vertical-align: middle;

            /* Altura fija */
            height: 45px;
            box-sizing: border-box;

            /* Asegurar que el texto se vea centrado */
            appearance: none;
            -webkit-appearance: none;
            -moz-appearance: none;

            /* Flecha personalizada */
            background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6,9 12,15 18,9'%3e%3c/polyline%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right 12px center;
            background-size: 16px;
            padding-right: 40px;
        }
        .btn-primary {
            background: #007bff;
            border: none;
            padding: 12px 30px;
            border-radius: 8px;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        
        .btn-primary:hover {
            background: #0056b3;
            transform: translateY(-1px);
        }
        
        .btn-secondary {
            background: #6c757d;
            border: none;
            padding: 12px 30px;
            border-radius: 8px;
            font-weight: 500;
        }

        .verification-status {
            margin-bottom: 20px;
        }

        .verification-badge {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 20px;
            border-radius: 10px;
            border: 2px solid;
            background: #f8f9fa;
        }

        .verification-badge.verified {
            border-color: #28a745;
            background: #d4edda;
            color: #155724;
        }

        .verification-badge.pending {
            border-color: #ffc107;
            background: #fff3cd;
            color: #856404;
        }

        .verification-badge.unverified {
            border-color: #6c757d;
            background: #f8f9fa;
            color: #495057;
        }

        .verification-badge i {
            font-size: 2rem;
        }

        .badge-content h6 {
            margin: 0 0 5px 0;
            font-weight: 600;
        }

        .badge-content p {
            margin: 0;
            font-size: 0.9rem;
        }

        .verification-benefits {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            border-left: 4px solid #007bff;
        }

        .verification-benefits h6 {
            margin-bottom: 15px;
            color: #333;
            font-weight: 600;
        }

        .verification-benefits ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .verification-benefits li {
            padding: 5px 0;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .upload-area {
            border: 2px dashed #ddd;
            border-radius: 10px;
            padding: 30px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
        }

        .upload-area:hover {
            border-color: #007bff;
            background: rgba(0,123,255,0.05);
        }

        .upload-area input[type="file"] {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            opacity: 0;
            cursor: pointer;
        }

        .upload-placeholder i {
            font-size: 3rem;
            color: #6c757d;
            margin-bottom: 10px;
        }

        .upload-placeholder p {
            margin: 10px 0 5px 0;
            font-weight: 600;
            color: #333;
        }

        .upload-placeholder small {
            color: #6c757d;
        }

        .document-preview {
            margin-top: 15px;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 8px;
            border: 1px solid #e9ecef;
        }

        .document-preview img {
            max-width: 200px;
            max-height: 150px;
            border-radius: 5px;
        }

        .document-info {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-top: 10px;
        }

        .document-info i {
            color: #007bff;
        }
        @media (max-width: 768px) {
            .profile-content {
                flex-direction: column;
                text-align: center;
            }
            
            .profile-sections {
                grid-template-columns: 1fr;
            }
            
            .profile-stats {
                justify-content: center;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
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
                
                <!-- Header del Perfil -->
                <div class="profile-header">
                    <div class="profile-content">
                        <div class="profile-avatar-container">
                            <div class="profile-avatar" id="profileAvatar">
                                <% if (usuario.getAvatar() != null && !usuario.getAvatar().trim().isEmpty()) { %>
                                    <img src="<%= usuario.getAvatar() %>" alt="Avatar">
                                <% } else { %>
                                    <%= usuario.getNombreCompleto().substring(0,1).toUpperCase() %>
                                <% } %>
                            </div>
                            <div class="avatar-edit-btn" onclick="editarAvatar()">
                                <i class="fas fa-camera"></i>
                            </div>
                        </div>
                        
                        <div class="profile-info">
                            <h1><%= usuario.getNombreCompleto() %></h1>
                            <div class="profile-username">@<%= usuario.getUsername() %></div>
                            
                            <div class="profile-stats">
                                <div class="stat-item">
                                    <span class="stat-number" id="comunidadesCount">-</span>
                                    <span class="stat-label">Comunidades</span>
                                </div>
                                <div class="stat-item">
                                    <span class="stat-number">
                                        <%= usuario.getFechaRegistro() != null ? 
   usuario.getFechaRegistro().toLocalDateTime().format(DateTimeFormatter.ofPattern("yyyy")) : "2024" %>
                                    </span>
                                    <span class="stat-label">Miembro desde</span>
                                </div>
                                <div class="stat-item">
                                    <span class="stat-number" id="solicitudesCount">-</span>
                                    <span class="stat-label">Solicitudes</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Secciones del Perfil -->
                <div class="profile-sections">
                    <div class="profile-card" style="grid-column: 1 / -1;">
                        <div class="card-header">
                            <div class="card-title">
                                <i class="fas fa-chart-bar"></i>
                                Estadísticas de Actividad
                            </div>
                        </div>
                        
                        <div class="stats-grid" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px;">
                            <div class="stat-card">
                                <div class="stat-card-number" id="comunidadesSeguidas">0</div>
                                <div class="stat-card-label">Comunidades Seguidas</div>
                            </div>

                            <!-- ✅ NUEVA TARJETA DE PUBLICACIONES -->
                            <div class="stat-card">
                                <div class="stat-card-number" id="totalPublicaciones">0</div>
                                <div class="stat-card-label">Publicaciones</div>
                            </div>

                            <div class="stat-card">
                                <div class="stat-card-number" id="solicitudesEnviadas">0</div>
                                <div class="stat-card-label">Solicitudes Enviadas</div>
                            </div>

                            <div class="stat-card">
                                <div class="stat-card-number" id="solicitudesAprobadas">0</div>
                                <div class="stat-card-label">Solicitudes Aprobadas</div>
                            </div>

                            <div class="stat-card">
                                <div class="stat-card-number" id="comunidadesAdmin">0</div>
                                <div class="stat-card-label">Comunidades Admin</div>
                            </div>
                        </div>
                    </div>
                    <!-- Información Personal -->
                    <div class="profile-card">
                        <div class="card-header">
                            <div class="card-title">
                                <i class="fas fa-user"></i>
                                Información Personal
                            </div>
                            <button class="btn-edit" onclick="editarInformacion()">
                                <i class="fas fa-edit"></i> Editar
                            </button>
                        </div>
                        
                        <div class="info-group">
                            <div class="info-label">Nombre Completo</div>
                            <div class="info-value"><%= usuario.getNombreCompleto() %></div>
                        </div>
                        
                        <div class="info-group">
                            <div class="info-label">Nombre de Usuario</div>
                            <div class="info-value">@<%= usuario.getUsername() %></div>
                        </div>
                        
                        <div class="info-group">
                            <div class="info-label">Correo Electrónico</div>
                            <div class="info-value"><%= usuario.getEmail() %></div>
                        </div>
                        
                        <div class="info-group">
                            <div class="info-label">Miembro desde</div>
                            <div class="info-value">
                            <%= usuario.getFechaRegistro() != null ? 
                               usuario.getFechaRegistro().toLocalDateTime().format(DateTimeFormatter.ofPattern("yyyy")) : "2024" %>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Configuración -->
                    <div class="profile-card">
                        <div class="card-header">
                            <div class="card-title">
                                <i class="fas fa-cog"></i>
                                Configuración
                            </div>
                            <button class="btn-edit" onclick="editarConfiguracion()">
                                <i class="fas fa-edit"></i> Configurar
                            </button>
                        </div>
                        
                        <div class="info-group">
                            <div class="info-label">Contraseña</div>
                            <div class="info-value">••••••••••••</div>
                        </div>
                        
                        <div class="info-group">
                            <div class="info-label">Último acceso</div>
                            <div class="info-value" id="ultimoAcceso">Conectado ahora</div>
                        </div>
                        
                        <div class="info-group">
                            <div class="info-label">Estado de la cuenta</div>
                            <div class="info-value">
                                <% if (usuario.isVerificado()) { %>
                                    <span style="color: #28a745;">
                                        <i class="fas fa-check-circle"></i> Verificado
                                    </span>
                                <% } else { %>
                                    <span style="color: #ffc107;">
                                        <i class="fas fa-clock"></i> No Verificado
                                    </span>
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <div class="profile-card">
                        <div class="card-header">
                            <div class="card-title">
                                <i class="fas fa-shield-check"></i>
                                Verificación de Cuenta
                            </div>
                            <% if (!usuario.isVerificado() && !usuario.isSolicitoVerificacion()) { %>
                                <button class="btn-edit" onclick="solicitarVerificacion()">
                                    <i class="fas fa-check-circle"></i> Solicitar
                                </button>
                            <% } %>
                        </div>

                        <div class="verification-status">
                            <% if (usuario.isVerificado()) { %>
                                <!-- Usuario ya verificado -->
                                <div class="verification-badge verified">
                                    <i class="fas fa-check-circle"></i>
                                    <div class="badge-content">
                                        <h6>Cuenta Verificada</h6>
                                        <p>Tu cuenta ha sido verificada exitosamente</p>
                                    </div>
                                </div>

                            <% } else if (usuario.isSolicitoVerificacion()) { %>
                                <!-- Solicitud pendiente -->
                                <div class="verification-badge pending">
                                    <i class="fas fa-clock"></i>
                                    <div class="badge-content">
                                        <h6>Solicitud Pendiente</h6>
                                        <p>Tu solicitud de verificación está siendo revisada por nuestro equipo</p>
                                    </div>
                                </div>

                            <% } else { %>
                                <!-- Sin verificar -->
                                <div class="verification-badge unverified">
                                    <i class="fas fa-exclamation-circle"></i>
                                    <div class="badge-content">
                                        <h6>Cuenta No Verificada</h6>
                                        <p>Solicita la verificación para obtener la insignia azul y mayor credibilidad</p>
                                    </div>
                                </div>
                            <% } %>
                        </div>

                        <% if (!usuario.isVerificado() && !usuario.isSolicitoVerificacion()) { %>
                            <div class="verification-benefits">
                                <h6>Beneficios de la verificación:</h6>
                                <ul>
                                    <li><i class="fas fa-check text-success"></i> Insignia de verificación azul</li>
                                    <li><i class="fas fa-check text-success"></i> Mayor credibilidad en la plataforma</li>
                                    <li><i class="fas fa-check text-success"></i> Prioridad en el soporte técnico</li>
                                    <li><i class="fas fa-check text-success"></i> Acceso a funciones exclusivas</li>
                                </ul>
                            </div>
                        <% } %>
                    </div>
                    <!-- Estadísticas de Actividad -->

                    
                </div>
            </div>
        </div>
    </main>
    
    <!-- Modal Editar Información -->
    <div class="modal fade" id="editarInfoModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="fas fa-edit"></i> Editar Información Personal
                    </h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <form id="formEditarInfo" onsubmit="guardarInformacion(event)">
                    <div class="modal-body">
                        <div class="form-group">
                            <label for="nombreCompleto">Nombre Completo</label>
                            <input type="text" class="form-control" id="nombreCompleto" 
                                   value="<%= usuario.getNombreCompleto() %>" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="email">Correo Electrónico</label>
                            <input type="email" class="form-control" id="email" 
                                   value="<%= usuario.getEmail() %>" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="bio">Descripción (opcional)</label>
                            <textarea class="form-control" id="bio" rows="3" 
                                     placeholder="Cuéntanos un poco sobre ti..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">
                            <i class="fas fa-times"></i> Cancelar
                        </button>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Guardar Cambios
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- Modal Cambiar Contraseña -->
    <div class="modal fade" id="cambiarPasswordModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="fas fa-lock"></i> Cambiar Contraseña
                    </h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <form id="formCambiarPassword" onsubmit="cambiarPassword(event)">
                    <div class="modal-body">
                        <div class="form-group">
                            <label for="passwordActual">Contraseña Actual</label>
                            <input type="password" class="form-control" id="passwordActual" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="passwordNueva">Nueva Contraseña</label>
                            <input type="password" class="form-control" id="passwordNueva" 
                                   minlength="8" required>
                            <small class="form-text text-muted">Mínimo 8 caracteres</small>
                        </div>
                        
                        <div class="form-group">
                            <label for="passwordConfirmar">Confirmar Nueva Contraseña</label>
                            <input type="password" class="form-control" id="passwordConfirmar" required>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">
                            <i class="fas fa-times"></i> Cancelar
                        </button>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Cambiar Contraseña
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- Modal Cambiar Avatar -->
    <div class="modal fade" id="cambiarAvatarModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="fas fa-camera"></i> Cambiar Avatar
                    </h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <form id="formCambiarAvatar" onsubmit="cambiarAvatar(event)">
                    <div class="modal-body">
                        <div class="text-center mb-3">
                               <% 
                                   String avatar = usuario.getAvatar();
                                   String nombreCompleto = usuario.getNombreCompleto();

                                   boolean tieneAvatarPersonalizado = avatar != null && 
                                                                     !avatar.trim().isEmpty() && 
                                                                     !avatar.equals("default.png") &&
                                                                     !avatar.endsWith("default.png");
                               %>
                            <div class="profile-avatar <%= tieneAvatarPersonalizado ? "avatar-with-image" : "avatar-with-letter" %>" id="avatarPreview">

                               <% if (tieneAvatarPersonalizado) { %>
                                   <img src="<%= avatar %>" alt="Avatar">
                               <% } else { %>
                                   <%= nombreCompleto != null ? nombreCompleto.substring(0,1).toUpperCase() : "U" %>
                               <% } %>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="avatarFile">Seleccionar nueva imagen</label>
                            <input type="file" class="form-control-file" id="avatarFile" 
                                   accept="image/jpeg,image/png,image/jpg" onchange="previewAvatar(this)">
                            <small class="form-text text-muted">Formatos permitidos: JPG, PNG. Tamaño máximo: 2MB</small>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">
                            <i class="fas fa-times"></i> Cancelar
                        </button>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-upload"></i> Subir Avatar
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal para Solicitar Verificación -->
    <div class="modal fade" id="verificacionModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title">
                        <i class="fas fa-shield-check"></i> Solicitar Verificación de Cuenta
                    </h5>
                    <button type="button" class="close text-white" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <form id="formSolicitarVerificacion" onsubmit="enviarSolicitudVerificacion(event)" enctype="multipart/form-data">
                    <div class="modal-body">

                        <!-- Información importante -->
                        <div class="alert alert-info">
                            <i class="fas fa-info-circle"></i>
                            <strong>Información importante:</strong> 
                            La verificación está destinada a cuentas de interés público, 
                            figuras reconocidas, empresas oficiales o creadores de contenido destacados.
                        </div>

                        <!-- Contraseña actual para seguridad -->
                        <div class="form-group">
                            <label for="passwordVerificacion">
                                <i class="fas fa-lock"></i> Contraseña Actual *
                            </label>
                            <input type="password" class="form-control" id="passwordVerificacion" 
                                   placeholder="Confirma tu identidad con tu contraseña" required>
                            <small class="form-text text-muted">
                                Requerido por seguridad para procesar la solicitud
                            </small>
                        </div>

                        <!-- Motivo de la solicitud -->
                        <div class="form-group">
                            <label for="motivoVerificacion">
                                <i class="fas fa-comment-alt"></i> Motivo de la Solicitud *
                            </label>
                            <textarea class="form-control" id="motivoVerificacion" rows="4" 
                                      placeholder="Explica por qué tu cuenta debería ser verificada..." 
                                      maxlength="500" required></textarea>
                            <small class="form-text text-muted">
                                <span id="contadorCaracteres">0</span>/500 caracteres
                            </small>
                        </div>

                        <!-- Categoría de verificación -->
                        <div class="form-group">
                            <label for="categoriaVerificacion">
                                <i class="fas fa-tags"></i> Categoría *
                            </label>
                            <select class="form-control" id="categoriaVerificacion" required>
                                <option value="">Selecciona una categoría</option>
                                <option value="figura_publica">Figura Pública</option>
                                <option value="empresa_oficial">Empresa u Organización Oficial</option>
                                <option value="creador_contenido">Creador de Contenido</option>
                                <option value="periodista">Periodista o Medio de Comunicación</option>
                                <option value="deportista">Deportista</option>
                                <option value="artista">Artista o Músico</option>
                                <option value="influencer">Influencer</option>
                                <option value="otro">Otro</option>
                            </select>
                        </div>

                        <!-- Upload de identificación -->
                        <div class="form-group">
                            <label for="documentoIdentificacion">
                                <i class="fas fa-id-card"></i> Documento de Identificación *
                            </label>
                            <div class="upload-area" id="uploadArea">
                                <input type="file" class="form-control-file" id="documentoIdentificacion" 
                                       accept="image/*,.pdf" required onchange="previewDocument(this)">
                                <div class="upload-placeholder">
                                    <i class="fas fa-cloud-upload-alt"></i>
                                    <p>Haz clic para subir tu documento de identificación</p>
                                    <small>Formatos permitidos: JPG, PNG, PDF (máx. 5MB)</small>
                                </div>
                            </div>
                            <div id="documentPreview" class="document-preview" style="display: none;">
                                <!-- Preview del documento -->
                            </div>
                            <small class="form-text text-muted">
                                Sube una copia de tu identificación oficial (cédula, pasaporte, licencia) 
                                o documento que acredite tu identidad/posición.
                            </small>
                        </div>

                        <!-- Enlaces adicionales (opcional) -->
                        <div class="form-group">
                            <label for="enlacesAdicionales">
                                <i class="fas fa-link"></i> Enlaces Adicionales (Opcional)
                            </label>
                            <textarea class="form-control" id="enlacesAdicionales" rows="2" 
                                      placeholder="Enlaces a redes sociales oficiales, sitio web, artículos de prensa, etc."></textarea>
                            <small class="form-text text-muted">
                                Enlaces que ayuden a verificar tu identidad (uno por línea)
                            </small>
                        </div>

                        <!-- Términos y condiciones -->
                        <div class="form-check">
                            <input type="checkbox" class="form-check-input" id="aceptoTerminos" required>
                            <label class="form-check-label" for="aceptoTerminos">
                                Acepto que la información proporcionada es verídica y entiendo que 
                                proporcionar información falsa puede resultar en la suspensión de mi cuenta.
                            </label>
                        </div>

                    </div>

                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">
                            <i class="fas fa-times"></i> Cancelar
                        </button>
                        <button type="submit" class="btn btn-primary" id="btnEnviarSolicitud">
                            <i class="fas fa-paper-plane"></i> Enviar Solicitud
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <!-- Scripts -->
    <jsp:include page="/components/js_imports.jsp" />
    
    <script>
        $(document).ready(function() {
            cargarEstadisticas();
        });
        
        // Funciones para abrir modals
        function editarInformacion() {
            $('#editarInfoModal').modal('show');
        }
        
        function editarConfiguracion() {
            $('#cambiarPasswordModal').modal('show');
        }
        
        function editarAvatar() {
            $('#cambiarAvatarModal').modal('show');
        }
        
        // Guardar información personal
        function guardarInformacion(event) {
            event.preventDefault();
            
            const formData = {
                action: 'updateInfo',
                nombreCompleto: $('#nombreCompleto').val(),
                email: $('#email').val(),
                bio: $('#bio').val()
            };
            
            console.log('Guardando información:', formData);
            
            $.ajax({
                url: 'PerfilServlet',
                type: 'POST',
                data: formData,
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        $('#editarInfoModal').modal('hide');
                        showSuccess(response.message);
                        // Recargar página para mostrar cambios
                        setTimeout(() => location.reload(), 1500);
                    } else {
                        showError(response.message);
                    }
                },
                error: function() {
                    showError('Error de conexión al guardar la información');
                }
            });
        }
        
        // Cambiar contraseña
        function cambiarPassword(event) {
            event.preventDefault();
            
            const passwordNueva = $('#passwordNueva').val();
            const passwordConfirmar = $('#passwordConfirmar').val();
            
            if (passwordNueva !== passwordConfirmar) {
                showError('Las contraseñas no coinciden');
                return;
            }
            
            const formData = {
                action: 'changePassword',
                passwordActual: $('#passwordActual').val(),
                passwordNueva: passwordNueva
            };
            
            console.log('Cambiando contraseña...');
            
            $.ajax({
                url: 'PerfilServlet',
                type: 'POST',
                data: formData,
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        $('#cambiarPasswordModal').modal('hide');
                        showSuccess(response.message);
                        // Limpiar formulario
                        $('#formCambiarPassword')[0].reset();
                    } else {
                        showError(response.message);
                    }
                },
                error: function() {
                    showError('Error de conexión al cambiar la contraseña');
                }
            });
        }
        
        // Preview del avatar
        function previewAvatar(input) {
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    $('#avatarPreview').html('<img src="' + e.target.result + '" alt="Preview" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">');
                };
                reader.readAsDataURL(input.files[0]);
            }
        }


        function previewDocument(input) {
            var file = input.files[0];
            var preview = document.getElementById('documentPreview');
            var placeholder = document.querySelector('.upload-placeholder');

            if (file) {
                var fileType = file.type;
                var fileName = file.name;
                var fileSize = (file.size / 1024 / 1024).toFixed(2);

                if (file.size > 5 * 1024 * 1024) {
                    showError('El archivo es demasiado grande. Máximo 5MB.');
                    input.value = '';
                    return;
                }

                placeholder.style.display = 'none';
                preview.style.display = 'block';

                if (fileType.indexOf('image/') === 0) {
                    var reader = new FileReader();
                    reader.onload = function(e) {
                        preview.innerHTML = 
                            '<div class="document-info">' +
                                '<img src="' + e.target.result + '" alt="Preview">' +
                                '<div>' +
                                    '<strong>' + fileName + '</strong><br>' +
                                    '<small>Tamaño: ' + fileSize + ' MB</small>' +
                                '</div>' +
                            '</div>';
                    };
                    reader.readAsDataURL(file);
                } else if (fileType === 'application/pdf') {
                    preview.innerHTML = 
                        '<div class="document-info">' +
                            '<i class="fas fa-file-pdf fa-3x text-danger"></i>' +
                            '<div>' +
                                '<strong>' + fileName + '</strong><br>' +
                                '<small>Tamaño: ' + fileSize + ' MB</small>' +
                            '</div>' +
                        '</div>';
                }
            } else {
                placeholder.style.display = 'block';
                preview.style.display = 'none';
            }
        }

        // Cambiar avatar
        function cambiarAvatar(event) {
            event.preventDefault();
            
            const fileInput = $('#avatarFile')[0];
            if (!fileInput.files || !fileInput.files[0]) {
                showError('Por favor selecciona una imagen');
                return;
            }
            
            const formData = new FormData();
            formData.append('action', 'changeAvatar');
            formData.append('avatar', fileInput.files[0]);
            
            console.log('Subiendo avatar...');
            
            $.ajax({
                url: 'PerfilServlet',
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        $('#cambiarAvatarModal').modal('hide');
                        showSuccess(response.message);
                        // Recargar página para mostrar nuevo avatar
                        setTimeout(() => location.reload(), 1500);
                    } else {
                        showError(response.message);
                    }
                },
                error: function() {
                    showError('Error de conexión al subir el avatar');
                }
            });
        }
        
        // Cargar estadísticas
        function cargarEstadisticas() {
            $.ajax({
                url: 'PerfilServlet',
                type: 'GET',
                data: { action: 'getStats' },
                dataType: 'json',
                success: function(data) {
                    if (data.success) {
                        const stats = data.stats;

                        // Actualizar contadores en header
                        $('#comunidadesCount').text(stats.comunidadesSeguidas || 0);
                        $('#solicitudesCount').text(stats.solicitudesEnviadas || 0);

                        // ===== ACTUALIZAR ESTADÍSTICAS DETALLADAS =====
                        $('#comunidadesSeguidas').text(stats.comunidadesSeguidas || 0);
                        $('#totalPublicaciones').text(stats.totalPublicaciones || 0); // ← ESTA ES LA LÍNEA IMPORTANTE
                        $('#solicitudesEnviadas').text(stats.solicitudesEnviadas || 0);
                        $('#solicitudesAprobadas').text(stats.solicitudesAprobadas || 0);
                        $('#comunidadesAdmin').text(stats.comunidadesAdmin || 0);

                        // ===== ESTADÍSTICAS OPCIONALES (solo si existen en el DOM) =====
                        // Solo actualizar si los elementos existen
                        if ($('#publicacionesAprobadas').length) {
                            $('#publicacionesAprobadas').text(stats.publicacionesAprobadas || 0);
                        }
                        if ($('#publicacionesPendientes').length) {
                            $('#publicacionesPendientes').text(stats.publicacionesPendientes || 0);
                        }
                        if ($('#likesRecibidos').length) {
                            $('#likesRecibidos').text(stats.likesRecibidos || 0);
                        }
                        if ($('#likesDados').length) {
                            $('#likesDados').text(stats.likesDados || 0);
                        }

                        console.log('📊 Estadísticas cargadas:', stats);
                    } else {
                        console.log('❌ Error en respuesta:', data);
                    }
                },
                error: function(xhr, status, error) {
                    console.log('❌ Error al cargar estadísticas:', error);
                    console.log('Status:', status);
                    console.log('Response:', xhr.responseText);
                }
            });
        }
        
        // Sistema de notificaciones
        function showNotification(message, type, duration) {
            duration = duration || 4000;
            
            const config = {
                success: { icon: 'fa-check-circle', bgColor: '#28a745', textColor: '#fff', title: '¡Éxito!' },
                error: { icon: 'fa-exclamation-triangle', bgColor: '#dc3545', textColor: '#fff', title: 'Error' }
            };
            
            const setting = config[type] || config.error;
            const toastId = 'toast-' + Date.now();
            
            if ($('#toast-container').length === 0) {
                $('body').append('<div id="toast-container" style="position: fixed; top: 20px; right: 20px; z-index: 9999; max-width: 350px;"></div>');
            }
            
            const toast = '<div id="' + toastId + '" class="toast-notification" style="background: ' + setting.bgColor + '; color: ' + setting.textColor + '; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); margin-bottom: 10px; overflow: hidden; transform: translateX(100%); transition: all 0.3s ease; position: relative;">' +
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
        
        function showSuccess(message) { 
            showNotification(message, 'success'); 
        }
        
        function showError(message) { 
            showNotification(message, 'error'); 
        }
        
        // Atajos de teclado
        $(document).on('keydown', function(e) {
            // Ctrl + E para editar perfil
            if (e.ctrlKey && e.key === 'e') {
                e.preventDefault();
                editarInformacion();
            }
            
            // ESC para cerrar modales
            if (e.key === 'Escape') {
                $('.modal').modal('hide');
            }
        });
        
        console.log('🏠 Mi Perfil cargado correctamente');
        
        function solicitarVerificacion() {
            $('#verificacionModal').modal('show');
        }

        // Contador de caracteres para el motivo
        $('#motivoVerificacion').on('input', function() {
            const length = $(this).val().length;
            $('#contadorCaracteres').text(length);

            if (length > 450) {
                $('#contadorCaracteres').css('color', '#dc3545');
            } else if (length > 400) {
                $('#contadorCaracteres').css('color', '#ffc107');
            } else {
                $('#contadorCaracteres').css('color', '#6c757d');
            }
        });

        // Enviar solicitud de verificación
        function enviarSolicitudVerificacion(event) {
            event.preventDefault();

            const formData = new FormData();
            formData.append('action', 'solicitarVerificacion');
            formData.append('password', $('#passwordVerificacion').val());
            formData.append('motivo', $('#motivoVerificacion').val());
            formData.append('categoria', $('#categoriaVerificacion').val());
            formData.append('enlaces', $('#enlacesAdicionales').val());

            const documentFile = $('#documentoIdentificacion')[0].files[0];
            if (documentFile) {
                formData.append('documento', documentFile);
            }

            // Deshabilitar botón
            $('#btnEnviarSolicitud').prop('disabled', true)
                                    .html('<i class="fas fa-spinner fa-spin"></i> Enviando...');

            $.ajax({
                url: 'PerfilServlet',
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                dataType: 'json',
                success: function(response) {
                    $('#btnEnviarSolicitud').prop('disabled', false)
                                           .html('<i class="fas fa-paper-plane"></i> Enviar Solicitud');

                    if (response.success) {
                        $('#verificacionModal').modal('hide');
                        showSuccess(response.message);

                        // Recargar página para mostrar el nuevo estado
                        setTimeout(() => location.reload(), 2000);
                    } else {
                        showError(response.message);
                    }
                },
                error: function() {
                    $('#btnEnviarSolicitud').prop('disabled', false)
                                           .html('<i class="fas fa-paper-plane"></i> Enviar Solicitud');
                    showError('Error de conexión al enviar la solicitud');
                }
            });
        }
    </script>
</body>
</html>