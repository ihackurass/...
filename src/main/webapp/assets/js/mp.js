$(document).ready(function() {
    setupDonationHandlers();
});

function setupDonationHandlers() {
    $(document).on('click', '#processDonationBtn', function() {
        processDonation();
    });
    
    $(document).on('input', '#donationAmount', function() {
        updateTotal();
        validateDonationAmount();
        validateForm();
    });
    
    $(document).on('input change', '#donorName, #donorEmail', function() {
        validateForm();
    });
    
    $(document).on('blur', '#donorEmail', function() {
        $(this).val($(this).val().toLowerCase().trim());
        validateForm();
    });
    
    $('#donationModal').on('shown.bs.modal', function() {
        setTimeout(() => {
            validateForm();
            $('#donationAmount').focus().select();
        }, 300);
    });
    
    $('#donationModal').on('hidden.bs.modal', function() {
        resetDonationForm();
    });
}

function openDonationModal(publicationId, nombreCompleto, nombreUsuario, creatorId) {
    if (!creatorId && !publicationId) {
        showError('Error: No se pudo identificar al destinatario');
        return;
    }
    
    if (!creatorId) {
        creatorId = extractCreatorIdFromButton(event.target, publicationId);
        if (!creatorId) {
            showError('Error: No se pudo identificar al usuario destinatario');
            return;
        }
    }
    
    $('#donationModal').data('publication-id', publicationId);
    $('#donationModal').data('creator-id', creatorId);
    
    $('.creator-name').text(nombreCompleto || 'Usuario');
    $('#donationUserHandle').text(nombreUsuario || '@usuario');
    
    updateUserAvatar(creatorId);
    resetDonationForm();
    $('#donationModal').modal('show');
}

function extractCreatorIdFromButton(buttonElement, publicationId) {
    try {
        const $button = $(buttonElement).closest('button');
        let creatorId = $button.data('creator-id');
        
        if (creatorId) {
            return creatorId;
        }
        
        const $publication = $button.closest('.publication, .post, .card');
        creatorId = $publication.data('creator-id') || $publication.data('user-id');
        
        if (creatorId) {
            return creatorId;
        }
        
        creatorId = $publication.find('[data-creator-id], [data-user-id]').first().data('creator-id') || 
                   $publication.find('[data-creator-id], [data-user-id]').first().data('user-id');
        
        if (creatorId) {
            return creatorId;
        }
        
        return null;
        
    } catch (error) {
        return null;
    }
}

function updateUserAvatar(creatorId) {
    try {
        const avatarSrc = $(`.user-avatar[data-user-id="${creatorId}"], .avatar[data-user-id="${creatorId}"]`).first().attr('src') ||
                         $(`.publication[data-creator-id="${creatorId}"] .avatar, .post[data-creator-id="${creatorId}"] .avatar`).first().attr('src') ||
                         'assets/images/avatars/default.png';
        
        $('#donationUserAvatar').attr('src', avatarSrc);
        
    } catch (error) {
        $('#donationUserAvatar').attr('src', 'assets/images/avatars/default.png');
    }
}

function updateTotal() {
    const amount = parseFloat($('#donationAmount').val()) || 0;
    $('#donationTotal').text(`S/ ${amount.toFixed(2)}`);
}

function validateDonationAmount() {
    const amountInput = $('#donationAmount');
    const amount = parseFloat(amountInput.val());
    const errorDiv = $('#amountError');
    
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

function validateForm() {
    const amount = parseFloat($('#donationAmount').val());
    const name = $('#donorName').val().trim();
    const email = $('#donorEmail').val().trim();
    
    const isAmountValid = amount >= 1 && amount <= 10000;
    const isNameValid = name.length >= 2;
    const isEmailValid = isValidEmail(email);
    
    const isFormValid = isAmountValid && isNameValid && isEmailValid;
    
    updateFieldValidation('#donorName', isNameValid, name.length > 0);
    updateFieldValidation('#donorEmail', isEmailValid, email.length > 0);
    
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

function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

async function processDonation() {
    if (!validateDonationAmount() || !validateForm()) {
        showError('Por favor complete todos los campos correctamente');
        return;
    }
    
    const formData = {
        amount: parseFloat($('#donationAmount').val()),
        publicationId: $('#donationModal').data('publication-id'),
        creatorId: $('#donationModal').data('creator-id'),
        donorName: $('#donorName').val().trim(),
        donorEmail: $('#donorEmail').val().trim().toLowerCase(),
        donorMessage: $('#donorMessage').val().trim()
    };
    
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
    
    showProcessingState(true);
    
    try {
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
                donor_message: formData.donorMessage,
                source: getPageSource(),
                community_id: getCommunityId()
            },
            dataType: 'json'
        });
        
        if (response.success) {
            $('#donationModal').modal('hide');
            
            const checkoutUrl = response.init_point;
            
            if (!checkoutUrl) {
                throw new Error('No se recibió URL de checkout');
            }
            
            showInfo('Redirigiendo a Mercado Pago...', () => {
                window.location.href = checkoutUrl;
            });
            
        } else {
            throw new Error(response.error || 'Error desconocido del servidor');
        }
        
    } catch (error) {
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

function getPageSource() {
    
    if (typeof window.currentPage !== 'undefined') {
        return window.currentPage === 'community' ? 'community' : 'home';
    }
    
    // Por defecto
    return 'home';
}

function getCommunityId() {

    if (typeof window.communityId !== 'undefined') {
        return window.communityId;
    }
    
    return '';
}

function resetDonationForm() {
    $('#formDonacion')[0].reset();
    $('#donationAmount').val('2');
    $('#donationTotal').text('S/ 2.00');
    $('#amountError').hide();
    $('.form-control').removeClass('is-valid is-invalid');
    
    $('#processDonationBtn')
        .prop('disabled', true)
        .removeClass('btn-success')
        .addClass('btn-secondary')
        .html('<i class="fas fa-heart"></i> Completar datos');
}

function showProcessingState(isProcessing) {
    const btn = $('#processDonationBtn');
    
    if (isProcessing) {
        btn.prop('disabled', true)
           .html('<span class="spinner-border spinner-border-sm me-2"></span>Creando donación...');
    } else {
        btn.prop('disabled', false)
           .html('<i class="fas fa-heart"></i> Donar con Mercado Pago');
        
        setTimeout(validateForm, 100);
    }
}

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

function openDirectDonationModal(creatorId, creatorName) {
    openDonationModal(null, creatorName, '@' + creatorName.toLowerCase(), creatorId);
}

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
