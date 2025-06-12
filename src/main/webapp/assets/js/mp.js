/**
 * donations.js - Sistema completo de donaciones con Mercado Pago Checkout Pro
 * Adaptado para la estructura actual de Agua Bendita
 */

$(document).ready(function() {
    console.log('🚀 Sistema de donaciones con Mercado Pago iniciado');
    setupDonationHandlers();
});

/**
 * Configurar todos los manejadores de eventos
 */
function setupDonationHandlers() {
    console.log('⚙️ Configurando manejadores de eventos...');
    
    // Botón principal de procesar donación
    $(document).on('click', '#processDonationBtn', function() {
        processDonation();
    });
    
    // Validaciones en tiempo real del monto
    $(document).on('input', '#donationAmount', function() {
        updateTotal();
        validateDonationAmount();
        validateForm();
    });
    
    // Validaciones en tiempo real de campos requeridos
    $(document).on('input change', '#donorName, #donorEmail', function() {
        validateForm();
    });
    
    // Formatear email automáticamente
    $(document).on('blur', '#donorEmail', function() {
        $(this).val($(this).val().toLowerCase().trim());
        validateForm();
    });
    
    // Validar cuando se abre el modal
    $('#donationModal').on('shown.bs.modal', function() {
        setTimeout(() => {
            validateForm();
            $('#donationAmount').focus().select();
        }, 300);
    });
    
    // Limpiar cuando se cierra el modal
    $('#donationModal').on('hidden.bs.modal', function() {
        resetDonationForm();
    });
    
    console.log('✅ Manejadores configurados correctamente');
}

/**
 * TU FUNCIÓN ACTUAL - Adaptada para Mercado Pago
 * Esta reemplaza tu función openDonationModal existente
 */
function openDonationModal(publicationId, nombreCompleto, nombreUsuario, creatorId) {
    console.log('💰 Abriendo modal de donación:', { 
        publicationId, 
        creatorId, 
        nombreCompleto, 
        nombreUsuario 
    });
    
    // Validar que tenemos los datos necesarios
    if (!creatorId && !publicationId) {
        console.error('❌ Faltan datos: creatorId o publicationId');
        showError('Error: No se pudo identificar al destinatario');
        return;
    }
    
    // Si no tenemos creatorId, intentar extraerlo del contexto
    if (!creatorId) {
        creatorId = extractCreatorIdFromButton(event.target, publicationId);
        if (!creatorId) {
            showError('Error: No se pudo identificar al usuario destinatario');
            return;
        }
    }
    
    // Configurar modal con los datos
    $('#donationModal').data('publication-id', publicationId);
    $('#donationModal').data('creator-id', creatorId);
    
    // Actualizar información del destinatario en el modal
    $('.creator-name').text(nombreCompleto || 'Usuario');
    $('#donationUserHandle').text(nombreUsuario || '@usuario');
    
    // Buscar y actualizar avatar del usuario
    updateUserAvatar(creatorId);
    
    // Limpiar y resetear formulario
    resetDonationForm();
    
    // Mostrar modal
    $('#donationModal').modal('show');
    
    console.log('✅ Modal abierto correctamente');
}

/**
 * Función helper para extraer creator ID del contexto
 */
function extractCreatorIdFromButton(buttonElement, publicationId) {
    try {
        // Opción 1: Buscar data-creator-id en el botón
        const $button = $(buttonElement).closest('button');
        let creatorId = $button.data('creator-id');
        
        if (creatorId) {
            console.log('🔍 Creator ID encontrado en botón:', creatorId);
            return creatorId;
        }
        
        // Opción 2: Buscar en el contenedor de la publicación
        const $publication = $button.closest('.publication, .post, .card');
        creatorId = $publication.data('creator-id') || $publication.data('user-id');
        
        if (creatorId) {
            console.log('🔍 Creator ID encontrado en publicación:', creatorId);
            return creatorId;
        }
        
        // Opción 3: Buscar en elementos con data attributes
        creatorId = $publication.find('[data-creator-id], [data-user-id]').first().data('creator-id') || 
                   $publication.find('[data-creator-id], [data-user-id]').first().data('user-id');
        
        if (creatorId) {
            console.log('🔍 Creator ID encontrado en elemento hijo:', creatorId);
            return creatorId;
        }
        
        console.warn('⚠️ No se encontró creator ID en el contexto');
        return null;
        
    } catch (error) {
        console.error('❌ Error extrayendo creator ID:', error);
        return null;
    }
}

/**
 * Actualizar avatar del usuario en el modal
 */
function updateUserAvatar(creatorId) {
    try {
        // Buscar avatar existente en la página
        const avatarSrc = $(`.user-avatar[data-user-id="${creatorId}"], .avatar[data-user-id="${creatorId}"]`).first().attr('src') ||
                         $(`.publication[data-creator-id="${creatorId}"] .avatar, .post[data-creator-id="${creatorId}"] .avatar`).first().attr('src') ||
                         'assets/images/avatars/default.png';
        
        $('#donationUserAvatar').attr('src', avatarSrc);
        console.log('📸 Avatar actualizado:', avatarSrc);
        
    } catch (error) {
        console.warn('⚠️ Error actualizando avatar:', error);
        $('#donationUserAvatar').attr('src', 'assets/images/avatars/default.png');
    }
}

/**
 * Auto-llenar datos del usuario logueado
 */

/**
 * Actualizar total cuando cambie el monto
 */
function updateTotal() {
    const amount = parseFloat($('#donationAmount').val()) || 0;
    $('#donationTotal').text(`S/ ${amount.toFixed(2)}`);
}

/**
 * Validar monto de donación
 */
function validateDonationAmount() {
    const amountInput = $('#donationAmount');
    const amount = parseFloat(amountInput.val());
    const errorDiv = $('#amountError');
    
    // Limpiar estados previos
    errorDiv.hide();
    amountInput.removeClass('is-invalid is-valid');
    
    if (isNaN(amount) || amount <= 0) {
        errorDiv.text('Ingrese un monto válido').show();
        amountInput.addClass('is-invalid');
        return false;
    }
    
    if (amount < 1) {
        errorDiv.text('El monto mínimo es S/ 1.00').show();
        amountInput.addClass('is-invalid');
        return false;
    }
    
    if (amount > 10000) {
        errorDiv.text('El monto máximo es S/ 10,000.00').show();
        amountInput.addClass('is-invalid');
        return false;
    }
    
    amountInput.addClass('is-valid');
    return true;
}

/**
 * Validar formulario completo
 */
function validateForm() {
    const amount = parseFloat($('#donationAmount').val());
    const name = $('#donorName').val().trim();
    const email = $('#donorEmail').val().trim();
    
    const isAmountValid = amount >= 1 && amount <= 10000;
    const isNameValid = name.length >= 2;
    const isEmailValid = isValidEmail(email);
    
    const isFormValid = isAmountValid && isNameValid && isEmailValid;
    
    // Actualizar estilos de campos
    updateFieldValidation('#donorName', isNameValid, name.length > 0);
    updateFieldValidation('#donorEmail', isEmailValid, email.length > 0);
    
    // Actualizar botón
    const btn = $('#processDonationBtn');
    btn.prop('disabled', !isFormValid);
    
    if (isFormValid) {
        btn.removeClass('btn-secondary').addClass('btn-success')
           .html('<i class="fas fa-heart"></i> Donar con Mercado Pago');
    } else {
        btn.removeClass('btn-success').addClass('btn-secondary')
           .html('<i class="fas fa-heart"></i> Completar datos');
    }
    
    return isFormValid;
}

/**
 * Actualizar validación visual de campo
 */
function updateFieldValidation(fieldId, isValid, hasContent) {
    const field = $(fieldId);
    
    if (!hasContent) {
        field.removeClass('is-valid is-invalid');
    } else if (isValid) {
        field.removeClass('is-invalid').addClass('is-valid');
    } else {
        field.removeClass('is-valid').addClass('is-invalid');
    }
}

/**
 * Validar formato de email
 */
function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

/**
 * FUNCIÓN PRINCIPAL: Procesar donación
 */
async function processDonation() {
    console.log('💳 Iniciando proceso de donación...');
    
    // Validaciones finales
    if (!validateDonationAmount() || !validateForm()) {
        showError('Por favor complete todos los campos correctamente');
        return;
    }
    
    // Obtener datos del formulario
    const formData = {
        amount: parseFloat($('#donationAmount').val()),
        publicationId: $('#donationModal').data('publication-id'),
        creatorId: $('#donationModal').data('creator-id'),
        donorName: $('#donorName').val().trim(),
        donorEmail: $('#donorEmail').val().trim().toLowerCase(),
        donorMessage: $('#donorMessage').val().trim()
    };
    
    console.log('📋 Datos de donación:', formData);
    
    // Validaciones adicionales
    if (!formData.creatorId) {
        showError('Error: Usuario destinatario no válido');
        return;
    }
    
    if (formData.donorName.length < 2) {
        showError('El nombre debe tener al menos 2 caracteres');
        $('#donorName').focus();
        return;
    }
    
    if (!isValidEmail(formData.donorEmail)) {
        showError('Por favor ingrese un email válido');
        $('#donorEmail').focus();
        return;
    }
    
    // Mostrar estado de carga
    showProcessingState(true);
    
    try {
        console.log('🌐 Enviando datos al servidor...');
        
        // Crear preferencia usando AJAX con DonationServlet
        const response = await $.ajax({
            url: 'DonationServlet',
            method: 'POST',
            data: {
                action: 'create_preference',
                amount: formData.amount,
                publication_id: formData.publicationId || '',
                creator_id: formData.creatorId,
                donor_name: formData.donorName,
                donor_email: formData.donorEmail,
                donor_message: formData.donorMessage
            },
            dataType: 'json'
        });
        
        console.log('📡 Respuesta del servidor recibida');
        console.log('📦 Datos de respuesta:', response);
        
        if (response.success) {
            console.log('✅ Preferencia creada exitosamente:', response.preference_id);
            
            // Cerrar modal
            $('#donationModal').modal('hide');
            
            // Determinar URL de checkout (sandbox para testing, normal para producción)
            const checkoutUrl = response.init_point;
            
            if (!checkoutUrl) {
                throw new Error('No se recibió URL de checkout');
            }
            
            console.log('🔗 Redirigiendo a:', checkoutUrl);
            
            // Mostrar mensaje y redirigir
            showInfo('Redirigiendo a Mercado Pago...', () => {
                window.location.href = checkoutUrl;
            });
            
        } else {
            console.error('❌ Error del servidor:', response.error);
            throw new Error(response.error || 'Error desconocido del servidor');
        }
        
    } catch (error) {
        console.error('❌ Error al procesar donación:', error);
        
        // Manejar diferentes tipos de errores AJAX
        if (error.responseJSON && error.responseJSON.error) {
            showError('Error del servidor: ' + error.responseJSON.error);
        } else if (error.statusText) {
            showError('Error de conexión: ' + error.statusText);
        } else {
            showError('Error al procesar la donación: ' + error.message);
        }
    } finally {
        showProcessingState(false);
    }
}

/**
 * Resetear formulario de donación
 */
function resetDonationForm() {
    console.log('🧹 Reseteando formulario...');
    
    // Resetear campos del formulario
    $('#formDonacion')[0].reset();
    
    // Valores por defecto
    $('#donationAmount').val('2');
    $('#donationTotal').text('S/ 2.00');
    
    // Ocultar errores
    $('#amountError').hide();
    
    // Resetear estados de validación
    $('.form-control').removeClass('is-valid is-invalid');
    
    // Resetear botón
    $('#processDonationBtn')
        .prop('disabled', true)
        .removeClass('btn-success')
        .addClass('btn-secondary')
        .html('<i class="fas fa-heart"></i> Completar datos');
    
}

/**
 * Mostrar estado de procesamiento en el botón
 */
function showProcessingState(isProcessing) {
    const btn = $('#processDonationBtn');
    
    if (isProcessing) {
        btn.prop('disabled', true)
           .html('<span class="spinner-border spinner-border-sm me-2"></span>Creando donación...');
    } else {
        btn.prop('disabled', false)
           .html('<i class="fas fa-heart"></i> Donar con Mercado Pago');
        
        // Re-validar formulario
        setTimeout(validateForm, 100);
    }
}

/**
 * FUNCIONES DE NOTIFICACIÓN (requiere SweetAlert2)
 */
function showSuccess(message, callback) {
    if (typeof Swal !== 'undefined') {
        Swal.fire({
            icon: 'success',
            title: '¡Éxito!',
            text: message,
            confirmButtonColor: '#28a745',
            timer: 5000,
            timerProgressBar: true,
            showConfirmButton: true
        }).then(() => {
            if (callback) callback();
        });
    } else {
        alert('✅ ' + message);
        if (callback) callback();
    }
}

function showError(message) {
    if (typeof Swal !== 'undefined') {
        Swal.fire({
            icon: 'error',
            title: 'Error',
            text: message,
            confirmButtonColor: '#dc3545'
        });
    } else {
        alert('❌ ' + message);
    }
}

function showWarning(message) {
    if (typeof Swal !== 'undefined') {
        Swal.fire({
            icon: 'warning',
            title: 'Atención',
            text: message,
            confirmButtonColor: '#ffc107'
        });
    } else {
        alert('⚠️ ' + message);
    }
}

function showInfo(message, callback) {
    if (typeof Swal !== 'undefined') {
        Swal.fire({
            icon: 'info',
            title: 'Información',
            text: message,
            confirmButtonColor: '#17a2b8',
            timer: 2000,
            timerProgressBar: true,
            showConfirmButton: false
        }).then(() => {
            if (callback) callback();
        });
    } else {
        alert('ℹ️ ' + message);
        if (callback) callback();
    }
}

/**
 * FUNCIONES ADICIONALES PARA COMPATIBILIDAD
 */

// Función para donaciones directas (sin publicación)
function openDirectDonationModal(creatorId, creatorName) {
    console.log('💰 Abriendo donación directa:', { creatorId, creatorName });
    openDonationModal(null, creatorName, '@' + creatorName.toLowerCase(), creatorId);
}

// Debugging helper
function logDonationData() {
    const data = {
        amount: $('#donationAmount').val(),
        creatorId: $('#donationModal').data('creator-id'),
        publicationId: $('#donationModal').data('publication-id'),
        donorName: $('#donorName').val(),
        donorEmail: $('#donorEmail').val(),
        formValid: validateForm()
    };
    console.table(data);
    return data;
}

// Validar configuración al cargar
$(window).on('load', function() {
    console.log('🔍 Verificando configuración del sistema...');
    
    // Verificar que jQuery está disponible
    if (typeof $ === 'undefined') {
        console.error('❌ jQuery no está disponible');
        return;
    }
    
    // Verificar que el modal existe
    if ($('#donationModal').length === 0) {
        console.warn('⚠️ Modal #donationModal no encontrado en el DOM');
    }
    
    // Verificar SweetAlert2
    if (typeof Swal === 'undefined') {
        console.warn('⚠️ SweetAlert2 no disponible, usando alert() nativo');
    }
    
    console.log('✅ Sistema de donaciones listo');
});