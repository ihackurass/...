<%-- 
    Document   : edit
    Created on : Formulario de Edición de Comunidad
    Author     : Sistema
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="pe.aquasocial.entity.Comunidad"%>
<%@page import="pe.aquasocial.entity.Usuario"%>

<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuarioLogueado");
    Comunidad comunidad = (Comunidad) request.getAttribute("comunidad");
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
%>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Editar - <%= comunidad.getNombre() %> - AquaSocial</title>
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
        
        .current-image-section {
            margin-bottom: 20px;
            text-align: center;
        }
        
        .current-image {
            max-width: 200px;
            max-height: 150px;
            border-radius: 10px;
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
        
        .form-text {
            font-size: 12px;
            color: #6c757d;
            margin-top: 5px;
        }
        
        .error-message {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .success-message {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .btn-group-actions {
            display: flex;
            gap: 15px;
            justify-content: space-between;
            padding-top: 20px;
            margin-top: 20px;
            border-top: 1px solid #e9ecef;
        }
        
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }
        
        .btn-primary {
            background: #007bff;
            color: white;
        }
        
        .btn-primary:hover {
            background: #0056b3;
            transform: translateY(-1px);
        }
        
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #545b62;
        }
        
        .btn-danger {
            background: #dc3545;
            color: white;
        }
        
        .btn-danger:hover {
            background: #c82333;
        }
        
        .loading-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.7);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 9999;
        }
        
        .loading-content {
            background: white;
            padding: 40px;
            border-radius: 15px;
            text-align: center;
            max-width: 400px;
        }
        
        .spinner {
            width: 40px;
            height: 40px;
            border: 4px solid #f3f3f3;
            border-top: 4px solid #007bff;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .danger-zone {
            background: #fff5f5;
            border: 2px solid #fed7d7;
            border-radius: 10px;
            padding: 20px;
            margin-top: 30px;
        }
        
        .danger-zone h5 {
            color: #dc3545;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .username-readonly {
            background: #f8f9fa;
            color: #6c757d;
            cursor: not-allowed;
        }
        
        .username-info {
            background: #e7f3ff;
            border: 1px solid #b3d7ff;
            border-radius: 8px;
            padding: 12px;
            margin-top: 8px;
            font-size: 12px;
            color: #0856a8;
        }
        
        @media (max-width: 768px) {
            .main-container {
                padding: 15px;
            }
            
            .form-container {
                padding: 20px;
            }
            
            .btn-group-actions {
                flex-direction: column;
            }
            
            .btn {
                justify-content: center;
            }
        }
        
        /* ==================== ESTILOS PARA MODAL DE ELIMINAR ==================== */
        .modal-header.bg-danger {
            background: linear-gradient(135deg, #dc3545, #c82333) !important;
            border-bottom: none;
        }
        
        .modal-header.bg-danger .close {
            color: white !important;
            text-shadow: none;
            opacity: 0.8;
        }
        
        .modal-header.bg-danger .close:hover {
            opacity: 1;
        }
        
        .warning-icon {
            animation: pulse-warning 2s infinite;
        }
        
        @keyframes pulse-warning {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }
        
        .confirmation-section {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
            border-left: 4px solid #dc3545;
        }
        
        .confirmation-section .form-control:focus {
            border-color: #dc3545;
            box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.25);
        }
        
        #btnConfirmarEliminacion:disabled {
            background-color: #6c757d;
            border-color: #6c757d;
            cursor: not-allowed;
        }
        
        .modal-dialog-centered {
            min-height: calc(100% - 1rem);
        }
        
        .modal-content {
            border: none;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
        }
        
        .alert-danger ul {
            padding-left: 1.2rem;
        }
        
        .alert-danger li {
            margin-bottom: 0.3rem;
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
                        <h1><i class="fas fa-edit"></i> Editar Comunidad</h1>
                        <p>Modifica la información de "<%= comunidad.getNombre() %>"</p>
                    </div>
                    
                    <!-- Mensajes de estado -->
                    <% if (error != null) { %>
                        <div class="error-message">
                            <i class="fas fa-exclamation-triangle"></i>
                            <%= error %>
                        </div>
                    <% } %>
                    
                    <% if (success != null) { %>
                        <div class="success-message">
                            <i class="fas fa-check-circle"></i>
                            <%= success %>
                        </div>
                    <% } %>
                    
                    <!-- Formulario de edición -->
                    <form id="formEditarComunidad" method="post" action="ComunidadServlet" enctype="multipart/form-data">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="idComunidad" value="<%= comunidad.getIdComunidad() %>">
                        
                        <!-- Nombre de la comunidad -->
                        <div class="form-group">
                            <label for="nombre">
                                <i class="fas fa-tag"></i> Nombre de la Comunidad *
                            </label>
                            <input type="text" 
                                   class="form-control" 
                                   id="nombre" 
                                   name="nombre" 
                                   value="<%= comunidad.getNombre() != null ? comunidad.getNombre() : "" %>"
                                   maxlength="100" 
                                   placeholder="Nombre único y descriptivo"
                                   required>
                            <div class="char-counter">
                                <span id="nombreCounter">0</span>/100 caracteres
                            </div>
                            <div class="form-text">
                                El nombre debe ser único y representativo de tu comunidad
                            </div>
                        </div>
                        
                        <!-- Username de la comunidad (solo lectura) -->
                        <div class="form-group">
                            <label for="username">
                                <i class="fas fa-at"></i> Username de la Comunidad
                            </label>
                            <input type="text" 
                                   class="form-control username-readonly" 
                                   id="username" 
                                   value="<%= comunidad.getUsername() != null ? "@" + comunidad.getUsername() : "Sin username asignado" %>"
                                   readonly>
                            <div class="username-info">
                                <i class="fas fa-info-circle"></i>
                                El username no se puede modificar una vez creada la comunidad por motivos de seguridad y consistencia de enlaces.
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
                                      required><%= comunidad.getDescripcion() != null ? comunidad.getDescripcion() : "" %></textarea>
                            <div class="char-counter">
                                <span id="descripcionCounter">0</span>/1000 caracteres
                            </div>
                            <div class="form-text">
                                Una buena descripción ayuda a las personas a entender si la comunidad es para ellas
                            </div>
                        </div>
                        
                        <!-- Imagen actual -->
                        <% if (comunidad.getImagenUrl() != null && !comunidad.getImagenUrl().trim().isEmpty()) { %>
                            <div class="current-image-section">
                                <label>Imagen Actual:</label>
                                <br>
                                <img src="<%= comunidad.getImagenUrl() %>" alt="Imagen actual" class="current-image">
                                <div class="form-text" style="margin-top: 10px;">
                                    Sube una nueva imagen para reemplazar la actual
                                </div>
                            </div>
                        <% } %>
                        
                        <!-- Nueva imagen -->
                        <div class="form-group">
                            <label>
                                <i class="fas fa-image"></i> <% if (comunidad.getImagenUrl() != null && !comunidad.getImagenUrl().trim().isEmpty()) { %>Nueva <% } %>Imagen de la Comunidad
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
                            
                            <div class="privacy-option <%= comunidad.isEsPublica() ? "selected" : "" %>" data-value="true">
                                <input type="radio" name="esPublica" value="true" id="publica" <%= comunidad.isEsPublica() ? "checked" : "" %>>
                                <div class="privacy-details">
                                    <div class="privacy-title">
                                        <i class="fas fa-globe text-success"></i> Comunidad Pública
                                    </div>
                                    <p class="privacy-description">
                                        Cualquier persona puede ver y unirse a esta comunidad
                                    </p>
                                </div>
                            </div>
                            
                            <div class="privacy-option <%= !comunidad.isEsPublica() ? "selected" : "" %>" data-value="false">
                                <input type="radio" name="esPublica" value="false" id="privada" <%= !comunidad.isEsPublica() ? "checked" : "" %>>
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
                            <a href="ComunidadServlet?action=view&id=<%= comunidad.getIdComunidad() %>" class="btn btn-secondary">
                                <i class="fas fa-arrow-left"></i> Cancelar
                            </a>
                            <button type="button" class="btn btn-primary" id="btnGuardar" onclick="submitFormManually()">
                                <i class="fas fa-save"></i> Guardar Cambios
                            </button>
                        </div>
                    </form>
                    
                    <!-- Zona peligrosa -->
                    <div class="danger-zone">
                        <h5><i class="fas fa-exclamation-triangle"></i> Zona Peligrosa</h5>
                        <p>Las siguientes acciones son irreversibles. Úsalas con precaución.</p>
                        <button type="button" class="btn btn-danger" onclick="confirmarEliminacion()">
                            <i class="fas fa-trash"></i> Eliminar Comunidad
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </main>
    
    <!-- Modal para Eliminar Comunidad -->
    <div class="modal fade" id="eliminarModal" tabindex="-1" role="dialog" aria-labelledby="eliminarModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <!-- Header con colores de peligro -->
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title" id="eliminarModalLabel">
                        <i class="fas fa-exclamation-triangle"></i> 
                        Eliminar Comunidad
                    </h5>
                    <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close" style="opacity: 0.8;">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                
                <!-- Cuerpo del modal -->
                <div class="modal-body">
                    <div class="text-center mb-4">
                        <div class="warning-icon mb-3">
                            <i class="fas fa-exclamation-triangle text-danger" style="font-size: 4rem;"></i>
                        </div>
                        <h4 class="text-danger mb-3">¿Estás completamente seguro?</h4>
                        <p class="mb-3">
                            Estás a punto de eliminar permanentemente la comunidad 
                            <strong>"<%= comunidad.getNombre() %>"</strong>.
                        </p>
                    </div>
                    
                    <div class="alert alert-danger" role="alert">
                        <h6><i class="fas fa-info-circle"></i> Esta acción:</h6>
                        <ul class="mb-0">
                            <li>Es <strong>irreversible</strong> y permanente</li>
                            <li>Eliminará <strong>todas las publicaciones</strong> de la comunidad</li>
                            <li>Eliminará <strong>todos los comentarios</strong> asociados</li>
                            <li>Removerá <strong>todos los miembros</strong> automáticamente</li>
                            <li>Borrará <strong>todo el historial</strong> de la comunidad</li>
                        </ul>
                    </div>
                    
                    <div class="confirmation-section mt-4">
                        <label for="confirmacionTexto" class="form-label">
                            <strong>Para confirmar, escribe exactamente:</strong> 
                            <code class="text-danger">ELIMINAR</code>
                        </label>
                        <input type="text" 
                               class="form-control" 
                               id="confirmacionTexto" 
                               placeholder="Escribe ELIMINAR para confirmar"
                               autocomplete="off">
                        <small class="form-text text-muted">
                            Distingue entre mayúsculas y minúsculas
                        </small>
                    </div>
                </div>
                
                <!-- Footer del modal -->
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">
                        <i class="fas fa-times"></i> Cancelar
                    </button>
                    <button type="button" class="btn btn-danger" id="btnConfirmarEliminacion" disabled>
                        <i class="fas fa-trash"></i> Eliminar Permanentemente
                    </button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Loading Overlay -->
    <div class="loading-overlay" id="loadingOverlay">
        <div class="loading-content">
            <div class="spinner"></div>
            <h5>Guardando cambios...</h5>
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
            
            // Modal de eliminación
            initEliminarModal();
        }
        
        function initEliminarModal() {
            // Validación del texto de confirmación
            $('#confirmacionTexto').on('input', function() {
                const texto = $(this).val();
                const btnConfirmar = $('#btnConfirmarEliminacion');
                
                if (texto === 'ELIMINAR') {
                    btnConfirmar.prop('disabled', false)
                               .removeClass('btn-secondary')
                               .addClass('btn-danger');
                } else {
                    btnConfirmar.prop('disabled', true)
                               .removeClass('btn-danger')
                               .addClass('btn-secondary');
                }
            });
            
            // Limpiar campo cuando se abre el modal
            $('#eliminarModal').on('show.bs.modal', function() {
                $('#confirmacionTexto').val('');
                $('#btnConfirmarEliminacion').prop('disabled', true)
                                           .removeClass('btn-danger')
                                           .addClass('btn-secondary');
            });
            
            // Manejar clic en eliminar
            $('#btnConfirmarEliminacion').on('click', function() {
                if ($(this).prop('disabled')) {
                    return;
                }
                
                eliminarComunidad();
            });
        }
        
        function initCharacterCounters() {
            // Contador para nombre
            $('#nombre').on('input', function() {
                updateCharCounter($(this), 100, '#nombreCounter');
            });
            
            // Contador para descripción
            $('#descripcion').on('input', function() {
                updateCharCounter($(this), 1000, '#descripcionCounter');
            });
            
            // Inicializar contadores
            $('#nombre').trigger('input');
            $('#descripcion').trigger('input');
        }
        
        function updateCharCounter(input, maxLength, counterSelector) {
            const current = input.val().length;
            const counter = $(counterSelector);
            
            counter.text(current);
            
            const parent = counter.parent();
            parent.removeClass('warning danger');
            
            if (current > maxLength * 0.9) {
                parent.addClass(current >= maxLength ? 'danger' : 'warning');
            }
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
                showInfo('Nueva imagen seleccionada correctamente');
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
            $('#formEditarComunidad').on('submit', function(e) {
                e.preventDefault(); // ⭐ PREVENIR ENVÍO NORMAL DEL FORMULARIO
                
                if (validateForm()) {
                    submitForm();
                }
                
                return false; // ⭐ ASEGURAR QUE NO SE ENVÍE
            });
        }
        
        function validateForm() {
            let isValid = true;
            
            // Validar nombre
            const nombre = $('#nombre').val().trim();
            if (nombre.length === 0) {
                showError('El nombre de la comunidad es obligatorio');
                isValid = false;
            } else if (nombre.length < 3) {
                showError('El nombre debe tener al menos 3 caracteres');
                isValid = false;
            }
            
            // Validar descripción
            const descripcion = $('#descripcion').val().trim();
            if (descripcion.length === 0) {
                showError('La descripción es obligatoria');
                isValid = false;
            } else if (descripcion.length < 10) {
                showError('La descripción debe tener al menos 10 caracteres');
                isValid = false;
            }
            
            return isValid;
        }
        
        function submitForm() {
            console.log('📤 Enviando formulario por AJAX...');
            showLoading();
            
            // Crear FormData para manejar archivos
            var formData = new FormData($('#formEditarComunidad')[0]);
            
            console.log('📋 Datos del formulario:');
            for (var pair of formData.entries()) {
                console.log(pair[0] + ': ' + pair[1]);
            }
            
            // Enviar por AJAX
            $.ajax({
                url: 'ComunidadServlet',
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                dataType: 'json',
                success: function(response) {
                    console.log('✅ Respuesta exitosa:', response);
                    hideLoading();
                    
                    if (response.success) {
                        showSuccess(response.message || 'Comunidad actualizada exitosamente');
                        
                        // Opcional: redirigir después de un tiempo
                        setTimeout(() => {
                            window.location.href = 'ComunidadServlet?action=view&id=<%= comunidad.getIdComunidad() %>';
                        }, 2000);
                    } else {
                        showError(response.message || 'Error al actualizar la comunidad');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('❌ Error AJAX:', {
                        status: status,
                        error: error,
                        response: xhr.responseText
                    });
                    hideLoading();
                    
                    // Intentar parsear respuesta de error
                    try {
                        var errorResponse = JSON.parse(xhr.responseText);
                        showError(errorResponse.message || 'Error de conexión al actualizar la comunidad');
                    } catch (e) {
                        showError('Error de conexión al actualizar la comunidad');
                    }
                }
            });
        }
        
        function showLoading() {
            $('#loadingOverlay').css('display', 'flex');
            $('#btnGuardar').prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Guardando...');
        }
        
        function hideLoading() {
            $('#loadingOverlay').hide();
            $('#btnGuardar').prop('disabled', false).html('<i class="fas fa-save"></i> Guardar Cambios');
        }
        
        // ==================== SISTEMA DE NOTIFICACIONES TOAST ====================
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

        // Funciones de conveniencia
        function showSuccess(message) { showNotification(message, 'success'); }
        function showError(message) { showNotification(message, 'error'); }
        function showWarning(message) { showNotification(message, 'warning'); }
        function showInfo(message) { showNotification(message, 'info'); }
        
        // ==================== FUNCIÓN MANUAL PARA ENVÍO ====================
        function submitFormManually() {
            console.log('🚀 Iniciando envío manual del formulario...');
            
            if (validateForm()) {
                submitForm();
            }
        }
        
        function eliminarComunidad() {
            console.log('🗑️ Iniciando eliminación de comunidad...');
            
            // Cerrar modal
            $('#eliminarModal').modal('hide');
            
            // Mostrar loading
            showLoading();
            
            $.ajax({
                url: 'ComunidadServlet',
                type: 'POST',
                data: {
                    action: 'delete',
                    idComunidad: <%= comunidad.getIdComunidad() %>
                },
                dataType: 'json',
                success: function(response) {
                    console.log('✅ Respuesta de eliminación:', response);
                    hideLoading();
                    
                    if (response.success) {
                        showSuccess('Comunidad eliminada exitosamente');
                        
                        // Redirigir después de mostrar el mensaje
                        setTimeout(() => {
                            window.location.href = 'ComunidadServlet';
                        }, 2000);
                    } else {
                        showError(response.message || 'Error al eliminar la comunidad');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('❌ Error al eliminar:', {
                        status: status,
                        error: error,
                        response: xhr.responseText
                    });
                    hideLoading();
                    
                    try {
                        var errorResponse = JSON.parse(xhr.responseText);
                        showError(errorResponse.message || 'Error de conexión al eliminar la comunidad');
                    } catch (e) {
                        showError('Error de conexión al eliminar la comunidad');
                    }
                }
            });
        }
        
    </script>
</body>
</html>