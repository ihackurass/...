// ============= MANEJO GLOBAL DE SESIONES =============

$(document).ready(function() {
    setupGlobalAjaxHandlers();
    
    if (shouldSkipPeriodicCheck()) {
        console.log('ℹ️ Session handler: Solo AJAX handlers (verificación periódica desactivada)');
    } else {
        startUserStatusChecker(0.167); // 10 segundos
        console.log('✅ Session handler completo inicializado (con verificación periódica)');
    }
});

/**
 * Determina si se debe EVITAR la verificación periódica
 */
function shouldSkipPeriodicCheck() {
    // Verificar si la página tiene el atributo data-skip-session-check
    const skipCheck = $('body').data('skip-session-check') || $('html').data('skip-session-check');
    
    // Si está explícitamente definido como true, evitar verificación periódica
    return skipCheck === true || skipCheck === 'true';
}

/**
 * Configura manejadores globales para todas las peticiones AJAX
 */
function setupGlobalAjaxHandlers() {
    // Interceptar TODAS las peticiones AJAX
    $(document).ajaxComplete(function(event, xhr, settings) {
        // Verificar respuestas de error de autenticación
        if (xhr.status === 401 || xhr.status === 403) {
            try {
                const response = JSON.parse(xhr.responseText);
                
                if (response.sessionExpired) {
                    handleSessionExpired(response.message);
                    return;
                } else if (response.loginRequired) {
                    handleLoginRequired(response.message);
                    return;
                } else if (response.accountSuspended) {
                    handleAccountSuspended(response.message);
                    return;
                } else if (response.accessDenied) {
                    handleAccessDenied(response.message);
                    return;
                }
            } catch (e) {
                // No es JSON, verificar si es HTML de login
                if (xhr.responseText && xhr.responseText.includes('<title>Login - Agua Bendita</title>')) {
                    handleSessionExpired("Tu sesión ha expirado. Redirigiendo al login...");
                    return;
                }
            }
        }
    });

    // Manejar errores de conexión
    $(document).ajaxError(function(event, xhr, settings, thrownError) {
        if (xhr.status === 401 || xhr.status === 403) {
            // Ya manejado en ajaxComplete
            return;
        }
        
        if (xhr.status === 0 && thrownError === '') {
            // Posible redirección o problema de sesión
            console.warn('⚠️ Posible problema de sesión detectado');
        }
    });
}

/**
 * Maneja cuando la sesión ha expirado
 */
function handleSessionExpired(message) {
    console.log('⏰ Sesión expirada detectada');
    
    // Mostrar modal de advertencia
    showSessionModal('warning', message || 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.');
    
    // Redirigir después de 3 segundos
    setTimeout(function() {
        window.location.href = 'LoginServlet';
    }, 3000);
}

/**
 * Maneja cuando se requiere login
 */
function handleLoginRequired(message) {
    console.log('🔒 Login requerido detectado');
    
    // Mostrar modal de advertencia
    showSessionModal('warning', message || 'Debes iniciar sesión para acceder a esta página.');
    
    // Redirigir después de 2 segundos
    setTimeout(function() {
        window.location.href = 'LoginServlet';
    }, 2000);
}

/**
 * Maneja cuando la cuenta está suspendida
 */
function handleAccountSuspended(message) {
    console.log('🚫 Cuenta suspendida detectada');
    
    // Mostrar modal de error
    showSessionModal('error', message || 'Tu cuenta ha sido suspendida. Contacta al administrador.');
    
    // Redirigir después de 4 segundos
    setTimeout(function() {
        window.location.href = 'LoginServlet';
    }, 4000);
}

/**
 * Maneja cuando se niega el acceso
 */
function handleAccessDenied(message) {
    console.log('🛡️ Acceso denegado detectado');
    
    // Mostrar modal de error
    showSessionModal('error', message || 'No tienes permisos para acceder a esta página.');
    
    // Redirigir al home después de 3 segundos
    setTimeout(function() {
        window.location.href = 'HomeServlet';
    }, 3000);
}

/**
 * Muestra modal para problemas de sesión
 */
function showSessionModal(type, message) {
    // Determinar configuración del modal según el tipo
    let modalConfig = {
        title: '',
        headerClass: '',
        icon: '',
        redirectText: ''
    };
    
    switch(type) {
        case 'warning':
            modalConfig = {
                title: 'Sesión Expirada',
                headerClass: 'bg-warning text-dark',
                icon: 'fas fa-exclamation-triangle',
                redirectText: 'Redirigiendo al login...'
            };
            break;
        case 'error':
            modalConfig = {
                title: 'Acceso Denegado',
                headerClass: 'bg-danger text-white',
                icon: 'fas fa-ban',
                redirectText: 'Redirigiendo...'
            };
            break;
        default:
            modalConfig = {
                title: 'Atención',
                headerClass: 'bg-info text-white',
                icon: 'fas fa-info-circle',
                redirectText: 'Redirigiendo...'
            };
    }
    
    // Crear modal dinámicamente si no existe
    if ($('#sessionModal').length === 0) {
        const modalHtml = `
            <div class="modal fade" id="sessionModal" tabindex="-1" role="dialog">
                <div class="modal-dialog" role="document">
                    <div class="modal-content border-warning">
                        <div class="modal-header" id="sessionModalHeader">
                            <h5 class="modal-title" id="sessionModalTitle">
                                <i id="sessionModalIcon"></i> <span id="sessionModalTitleText"></span>
                            </h5>
                        </div>
                        <div class="modal-body">
                            <p id="sessionMessage"></p>
                            <div class="text-center">
                                <div class="spinner-border text-warning" role="status">
                                    <span class="sr-only">Cargando...</span>
                                </div>
                                <p class="mt-2" id="redirectText"></p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `;
        $('body').append(modalHtml);
    }
    
    // Configurar modal
    $('#sessionModalHeader').attr('class', 'modal-header ' + modalConfig.headerClass);
    $('#sessionModalIcon').attr('class', modalConfig.icon);
    $('#sessionModalTitleText').text(modalConfig.title);
    $('#sessionMessage').text(message);
    $('#redirectText').text(modalConfig.redirectText);
    
    // Mostrar modal
    $('#sessionModal').modal({
        backdrop: 'static',
        keyboard: false
    });
}

/**
 * Función para hacer peticiones AJAX "seguras" con manejo de sesión
 */
function safeAjax(options) {
    // Agregar headers para detectar AJAX
    const defaultOptions = {
        headers: {
            'X-Requested-With': 'XMLHttpRequest'
        },
        error: function(xhr, status, error) {
            // El manejo global se encarga de sesiones expiradas
            if (xhr.status !== 401 && xhr.status !== 403) {
                // Manejar otros errores específicos aquí
                console.error('Error en petición AJAX:', error);
                
                // Opcional: mostrar mensaje de error genérico
                if (typeof showErrorMessage === 'function') {
                    showErrorMessage('Error de conexión. Por favor, intenta de nuevo.');
                }
            }
        }
    };
    
    // Combinar opciones
    const finalOptions = $.extend(true, defaultOptions, options);
    
    return $.ajax(finalOptions);
}

// ============= UTILIDADES ADICIONALES =============

/**
 * Verifica el estado del usuario (sesión, ban, etc.) manualmente
 */
function checkUserStatus() {
    return safeAjax({
        url: 'CheckSessionServlet',
        type: 'GET',
        timeout: 5000,
        success: function(response) {
            if (!response.sessionValid) {
                handleSessionExpired('Tu sesión ha expirado.');
                return false;
            } else if (response.userBanned) {
                handleAccountSuspended('Tu cuenta ha sido suspendida. Contacta al administrador.');
                return false;
            }
            return true;
        },
        error: function(xhr) {
            if (xhr.status === 401) {
                handleSessionExpired('Tu sesión ha expirado.');
                return false;
            } else if (xhr.status === 403) {
                try {
                    const response = JSON.parse(xhr.responseText);
                    if (response.accountSuspended) {
                        handleAccountSuspended(response.message);
                    } else {
                        handleAccessDenied(response.message);
                    }
                } catch (e) {
                    handleAccessDenied('No tienes permisos para continuar.');
                }
                return false;
            }
            return true;
        }
    });
}

/**
 * Inicia verificador periódico de estado de usuario (solo si se requiere)
 */
function startUserStatusChecker(intervalMinutes = 0.167) { // 10 segundos por defecto
    // Verificar estado cada X minutos
    const intervalId = setInterval(function() {
        checkUserStatus();
    }, intervalMinutes * 60 * 1000);
    
    const seconds = Math.round(intervalMinutes * 60);
    console.log(`🔄 Verificador de estado de usuario iniciado (cada ${seconds} segundos)`);
    
    return intervalId;
}

/**
 * Inicia el session handler solo si la página lo requiere explícitamente
 */
function startSessionHandlerIfNeeded() {
    if (shouldInitializeSessionHandler()) {
        startUserStatusChecker(0.167); // 10 segundos
        console.log('🔄 Verificación periódica activada');
    }
}
