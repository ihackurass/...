<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Registro - Agua Bendita</title>
        <!-- Bootstrap 4 CSS CDN -->
        <jsp:include page="/components/css_imports.jsp" />


        <style>
            body {
                background-color: #f3f3f3;
            }

            .register-container {
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 100vh;
                padding: 20px 0;
            }

            .register-card {
                display: flex;
                width: 100%;
                max-width: 1000px;
                min-height: 700px;
                border-radius: 10px;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
                overflow: hidden;
                background-color: #fff;
            }

            .register-form {
                width: 50%;
                padding: 40px;
                display: flex;
                flex-direction: column;
                justify-content: center;
            }

            .register-form h2 {
                font-size: 24px;
                font-weight: bold;
                color: #333;
                margin-bottom: 20px;
                text-align: center;
            }

            .register-logo {
                width: 50%;
                background-color: #3b82f6;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
                padding: 20px;
            }

            .register-logo img {
                width: 250px;
                height: auto;
                margin-bottom: 20px;
            }

            .register-logo h3 {
                color: #ffffff;
                font-size: 20px;
                font-weight: bold;
                text-align: center;
            }

            .register-logo p {
                color: #ffffff;
                font-size: 14px;
                text-align: center;
            }

            .register-form .form-group {
                margin-bottom: 15px;
            }

            .register-form .form-control {
                border-radius: 5px;
                padding: 10px;
                border: 1px solid #ddd;
                transition: border-color 0.3s;
            }

            .register-form .form-control:focus {
                border-color: #3b82f6;
                box-shadow: 0 0 0 0.2rem rgba(59, 130, 246, 0.25);
            }

            .register-form .form-check-label {
                font-size: 14px;
                color: #555;
            }

            .register-form button {
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

            .register-form button:hover:not(:disabled) {
                background-color: #333;
            }

            .register-form .register-link {
                font-size: 14px;
                color: #555;
                margin-top: 15px;
                text-align: center;
            }

            .register-form .register-link a {
                color: #3b82f6;
                text-decoration: none;
                margin-left: 5px;
            }

            .register-form .register-link a:hover {
                text-decoration: underline;
            }

            /* Estilos para validaciones */
            .form-control.is-invalid {
                border-color: #dc3545;
                background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' fill='none' stroke='%23dc3545' viewBox='0 0 12 12'%3e%3ccircle cx='6' cy='6' r='4.5'/%3e%3cpath stroke-linejoin='round' d='M5.8 3.6h.4L6 6.5z'/%3e%3ccircle cx='6' cy='8.2' r='.6' fill='%23dc3545' stroke='none'/%3e%3c/svg%3e");
                background-repeat: no-repeat;
                background-position: right calc(0.375em + 0.1875rem) center;
                background-size: calc(0.75em + 0.375rem) calc(0.75em + 0.375rem);
            }

            .form-control.is-valid {
                border-color: #28a745;
                background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' width='8' height='8' viewBox='0 0 8 8'%3e%3cpath fill='%2328a745' d='m2.3 6.73.4.7 3.1-3.2.7-.3.2-1.4L6.6 2l-.7.7L3.4 5.2l-.7-1.2-.4-.4L2.3 4z'/%3e%3c/svg%3e");
                background-repeat: no-repeat;
                background-position: right calc(0.375em + 0.1875rem) center;
                background-size: calc(0.75em + 0.375rem) calc(0.75em + 0.375rem);
            }

            .invalid-feedback {
                display: block;
                width: 100%;
                margin-top: 0.25rem;
                font-size: 0.875em;
                color: #dc3545;
            }

            .valid-feedback {
                display: block;
                width: 100%;
                margin-top: 0.25rem;
                font-size: 0.875em;
                color: #28a745;
            }

            .loading-spinner {
                display: none;
                text-align: center;
                margin: 20px 0;
                padding: 20px;
            }

            .success-message {
                display: none;
                text-align: center;
                color: #28a745;
                margin: 20px 0;
                padding: 20px;
            }

            .success-message i {
                color: #28a745;
                margin-bottom: 10px;
            }

            .btn-loading {
                position: relative;
                pointer-events: none;
                opacity: 0.8;
            }

            .btn-loading .btn-text {
                opacity: 0;
            }

            .btn-loading::after {
                content: "";
                position: absolute;
                width: 16px;
                height: 16px;
                top: 50%;
                left: 50%;
                margin-left: -8px;
                margin-top: -8px;
                border: 2px solid #ffffff;
                border-radius: 50%;
                border-top-color: transparent;
                animation: spin 1s linear infinite;
            }

            .register-footer {
                margin-top: 30px;
                padding-top: 20px;
                border-top: 1px solid #e1e5e9;
                text-align: center;
            }

            .register-footer p {
                font-size: 14px;
                color: #555;
                margin-bottom: 10px !important;
            }

            .register-footer a {
                color: #007bff;
                text-decoration: none;
                font-weight: 600;
                margin-left: 5px;
            }

            .register-footer a:hover {
                color: #0056b3;
                text-decoration: none;
            }

            .register-footer a i {
                margin-right: 3px;
            }
            @keyframes spin {
                to { transform: rotate(360deg); }
            }

            /* Responsivo */
            @media (max-width: 768px) {
                .register-container {
                    padding: 10px;
                }

                .register-card {
                    flex-direction: column;
                    max-width: 500px;
                }

                .register-form {
                    width: 100%;
                    padding: 30px 20px;
                }

                .register-logo {
                    width: 100%;
                    padding: 30px 20px;
                }

                .register-logo img {
                    width: 200px;
                }
            }

            /* Indicador de fortaleza de contraseña */
            .password-strength {
                height: 4px;
                border-radius: 2px;
                margin-top: 5px;
                transition: all 0.3s;
            }

            .password-strength.weak { background-color: #dc3545; width: 33%; }
            .password-strength.medium { background-color: #ffc107; width: 66%; }
            .password-strength.strong { background-color: #28a745; width: 100%; }
        </style>
    </head>

    <body data-skip-session-check="true">
        <div class="register-container">
            <div class="register-card">
                <!-- Register Form Section -->
                <div class="register-form">
                    <h2><i class="fas fa-user-plus"></i> Registro</h2>

                    <!-- Formulario con Ajax -->
                    <form id="registerForm">
                        <div class="form-group">
                            <label for="nombre_completo">
                                <i class="fas fa-user"></i> Nombre Completo
                            </label>
                            <input type="text" class="form-control" id="nombre_completo" name="nombre_completo" 
                                   placeholder="Ingresa tu nombre completo" required>
                            <div class="invalid-feedback"></div>
                        </div>

                        <div class="form-group">
                            <label for="username">
                                <i class="fas fa-at"></i> Usuario
                            </label>
                            <input type="text" class="form-control" id="username" name="username" 
                                   placeholder="Elige un nombre de usuario" required>
                            <div class="invalid-feedback"></div>
                        </div>

                        <div class="form-group">
                            <label for="email">
                                <i class="fas fa-envelope"></i> Correo Electrónico
                            </label>
                            <input type="email" class="form-control" id="email" name="email" 
                                   placeholder="tu@email.com" required>
                            <div class="invalid-feedback"></div>
                        </div>

                        <div class="form-group">
                            <label for="telefono">
                                <i class="fas fa-phone"></i> Teléfono
                            </label>
                            <input type="text" class="form-control" id="telefono" name="telefono" 
                                   placeholder="+51 999 999 999" required>
                            <div class="invalid-feedback"></div>
                        </div>

                        <div class="form-group">
                            <label for="password">
                                <i class="fas fa-lock"></i> Contraseña
                            </label>
                            <input type="password" class="form-control" id="password" name="password" 
                                   placeholder="Mínimo 6 caracteres" required>
                            <div class="invalid-feedback"></div>
                        </div>

                        <div class="form-check" style="margin-bottom: 20px;">
                            <input type="checkbox" class="form-check-input" id="remember">
                            <label class="form-check-label" for="remember">
                                Recordar Contraseña
                            </label>
                        </div>

                        <button type="submit" class="btn btn-dark" id="btnRegistrar">
                            <span class="btn-text">
                                <i class="fas fa-user-plus"></i> REGISTRAR
                            </span>
                        </button>
                    </form>

                    <!-- Loading spinner -->
                    <div class="loading-spinner" id="loadingSpinner">
                        <div class="spinner-border text-primary" role="status">
                            <span class="sr-only">Registrando...</span>
                        </div>
                        <p class="mt-2">Creando tu cuenta...</p>
                    </div>

                    <!-- Mensaje de éxito -->
                    <div class="success-message" id="successMessage">
                        <i class="fas fa-check-circle fa-3x text-success"></i>
                        <p class="mt-2">¡Cuenta creada exitosamente!</p>
                    </div>

                    <!-- Footer con enlaces -->
                    <div class="register-footer">
                        <p class="mb-0">
                            ¿Ya tienes cuenta? 
                            <a href="LoginServlet">
                                <i class="fas fa-sign-in-alt"></i> Inicia Sesión
                            </a>
                        </p>
                    </div>
                </div>

                <!-- Logo Section -->
                <div class="register-logo">
                    <img src="assets/images/logo.jpg" alt="Logo Agua Bendita">
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
                        <button type="button" class="close text-white" data-dismiss="modal" aria-label="Cerrar">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <p id="errorMessage"></p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal Clave Secreta -->
        <div class="modal fade" id="claveModal" tabindex="-1" aria-labelledby="claveModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title" id="claveModalLabel">
                            <i class="fas fa-key"></i> Configura tu clave secreta
                        </h5>
                        <button type="button" class="close text-white" data-dismiss="modal" aria-label="Cerrar">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <form id="claveForm">
                        <div class="modal-body">
                            <input type="hidden" id="usuario_id_clave" name="usuario_id">
                            <div class="form-group">
                                <label for="clave_secreta">Clave secreta para recuperación de cuenta</label>
                                <input type="text" class="form-control" id="clave_secreta" name="clave_secreta" 
                                       placeholder="Escribe una clave que puedas recordar" required>
                                <small class="form-text text-muted">
                                    Esta clave te ayudará a recuperar tu cuenta si olvidas tu contraseña.
                                </small>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="submit" class="btn btn-primary" id="btnGuardarClave">
                                <i class="fas fa-save"></i> Guardar
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Modal de Éxito -->
        <div class="modal fade" id="successModal" tabindex="-1" role="dialog" aria-labelledby="successModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered" role="document">
                <div class="modal-content border-success">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title" id="successModalTitle">
                            <i class="fas fa-check-circle"></i> Éxito
                        </h5>
                        <button type="button" class="close text-white" data-dismiss="modal" aria-label="Cerrar">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <p id="successModalMessage"></p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-success" data-dismiss="modal">
                            <i class="fas fa-check"></i> Continuar
                        </button>
                    </div>
                </div>
            </div>
        </div>
        <!-- Bootstrap 4 JS, Popper.js and jQuery -->
        <jsp:include page="/components/js_imports.jsp" />


        <script>
            $(document).ready(function() {
                
                // Función para limpiar validaciones
                function limpiarValidaciones() {
                    $('.form-control').removeClass('is-invalid is-valid');
                    $('.invalid-feedback').text('');
                }

                // Función para mostrar error en campo específico
                function mostrarErrorCampo(campo, mensaje) {
                    $('#' + campo).removeClass('is-valid').addClass('is-invalid');
                    $('#' + campo).next('.invalid-feedback').text(mensaje);
                }

                // Función para mostrar éxito en campo
                function mostrarExitoCampo(campo, mensaje = '') {
                   $('#' + campo).addClass('is-valid').removeClass('is-invalid');
                   $('#' + campo).next('.invalid-feedback').text('');
                   if (mensaje) {
                       $('#' + campo).siblings('.valid-feedback').text(mensaje);
                   }
                }
                function limpiarErrorCampo(campo) {
                    $('#' + campo).removeClass('is-invalid');
                    $('#' + campo).next('.invalid-feedback').text('');
                }
                // Validaciones en tiempo real
                $('#username').on('blur', function() {
                    const username = $(this).val().trim();
                    if (username.length >= 3) {
                        // Verificar disponibilidad del username
                        $.ajax({
                            url: 'RegisterServlet',
                            type: 'POST',
                            data: {
                                action: 'checkUsername',
                                username: username
                            },
                            success: function(response) {
                                if (response.available) {
                                    mostrarExitoCampo('username');
                                } else {
                                    mostrarErrorCampo('username', 'Este nombre de usuario ya está en uso');
                                }
                            }
                        });
                    } else {
                        //limpiarErrorCampo("username"); // MOVER ESTO AQUÍ
                    }
                    // limpiarErrorCampo("username"); // QUITAR ESTA LÍNEA
                });


                $('#email').on('blur', function() {
                    const email = $(this).val().trim();
                    if (email.includes('@')) {
                        // Verificar disponibilidad del email
                        $.ajax({
                            url: 'RegisterServlet',
                            type: 'POST',
                            data: {
                                action: 'checkEmail',
                                email: email
                            },
                            success: function(response) {
                                if (response.available) {
                                    mostrarExitoCampo('email');
                                } else {
                                    mostrarErrorCampo('email', 'Este correo ya está registrado');
                                }
                            }
                        });
                    } else {
                        //limpiarErrorCampo("email"); // MOVER ESTO AQUÍ
                    }
                    // limpiarErrorCampo("email"); // QUITAR ESTA LÍNEA
                });

                // Envío del formulario de registro
                $('#registerForm').on('submit', function(e) {
                    e.preventDefault();
                    
                    // Limpiar validaciones previas
                    limpiarValidaciones();
                    
                    // Obtener datos del formulario
                    const formData = {
                        nombre_completo: $('#nombre_completo').val().trim(),
                        username: $('#username').val().trim(),
                        email: $('#email').val().trim(),
                        telefono: $('#telefono').val().trim(),
                        password: $('#password').val()
                    };

                    // Validaciones básicas
                    let errores = false;

                    if (formData.nombre_completo.length < 2) {
                        mostrarErrorCampo('nombre_completo', 'El nombre completo debe tener al menos 2 caracteres');
                        errores = true;
                    }

                    if (formData.username.length < 3) {
                        mostrarErrorCampo('username', 'El usuario debe tener al menos 3 caracteres');
                        errores = true;
                    }

                    if (!formData.email.includes('@') || !formData.email.includes('.')) {
                        mostrarErrorCampo('email', 'Ingresa un correo válido');
                        errores = true;
                    }

                    if (formData.telefono.length < 9) {
                        mostrarErrorCampo('telefono', 'Ingresa un teléfono válido');
                        errores = true;
                    }

                    if (formData.password.length < 6) {
                        mostrarErrorCampo('password', 'La contraseña debe tener al menos 6 caracteres');
                        errores = true;
                    }

                    if (errores) {
                        return;
                    }

                    // Mostrar loading
                    $('#registerForm').hide();
                    $('#loadingSpinner').show();
                    $('#btnRegistrar').addClass('btn-loading');

                    // Enviar registro
                    $.ajax({
                        url: 'RegisterServlet',
                        type: 'POST',
                        data: formData,
                        success: function(response) {
                            console.log('Respuesta del servidor:', response);
                            
                            if (response.success) {
                                // Mostrar mensaje de éxito
                                $('#loadingSpinner').hide();
                                $('#successMessage').show();
                                
                                // Si necesita configurar clave secreta
                                if (response.success && response.requireSecretKey && response.userId && response.userId !== "0") {
                                    setTimeout(function() {
                                        $('#successMessage').hide();
                                        $('#registerForm').show();
                                        $('#btnRegistrar').removeClass('btn-loading');
                                        
                                        // Mostrar modal de clave secreta
                                        $('#usuario_id_clave').val(response.userId);
                                        $('#claveModal').modal('show');
                                    }, 2000);
                                } else {
                                    // Redirigir al login después de 3 segundos
                                    setTimeout(function() {
                                        window.location.href = 'LoginServlet';
                                    }, 2000);
                                }
                            } else {
                                // Mostrar errores específicos
                                $('#loadingSpinner').hide();
                                $('#registerForm').show();
                                $('#btnRegistrar').removeClass('btn-loading');
                                
                                if (response.fieldErrors) {
                                    Object.keys(response.fieldErrors).forEach(function(field) {
                                        mostrarErrorCampo(field, response.fieldErrors[field]);
                                    });
                                } else {
                                    $('#errorMessage').text(response.message || 'Error al registrar usuario');
                                    $('#errorModal').modal('show');
                                }
                            }
                        },
                        error: function(xhr, status, error) {
                            console.error('Error en registro:', error);
                            
                            $('#loadingSpinner').hide();
                            $('#registerForm').show();
                            $('#btnRegistrar').removeClass('btn-loading');
                            
                            let errorMessage = 'Error al registrar usuario. Intenta de nuevo.';
                            
                            try {
                                const errorResponse = JSON.parse(xhr.responseText);
                                if (errorResponse.message) {
                                    errorMessage = errorResponse.message;
                                }
                            } catch (e) {
                                // Si no es JSON, usar mensaje por defecto
                            }
                            
                            $('#errorMessage').text(errorMessage);
                            $('#errorModal').modal('show');
                        }
                    });
                });

                // Envío del formulario de clave secreta
                $('#claveForm').on('submit', function(e) {
                    e.preventDefault();
                    
                    const userId = $('#usuario_id_clave').val();
                    const claveSecreta = $('#clave_secreta').val().trim();
                    
                    if (claveSecreta.length < 3) {
                        alert('La clave secreta debe tener al menos 3 caracteres');
                        return;
                    }
                    
                    $('#btnGuardarClave').prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Guardando...');
                    
                    $.ajax({
                       url: 'RegisterServlet',
                       type: 'POST',
                       data: {
                           action: 'guardarClave',
                           usuario_id: userId,
                           clave_secreta: claveSecreta
                       },
                       success: function(response) {
                           if (response.success) {
                               $('#claveModal').modal('hide');

                               // Mostrar modal de éxito
                               $('#successModalTitle').html('<i class="fas fa-check-circle"></i> ¡Éxito!');
                               $('#successModalMessage').text('¡Clave secreta guardada correctamente! Ahora puedes iniciar sesión.');
                               $('#successModal').modal('show');

                               // Redirigir después de cerrar el modal
                               $('#successModal').on('hidden.bs.modal', function() {
                                   window.location.href = 'LoginServlet';
                               });

                           } else {
                               // Mostrar modal de error
                               $('#errorModalTitle').html('<i class="fas fa-exclamation-triangle"></i> Error');
                               $('#errorModalMessage').text(response.message || 'Error al guardar la clave secreta');
                               $('#errorModal').modal('show');

                               $('#btnGuardarClave').prop('disabled', false).html('<i class="fas fa-save"></i> Guardar');
                           }
                       },
                       error: function() {
                           // Mostrar modal de error
                           $('#errorModalTitle').html('<i class="fas fa-exclamation-triangle"></i> Error de Conexión');
                           $('#errorModalMessage').text('Error al guardar la clave secreta. Intenta de nuevo.');
                           $('#errorModal').modal('show');

                           $('#btnGuardarClave').prop('disabled', false).html('<i class="fas fa-save"></i> Guardar');
                       }
                    });
                });

                // Limpiar modal al cerrarse
                $('#claveModal').on('hidden.bs.modal', function() {
                    $('#claveForm')[0].reset();
                    $('#btnGuardarClave').prop('disabled', false).html('<i class="fas fa-save"></i> Guardar');
                });
            });
        </script>
    </body>
</html>