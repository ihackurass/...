<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Recuperar Contraseña - Agua Bendita</title>
        <!-- Bootstrap 4 CSS CDN -->
        <jsp:include page="/components/css_imports.jsp" />


        <style>
            body {
                background-color: #f3f3f3;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }

            .recovery-container {
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 100vh;
                padding: 20px 0;
            }

            .recovery-card {
                background: rgba(255, 255, 255, 0.95);
                border-radius: 20px;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
                padding: 40px;
                width: 100%;
                max-width: 450px;
                text-align: center;
                position: relative;
                overflow: hidden;
            }

            .recovery-header {
                margin-bottom: 30px;
            }

            .recovery-header h2 {
                color: #333;
                font-weight: 700;
                margin-bottom: 10px;
                font-size: 24px;
            }

            .recovery-header p {
                color: #666;
                font-size: 14px;
                margin-bottom: 0;
            }

            .recovery-icon {
                width: 80px;
                height: 80px;
                background-color: #333;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 20px;
                color: white;
                font-size: 2rem;
            }

            .form-group {
                margin-bottom: 20px;
                text-align: left;
            }

            .form-group label {
                font-weight: 600;
                color: #555;
                margin-bottom: 8px;
                display: block;
            }

            .form-control {
                border: 2px solid #e1e5e9;
                border-radius: 10px;
                padding: 12px 15px;
                font-size: 16px;
                transition: all 0.3s ease;
                background-color: #f8f9fa;
            }


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

            .btn-recovery {
                background-color: #000;
                border: none;
                border-radius: 10px;
                padding: 12px 30px;
                font-size: 16px;
                font-weight: 600;
                color: white;
                width: 100%;
                transition: all 0.3s ease;
                margin-top: 10px;
            }

            .btn-recovery:hover:not(:disabled) {
                background-color: #333;
                transform: translateY(-1px);
                color: white;
            }

            .btn-recovery:disabled {
                opacity: 0.7;
                cursor: not-allowed;
            }

            .btn-outline-secondary {
                border: 2px solid #6c757d;
                color: #6c757d;
                background-color: transparent;
                border-radius: 10px;
                padding: 10px 20px;
                font-weight: 600;
                transition: all 0.3s ease;
            }

            .btn-outline-secondary:hover {
                background-color: #6c757d;
                color: white;
            }

            .recovery-footer {
                margin-top: 30px;
                padding-top: 20px;
                border-top: 1px solid #e1e5e9;
            }

            .recovery-footer a {
                color: #333;
                text-decoration: none;
                font-weight: 600;
            }

            .recovery-footer a:hover {
                color: #000;
                text-decoration: none;
            }

            /* Estados de carga */
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

            /* Animación del botón loading */
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

            @keyframes spin {
                to { transform: rotate(360deg); }
            }

            /* Progress steps */
            .progress-steps {
                display: flex;
                justify-content: center;
                margin-bottom: 30px;
            }

            .step {
                width: 30px;
                height: 30px;
                border-radius: 50%;
                background-color: #e1e5e9;
                color: #999;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 10px;
                font-size: 14px;
                font-weight: 600;
                position: relative;
            }

            .step.active {
                background-color: #333;
                color: white;
            }

            .step.completed {
                background-color: #28a745;
                color: white;
            }

            .step:not(:last-child)::after {
                content: '';
                position: absolute;
                top: 50%;
                left: 100%;
                width: 20px;
                height: 2px;
                background-color: #e1e5e9;
                transform: translateY(-50%);
            }

            .step.completed:not(:last-child)::after {
                background-color: #28a745;
            }

            /* Password strength indicator */
            .password-strength {
                height: 4px;
                border-radius: 2px;
                margin-top: 5px;
                transition: all 0.3s;
            }

            .password-strength.weak { background-color: #dc3545; width: 33%; }
            .password-strength.medium { background-color: #ffc107; width: 66%; }
            .password-strength.strong { background-color: #28a745; width: 100%; }

            /* Responsive */
            @media (max-width: 576px) {
                .recovery-card {
                    margin: 10px;
                    padding: 30px 20px;
                }

                .recovery-icon {
                    width: 60px;
                    height: 60px;
                    font-size: 1.5rem;
                }
            }
        </style>
    </head>

    <body data-skip-session-check="true">
        <div class="recovery-container">
            <div class="recovery-card">
                <!-- Progress Steps -->
                <div class="progress-steps">
                    <div class="step active" id="step1">1</div>
                    <div class="step" id="step2">2</div>
                </div>

                <!-- Recovery Icon -->
                <div class="recovery-icon">
                    <i class="fas fa-key"></i>
                </div>

                <!-- Step 1: Validate Secret Key -->
                <div id="validateStep">
                    <div class="recovery-header">
                        <h2><i class="fas fa-shield-alt"></i> Recuperar Contraseña</h2>
                        <p>Ingresa tu usuario y clave secreta para verificar tu identidad</p>
                    </div>

                    <form id="validateForm">
                        <div class="form-group">
                            <label for="usuario">
                                <i class="fas fa-user"></i> Nombre de Usuario
                            </label>
                            <input type="text" class="form-control" id="usuario" name="usuario" 
                                   placeholder="Ingresa tu nombre de usuario" required>
                            <div class="invalid-feedback"></div>
                        </div>

                        <div class="form-group">
                            <label for="clave_secreta">
                                <i class="fas fa-key"></i> Clave Secreta
                            </label>
                            <input type="password" class="form-control" id="clave_secreta" name="clave_secreta" 
                                   placeholder="Ingresa tu clave secreta" required>
                            <div class="invalid-feedback"></div>
                            <small class="form-text text-muted">
                                <i class="fas fa-info-circle"></i> La clave que configuraste al registrarte
                            </small>
                        </div>

                        <button type="submit" class="btn btn-recovery" id="btnValidar">
                            <span class="btn-text">
                                <i class="fas fa-check-circle"></i> Validar Identidad
                            </span>
                        </button>
                    </form>

                    <div class="recovery-footer">
                        <p class="mb-0">
                            ¿Recordaste tu contraseña? 
                            <a href="LoginServlet">
                                <i class="fas fa-sign-in-alt"></i> Iniciar Sesión
                            </a>
                        </p>
                    </div>
                </div>

                <!-- Step 2: Change Password -->
                <div id="changePasswordStep" style="display: none;">
                    <div class="recovery-header">
                        <h2><i class="fas fa-lock"></i> Nueva Contraseña</h2>
                        <p>Crea una nueva contraseña segura para tu cuenta</p>
                    </div>

                    <form id="changePasswordForm">
                        <input type="hidden" id="validated_usuario" name="usuario">
                        
                        <div class="form-group">
                            <label for="nuevaPassword">
                                <i class="fas fa-lock"></i> Nueva Contraseña
                            </label>
                            <input type="password" class="form-control" id="nuevaPassword" name="nuevaPassword" 
                                   placeholder="Mínimo 6 caracteres" required>
                            <div class="password-strength" id="passwordStrength"></div>
                            <div class="invalid-feedback"></div>
                        </div>

                        <div class="form-group">
                            <label for="confirmarPassword">
                                <i class="fas fa-lock"></i> Confirmar Contraseña
                            </label>
                            <input type="password" class="form-control" id="confirmarPassword" name="confirmarPassword" 
                                   placeholder="Repite la nueva contraseña" required>
                            <div class="invalid-feedback"></div>
                        </div>

                        <button type="submit" class="btn btn-recovery" id="btnCambiar">
                            <span class="btn-text">
                                <i class="fas fa-save"></i> Actualizar Contraseña
                            </span>
                        </button>

                        <button type="button" class="btn btn-outline-secondary mt-2" onclick="volverAValidacion()">
                            <i class="fas fa-arrow-left"></i> Volver
                        </button>
                    </form>
                </div>

                <!-- Loading spinner -->
                <div class="loading-spinner" id="loadingSpinner">
                    <div class="spinner-border text-primary" role="status">
                        <span class="sr-only">Procesando...</span>
                    </div>
                    <p class="mt-2" id="loadingText">Validando datos...</p>
                </div>

                <!-- Mensaje de éxito -->
                <div class="success-message" id="successMessage">
                    <i class="fas fa-check-circle fa-3x text-success"></i>
                    <h4 class="mt-2">¡Contraseña actualizada!</h4>
                    <p class="mb-0">Tu contraseña ha sido cambiada exitosamente</p>
                </div>
            </div>
        </div>

        <!-- Modal de Error -->
        <div class="modal fade" id="errorModal" tabindex="-1" role="dialog" aria-labelledby="errorModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered" role="document">
                <div class="modal-content border-danger">
                    <div class="modal-header bg-danger text-white">
                        <h5 class="modal-title" id="errorModalTitle">
                            <i class="fas fa-exclamation-triangle"></i> Error
                        </h5>
                        <button type="button" class="close text-white" data-dismiss="modal" aria-label="Cerrar">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <p id="errorModalMessage"></p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">
                            <i class="fas fa-times"></i> Cerrar
                        </button>
                    </div>
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

        <!-- Scripts -->
        <jsp:include page="/components/js_imports.jsp" />

        <script>
            $(document).ready(function() {
                
                // Funciones de utilidad
                function mostrarErrorCampo(campo, mensaje) {
                    $('#' + campo).addClass('is-invalid').removeClass('is-valid');
                    $('#' + campo).next('.invalid-feedback').text(mensaje);
                }

                function mostrarExitoCampo(campo) {
                    $('#' + campo).addClass('is-valid').removeClass('is-invalid');
                    $('#' + campo).next('.invalid-feedback').text('');
                }

                function limpiarValidaciones() {
                    $('.form-control').removeClass('is-invalid is-valid');
                    $('.invalid-feedback').text('');
                }

                function mostrarError(titulo, mensaje) {
                    $('#errorModalTitle').html(titulo);
                    $('#errorModalMessage').text(mensaje);
                    $('#errorModal').modal('show');
                }

                function mostrarExito(titulo, mensaje) {
                    $('#successModalTitle').html(titulo);
                    $('#successModalMessage').text(mensaje);
                    $('#successModal').modal('show');
                }

                // Validación de fortaleza de contraseña
                $('#nuevaPassword').on('input', function() {
                    const password = $(this).val();
                    const strengthIndicator = $('#passwordStrength');
                    
                    let strength = 0;
                    if (password.length >= 6) strength++;
                    if (password.match(/[a-z]/) && password.match(/[A-Z]/)) strength++;
                    if (password.match(/\d/)) strength++;
                    if (password.match(/[^a-zA-Z\d]/)) strength++;
                    
                    strengthIndicator.removeClass('weak medium strong');
                    if (password.length > 0) {
                        if (strength <= 1) {
                            strengthIndicator.addClass('weak');
                        } else if (strength <= 2) {
                            strengthIndicator.addClass('medium');
                        } else {
                            strengthIndicator.addClass('strong');
                        }
                    }
                });

                // Validación de confirmación de contraseña
                $('#confirmarPassword').on('input', function() {
                    const password = $('#nuevaPassword').val();
                    const confirmPassword = $(this).val();
                    
                    if (confirmPassword.length > 0) {
                        if (password === confirmPassword) {
                            mostrarExitoCampo('confirmarPassword');
                        } else {
                            mostrarErrorCampo('confirmarPassword', 'Las contraseñas no coinciden');
                        }
                    }
                });

                // Paso 1: Validar usuario y clave secreta
                $('#validateForm').on('submit', function(e) {
                    e.preventDefault();
                    
                    const formData = {
                        usuario: $('#usuario').val().trim(),
                        clave_secreta: $('#clave_secreta').val().trim()
                    };

                    // Validaciones básicas
                    let errores = false;

                    if (formData.usuario.length < 3) {
                        mostrarErrorCampo('usuario', 'El usuario debe tener al menos 3 caracteres');
                        errores = true;
                    }

                    if (formData.clave_secreta.length < 3) {
                        mostrarErrorCampo('clave_secreta', 'La clave secreta es requerida');
                        errores = true;
                    }

                    if (errores) {
                        return;
                    }

                    // Mostrar loading
                    $('#validateStep').hide();
                    $('#loadingSpinner').show();
                    $('#loadingText').text('Validando identidad...');
                    $('#btnValidar').addClass('btn-loading').prop('disabled', true);

                    // Enviar validación
                    $.ajax({
                        url: 'ProcesarRecuperacionServlet',
                        type: 'POST',
                        data: {
                            action: 'validateCredentials',
                            usuario: formData.usuario,
                            clave_secreta: formData.clave_secreta
                        },
                        timeout: 10000,
                        success: function(response) {
                            console.log('✅ Respuesta validación:', response);
                            
                            if (response.success) {
                                // Validación exitosa, pasar al siguiente paso
                                $('#loadingSpinner').hide();
                                $('#step1').removeClass('active').addClass('completed');
                                $('#step2').addClass('active');
                                $('#validated_usuario').val(formData.usuario);
                                $('#changePasswordStep').show();
                                
                            } else {
                                // Error en validación
                                $('#loadingSpinner').hide();
                                $('#validateStep').show();
                                $('#btnValidar').removeClass('btn-loading').prop('disabled', false);
                                
                                mostrarError(
                                    '<i class="fas fa-exclamation-triangle"></i> Validación Fallida',
                                    response.message || 'Usuario o clave secreta incorrectos'
                                );
                            }
                        },
                        error: function(xhr, status, error) {
                            console.error('❌ Error en validación:', error);
                            
                            $('#loadingSpinner').hide();
                            $('#validateStep').show();
                            $('#btnValidar').removeClass('btn-loading').prop('disabled', false);
                            
                            let errorMessage = 'Error al conectar con el servidor. Intenta de nuevo.';
                            if (status === 'timeout') {
                                errorMessage = 'La solicitud tardó demasiado. Intenta de nuevo.';
                            }
                            
                            mostrarError(
                                '<i class="fas fa-exclamation-triangle"></i> Error de Conexión',
                                errorMessage
                            );
                        }
                    });
                });

                // Paso 2: Cambiar contraseña
                $('#changePasswordForm').on('submit', function(e) {
                    e.preventDefault();
                    
                    const formData = {
                        usuario: $('#validated_usuario').val(),
                        nuevaPassword: $('#nuevaPassword').val(),
                        confirmarPassword: $('#confirmarPassword').val()
                    };

                    // Validaciones
                    let errores = false;

                    if (formData.nuevaPassword.length < 6) {
                        mostrarErrorCampo('nuevaPassword', 'La contraseña debe tener al menos 6 caracteres');
                        errores = true;
                    }

                    if (formData.nuevaPassword !== formData.confirmarPassword) {
                        mostrarErrorCampo('confirmarPassword', 'Las contraseñas no coinciden');
                        errores = true;
                    }

                    if (errores) {
                        return;
                    }

                    // Mostrar loading
                    $('#changePasswordStep').hide();
                    $('#loadingSpinner').show();
                    $('#loadingText').text('Actualizando contraseña...');
                    $('#btnCambiar').addClass('btn-loading').prop('disabled', true);

                    // Enviar cambio de contraseña
                    $.ajax({
                        url: 'ProcesarRecuperacionServlet',
                        type: 'POST',
                        data: {
                            action: 'changePassword',
                            usuario: formData.usuario,
                            nuevaPassword: formData.nuevaPassword,
                            confirmarPassword: formData.confirmarPassword
                        },
                        timeout: 10000,
                        success: function(response) {
                            console.log('✅ Respuesta cambio password:', response);
                            
                            if (response.success) {
                                // Contraseña cambiada exitosamente
                                $('#loadingSpinner').hide();
                                $('#successMessage').show();
                                
                                // Redirigir al login después de 3 segundos
                                setTimeout(function() {
                                    mostrarExito(
                                        '<i class="fas fa-check-circle"></i> ¡Contraseña Actualizada!',
                                        '¡Tu contraseña ha sido cambiada exitosamente! Serás redirigido al login.'
                                    );
                                    
                                    $('#successModal').on('hidden.bs.modal', function() {
                                        window.location.href = 'LoginServlet';
                                    });
                                }, 2000);
                                
                            } else {
                                // Error al cambiar contraseña
                                $('#loadingSpinner').hide();
                                $('#changePasswordStep').show();
                                $('#btnCambiar').removeClass('btn-loading').prop('disabled', false);
                                
                                mostrarError(
                                    '<i class="fas fa-exclamation-triangle"></i> Error al Actualizar',
                                    response.message || 'Error al actualizar la contraseña'
                                );
                            }
                        },
                        error: function(xhr, status, error) {
                            console.error('❌ Error en cambio password:', error);
                            
                            $('#loadingSpinner').hide();
                            $('#changePasswordStep').show();
                            $('#btnCambiar').removeClass('btn-loading').prop('disabled', false);
                            
                            let errorMessage = 'Error al cambiar la contraseña. Intenta de nuevo.';
                            if (status === 'timeout') {
                                errorMessage = 'La solicitud tardó demasiado. Intenta de nuevo.';
                            }
                            
                            mostrarError(
                                '<i class="fas fa-exclamation-triangle"></i> Error de Conexión',
                                errorMessage
                            );
                        }
                    });
                });

                // Función para volver al paso de validación
                window.volverAValidacion = function() {
                    $('#changePasswordStep').hide();
                    $('#validateStep').show();
                    $('#step2').removeClass('active');
                    $('#step1').removeClass('completed').addClass('active');
                    $('#btnValidar').removeClass('btn-loading').prop('disabled', false);
                    limpiarValidaciones();
                };

                // Limpiar validaciones al escribir
                $('.form-control').on('input', function() {
                    $(this).removeClass('is-invalid');
                });
            });
        </script>
    </body>
</html>