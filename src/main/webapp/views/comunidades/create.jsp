<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="pe.aquasocial.entity.Usuario"%>
<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuarioLogueado");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Crear Nueva Comunidad - AquaSocial</title>
    <jsp:include page="/components/css_imports.jsp" />
    
    <style>
        .main-container {
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .form-container {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            border: 1px solid #e9ecef;
        }
        
        .header-section {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #f8f9fa;
        }
        
        .header-section h1 {
            color: #007bff;
            font-weight: 600;
            margin-bottom: 10px;
        }
        
        .header-section p {
            color: #6c757d;
            margin: 0;
        }
        
        .form-group {
            margin-bottom: 25px;
        }
        
        .form-group label {
            font-weight: 600;
            color: #495057;
            margin-bottom: 8px;
            display: block;
        }
        
        .form-control {
            border-radius: 10px;
            border: 2px solid #e9ecef;
            padding: 12px 15px;
            font-size: 14px;
            transition: all 0.3s ease;
        }
        
        .form-control:focus {
            border-color: #007bff;
            box-shadow: 0 0 0 0.2rem rgba(0,123,255,0.25);
        }
        
        .image-upload-area {
            border: 2px dashed #ddd;
            border-radius: 10px;
            padding: 30px;
            text-align: center;
            background: #f8f9fa;
            transition: all 0.3s ease;
            cursor: pointer;
        }
        
        .image-upload-area:hover {
            border-color: #007bff;
            background: rgba(0,123,255,0.05);
        }
        
        .image-upload-area.dragover {
            border-color: #007bff;
            background: rgba(0,123,255,0.1);
        }
        
        .image-preview {
            max-width: 100%;
            max-height: 200px;
            border-radius: 10px;
            margin-top: 15px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .privacy-section {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 25px;
        }
        
        .privacy-option {
            display: flex;
            align-items: center;
            padding: 15px;
            border: 2px solid #e9ecef;
            border-radius: 10px;
            margin-bottom: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .privacy-option:hover {
            border-color: #007bff;
            background: rgba(0,123,255,0.05);
        }
        
        .privacy-option.selected {
            border-color: #007bff;
            background: rgba(0,123,255,0.1);
        }
        
        .privacy-option input[type="radio"] {
            margin-right: 15px;
            transform: scale(1.2);
        }
        
        .privacy-details {
            flex: 1;
        }
        
        .privacy-title {
            font-weight: 600;
            color: #495057;
            margin-bottom: 5px;
        }
        
        .privacy-description {
            font-size: 12px;
            color: #6c757d;
            margin: 0;
        }
        
        .char-counter {
            text-align: right;
            font-size: 12px;
            margin-top: 5px;
        }
        
        .char-counter.warning {
            color: #ffc107;
        }
        
        .char-counter.danger {
            color: #dc3545;
        }
        
        .btn-group-actions {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
            border: none;
            border-radius: 10px;
            padding: 12px 30px;
            font-weight: 600;
            flex: 1;
        }
        
        .btn-secondary {
            background: #6c757d;
            border: none;
            border-radius: 10px;
            padding: 12px 30px;
            font-weight: 600;
            flex: 1;
        }
        
        .form-text {
            font-size: 12px;
            color: #6c757d;
            margin-top: 5px;
        }
        
        .loading-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.7);
            z-index: 9999;
            align-items: center;
            justify-content: center;
        }
        
        .loading-content {
            background: white;
            padding: 30px;
            border-radius: 15px;
            text-align: center;
        }
        
        .spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #007bff;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto 15px;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .error-message {
            background: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            border: 1px solid #f5c6cb;
        }
        
        .success-message {
            background: #d4edda;
            color: #155724;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            border: 1px solid #c3e6cb;
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
                <div class="form-container">
                    <!-- Header -->
                    <div class="header-section">
                        <h1><i class="fas fa-users"></i> Crear Nueva Comunidad</h1>
                        <p>Crea un espacio para que personas con intereses similares puedan conectar y compartir</p>
                    </div>
                    
                    <!-- Mensajes de error/éxito -->
                    <% if (request.getAttribute("error") != null) { %>
                        <div class="error-message">
                            <i class="fas fa-exclamation-triangle"></i>
                            <%= request.getAttribute("error") %>
                        </div>
                    <% } %>
                    
                    <% if (request.getAttribute("success") != null) { %>
                        <div class="success-message">
                            <i class="fas fa-check-circle"></i>
                            <%= request.getAttribute("success") %>
                        </div>
                    <% } %>
                    
                    <!-- Formulario -->
                    <form id="formCrearComunidad" method="post" action="ComunidadServlet" enctype="multipart/form-data">
                        <input type="hidden" name="action" value="create">
                        <input type="hidden" name="idCreador" value="<%= usuarioActual.getId() %>">
                        
                        <!-- Nombre de la comunidad -->
                        <div class="form-group">
                            <label for="nombre">
                                <i class="fas fa-tag"></i> Nombre de la Comunidad *
                            </label>
                            <input type="text" 
                                   class="form-control" 
                                   id="nombre" 
                                   name="nombre" 
                                   placeholder="Ej: Amantes de la Fotografía"
                                   maxlength="100"
                                   required>
                            <div class="char-counter">
                                <span id="nombreCounter">0</span>/100 caracteres
                            </div>
                            <div class="form-text">
                                Elige un nombre descriptivo y fácil de recordar
                            </div>
                        </div>
                        
                        <!-- Descripción -->
                        <div class="form-group">
                            <label for="descripcion">
                                <i class="fas fa-align-left"></i> Descripción *
                            </label>
                            <textarea class="form-control" 
                                      id="descripcion" 
                                      name="descripcion" 
                                      rows="4"
                                      placeholder="Describe de qué trata tu comunidad, qué tipo de contenido se compartirá y qué esperas de los miembros..."
                                      maxlength="1000"
                                      required></textarea>
                            <div class="char-counter">
                                <span id="descripcionCounter">0</span>/1000 caracteres
                            </div>
                            <div class="form-text">
                                Una buena descripción ayuda a las personas a entender si la comunidad es para ellas
                            </div>
                        </div>
                        
                        <!-- Imagen de la comunidad -->
                        <div class="form-group">
                            <label>
                                <i class="fas fa-image"></i> Imagen de la Comunidad
                            </label>
                            <div class="image-upload-area" id="imageUploadArea">
                                <i class="fas fa-cloud-upload-alt fa-3x text-muted mb-3"></i>
                                <h5>Sube una imagen para tu comunidad</h5>
                                <p class="text-muted">Arrastra una imagen aquí o haz clic para seleccionar</p>
                                <p class="text-muted"><small>Formatos: JPG, PNG, GIF. Máximo 5MB</small></p>
                                <input type="file" 
                                       id="imagen" 
                                       name="imagen" 
                                       accept="image/*" 
                                       style="display: none;">
                            </div>
                            <img id="imagePreview" class="image-preview" style="display: none;">
                        </div>
                        
                        <!-- Configuración de privacidad -->
                        <div class="privacy-section">
                            <label style="margin-bottom: 15px;">
                                <i class="fas fa-shield-alt"></i> Configuración de Privacidad *
                            </label>
                            
                            <div class="privacy-option" data-value="true">
                                <input type="radio" name="esPublica" value="true" id="publica" checked>
                                <div class="privacy-details">
                                    <div class="privacy-title">
                                        <i class="fas fa-globe text-success"></i> Comunidad Pública
                                    </div>
                                    <p class="privacy-description">
                                        Cualquier persona puede ver y unirse a esta comunidad
                                    </p>
                                </div>
                            </div>
                            
                            <div class="privacy-option" data-value="false">
                                <input type="radio" name="esPublica" value="false" id="privada">
                                <div class="privacy-details">
                                    <div class="privacy-title">
                                        <i class="fas fa-lock text-warning"></i> Comunidad Privada
                                    </div>
                                    <p class="privacy-description">
                                        Solo los miembros pueden ver el contenido. Requiere aprobación para unirse
                                    </p>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Botones de acción -->
                        <div class="btn-group-actions">
                            <button type="button" class="btn btn-secondary" onclick="window.history.back()">
                                <i class="fas fa-arrow-left"></i> Cancelar
                            </button>
                            <button type="submit" class="btn btn-primary" id="btnCrear">
                                <i class="fas fa-plus"></i> Crear Comunidad
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </main>
    
    <!-- Loading Overlay -->
    <div class="loading-overlay" id="loadingOverlay">
        <div class="loading-content">
            <div class="spinner"></div>
            <h5>Creando tu comunidad...</h5>
            <p>Por favor espera un momento</p>
        </div>
    </div>
    
    <!-- Scripts -->
    <jsp:include page="/components/js_imports.jsp" />
    
    <script>
        $(document).ready(function() {
            initializeForm();
        });
        
        function initializeForm() {
            // Contadores de caracteres
            initCharacterCounters();
            
            // Upload de imagen
            initImageUpload();
            
            // Opciones de privacidad
            initPrivacyOptions();
            
            // Validación del formulario
            initFormValidation();
        }
        
        function initCharacterCounters() {
            // Contador para nombre
            $('#nombre').on('input', function() {
                const current = $(this).val().length;
                const max = 100;
                const counter = $('#nombreCounter');
                
                counter.text(current);
                
                if (current > max * 0.9) {
                    counter.parent().addClass(current >= max ? 'danger' : 'warning');
                } else {
                    counter.parent().removeClass('warning danger');
                }
            });
            
            // Contador para descripción
            $('#descripcion').on('input', function() {
                const current = $(this).val().length;
                const max = 1000;
                const counter = $('#descripcionCounter');
                
                counter.text(current);
                
                if (current > max * 0.9) {
                    counter.parent().addClass(current >= max ? 'danger' : 'warning');
                } else {
                    counter.parent().removeClass('warning danger');
                }
            });
        }
        
        function initImageUpload() {
            const uploadArea = $('#imageUploadArea');
            const fileInput = $('#imagen');
            const preview = $('#imagePreview');
            
            // Click para abrir selector
            uploadArea.on('click', function(e) {
                if (e.target.tagName !== 'INPUT') {
                    fileInput.click();
                }
            });
            
            // Drag and drop
            uploadArea.on('dragover', function(e) {
                e.preventDefault();
                $(this).addClass('dragover');
            });
            
            uploadArea.on('dragleave', function(e) {
                e.preventDefault();
                $(this).removeClass('dragover');
            });
            
            uploadArea.on('drop', function(e) {
                e.preventDefault();
                $(this).removeClass('dragover');
                
                const files = e.originalEvent.dataTransfer.files;
                if (files.length > 0) {
                    handleImageSelect(files[0]);
                }
            });
            
            // Cambio de archivo
            fileInput.on('change', function(e) {
                if (e.target.files.length > 0) {
                    handleImageSelect(e.target.files[0]);
                }
            });
        }
        
        function handleImageSelect(file) {
            // Validar tipo
            if (!file.type.startsWith('image/')) {
                showError('Por favor selecciona un archivo de imagen válido');
                return;
            }
            
            // Validar tamaño (5MB)
            if (file.size > 5 * 1024 * 1024) {
                showError('La imagen es muy grande. Máximo 5MB permitido');
                return;
            }
            
            // Mostrar preview
            const reader = new FileReader();
            reader.onload = function(e) {
                $('#imagePreview').attr('src', e.target.result).show();
                $('#imageUploadArea').hide();
            };
            reader.readAsDataURL(file);
        }
        
        function initPrivacyOptions() {
            $('.privacy-option').on('click', function() {
                $('.privacy-option').removeClass('selected');
                $(this).addClass('selected');
                $(this).find('input[type="radio"]').prop('checked', true);
            });
        }
        
        function initFormValidation() {
            $('#formCrearComunidad').on('submit', function(e) {
                e.preventDefault();
                
                if (validateForm()) {
                    submitForm();
                }
            });
        }
        
        function validateForm() {
            let isValid = true;
            
            // Validar nombre
            const nombre = $('#nombre').val().trim();
            if (nombre.length < 3) {
                showError('El nombre debe tener al menos 3 caracteres');
                $('#nombre').focus();
                return false;
            }
            
            // Validar descripción
            const descripcion = $('#descripcion').val().trim();
            if (descripcion.length < 10) {
                showError('La descripción debe tener al menos 10 caracteres');
                $('#descripcion').focus();
                return false;
            }
            
            return isValid;
        }
        
        function submitForm() {
            // Mostrar loading
            $('#loadingOverlay').css('display', 'flex');
            $('#btnCrear').prop('disabled', true);
            
            // Preparar datos del formulario
            const formData = new FormData($('#formCrearComunidad')[0]);
            
            // Enviar via AJAX
            $.ajax({
                url: 'ComunidadServlet',
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                success: function(response) {
                    // Éxito - redirigir
                    if (response.success) {
                        showSuccess('¡Comunidad creada exitosamente!');
                        setTimeout(function() {
                            window.location.href = 'ComunidadServlet?action=view&id=' + response.comunidadId;
                        }, 2000);
                    } else {
                        showError(response.message || 'Error al crear la comunidad');
                        $('#loadingOverlay').hide();
                        $('#btnCrear').prop('disabled', false);
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Error:', error);
                    showError('Error de conexión. Por favor intenta de nuevo');
                    $('#loadingOverlay').hide();
                    $('#btnCrear').prop('disabled', false);
                }
            });
        }
        
            // ========== FUNCIONES DE UTILIDAD ==========
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