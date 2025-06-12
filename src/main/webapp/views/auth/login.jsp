<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Login - Agua Bendita</title>
        <jsp:include page="/components/css_imports.jsp" />
        <style>
            body {
                background-color: #f3f3f3;
            }

            .login-container {
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
            }

            .login-card {
                display: flex;
                width: 100%;
                max-width: 900px;
                height: 500px;
                border-radius: 10px;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
                overflow: hidden;
                background-color: #fff;
            }

            .login-form {
                width: 50%;
                padding: 40px;
            }

            .login-form h2 {
                font-size: 24px;
                font-weight: bold;
                color: #333;
                margin-bottom: 20px;
                text-align: center
            }

            .login-logo {
                width: 50%;
                background-color: #3b82f6;
                display: flex;
                justify-content: center;
                align-items: center;
                padding: 20px;
            }

            .login-logo img {
                width: 250px;
                height: auto;
                margin-bottom: 10px;
            }

            .login-logo h3 {
                color: #ffffff;
                font-size: 20px;
                font-weight: bold;
            }

            .login-logo p {
                color: #ffffff;
                font-size: 14px;
            }

            .login-form .form-group {
                margin-bottom: 20px;
            }

            .login-form .form-control {
                border-radius: 5px;
                padding: 10px;
            }

            .login-form .form-check-label {
                font-size: 14px;
                color: #555;
            }

            .login-form button {
                width: 100%;
                padding: 12px;
                font-size: 16px;
                color: #ffffff;
                background-color: #000;
                border: none;
                border-radius: 5px;
                cursor: pointer;
                transition: background-color 0.3s;
            }

            .login-form button:hover {
                background-color: #333;
            }

            .login-form button:disabled {
                background-color: #6c757d;
                cursor: not-allowed;
            }

            .login-form .register-link {
                font-size: 14px;
                color: #555;
                margin-top: 10px;
                text-align: center;
            }

            .login-form .register-link a {
                color: #007bff;
                text-decoration: none;
                margin-left: 5px;
            }

            .login-form .register-link a:hover {
                text-decoration: underline;
            }

            /* Footer del login */
            .login-footer {
                margin-top: 30px;
                padding-top: 20px;
                border-top: 1px solid #e1e5e9;
                text-align: center;
            }

            .login-footer p {
                font-size: 14px;
                color: #555;
                margin-bottom: 10px !important;
            }

            .login-footer a {
                color: #007bff;
                text-decoration: none;
                font-weight: 600;
                margin-left: 5px;
            }

            .login-footer a:hover {
                color: #0056b3;
                text-decoration: none;
            }

            .login-footer a i {
                margin-right: 3px;
            }

            /* Spinner de carga */
            .spinner-border-sm {
                width: 1rem;
                height: 1rem;
            }

            /* Modales personalizados */
            .modal-content.border-success {
                border-color: #28a745 !important;
                border-width: 2px;
            }

            .modal-content.border-danger {
                border-color: #dc3545 !important;
                border-width: 2px;
            }

            .modal-content.border-warning {
                border-color: #ffc107 !important;
                border-width: 2px;
            }

            .modal-header.bg-success {
                background-color: #28a745 !important;
            }

            .modal-header.bg-warning {
                background-color: #ffc107 !important;
                color: #212529 !important;
            }

            .modal-body {
                font-size: 16px;
                line-height: 1.5;
            }

            @media (max-width: 768px) {
                .login-card {
                    flex-direction: column;
                }

                .login-form {
                    width: 100%;
                    padding: 20px;
                }

                .login-logo {
                    width: 100%;
                    padding: 20px;
                }

                .login-logo img {
                    width: 200px;
                }
            }
        </style>
    </head>
    <body data-skip-session-check="true">

        <div class="login-container">
            <div class="login-card">
                <!-- Login Form Section -->
                <div class="login-form">
                    <h2><i class="fas fa-sign-in-alt"></i> Login</h2>

                    <!-- Modal de éxito -->
                    <div class="modal fade" id="successModal" tabindex="-1" role="dialog" aria-labelledby="successModalLabel" aria-hidden="true">
                        <div class="modal-dialog" role="document">
                            <div class="modal-content border-success">
                                <div class="modal-header bg-success text-white">
                                    <h5 class="modal-title" id="successModalLabel">
                                        <i class="fas fa-check-circle"></i> Éxito
                                    </h5>
                                </div>
                                <div class="modal-body">
                                    <p id="successMessage"></p>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-success" data-dismiss="modal">
                                        <i class="fas fa-check"></i> Continuar
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Modal de error -->
                    <div class="modal fade" id="errorModal" tabindex="-1" role="dialog" aria-labelledby="errorModalLabel" aria-hidden="true">
                        <div class="modal-dialog" role="document">
                            <div class="modal-content border-danger">
                                <div class="modal-header bg-danger text-white">
                                    <h5 class="modal-title" id="errorModalLabel">
                                        <i class="fas fa-exclamation-triangle"></i> Error
                                    </h5>
                                </div>
                                <div class="modal-body">
                                    <p id="errorMessage"></p>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-dismiss="modal">
                                        <i class="fas fa-times"></i> Cerrar
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Modal de advertencia -->
                    <div class="modal fade" id="warningModal" tabindex="-1" role="dialog" aria-labelledby="warningModalLabel" aria-hidden="true">
                        <div class="modal-dialog" role="document">
                            <div class="modal-content border-warning">
                                <div class="modal-header bg-warning text-dark">
                                    <h5 class="modal-title" id="warningModalLabel">
                                        <i class="fas fa-exclamation-circle"></i> Advertencia
                                    </h5>
                                </div>
                                <div class="modal-body">
                                    <p id="warningMessage"></p>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-warning" data-dismiss="modal">
                                        <i class="fas fa-check"></i> Entendido
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <form id="loginForm" action="LoginServlet" method="POST">
                        <div class="form-group">
                            <label for="username">
                                <i class="fas fa-user"></i> Usuario
                            </label>
                            <input type="text" class="form-control" id="username" name="username" 
                                   placeholder="Ingresa tu nombre de usuario" required>
                        </div>

                        <div class="form-group">
                            <label for="password">
                                <i class="fas fa-lock"></i> Contraseña
                            </label>
                            <input type="password" class="form-control" id="password" name="password" 
                                   placeholder="Ingresa tu contraseña" required>
                        </div>

                        <div class="form-check" style="margin-bottom: 20px;">
                            <input type="checkbox" class="form-check-input" id="rememberMe" name="rememberMe" value="true">
                            <label class="form-check-label" for="rememberMe">
                                Recordar Contraseña
                            </label>
                        </div>

                        <button type="submit" id="loginBtn" class="btn btn-dark">
                            <span id="loginBtnText">
                                <i class="fas fa-sign-in-alt"></i> INICIAR SESIÓN
                            </span>
                            <span id="loginBtnLoading" style="display: none;">
                                <span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
                                Iniciando sesión...
                            </span>
                        </button>
                    </form>

                    <!-- Footer con enlaces -->
                    <div class="login-footer">
                        <p class="mb-0">
                            ¿No tienes cuenta? 
                            <a href="RegisterServlet">
                                <i class="fas fa-user-plus"></i> Regístrate
                            </a>
                        </p>
                        <p class="mb-0">
                            ¿Olvidaste tu contraseña? 
                            <a href="ProcesarRecuperacionServlet">
                                <i class="fas fa-key"></i> Recupérala
                            </a>
                        </p>
                    </div>
                </div>

                <!-- Logo Section -->
                <div class="login-logo">
                    <img src="assets/images/logo.jpg" alt="Logo Agua Bendita">
                </div>
            </div>
        </div>

        <!-- Bootstrap 4 JS, Popper.js and jQuery -->
        <jsp:include page="/components/js_imports.jsp" />


        <script>
            $(document).ready(function() {
                // Cargar datos de cookies si existen
                loadRememberedData();
                
                // Verificar mensajes del servidor al cargar la página
                checkServerMessages();
                
                
                // Manejar envío del formulario
                $('#loginForm').on('submit', function(e) {
                    e.preventDefault();
                    handleLogin();
                });
            });

            // Función para verificar mensajes del servidor (GET parameters o atributos)
            function checkServerMessages() {
                <% if (request.getAttribute("errorMessage") != null) { %>
                    showModal('error', '<%= request.getAttribute("errorMessage") %>');
                <% } %>
                
                <% if (request.getAttribute("successMessage") != null) { %>
                    showModal('success', '<%= request.getAttribute("successMessage") %>');
                <% } %>
                
                <% if (request.getAttribute("warningMessage") != null) { %>
                    showModal('warning', '<%= request.getAttribute("warningMessage") %>');
                <% } %>
            }

            // Función para cargar datos recordados de cookies
            function loadRememberedData() {
                const rememberMe = getCookie('rememberMe');
                const rememberedUsername = getCookie('rememberUsername');
                
                if (rememberMe === 'true' && rememberedUsername) {
                    $('#username').val(rememberedUsername);
                    $('#rememberMe').prop('checked', true);
                    console.log('✅ Datos cargados desde cookies');
                }
            }

            // Función para obtener cookies
            function getCookie(name) {
                const value = `; ${document.cookie}`;
                const parts = value.split(`; ${name}=`);
                if (parts.length === 2) return parts.pop().split(';').shift();
                return null;
            }

            // Función para eliminar cookies
            function deleteCookie(name) {
                document.cookie = name + '=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
            }

            // Función para manejar el login
            function handleLogin() {
                const $form = $('#loginForm');
                const $btn = $('#loginBtn');
                const $btnText = $('#loginBtnText');
                const $btnLoading = $('#loginBtnLoading');
                
                // Deshabilitar botón y mostrar spinner
                $btn.prop('disabled', true);
                $btnText.hide();
                $btnLoading.show();
                
                // Enviar datos via AJAX
                $.ajax({
                    url: 'LoginServlet',
                    type: 'POST',
                    data: $form.serialize(),
                    dataType: 'json',
                    timeout: 10000, // 10 segundos timeout
                    success: function(response) {
                        console.log('Respuesta del servidor:', response);
                        
                        if (response.success) {
                            // Login exitoso
                            showModal('success', response.message);
                            
                            // Log información del usuario
                            console.log('✅ Login exitoso:', {
                                username: response.username,
                                userId: response.userId,
                                role: response.userRole,
                                redirectUrl: response.redirectUrl
                            });
                            
                            // Redirigir después de 2 segundos
                            setTimeout(function() {
                                window.location.href = response.redirectUrl;
                            }, 2000);
                            
                        } else {
                            // Login fallido
                            handleLoginError(response);
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error('Error en la petición:', { xhr, status, error });
                        
                        let errorMessage = 'Error de conexión. Por favor, intenta de nuevo.';
                        
                        if (status === 'timeout') {
                            errorMessage = 'La petición tardó demasiado. Verifica tu conexión.';
                        } else if (xhr.responseJSON && xhr.responseJSON.message) {
                            errorMessage = xhr.responseJSON.message;
                        }
                        
                        showModal('error', errorMessage);
                        resetLoginButton($btn, $btnText, $btnLoading);
                    }
                });
            }

            // Función para manejar errores de login
            function handleLoginError(response) {
                const $btn = $('#loginBtn');
                const $btnText = $('#loginBtnText');
                const $btnLoading = $('#loginBtnLoading');
                
                if (response.isBlocked) {
                    // Cuenta bloqueada
                    showModal('warning', response.message);
                    console.warn('🔒 Cuenta bloqueada por', response.blockTimeMinutes, 'minutos');
                } else if (response.remainingAttempts !== undefined) {
                    // Intentos restantes
                    showModal('error', response.message);
                    console.warn('❌ Intentos restantes:', response.remainingAttempts);
                } else {
                    // Error general
                    showModal('error', response.message);
                }
                
                resetLoginButton($btn, $btnText, $btnLoading);
            }

            // Función para resetear el botón de login
            function resetLoginButton($btn, $btnText, $btnLoading) {
                $btn.prop('disabled', false);
                $btnLoading.hide();
                $btnText.show();
            }

            // Función para mostrar modales
            function showModal(type, message) {
                let modalId = '';
                let messageId = '';
                
                switch(type) {
                    case 'success':
                        modalId = '#successModal';
                        messageId = '#successMessage';
                        break;
                    case 'error':
                        modalId = '#errorModal';
                        messageId = '#errorMessage';
                        break;
                    case 'warning':
                        modalId = '#warningModal';
                        messageId = '#warningMessage';
                        break;
                    default:
                        modalId = '#errorModal';
                        messageId = '#errorMessage';
                }
                
                $(messageId).text(message);
                $(modalId).modal('show');
            }

            // Manejar Enter en los campos del formulario
            $('#username, #password').on('keypress', function(e) {
                if (e.which === 13) { // Enter key
                    $('#loginForm').submit();
                }
            });

            // Focus automático en el campo username si está vacío
            $(document).ready(function() {
                if ($('#username').val().trim() === '') {
                    $('#username').focus();
                } else {
                    $('#password').focus();
                }
            });
        </script>
    </body>

</html>