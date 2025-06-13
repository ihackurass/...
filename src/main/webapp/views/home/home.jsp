<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="pe.aquasocial.entity.Usuario"%>
<%@page import="pe.aquasocial.entity.Publicacion"%>
<%@page import="pe.aquasocial.entity.Comentario"%>
<%@page import="pe.aquasocial.entity.Comunidad"%>
<%@page import="java.util.List"%>
<%@page import="java.util.LinkedList"%>
<!doctype html>
<html lang="es">

    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <jsp:include page="/components/css_imports.jsp" />

        <title>Agua Bendita - Home</title>
        <style id="toast-styles">
            @keyframes toastProgress {
                0% { transform: scaleX(1); }
                100% { transform: scaleX(0); }
            }
            
            .toast-close:hover {
                opacity: 1 !important;
                background: rgba(255,255,255,0.1) !important;
            }
                
            .toast-notification:hover .toast-progress {
                animation-play-state: paused !important;
            }
            
            /* Responsive */
            @media (max-width: 480px) {
                #toast-container {
                    left: 10px !important;
                    right: 10px !important;
                    max-width: none !important;
                }
            }
        </style>
        <style>
           
            .main-content {
                width: 600px;
                background-color: #ffffff;
                border-radius: 10px;
                box-shadow: 2px 15px 50px rgba(0, 0, 0, 0.1);
                padding: 20px;
            }

            .post-container {
                margin-bottom: 30px;
                background-color: #ffffff;
                border-radius: 10px;
                padding: 20px;
                box-shadow: 0 15px 50px rgba(0, 0, 0, 0.2);
                border: 1px solid #ddd;
                position: relative; /* Añadido para posicionar el badge */
            }

            .post-header {
                display: flex;
                align-items: center;
                margin-bottom: 15px;
            }

            .post-header img {
                width: 50px;
                height: 50px;
                border-radius: 50%;
                margin-right: 10px;
            }

            .badge {
                background-color: #0099ff;
                color: white;
                padding: 2px 6px;
                border-radius: 12px;
                font-size: 12px;
                margin-left: 60px;
            }

            .post-header .user-info {
                display: flex;
                flex-direction: column;
            }

            .post-header .user-info .username {
                font-weight: bold;
                color: #333;
            }

            .post-header .user-info .handle {
                font-size: 14px;
                color: #888;
            }

            .post-header .user-info .post-time {
                font-size: 12px;
                color: #999;
                margin-top: 2px;
            }

            .post-content p {
                font-size: 14px;
                color: #333;
                margin-bottom: 15px;
                line-height: 1.5;
            }

            .post-image {
                width: 100%;
                height: 300px;
                background-size: cover;
                background-position: center;
                border-radius: 10px;
                margin-bottom: 15px;
            }

            .post-actions {
                display: flex;
                align-items: center;
                margin-top: 15px;
                gap: 10px;
            }

            .action-button {
                text-align: center;
                display: flex;
                justify-content: center;
                align-items: center;
                padding: 10px 15px;
                font-size: 14px;
                border-radius: 5px;
                transition: background-color 0.3s, color 0.3s;
                cursor: pointer;
                border: 1px solid #ddd;
                background: white;
            }

            .action-button i {
                margin-right: 5px;
            }

            .action-button:hover {
                background-color: #f0f0f0;
                color: #333;
            }

            .action-button.liked {
                background-color: #ff6b6b;
                color: white;
                border-color: #ff6b6b;
            }
            
            .disabled-donation,
            .action-button:disabled {
                opacity: 0.6;
                cursor: not-allowed;
                background-color: #e9ecef !important;
                color: #6c757d !important;
                border-color: #dee2e6 !important;
            }

            .disabled-donation:hover,
            .action-button:disabled:hover {
                background-color: #e9ecef !important;
                transform: none !important;
                box-shadow: none !important;
            }
            .comments-section {
               margin-top: 15px;
               border-top: 1px solid #ddd;
               padding: 10px 8px;
               max-height: 300px;
               overflow-y: auto;

               /* Scrollbar personalizado más delgado y flat */
               scrollbar-width: thin;
               scrollbar-color: #ccc transparent;
            }

            .new-comment {
               display: flex;
               align-items: center;
               margin: 15px 8px 8px 8px;
               gap: 8px;
            }

            .new-comment input {
               flex: 1;
               padding: 8px 12px;
               border: 1px solid #ddd;
               border-radius: 15px;
               font-size: 13px;
               height: 36px;
               margin-right: 4px;
            }

            .new-comment button {
               background-color: #112ed4;
               color: white;
               border: none;
               border-radius: 50%;
               width: 36px;
               height: 36px;
               cursor: pointer;
               font-size: 14px;
               display: flex;
               align-items: center;
               justify-content: center;
               margin-right: 4px;
            }

            /* Webkit scrollbar para Chrome/Safari */
            .comments-section::-webkit-scrollbar {
                width: 6px;
            }

            .comments-section::-webkit-scrollbar-track {
                background: transparent;
                border-radius: 3px;
            }

            .comments-section::-webkit-scrollbar-thumb {
                background: #ccc;
                border-radius: 3px;
                transition: background 0.3s ease;
            }

            .comments-section::-webkit-scrollbar-thumb:hover {
                background: #999;
            }

            .comment {
                display: flex;
                align-items: flex-start;
                margin-top: 10px;
            }

            .comment img {
                width: 35px;
                height: 35px;
                border-radius: 50%;
                margin-right: 10px;
            }

            .comment .comment-content {
                background-color: #f9f9f9;
                padding: 8px 12px;
                border-radius: 10px;
                flex: 1;
            }

            .comment .comment-content .comment-text {
                font-size: 14px;
                color: #333;
                margin-bottom: 2px;
            }

            .comment .comment-content .comment-info {
                font-size: 12px;
                color: #888;
                display: flex;
                justify-content: space-between;
                margin-top: 5px;
            }


            /* Estilos para el contenedor central */
            .center-container {
                display: flex;
                align-items: flex-start;
                justify-content: center;
                padding: 20px;
            }

            /* Estilos para el Suggestion Sidebar */
            .suggestions-sidebar {
                width: 300px;
                background-color: #ffffff;
                color: #333;
                border-radius: 10px;
                padding: 15px;
                display: flex;
                flex-direction: column;
                align-items: center;
                gap: 20px;
                box-shadow: 0 15px 50px rgba(0, 0, 0, 0.3);
            }

            .suggestions-box {
                width: 100%;
                background-color: #f9f9f9;
                border-radius: 8px;
                padding: 10px;
                display: flex;
                flex-direction: column;
                align-items: flex-start;
            }

            .suggestions-box h3 {
                font-size: 16px;
                font-weight: bold;
                color: #333;
                margin-bottom: 10px;
            }

            .suggestion-item {
                display: flex;
                align-items: center;
                background-color: #ffffff;
                border: 1px solid #ddd;
                border-radius: 8px;
                overflow: hidden;
                margin-bottom: 10px;
                width: 100%;
                color: #333;
                padding: 10px;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            }

            
            <!-- CSS adicional para los botones de comentarios -->

            .comment-actions {
            opacity: 0;
            transition: opacity 0.2s ease;
            margin-top: 5px;
            }

            .comment:hover .comment-actions {
                opacity: 1;
            }

            .comment-actions .btn {
                padding: 2px 6px;
                font-size: 11px;
                margin-left: 3px;
                border-radius: 3px;
            }

            .comment-actions .btn:hover {
                transform: translateY(-1px);
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }

            .edit-comment-form {
                margin-top: 8px;
            }

            .edit-comment-form .input-group {
                margin-bottom: 5px;
            }

            .edit-comment-form textarea {
                font-size: 13px;
                border-radius: 8px;
                resize: vertical;
                min-height: 60px;
            }

            .edit-comment-form .btn {
                padding: 4px 8px;
                font-size: 12px;
            }

            .edit-comment-form small {
                font-size: 11px;
                color: #6c757d;
            }

            /* Mejorar la apariencia general de los comentarios */
            .comment {
                position: relative;
                padding: 10px;
                margin-bottom: 8px;
                border-radius: 8px;
                transition: background-color 0.2s ease;
            }

            .comment:hover {
                background-color: #f8f9fa;
            }

            .comment-content {
                flex: 1;
            }

            .comment-info {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-top: 4px;
            }

            .comment-info span {
                font-size: 11px;
                color: #6c757d;
            }

            /* Indicador de comentario editado */
            .comment-text .text-muted {
                font-size: 10px;
                color: #28a745 !important;
            }

            /* Responsive para móviles */
            @media (max-width: 576px) {
                .comment-actions {
                    opacity: 1; /* Siempre visible en móviles */
                }

                .comment-actions .btn {
                    padding: 4px 8px;
                    font-size: 12px;
                }

                .edit-comment-form .input-group {
                    flex-direction: column;
                }

                .edit-comment-form .input-group-append {
                    display: flex;
                    margin-top: 8px;
                    justify-content: space-between;
                }

                .edit-comment-form .btn {
                    flex: 1;
                    margin: 0 2px;
                }
            }

            /* Animación para comentarios eliminados */
            .comment.deleting {
                animation: slideOutLeft 0.3s ease-out forwards;
                opacity: 0.5;
            }

            @keyframes slideOutLeft {
                from {
                    transform: translateX(0);
                    opacity: 1;
                }
                to {
                    transform: translateX(-100%);
                    opacity: 0;
                }
            }

            /* Loading state para comentarios */
            .comment.loading {
                pointer-events: none;
                opacity: 0.6;
            }

            .comment.loading::after {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: rgba(255,255,255,0.8);
                display: flex;
                align-items: center;
                justify-content: center;
                border-radius: 8px;
            }
                .suggestion-item img {
                    width: 50px;
                    height: 50px;
                    border-radius: 50%;
                    margin-right: 10px;
                }

                .suggestion-item p {
                    font-size: 14px;
                    margin: 0;
                    color: #333;
                    font-weight: bold;
                }

                .suggestion-item span {
                    font-size: 12px;
                    color: #888;
                }

                .spacer {
                    height: 20px;
                }

                .btn-cuadrado {
                    border-radius: 4px;
                    width: 90%;
                    padding: 10px;
                    text-align: center;
                    margin-left: auto;
                    margin-right: auto;
                    border: 1px solid #0099ff;
                    display: block;
                    transition: all 0.3s ease;
                }

                .btn-cuadrado-crear-post {
                    background-color: #0099ff;
                    color: white;
                    margin: 15px;
                }

                .btn-cuadrado-crear-live {
                    background-color: white;
                    color: #0099ff;
                }

                .btn-cuadrado-crear-post:hover {
                    background-color: #007acc;
                    border-color: #007acc;
                }

                .btn-cuadrado-crear-live:hover {
                    background-color: #f1f1f1;
                    border-color: #0099ff;
                }

                .nav-menu li:last-child {
                    margin-top: 20px;
                }

                /* Estilo para checkbox deshabilitado */
                .form-check-input:disabled + .form-check-label {
                    color: #aaa;
                    cursor: not-allowed;
                }

                /* Tooltip para usuarios sin privilegios */
                .privilege-tooltip {
                    position: relative;
                    display: inline-block;
                }

                .privilege-tooltip .tooltip-text {
                    visibility: hidden;
                    width: 250px;
                    background-color: #555;
                    color: #fff;
                    text-align: center;
                    border-radius: 6px;
                    padding: 5px;
                    position: absolute;
                    z-index: 1;
                    bottom: 125%;
                    left: 50%;
                    margin-left: -125px;
                    opacity: 0;
                    transition: opacity 0.3s;
                }

                .privilege-tooltip:hover .tooltip-text {
                    visibility: visible;
                    opacity: 1;
                }

                /* Alertas personalizadas */
                .alert-custom {
                    padding: 15px;
                    margin-bottom: 20px;
                    border: 1px solid transparent;
                    border-radius: 8px;
                    font-size: 14px;
                }

                .alert-success {
                    color: #155724;
                    background-color: #d4edda;
                    border-color: #c3e6cb;
                }

                .alert-error {
                    color: #721c24;
                    background-color: #f8d7da;
                    border-color: #f5c6cb;
                }

                .donation-badge {
                    background-color: #28a745;
                    color: white;
                    padding: 2px 8px;
                    border-radius: 12px;
                    font-size: 11px;
                    margin-left: 10px;
                }

                .loading {
                    text-align: center;
                    padding: 20px;
                    color: #888;
                }

                .no-posts {
                    text-align: center;
                    padding: 40px;
                    color: #666;
                }
                
                /* Estilos para el preview de imagen */
                .image-preview-container {
                    position: relative;
                    display: none;
                    margin-top: 15px;
                    border: 2px dashed #dee2e6;
                    border-radius: 8px;
                    padding: 10px;
                    background-color: #f8f9fa;
                }

                .image-preview {
                    max-width: 100%;
                    max-height: 300px;
                    border-radius: 8px;
                    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                }

                .remove-image-btn {
                    position: absolute;
                    top: 5px;
                    right: 5px;
                    width: 30px;
                    height: 30px;
                    border-radius: 50%;
                    background-color: #dc3545;
                    color: white;
                    border: none;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    cursor: pointer;
                    font-size: 14px;
                    z-index: 10;
                }

                .remove-image-btn:hover {
                    background-color: #c82333;
                }

                /* Tooltip para usuarios sin privilegios */
                .privilege-tooltip {
                    position: relative;
                    display: inline-block;
                }

                .tooltip-text {
                    visibility: hidden;
                    width: 250px;
                    background-color: #555;
                    color: white;
                    text-align: center;
                    border-radius: 6px;
                    padding: 8px;
                    position: absolute;
                    z-index: 1;
                    bottom: 125%;
                    left: 50%;
                    margin-left: -125px;
                    opacity: 0;
                    transition: opacity 0.3s;
                    font-size: 12px;
                }

                .privilege-tooltip:hover .tooltip-text {
                    visibility: visible;
                    opacity: 1;
                }

                /* Estilos para el botón de subir imagen */
                .upload-btn-container {
                    position: relative;
                    overflow: hidden;
                    display: inline-block;
                }

                /* Loading spinner */
                .loading-spinner {
                    display: none;
                    text-align: center;
                    margin: 10px 0;
                }

                /* Animación de éxito */
                .success-message {
                    display: none;
                    text-align: center;
                    color: #28a745;
                    margin: 10px 0;
                }
                .warning-message {
                    display: none;
                    text-align: center;
                    color: #baad1e;
                    margin: 10px 0;
                }
                
                
                .payment-method-option .payment-label {
                    transition: all 0.3s ease;
                    background: #fff;
                }

                .payment-method-option .payment-label:hover {
                    border-color: #007bff !important;
                    transform: translateY(-2px);
                    box-shadow: 0 4px 12px rgba(0,123,255,0.15);
                }

                .payment-method-option input:checked + .payment-label {
                    border-color: #28a745 !important;
                    background-color: #f8f9fa;
                    box-shadow: 0 0 0 2px rgba(40,167,69,0.25);
                }

                .cursor-pointer {
                    cursor: pointer;
                }

                .form-control:focus {
                    border-color: #28a745;
                    box-shadow: 0 0 0 0.2rem rgba(40,167,69,0.25);
                }

                #donationTotal {
                    font-size: 1.25rem;
                    font-weight: bold;
                }
                
                .modal-dialog {
                    max-width: 700px;
                }

                .form-control:focus {
                    border-color: #00a650;
                    box-shadow: 0 0 0 0.2rem rgba(0, 166, 80, 0.25);
                }

                .btn-success {
                    background-color: #00a650;
                    border-color: #00a650;
                }

                .btn-success:hover {
                    background-color: #008f45;
                    border-color: #008f45;
                }

                .alert-info {
                    background-color: #e3f2fd;
                    border-color: #bbdefb;
                    color: #0d47a1;
                }

                .alert-success {
                    background-color: #e8f5e8;
                    border-color: #c3e6c3;
                    color: #2e7d32;
                }

                #donationTotal {
                    font-size: 1.5rem;
                    font-weight: bold;
                }

                .border {
                    border: 1px solid #dee2e6 !important;
                }

                .rounded {
                    border-radius: 0.375rem !important;
                }

                .text-center small {
                    font-size: 0.75rem;
                }

                .payment-result-modal {
                    border-radius: 15px;
                    border: none;
                    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
                    overflow: hidden;
                }

                .payment-result-modal .modal-header {
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    padding: 30px 20px 20px;
                    position: relative;
                }

                .payment-result-modal .modal-title {
                    color: white;
                    font-weight: 600;
                    font-size: 1.2rem;
                }

                .payment-result-modal .close {
                    position: absolute;
                    top: 15px;
                    right: 20px;
                    color: white;
                    opacity: 0.8;
                    font-size: 1.5rem;
                }

                .payment-result-modal .close:hover {
                    color: white;
                    opacity: 1;
                }

                .payment-icon-circle {
                    width: 80px;
                    height: 80px;
                    background: linear-gradient(135deg, #007bff, #0056b3);
                    border-radius: 50%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    margin: 0 auto;
                    animation: pulseIcon 2s infinite;
                    box-shadow: 0 4px 15px rgba(0, 123, 255, 0.3);
                }

                .payment-icon {
                    color: white;
                    font-size: 2.5rem;
                }

                .payment-result-modal .modal-body {
                    background: linear-gradient(to bottom, #f8f9fa, #ffffff);
                    padding: 30px 20px;
                }

                .payment-message {
                    margin: 20px 0;
                }

                .payment-message .lead {
                    font-size: 1.1rem;
                    color: #495057;
                    margin-bottom: 0;
                }

                .aqua-social-badge {
                    background: rgba(102, 126, 234, 0.1);
                    border: 1px solid rgba(102, 126, 234, 0.2);
                    padding: 12px 20px;
                    border-radius: 10px;
                    margin-top: 20px;
                }

                .aqua-social-badge small {
                    font-weight: 600;
                    color: #667eea;
                }

                .payment-result-modal .modal-footer {
                    background: #ffffff;
                    padding: 20px;
                }

                .btn-continue {
                    border-radius: 25px;
                    padding: 12px 30px;
                    font-weight: 600;
                    font-size: 1rem;
                    min-width: 120px;
                    transition: all 0.3s ease;
                }

                .btn-continue:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 4px 15px rgba(0, 123, 255, 0.3);
                }

                .payment-result-modal.success .modal-header {
                    background: linear-gradient(135deg, #28a745, #20c997);
                }

                .payment-result-modal.success .payment-icon-circle {
                    background: linear-gradient(135deg, #28a745, #20c997);
                    box-shadow: 0 4px 15px rgba(40, 167, 69, 0.3);
                }

                .payment-result-modal.success .payment-icon {
                    color: white;
                }

                .payment-result-modal.success .btn-continue {
                    background: linear-gradient(135deg, #28a745, #20c997);
                    border: none;
                    color: white;
                }

                .payment-result-modal.success .btn-continue:hover {
                    background: linear-gradient(135deg, #218838, #1ea97c);
                    box-shadow: 0 4px 15px rgba(40, 167, 69, 0.4);
                }

                .payment-result-modal.success .aqua-social-badge {
                    background: rgba(40, 167, 69, 0.1);
                    border-color: rgba(40, 167, 69, 0.2);
                }

                .payment-result-modal.success .aqua-social-badge small {
                    color: #28a745;
                }

                .payment-result-modal.error .modal-header {
                    background: linear-gradient(135deg, #dc3545, #c82333);
                }

                .payment-result-modal.error .payment-icon-circle {
                    background: linear-gradient(135deg, #dc3545, #c82333);
                    box-shadow: 0 4px 15px rgba(220, 53, 69, 0.3);
                    animation: shakeIcon 0.5s ease-in-out;
                }

                .payment-result-modal.error .payment-icon {
                    color: white;
                }

                .payment-result-modal.error .btn-continue {
                    background: linear-gradient(135deg, #dc3545, #c82333);
                    border: none;
                    color: white;
                }

                .payment-result-modal.error .btn-continue:hover {
                    background: linear-gradient(135deg, #c82333, #bd2130);
                    box-shadow: 0 4px 15px rgba(220, 53, 69, 0.4);
                }

                .payment-result-modal.error .aqua-social-badge {
                    background: rgba(220, 53, 69, 0.1);
                    border-color: rgba(220, 53, 69, 0.2);
                }

                .payment-result-modal.error .aqua-social-badge small {
                    color: #dc3545;
                }

                .payment-result-modal.warning .modal-header {
                    background: linear-gradient(135deg, #ffc107, #fd7e14);
                }

                .payment-result-modal.warning .payment-icon-circle {
                    background: linear-gradient(135deg, #ffc107, #fd7e14);
                    box-shadow: 0 4px 15px rgba(255, 193, 7, 0.3);
                }

                .payment-result-modal.warning .payment-icon {
                    color: #212529;
                }

                .payment-result-modal.warning .btn-continue {
                    background: linear-gradient(135deg, #ffc107, #fd7e14);
                    border: none;
                    color: #212529;
                }

                .payment-result-modal.warning .btn-continue:hover {
                    background: linear-gradient(135deg, #e0a800, #e55a00);
                    box-shadow: 0 4px 15px rgba(255, 193, 7, 0.4);
                }

                .payment-result-modal.warning .aqua-social-badge {
                    background: rgba(255, 193, 7, 0.1);
                    border-color: rgba(255, 193, 7, 0.2);
                }

                .payment-result-modal.warning .aqua-social-badge small {
                    color: #ffc107;
                }

                @keyframes pulseIcon {
                    0% {
                        transform: scale(1);
                        box-shadow: 0 4px 15px rgba(0, 123, 255, 0.3);
                    }
                    50% {
                        transform: scale(1.05);
                        box-shadow: 0 6px 20px rgba(0, 123, 255, 0.4);
                    }
                    100% {
                        transform: scale(1);
                        box-shadow: 0 4px 15px rgba(0, 123, 255, 0.3);
                    }
                }

                @keyframes shakeIcon {
                    0%, 100% {
                        transform: translateX(0);
                    }
                    25% {
                        transform: translateX(-5px);
                    }
                    75% {
                        transform: translateX(5px);
                    }
                }

                @media (max-width: 768px) {
                    .payment-result-modal {
                        margin: 20px;
                    }

                    .payment-result-modal .modal-header {
                        padding: 20px 15px 15px;
                    }

                    .payment-icon-circle {
                        width: 60px;
                        height: 60px;
                    }

                    .payment-icon {
                        font-size: 2rem;
                    }

                    .payment-result-modal .modal-title {
                        font-size: 1.1rem;
                    }

                    .payment-message .lead {
                        font-size: 1rem;
                    }

                    .btn-continue {
                        padding: 10px 25px;
                        font-size: 0.9rem;
                    }
                }

                @media (max-width: 480px) {
                    .payment-result-modal .modal-body {
                        padding: 20px 15px;
                    }

                    .aqua-social-badge {
                        padding: 10px 15px;
                    }

                    .payment-result-modal .modal-footer {
                        padding: 15px;
                    }
                }

    /* ============== MODAL MODERNO - BASE ============== */
    .modal-modern {
        border: none;
        border-radius: 20px;
        box-shadow: 0 20px 60px rgba(0,0,0,0.15);
        overflow: hidden;
    }

    /* ============== HEADER ============== */
    .modal-header-gradient {
        background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
        border: none;
        padding: 25px 30px;
        position: relative;
    }

    .modal-header-content {
        display: flex;
        align-items: center;
        width: 100%;
    }

    .modal-icon {
        width: 50px;
        height: 50px;
        background: rgba(255,255,255,0.2);
        border-radius: 15px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-right: 15px;
    }

    .modal-icon i {
        font-size: 20px;
        color: white;
    }

    .modal-title-section h5 {
        color: white;
        margin: 0;
        font-size: 18px;
        font-weight: 600;
    }

    .modal-subtitle {
        color: rgba(255,255,255,0.8);
        margin: 0;
        font-size: 13px;
    }

    .close-modern {
        background: rgba(255,255,255,0.2);
        border: none;
        border-radius: 10px;
        width: 35px;
        height: 35px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        transition: all 0.3s ease;
    }

    .close-modern:hover {
        background: rgba(255,255,255,0.3);
        transform: scale(1.1);
    }

    /* ============== BODY ============== */
    .modal-body-modern {
        padding: 30px;
        background: #f8f9fa;
    }

    .modern-form {
        background: white;
        border-radius: 15px;
        padding: 25px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.05);
    }

    /* ============== FORM GROUPS ============== */
    .form-group-modern {
        margin-bottom: 25px;
    }

    .form-label-modern {
        font-weight: 600;
        color: #495057;
        margin-bottom: 10px;
        display: flex;
        align-items: center;
        font-size: 14px;
    }

    .form-label-modern i {
        margin-right: 8px;
        color: #007bff;
        width: 16px;
    }

    .form-control-modern {
        border: 2px solid #e9ecef;
        border-radius: 12px;
        padding: 12px 15px;
        font-size: 14px;
        transition: all 0.3s ease;
        width: 100%;
        resize: vertical;
    }

    .form-control-modern:focus {
        border-color: #007bff;
        box-shadow: 0 0 0 0.2rem rgba(0,123,255,0.15);
        outline: none;
    }

    .form-help-text {
        font-size: 12px;
        color: #6c757d;
        margin-top: 5px;
    }

    /* ============== CONTADOR DE CARACTERES ============== */
    .char-counter-modern {
        text-align: right;
        font-size: 12px;
        color: #6c757d;
        margin-top: 5px;
    }

    .char-counter-modern.warning {
        color: #ffc107;
    }

    .char-counter-modern.danger {
        color: #dc3545;
    }

    /* ============== UPLOAD DE IMAGEN ============== */
    .image-upload-zone {
        border: 2px dashed #ddd;
        border-radius: 12px;
        padding: 30px;
        text-align: center;
        background: #f8f9fa;
        transition: all 0.3s ease;
        cursor: pointer;
    }

    .image-upload-zone:hover {
        border-color: #007bff;
        background: rgba(0,123,255,0.05);
    }

    .image-upload-zone.dragover {
        border-color: #007bff;
        background: rgba(0,123,255,0.1);
    }

    .upload-content h6 {
        color: #495057;
        margin: 10px 0 5px;
        font-weight: 600;
    }

    .upload-hint {
        color: #6c757d;
        font-size: 12px;
        margin-bottom: 15px;
    }

    .upload-icon {
        font-size: 32px;
        color: #007bff;
        margin-bottom: 10px;
    }

    .btn-upload {
        background: #007bff;
        color: white;
        border: none;
        border-radius: 8px;
        padding: 8px 16px;
        font-size: 13px;
        font-weight: 600;
        transition: all 0.3s ease;
    }

    .btn-upload:hover {
        background: #0056b3;
        transform: translateY(-1px);
    }

    /* ============== PREVIEW DE IMAGEN ============== */
    .image-preview-wrapper {
        position: relative;
        display: inline-block;
        margin-top: 15px;
    }

    .image-preview-modern {
        max-width: 100%;
        max-height: 200px;
        border-radius: 12px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
    }

    .remove-image-btn-modern {
        position: absolute;
        top: -8px;
        right: -8px;
        width: 25px;
        height: 25px;
        background: #dc3545;
        color: white;
        border: none;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 12px;
        cursor: pointer;
        transition: all 0.3s ease;
        box-shadow: 0 2px 8px rgba(220,53,69,0.3);
    }

    .remove-image-btn-modern:hover {
        background: #c82333;
        transform: scale(1.1);
    }

    /* ============== CHECKBOX MODERNO ============== */
    .checkbox-modern {
        display: flex;
        align-items: flex-start;
        margin-bottom: 10px;
    }

    .checkbox-modern.disabled {
        opacity: 0.6;
    }

    .checkbox-input {
        display: none;
    }

    .checkbox-label {
        display: flex;
        align-items: center;
        cursor: pointer;
        font-size: 14px;
        color: #495057;
    }

    .checkbox-custom {
        width: 20px;
        height: 20px;
        border: 2px solid #ddd;
        border-radius: 6px;
        margin-right: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s ease;
        flex-shrink: 0;
    }

    .checkbox-input:checked + .checkbox-label .checkbox-custom {
        background: #007bff;
        border-color: #007bff;
    }

    .checkbox-input:checked + .checkbox-label .checkbox-custom::after {
        content: '✓';
        color: white;
        font-size: 12px;
        font-weight: bold;
    }

    .checkbox-text i:first-child {
        margin-right: 6px;
        color: #007bff;
    }

    /* ============== LOADING MODERNO ============== */
    .loading-modern {
        text-align: center;
        padding: 40px 20px;
        display: none;
    }

    .spinner-modern {
        display: flex;
        justify-content: center;
        align-items: center;
        margin-bottom: 20px;
    }

    .spinner-circle {
        width: 12px;
        height: 12px;
        background: #007bff;
        border-radius: 50%;
        margin: 0 3px;
        animation: spinner-bounce 1.4s ease-in-out infinite both;
    }

    .spinner-circle:nth-child(1) { animation-delay: -0.32s; }
    .spinner-circle:nth-child(2) { animation-delay: -0.16s; }

    @keyframes spinner-bounce {
        0%, 80%, 100% {
            transform: scale(0);
        }
        40% {
            transform: scale(1);
        }
    }

    .loading-modern h6 {
        color: #495057;
        margin-bottom: 5px;
    }

    .loading-modern p {
        color: #6c757d;
        font-size: 14px;
        margin: 0;
    }

    /* ============== SUCCESS MODERNO ============== */
    .success-modern {
        text-align: center;
        padding: 40px 20px;
        display: none;
    }

    .success-icon {
        width: 80px;
        height: 80px;
        background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 20px;
        animation: success-pulse 1s ease-out;
    }

    .success-icon i {
        font-size: 32px;
        color: white;
    }

    @keyframes success-pulse {
        0% {
            transform: scale(0);
        }
        50% {
            transform: scale(1.1);
        }
        100% {
            transform: scale(1);
        }
    }

    .success-modern h6 {
        color: #28a745;
        margin-bottom: 8px;
        font-weight: 600;
    }

    .success-modern p {
        color: #6c757d;
        margin: 0;
    }

    /* ============== FOOTER ============== */
    .modal-footer-modern {
        background: white;
        border: none;
        padding: 20px 30px;
        display: flex;
        justify-content: space-between;
        gap: 15px;
    }

    .btn-modern {
        border: none;
        border-radius: 10px;
        padding: 12px 24px;
        font-weight: 600;
        font-size: 14px;
        display: flex;
        align-items: center;
        gap: 8px;
        transition: all 0.3s ease;
        flex: 1;
        justify-content: center;
    }

    .btn-modern.btn-secondary {
        background: #6c757d;
        color: white;
    }

    .btn-modern.btn-secondary:hover {
        background: #5a6268;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(108,117,125,0.3);
    }

    .btn-modern.btn-primary {
        background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
        color: white;
    }

    .btn-modern.btn-primary:hover {
        background: linear-gradient(135deg, #0056b3 0%, #004085 100%);
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(0,123,255,0.3);
    }

    .btn-modern:disabled {
        opacity: 0.6;
        cursor: not-allowed;
        transform: none !important;
    }
    .community-header {
        background: linear-gradient(135deg, #007bff, #0056b3);
        color: white;
        padding: 12px 20px;
        margin: -20px -20px 20px -20px;
        border-radius: 10px 10px 0 0;
        border-bottom: 3px solid rgba(255,255,255,0.2);
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
    }

    .community-header-content {
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .community-icon {
        background: rgba(255,255,255,0.2);
        width: 35px;
        height: 35px;
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 16px;
    }

    .community-name {
        margin: 0;
        font-size: 20px;
        font-weight: 500;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        letter-spacing: -0.02em;
    }

    .community-label {
        font-size: 11px;
        opacity: 0.85;
        text-transform: uppercase;
        letter-spacing: 0.08em;
        font-weight: 400;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
    }

    /* ============== RESPONSIVE ============== */
    @media (max-width: 768px) {
        .modal-dialog {
            margin: 10px;
        }
        
        .modal-body-modern {
            padding: 20px;
        }
        
        .modern-form {
            padding: 20px;
        }
        
        .modal-header-gradient {
            padding: 20px;
        }
        
        .modal-footer-modern {
            padding: 15px 20px;
            flex-direction: column;
        }
        
        .btn-modern {
            flex: none;
        }
    }
        </style>
    </head>

    <body>
        <%
            Usuario usuarioActual = (Usuario) session.getAttribute("usuarioLogueado");
            boolean tienePrivilegios = false;
        
            if (usuarioActual != null) {
                tienePrivilegios = usuarioActual.isPrivilegio();
            }
            
            // PUBLICACIONES
            @SuppressWarnings("unchecked")
            List<Publicacion> publicaciones = (List<Publicacion>) request.getAttribute("publicaciones");
            String mensajeExito = (String) request.getAttribute("success");
            String mensajeError = (String) request.getAttribute("error");
            Integer totalPublicaciones = (Integer) request.getAttribute("totalPublicaciones");
            
            // COMUNIDAD
            List<Comunidad> comunidadesQueAdministra = (List<Comunidad>) request.getAttribute("comunidadesQueAdministra");
            List<Comunidad> comunidadesSugeridas = (List<Comunidad>) request.getAttribute("comunidadesSugeridas");

            Boolean usuarioEsAdminComunidades = (Boolean) request.getAttribute("usuarioEsAdminComunidades");
            boolean puedeAdministrarComunidades = usuarioEsAdminComunidades != null && usuarioEsAdminComunidades;
        %>

        <!-- Sidebar Izquierdo -->
        <jsp:include page="/components/sidebar.jsp" />

        <!-- Modal de Stream -->
        <div class="modal fade" id="streamModal" tabindex="-1" role="dialog" aria-labelledby="streamModalLabel"
             aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="streamModalLabel">Iniciar Nuevo Stream</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <form>
                            <div class="form-group">
                                <label for="streamName">Nombre del Stream</label>
                                <input type="text" class="form-control" id="streamName" placeholder="Nombre del Stream">
                            </div>
                            <div class="form-group text-left">
                                <button type="button" class="btn btn-primary" id="streamImage">
                                    <i class="fas fa-image"></i> Subir Imagen De Stream
                                </button>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer d-flex justify-content-center">
                        <button type="button" class="btn btn-secondary me-3" data-dismiss="modal">
                            <i class="fas fa-times-circle"></i> Cancelar
                        </button>
                        <button type="button" class="btn btn-success ms-3">
                            <i class="fas fa-check-circle"></i> Guardar
                        </button>
                    </div>
                </div>
            </div>
        </div>

           <!-- Modal simple para resultados de pago -->
           <div class="modal fade" id="paymentResultModal" tabindex="-1" role="dialog">
               <div class="modal-dialog modal-dialog-centered" role="document">
                   <div class="modal-content payment-result-modal">
                       <div class="modal-header text-center border-0">
                           <div class="w-100">
                               <div class="payment-icon-circle">
                                   <i class="fas fa-heart payment-icon"></i>
                               </div>
                               <h5 class="modal-title mt-3">Resultado de Donación</h5>
                           </div>
                           <button type="button" class="close" data-dismiss="modal">
                               <span>&times;</span>
                           </button>
                       </div>
                       <div class="modal-body text-center pb-4">
                           <div class="payment-message">
                               <p class="lead">Tu donación se ha procesado correctamente.</p>
                           </div>
                           <div class="aqua-social-badge">
                               <small class="text-muted">💧 AQUASOCIAL - Red Social del Agua</small>
                           </div>
                       </div>
                       <div class="modal-footer border-0 justify-content-center">
                           <button type="button" class="btn btn-primary btn-continue" data-dismiss="modal">
                               Continuar
                           </button>
                       </div>
                   </div>
               </div>
           </div>   
            <div class="modal fade" id="postModal" tabindex="-1" role="dialog" aria-labelledby="postModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                    <div class="modal-content modal-modern">
                        <!-- Header mejorado -->
                        <div class="modal-header modal-header-gradient">
                            <div class="modal-header-content">
                                <div class="modal-icon">
                                    <i class="fas fa-edit"></i>
                                </div>
                                <div class="modal-title-section">
                                    <h5 class="modal-title" id="postModalLabel">Crear Nueva Publicación</h5>
                                    <p class="modal-subtitle">Comparte algo interesante con la comunidad</p>
                                </div>
                            </div>
                            <button type="button" class="close-modern" data-dismiss="modal" aria-label="Close">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>

                        <div class="modal-body modal-body-modern">
                            <form id="formCrearPost" class="modern-form">
                                <input type="hidden" name="action" value="createPost">
                                <input type="hidden" name="idUsuario" value="<%= usuarioActual != null ? usuarioActual.getId() : "" %>">

                                <!-- Textarea para el contenido -->
                                <div class="form-group-modern">
                                    <label for="postContent" class="form-label-modern">
                                        <i class="fas fa-pen-fancy"></i> ¿Qué quieres compartir?
                                    </label>
                                    <textarea class="form-control-modern" 
                                              id="postContent" 
                                              name="texto" 
                                              rows="4"
                                              placeholder="Escribe algo interesante, comparte una reflexión o cuenta tu experiencia..."
                                              maxlength="999"
                                              required></textarea>
                                    <div class="char-counter-modern">
                                        <span id="contadorCaracteres">0</span>/999 caracteres
                                    </div>
                                </div>

                                <!-- Sección de comunidades (si aplica) -->
                                <% if (puedeAdministrarComunidades && comunidadesQueAdministra != null && !comunidadesQueAdministra.isEmpty()) { %>
                                <div class="form-group-modern">
                                    <label for="communitySelect" class="form-label-modern">
                                        <i class="fas fa-users"></i> Publicar en:
                                    </label>
                                    <select class="form-control-modern" id="communitySelect" name="idComunidad">
                                        <option value="">📍 Feed Principal (Público)</option>
                                        <% for (Comunidad comunidad : comunidadesQueAdministra) { %>
                                            <option value="<%= comunidad.getIdComunidad() %>">
                                                🛡️ <%= comunidad.getNombre() %>
                                            </option>
                                        <% } %>
                                    </select>
                                    <div class="form-help-text">
                                        Como administrador, puedes publicar directamente en estas comunidades
                                    </div>
                                </div>
                                <% } %>

                                <!-- Upload de imagen mejorado -->
                                <div class="form-group-modern">
                                    <label class="form-label-modern">
                                        <i class="fas fa-image"></i> Agregar imagen (opcional)
                                    </label>
                                    <div class="image-upload-zone" id="imageUploadZone">
                                        <div class="upload-content">
                                            <i class="fas fa-cloud-upload-alt upload-icon"></i>
                                            <h6>Arrastra una imagen o haz clic para seleccionar</h6>
                                            <p class="upload-hint">Formatos: JPG, PNG, GIF. Máximo 5MB</p>
                                            <button type="button" class="btn-upload" id="btnSubirImagen">
                                                <i class="fas fa-plus"></i> Seleccionar Imagen
                                            </button>
                                        </div>
                                        <input type="file" id="inputImagen" name="imagen" accept="image/*" style="display:none">
                                    </div>

                                    <!-- Preview de imagen -->
                                    <div class="image-preview-container" id="imagePreviewContainer" style="display: none;">
                                        <div class="image-preview-wrapper">
                                            <img id="imagePreview" class="image-preview-modern" src="" alt="Preview">
                                            <button type="button" class="remove-image-btn-modern" id="removeImageBtn">
                                                <i class="fas fa-times"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>

                                <!-- Configuración de donaciones -->
                                <% if(tienePrivilegios) { %>
                                <div class="form-group-modern">
                                    <div class="checkbox-modern">
                                        <input type="checkbox" class="checkbox-input" id="receiveMoney" name="permiteDonacion">
                                        <label class="checkbox-label" for="receiveMoney">
                                            <span class="checkbox-custom"></span>
                                            <span class="checkbox-text">
                                                <i class="fas fa-gift"></i> Permitir donaciones en esta publicación
                                            </span>
                                        </label>
                                    </div>
                                    <div class="form-help-text">
                                        Los usuarios podrán apoyarte económicamente si les gusta tu contenido
                                    </div>
                                </div>
                                <% } else { %>
                                <div class="form-group-modern">
                                    <div class="checkbox-modern disabled">
                                        <input type="checkbox" class="checkbox-input" id="receiveMoney" disabled>
                                        <label class="checkbox-label" for="receiveMoney">
                                            <span class="checkbox-custom"></span>
                                            <span class="checkbox-text">
                                                <i class="fas fa-gift"></i> Permitir donaciones 
                                                <i class="fas fa-lock text-muted" title="Función solo para usuarios privilegiados"></i>
                                            </span>
                                        </label>
                                    </div>
                                    <div class="form-help-text">
                                        Necesitas ser un usuario privilegiado para habilitar esta opción
                                    </div>
                                </div>
                                <% } %>
                            </form>

                            <!-- Loading spinner mejorado -->
                            <div class="loading-modern" id="loadingSpinner" style="display: none;">
                                <div class="spinner-modern">
                                    <div class="spinner-circle"></div>
                                    <div class="spinner-circle"></div>
                                    <div class="spinner-circle"></div>
                                </div>
                                <h6>Publicando tu contenido...</h6>
                                <p>Por favor espera un momento</p>
                            </div>

                            <!-- Mensaje de éxito mejorado -->
                            <div class="success-modern" id="successMessage" style="display: none;">
                                <div class="success-icon">
                                    <i class="fas fa-check-circle"></i>
                                </div>
                                <h6>¡Publicación creada exitosamente!</h6>
                                <p>Tu contenido se ha compartido con la comunidad</p>
                            </div>
                        </div>

                        <!-- Footer mejorado -->
                        <div class="modal-footer modal-footer-modern">
                            <button type="button" class="btn-modern btn-secondary" data-dismiss="modal">
                                <i class="fas fa-times"></i> Cancelar
                            </button>
                            <button type="button" class="btn-modern btn-primary" id="btnPublicar">
                                <i class="fas fa-paper-plane"></i> Publicar
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        
        <!-- Modal de Donación - Adaptado para Checkout Pro -->
        <div class="modal fade" id="donationModal" tabindex="-1" role="dialog" aria-labelledby="donationModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="donationModalLabel">
                            <i class="fas fa-gift text-primary"></i> Enviar un regalo
                        </h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <form id="formDonacion">
                            <!-- IDs ocultos para el JavaScript -->
                            <input type="hidden" id="donationPostId" name="idPublicacion" value="">
                            <input type="hidden" id="donationUserId" name="idUsuario" value="">

                            <!-- Información del usuario destinatario -->
                            <div class="d-flex mb-3" id="donationUserInfo">
                                <img src="assets/images/avatars/default.png" alt="User Avatar" class="rounded-circle" width="50" height="50" id="donationUserAvatar">
                                <div class="ms-3">
                                    <p class="font-weight-bold mb-0 creator-name">Usuario</p>
                                    <p class="mb-0" id="donationUserHandle">@usuario</p>
                                    <p class="mb-0 text-muted">Enviar un regalo a este usuario</p>
                                </div>
                            </div>

                            <!-- Monto de donación -->
                            <div class="form-group mb-3">
                                <label for="donationAmount" class="form-label">
                                    <i class="fas fa-dollar-sign text-success"></i> Monto de la donación (S/)
                                </label>
                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">S/</span>
                                    </div>
                                    <input type="number" class="form-control" id="donationAmount" name="cantidad" 
                                           value="0" min="1" max="10000" step="0.01" required>
                                </div>
                                <div id="amountError" class="text-danger small mt-1" style="display: none;"></div>
                                <small class="form-text text-muted">Mínimo S/ 1.00 - Máximo S/ 10,000</small>
                            </div>

                            <!-- Datos del donante -->
                            <div class="form-group mb-3">
                                <label for="donorName">
                                    <i class="fas fa-user"></i> Nombre completo *
                                </label>
                                <input type="text" class="form-control" id="donorName" name="donorName" 
                                       placeholder="Tu nombre completo" required>
                            </div>

                            <div class="form-group mb-3">
                                <label for="donorEmail">
                                    <i class="fas fa-envelope"></i> Email *
                                </label>
                                <input type="email" class="form-control" id="donorEmail" name="donorEmail" 
                                       placeholder="tu@email.com" required>
                                <small class="form-text text-muted">Para enviarte el comprobante</small>
                            </div>

                            <div class="form-group mb-3">
                                <label for="donorMessage">
                                    <i class="fas fa-comment"></i> Mensaje (opcional)
                                </label>
                                <textarea class="form-control" id="donorMessage" name="mensaje" 
                                          placeholder="Mensaje opcional para el destinatario" rows="2"></textarea>
                            </div>

                            <!-- Total a pagar -->
                            <div class="card bg-light mb-3">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <span class="font-weight-bold">Total a pagar:</span>
                                        <span class="h5 mb-0 text-success" id="donationTotal">S/ 2.00</span>
                                    </div>
                                </div>
                            </div>

                            <!-- Información de Mercado Pago -->
                            <div class="alert alert-info">
                                <div class="d-flex align-items-center">
                                    <img src="assets/images/mp.png" 
                                         alt="Mercado Pago" width="120" class="me-3">
                                    <div>
                                        <strong>Pago seguro con Mercado Pago</strong><br>
                                        <small>Acepta tarjetas, Yape, PagoEfectivo y más métodos</small>
                                    </div>
                                </div>
                            </div>

                            <!-- Métodos de pago disponibles (solo informativo) -->
                            <div class="row text-center mb-3">
                                <div class="col-3">
                                    <div class="p-2 border rounded">
                                        <i class="fas fa-credit-card text-primary mb-1"></i>
                                        <small class="d-block">Tarjetas</small>
                                    </div>
                                </div>
                                <div class="col-3">
                                    <div class="p-2 border rounded">
                                        <i class="fas fa-mobile-alt text-warning mb-1"></i>
                                        <small class="d-block">Yape</small>
                                    </div>
                                </div>
                                <div class="col-3">
                                    <div class="p-2 border rounded">
                                        <i class="fas fa-university text-info mb-1"></i>
                                        <small class="d-block">Bancos</small>
                                    </div>
                                </div>
                                <div class="col-3">
                                    <div class="p-2 border rounded">
                                        <i class="fas fa-wallet text-success mb-1"></i>
                                        <small class="d-block">Efectivo</small>
                                    </div>
                                </div>
                            </div>

                            <div class="alert alert-success">
                                <small>
                                    <i class="fas fa-shield-alt"></i>
                                    <strong>100% Seguro:</strong> Mercado Pago protege tus datos y garantiza tu compra.
                                </small>
                            </div>
                        </form>
                    </div>

                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">
                            <i class="fas fa-times"></i> Cancelar
                        </button>
                        <button type="button" class="btn btn-success" id="processDonationBtn" disabled>
                            <i class="fas fa-heart"></i> Donar con Mercado Pago
                        </button>
                    </div>
                </div>
            </div>
        </div>


        <main>
            <div class="site-section">
                <div class="container">
                    <div class="row">
                        <div class="col-md-8">
                            
                            <!-- Mostrar mensajes de éxito o error -->
                            <% if (mensajeExito != null) { %>
                                <div class="alert-custom alert-success">
                                    <i class="fas fa-check-circle"></i> <%= mensajeExito %>
                                </div>
                            <% } %>
                            
                            <% if (mensajeError != null) { %>
                                <div class="alert-custom alert-error">
                                    <i class="fas fa-exclamation-triangle"></i> <%= mensajeError %>
                                </div>
                            <% } %>

                            <!-- Mostrar contador de publicaciones -->
                            <% if (totalPublicaciones != null && totalPublicaciones > 0) { %>
                                <div class="mb-3 text-muted">
                                    <small><i class="fas fa-newspaper"></i> Mostrando <%= totalPublicaciones %> publicaciones</small>
                                </div>
                            <% } %>

                            <!-- Contenedor de publicaciones dinámicas -->
                            <div id="publicacionesContainer">
                                <% 
                                if (publicaciones != null && !publicaciones.isEmpty()) {
                                    for (Publicacion pub : publicaciones) {
                                        @SuppressWarnings("unchecked")
                                        List<Comentario> comentarios = (List<Comentario>) request.getAttribute("comentarios_" + pub.getIdPublicacion());
                                %>
                                        <div class="post-container" data-post-id="<%= pub.getIdPublicacion() %>">

                                            <% if (pub.getNombreComunidad() != null && !pub.getNombreComunidad().trim().isEmpty()) { %>
                                                <div class="community-header">
                                                    <div class="community-header-content">
                                                        <div class="community-icon">
                                                            <i class="fas fa-users"></i>
                                                        </div>
                                                        <div class="community-info">
                                                            <h6 class="community-name"><%= pub.getNombreComunidad() %></h6>
                                                            <span class="community-label">Publicación de comunidad</span>
                                                        </div>
                                                    </div>
                                                </div>
                                            <% } %>
                                            <div class="post-header">
                                                <img src="<%= pub.getAvatarUsuario() != null ? pub.getAvatarUsuario() : "assets/images/avatars/default.png" %>" alt="User Avatar">
                                                <div class="user-info">
                                                    <span class="username"><%= pub.getNombreCompleto() != null ? pub.getNombreCompleto() : "Nombre" %></span>
                                                    <span class="handle"><%= pub.getNombreUsuario() != null ? pub.getNombreUsuario() : "@usuario" %></span>
                                                    <span class="post-time"><%= pub.getTiempoTranscurrido() %></span>
                                                </div>
                                                <% if (pub.isPermiteDonacion()) { %>
                                                    <span class="donation-badge">
                                                        <i class="fas fa-gift"></i> Acepta donaciones
                                                    </span>
                                                <% } %>
                                            </div>
                                            
                                            <div class="post-content">
                                                <p><%= pub.getTexto() %></p>
                                                <% if (pub.getImagenUrl() != null && !pub.getImagenUrl().isEmpty()) { %>
                                                    <div class="post-image" style="background-image: url('<%= pub.getImagenUrl() %>')"></div>
                                                <% } %>
                                            </div>
                                            
                                            <div class="post-actions d-flex flex-wrap justify-content-between align-items-center">
                                                <button class="action-button btn flex-grow-1 text-center me-2 mb-2" 
                                                        onclick="toggleLike(<%= pub.getIdPublicacion() %>)" 
                                                        id="likeBtn_<%= pub.getIdPublicacion() %>"
                                                        data-user-liked="<%= pub.isUsuarioDioLike() %>">
                                                    <i class="<%= pub.isUsuarioDioLike() ? "fas" : "far" %> fa-heart"></i> 
                                                    <span id="likeCount_<%= pub.getIdPublicacion() %>"><%= pub.getCantidadLikes() %></span>
                                                </button>
                                                
                                                <button class="action-button btn flex-grow-1 text-center me-2 mb-2" 
                                                        onclick="toggleComments(<%= pub.getIdPublicacion() %>)">
                                                    <i class="fas fa-comment"></i> <span id="commentCount_<%= pub.getIdPublicacion() %>"><%= pub.getCantidadComentarios() %></span>
                                                </button>

                                            <% if (pub.isPermiteDonacion()) { %>
                                                <button class="action-button btn flex-grow-1 text-center mb-2" 
                                                        data-creator-id="<%= pub.getIdUsuario() %>"
                                                        onclick="openDonationModal(<%= pub.getIdPublicacion() %>, '<%= pub.getNombreCompleto() != null ? pub.getNombreCompleto().replace("'", "\\'") : "Usuario" %>', '<%= pub.getNombreUsuario() != null ? pub.getNombreUsuario().replace("'", "\\'") : "@usuario" %>', <%= pub.getIdUsuario() %>)"
                                                        <%= (usuarioActual != null && pub.getIdUsuario() == usuarioActual.getId()) ? "disabled" : "" %>>
                                                    <i class="fas fa-gift"></i> Regalar
                                                    <% if (pub.getTotalDonaciones() > 0) { %>
                                                        <small>($<%= String.format("%.2f", pub.getTotalDonaciones()) %>)</small>
                                                    <% } %>   
                                                </button>
                                            <% } %>
                                            </div>

                                            <!-- Sección de comentarios -->
                                            <div class="comments-section" id="commentsSection_<%= pub.getIdPublicacion() %>" style="display: none;">
                                                <div id="commentsList_<%= pub.getIdPublicacion() %>">
                                                    <% 
                                                    if (comentarios != null && !comentarios.isEmpty()) {
                                                        for (Comentario com : comentarios) { 
                                                    %>
                                                            <div class="comment" data-comment-id="<%= com.getIdComentario() %>" 
                                                                 data-author-name="<%= com.getNombreUsuario() != null ? com.getNombreUsuario() : "Usuario" %>">
                                                                <img src="<%= com.getAvatarUsuario() != null ? com.getAvatarUsuario() : "assets/images/avatars/default.png" %>" 
                                                                     alt="User Avatar" 
                                                                     onerror="this.src='assets/images/avatars/default.png'">
                                                                <div class="comment-content">
                                                                    <div class="comment-text">
                                                                        <strong><%= com.getNombreUsuario() != null ? com.getNombreUsuario() : "Usuario" %></strong>: 
                                                                        <%= com.getContenido() %>
                                                                    </div>
                                                                    <div class="comment-info">
                                                                        <span><%= com.getHoraFormateada() %></span>

                                                                        <!-- Botones de edición/eliminación (solo para el dueño del comentario o admin) -->
                                                                        <% if (usuarioActual != null && 
                                                                               (com.getIdUsuario() == usuarioActual.getId() || usuarioActual.isPrivilegio())) { %>
                                                                            <div class="comment-actions" style="float: right;">
                                                                                <% if (com.getIdUsuario() == usuarioActual.getId()) { %>
                                                                                    <button class="btn btn-sm btn-outline-primary" 
                                                                                            onclick="editarComentario(<%= com.getIdComentario() %>, '<%= com.getContenido().replace("'", "\\'").replace("\"", "&quot;") %>')"
                                                                                            title="Editar comentario">
                                                                                        <i class="fas fa-edit"></i>
                                                                                    </button>
                                                                                <% } %>

                                                                                <button class="btn btn-sm btn-outline-danger" 
                                                                                        onclick="eliminarComentario(<%= com.getIdComentario() %>, '<%= com.getNombreUsuario() != null ? com.getNombreUsuario().replace("'", "\\'") : "Usuario" %>')"
                                                                                        title="Eliminar comentario">
                                                                                    <i class="fas fa-trash"></i>
                                                                                </button>
                                                                            </div>
                                                                        <% } %>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        <% 
                                                            } 
                                                    } 
                                                    %>
                                                </div>
                                                
                                                <% if (usuarioActual != null) { %>
                                                <div class="new-comment">
                                                    <input type="text" placeholder="Escriba un comentario..." 
                                                           id="commentInput_<%= pub.getIdPublicacion() %>"
                                                           onkeypress="handleCommentKeyPress(event, <%= pub.getIdPublicacion() %>)">
                                                    <button onclick="addComment(<%= pub.getIdPublicacion() %>)">
                                                        <i class="fas fa-paper-plane"></i>
                                                    </button>
                                                </div>
                                                <% } %>
                                            </div>
                                        </div>
                                <%
                                    }
                                } else {
                                %>
                                    <div class="no-posts">
                                        <i class="fas fa-newspaper" style="font-size: 48px; color: #ddd; margin-bottom: 15px;"></i>
                                        <h4>No hay publicaciones disponibles</h4>
                                        <p>¡Sé el primero en publicar algo!</p>
                                        <% if (usuarioActual != null) { %>
                                            <button class="btn btn-primary" data-toggle="modal" data-target="#postModal">
                                                <i class="fas fa-plus"></i> Crear primera publicación
                                            </button>
                                        <% } %>
                                    </div>
                                <%
                                }
                                %>
                            </div>
                            
                            <!-- Loading indicator para AJAX -->
                            <div id="loadingIndicator" class="loading" style="display: none;">
                                <i class="fas fa-spinner fa-spin"></i> Cargando...
                            </div>
                        </div>

                        <!-- Sidebar derecho con sugerencias -->

                        <div class="col-md-4">
                           <div class="suggestions-sidebar">
                               <div class="suggestions-box">
                                   <div class="spacer"></div>
                                   <h3>Sugerencias Comunidad</h3>

                                   <%
                                       if (comunidadesSugeridas != null && !comunidadesSugeridas.isEmpty()) {
                                           for (Comunidad comunidad : comunidadesSugeridas) {
                                   %>
                                               <div class="suggestion-item">
                                                   <img src="assets/images/avatars/default.png" alt="Avatar">
                                                   <div>
                                                       <p><%= comunidad.getNombre() %></p>
                                                       <span>@<%= comunidad.getNombre().replaceAll(" ", "").toLowerCase() %></span>
                                                   </div>
                                                    <button class="btn btn-sm btn-primary" 
                                                           onclick="seguirComunidad(<%= comunidad.getIdComunidad() %>, this)"
                                                           style="border-radius: 20px; 
                                                                  padding: 5px 10px; 
                                                                  margin-right: 8px;
                                                                  font-weight: 500;
                                                                  border: 2px solid #007bff;
                                                                  background-color: #007bff;
                                                                  color: white;
                                                                  transition: all 0.3s ease;
                                                                  box-shadow: 0 2px 4px rgba(0,123,255,0.3);"
                                                           onmouseover="this.style.backgroundColor='#0056b3'; this.style.borderColor='#0056b3'; this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 8px rgba(0,123,255,0.4)';"
                                                           onmouseout="this.style.backgroundColor='#007bff'; this.style.borderColor='#007bff'; this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 4px rgba(0,123,255,0.3)';">
                                                       <i class="fas fa-plus me-1"></i>
                                                    </button>
                                               </div>
                                   <%
                                           }
                                       } else {
                                   %>
                                           <div style="text-align: center; padding: 50px; color: #666;">
                                               <i class="fas fa-users" style="font-size: 24px; margin-bottom: 10px; opacity: 0.5;"></i>
                                               <p style="margin: 0; font-size: 14px;">No hay comunidades para ti</p>
                                           </div>
                                   <%
                                       }
                                   %>

                                    <!-- Botón explorar centrado -->
                                    <div style="text-align: center; margin-top: 20px; width: 100%;">
                                        <a href="ComunidadServlet" 
                                           class="btn btn-outline-primary btn-sm" 
                                           style="border-radius: 25px; 
                                                  padding: 10px 20px; 
                                                  font-weight: 500;
                                                  border: 2px solid #007bff;
                                                  color: #007bff;
                                                  text-decoration: none;
                                                  transition: all 0.3s ease;
                                                  box-shadow: 0 2px 4px rgba(0,123,255,0.2);
                                                  display: inline-block;"
                                           onmouseover="this.style.backgroundColor='#007bff'; this.style.color='white'; this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 8px rgba(0,123,255,0.3)';"
                                           onmouseout="this.style.backgroundColor='transparent'; this.style.color='#007bff'; this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 4px rgba(0,123,255,0.2)';">
                                            <i class="fas fa-compass fa-lg" style="margin-right: 5px;"></i>Explorar
                                        </a>
                                    </div>
                               </div>
                           </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <!-- Scripts -->
        <jsp:include page="/components/js_imports.jsp" />
                
        <!-- Scripts para funcionalidades dinámicas -->
        <script>
            $(document).ready(function() {
                // Inicializar funcionalidades
                initializePostCreation();
                initializeLikeButtons();
                checkServerMessages();
                console.log('🚀 Home cargado con <%= totalPublicaciones != null ? totalPublicaciones : 0 %> publicaciones');
            });

            function checkServerMessages() {
                <% if (request.getAttribute("errorMessagePayment") != null) { %>
                    showPaymentResult('error', '<%= request.getAttribute("errorMessagePayment") %>');
                <% } %>

                <% if (request.getAttribute("successMessagePayment") != null) { %>
                    showPaymentResult('success', '<%= request.getAttribute("successMessagePayment") %>');
                <% } %>

                <% if (request.getAttribute("warningMessagePayment") != null) { %>
                    showPaymentResult('warning', '<%= request.getAttribute("warningMessagePayment") %>');
                <% } %>
            }
            
            function showPaymentResult(type, message) {
                const modal = $('#paymentResultModal');
                const modalContent = modal.find('.payment-result-modal');
                const icon = modal.find('.payment-icon');
                const title = modal.find('.modal-title');
                const messageDiv = modal.find('.payment-message p');

                // Limpiar clases
                modalContent.removeClass('success error warning');

                // Configurar según tipo
                switch(type) {
                    case 'success':
                        modalContent.addClass('success');
                        icon.removeClass().addClass('fas fa-heart payment-icon');
                        title.text('¡Donación Exitosa!');
                        setTimeout(() => modal.modal('hide'), 8000);
                        break;
                    case 'error':
                        modalContent.addClass('error');
                        icon.removeClass().addClass('fas fa-exclamation-triangle payment-icon');
                        title.text('Error en el Pago');
                        break;
                    case 'warning':
                        modalContent.addClass('warning');
                        icon.removeClass().addClass('fas fa-clock payment-icon');
                        title.text('Pago en Proceso');
                        setTimeout(() => modal.modal('hide'), 6000);
                        break;
                }

                messageDiv.html(message);
                modal.modal('show');
            }
            // ========== CREACIÓN DE PUBLICACIONES ==========
            function initializePostCreation() {
                let selectedFile = null;

                $('#postContent').on('input', function() {
                    const currentLength = $(this).val().length;
                    const maxLength = 999;
                    $('#contadorCaracteres').text(currentLength + ' / ' + maxLength);

                    if (currentLength > maxLength) {
                        $(this).addClass('is-invalid');
                        $('#contadorCaracteres').addClass('text-danger');
                    } else {
                        $(this).removeClass('is-invalid');
                        $('#contadorCaracteres').removeClass('text-danger');
                    }
                });

                // Abrir selector de archivos
                $('#btnSubirImagen').click(function() {
                    $('#inputImagen').click();
                });

                $('#inputImagen').change(function(e) {
                    const file = e.target.files[0];

                    if (file) {
                        if (!file.type.startsWith('image/')) {
                            alert('Por favor selecciona un archivo de imagen válido.');
                            return;
                        }

                        if (file.size > 5 * 1024 * 1024) {
                            alert('La imagen es muy grande. Máximo 5MB permitido.');
                            return;
                        }

                        selectedFile = file;

                        const reader = new FileReader();
                        reader.onload = function(e) {
                            $('#imagePreview').attr('src', e.target.result);
                            $('#imagePreviewContainer').fadeIn();
                        };
                        reader.readAsDataURL(file);
                    }
                });

                $('#removeImageBtn').click(function() {
                    selectedFile = null;
                    $('#inputImagen').val('');
                    $('#imagePreviewContainer').fadeOut();
                });

            $('#communitySelect').on('change', function() {
                var selectedValue = $(this).val();
                var selectedText = $(this).find('option:selected').text();

                if (selectedValue) {
                    console.log('Comunidad seleccionada:', selectedText);
                    $('#postModalLabel').text('Nueva Publicación en ' + selectedText.replace(/🛡️|🎯/, '').trim());
                } else {
                    console.log('Feed principal seleccionado');
                    $('#postModalLabel').text('Nueva Publicación');
                }
            });

            function mostrarMensajeExito(response) {
                const mensaje = response.message || '¡Publicación creada exitosamente!';

                $('#successMessage').find('h6').text(mensaje);
                $('#successMessage').show();
            }

            // Función principal para enviar formulario
            function submitFormWithResponse() {
                $('#loadingSpinner').css('display', 'flex');
                $('#btnPublicar').prop('disabled', true);
                $('.modern-form').hide();

                const formData = new FormData($('#formCrearPost')[0]);

                $.ajax({
                    url: 'HomeServlet',
                    type: 'POST',
                    data: formData,
                    processData: false,
                    contentType: false,
                    success: function(response) {
                        console.log('Respuesta del servidor:', response);

                        $('#loadingSpinner').hide();

                        if (response && response.success) {
                            mostrarMensajeExito(response);

                            setTimeout(function() {
                                $('#postModal').modal('hide');
                                window.location.reload();
                            }, 3000);
                        } else {
                            $('.modern-form').show();
                            $('#btnPublicar').prop('disabled', false);
                            alert(response.message || 'Error al crear la publicación');
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error('Error al publicar:', error);

                        // Ocultar loading y mostrar formulario
                        $('#loadingSpinner').hide();
                        $('.modern-form').show();
                        $('#btnPublicar').prop('disabled', false);

                        // Mostrar error
                        let errorMessage = 'Error al publicar el post. Intenta de nuevo.';
                        try {
                            const errorResponse = JSON.parse(xhr.responseText);
                            if (errorResponse.message) {
                                errorMessage = errorResponse.message;
                            }
                        } catch (e) {
                        }

                        alert(errorMessage);
                    }
                });
            }

            $(document).ready(function() {
                $('#btnPublicar').off('click').on('click', function(e) {
                    e.preventDefault();

                    // Validaciones básicas
                    const contenido = $('#postContent').val().trim();
                    if (contenido.length === 0) {
                        alert('Por favor escribe algo antes de publicar');
                        $('#postContent').focus();
                        return;
                    }

                    if (contenido.length > 999) {
                        alert('El contenido es muy largo. Máximo 999 caracteres');
                        $('#postContent').focus();
                        return;
                    }

                    submitFormWithResponse();
                });

                $('#postModal').on('hidden.bs.modal', function() {
                    $('#formCrearPost')[0].reset();
                    $('#contadorCaracteres').text('0 / 999').removeClass('warning danger');
                    $('#postContent').removeClass('is-invalid');

                    $('#imagePreviewContainer').hide();
                    $('#imageUploadZone').show();

                    $('.modern-form').show();
                    $('#loadingSpinner').hide();
                    $('#successMessage').hide();
                    $('#btnPublicar').prop('disabled', false);
                });
            });
            }

            // ========== SISTEMA DE LIKES ==========
            function toggleLike(idPublicacion) {
                var likeBtn = $('#likeBtn_' + idPublicacion);
                var originalText = likeBtn.html();
                
                // Mostrar loading
                likeBtn.html('<i class="fas fa-spinner fa-spin"></i> ...');
                likeBtn.prop('disabled', true);
                
                $.ajax({
                    url: 'HomeServlet',
                    type: 'POST',
                    data: {
                        action: 'toggleLike',
                        idPublicacion: idPublicacion
                    },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            // Actualizar contador
                            $('#likeCount_' + idPublicacion).text(response.newCount);
                            
                            // Actualizar estilo del botón
                            if (response.userLiked) {
                                likeBtn.addClass('liked');
                                likeBtn.html('<i class="fas fa-heart"></i> <span id="likeCount_' + idPublicacion + '">' + response.newCount + '</span>');
                                showNotification("Like Agregado", 'success');
                            } else {
                                likeBtn.removeClass('liked');
                                likeBtn.html('<i class="far fa-heart"></i> <span id="likeCount_' + idPublicacion + '">' + response.newCount + '</span>');
                                showNotification("Like Quitado", 'success');
                            }
                                                        
                        } else {
                            showNotification(response.message, 'error');
                            likeBtn.html(originalText);
                        }
                    },
                    error: function() {
                        showNotification('Error de conexión', 'error');
                        likeBtn.html(originalText);
                    },
                    complete: function() {
                        likeBtn.prop('disabled', false);
                    }
                });
            }

            function initializeLikeButtons() {
                <% if (usuarioActual != null && publicaciones != null) { %>
                    <% for (Publicacion pub : publicaciones) { %>
                        var likeBtn = $('#likeBtn_<%= pub.getIdPublicacion() %>');

                        <% if (pub.isUsuarioDioLike()) { %>
                            likeBtn.addClass('liked');
                            likeBtn.find('i').removeClass('far').addClass('fas');
                        <% } else { %>
                            likeBtn.removeClass('liked');  
                            likeBtn.find('i').removeClass('fas').addClass('far');
                        <% } %>
                    <% } %>
                <% } %>
            }

            // ========== SISTEMA DE COMENTARIOS ==========
            function toggleComments(idPublicacion) {
                var commentsSection = $('#commentsSection_' + idPublicacion);
                
                if (commentsSection.is(':visible')) {
                    commentsSection.slideUp();
                } else {
                    commentsSection.slideDown();
                }
            }

            function addComment(idPublicacion) {
               var commentInput = $('#commentInput_' + idPublicacion);
               var contenido = commentInput.val().trim();

               if (contenido === '') {
                   showError('Por favor escribe un comentario');
                   return;
               }

               if (contenido.length > 500) {
                   showError('El comentario no puede exceder 500 caracteres');
                   return;
               }

               // Deshabilitar input mientras se procesa
               commentInput.prop('disabled', true);

               // Mostrar indicador de carga en el botón
               var sendButton = commentInput.next('button');
               var originalButtonContent = sendButton.html();
               sendButton.html('<i class="fas fa-spinner fa-spin"></i>');
               sendButton.prop('disabled', true);

               $.ajax({
                   url: 'HomeServlet',
                   type: 'POST',
                   data: {
                       action: 'addComment',
                       idPublicacion: idPublicacion,
                       contenido: contenido
                   },
                   dataType: 'json',
                   success: function(response) {
                       console.log('📊 Respuesta completa del servidor:', response);

                       if (response.success && response.comment) {
                           var comment = response.comment;

                           // Log para debugging
                           console.log('💬 Datos del comentario recibido:', comment);

                           // Extraer y validar datos - CORREGIDO
                           var avatarSrc = (comment.avatar && comment.avatar !== 'null' && comment.avatar.trim() !== '') 
                               ? comment.avatar 
                               : 'assets/images/avatars/default.png';

                           var nombreUsuario = comment.nombreUsuario || comment.nombre_usuario || 'Usuario';

                           // CORREGIR: Usar el contenido original enviado si no viene en la respuesta
                           var contenidoEscapado = comment.contenido ? escapeHtml(comment.contenido) : escapeHtml(contenido);

                           var horaComentario = comment.hora || comment.fecha_comentario || 'ahora';

                           var idComentario = comment.id || comment.id_comentario || 0;

                           // Para usar en atributos JS
                           var contenidoParaJS = escapeForJS(contenidoEscapado);
                           var nombreUsuarioParaJS = escapeForJS(nombreUsuario);

                           console.log('🔧 Datos procesados:', {
                               avatar: avatarSrc,
                               nombre: nombreUsuario,
                               contenido: contenidoEscapado,
                               hora: horaComentario,
                               id: idComentario
                           });

                           // HTML del nuevo comentario
                            var nuevoComentarioHTML = 
                                '<div class="comment" data-comment-id="' + idComentario + '" ' +
                                     'data-author-name="' + nombreUsuario + '" ' +
                                     'style="display: none;">' +
                                    '<img src="' + avatarSrc + '" alt="User Avatar" ' +
                                         'onerror="this.src=\'assets/images/avatars/default.png\'" ' +
                                         'style="width: 35px; height: 35px; border-radius: 50%; margin-right: 10px; object-fit: cover;">' +
                                    '<div class="comment-content">' +
                                        '<div class="comment-text">' +
                                            '<strong>@' + nombreUsuario + '</strong>: ' + contenidoEscapado +
                                        '</div>' +
                                        '<div class="comment-info">' +
                                            '<span>' + horaComentario + '</span>' +
                                            '<div class="comment-actions" style="float: right;">' +
                                                '<button class="btn btn-sm btn-outline-primary" ' +
                                                        'onclick="editarComentario(' + idComentario + ', \'' + contenidoParaJS + '\')" ' +
                                                        'title="Editar comentario">' +
                                                    '<i class="fas fa-edit"></i>' +
                                                '</button>' +
                                                '<button class="btn btn-sm btn-outline-danger" ' +
                                                        'onclick="eliminarComentario(' + idComentario + ', \'' + nombreUsuarioParaJS + '\')" ' +
                                                        'title="Eliminar comentario">' +
                                                    '<i class="fas fa-trash"></i>' +
                                                '</button>' +
                                            '</div>' +
                                        '</div>' +
                                    '</div>' +
                                '</div>';

                           console.log('🏗️ HTML generado:', nuevoComentarioHTML);

                           // Agregar el comentario al contenedor
                           var commentsList = $('#commentsList_' + idPublicacion);
                           commentsList.append(nuevoComentarioHTML);

                           // Mostrar el comentario con animación
                           commentsList.find('.comment:last').slideDown();

                           // Actualizar contador
                           if (response.newCount) {
                               $('#commentCount_' + idPublicacion).text(response.newCount);
                           }

                           // Limpiar y habilitar input
                           commentInput.val('').prop('disabled', false).focus();

                           // Auto-scroll al nuevo comentario
                           var commentsSection = $('#commentsSection_' + idPublicacion);
                           setTimeout(function() {
                               commentsSection.animate({
                                   scrollTop: commentsSection[0].scrollHeight
                               }, 300);
                           }, 100);

                           showSuccess('Comentario agregado exitosamente');

                       } else {
                           console.error('❌ Error en la respuesta:', response.message || 'Error desconocido');
                           showError(response.message || 'Error al agregar comentario');
                       }
                   },
                   error: function(xhr, status, error) {
                       console.error('❌ Error AJAX:', error);
                       console.error('📄 Respuesta del servidor:', xhr.responseText);
                       showError('Error de conexión al agregar comentario');
                   },
                   complete: function() {
                       // Rehabilitar controles
                       commentInput.prop('disabled', false);
                       sendButton.html(originalButtonContent);
                       sendButton.prop('disabled', false);
                       setTimeout(function() { commentInput.focus(); }, 100);
                   }
               });
           }
            
            function handleCommentKeyPress(event, idPublicacion) {
                if (event.key === 'Enter') {
                    addComment(idPublicacion);
                }
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

            function clearAllToasts() {
                $('.toast-notification').each(function() {
                    var id = $(this).attr('id');
                    if (id) {
                        closeToast(id);
                    }
                });
            }

            function escapeHtml(text) {
                if (!text) return '';
                var map = {
                    '&': '&amp;',
                    '<': '&lt;',
                    '>': '&gt;',
                    '"': '&quot;',
                    "'": '&#039;'
                };
                return text.replace(/[&<>"']/g, function(m) { return map[m]; });
            }

            function escapeForJS(text) {
                if (!text) return '';
                return text.replace(/\\/g, '\\\\')
                           .replace(/'/g, "\\'")
                           .replace(/"/g, '\\"')
                           .replace(/\n/g, '\\n')
                           .replace(/\r/g, '\\r');
            }



            function editarComentario(idComentario, contenidoActual) {
                console.log('🔧 Iniciando edición de comentario:', idComentario);

                // Encontrar el comentario en el DOM - SIN template literals
                var commentElement = $('[data-comment-id="' + idComentario + '"]');

                if (commentElement.length === 0) {
                    console.error('❌ No se encontró el comentario con ID:', idComentario);
                    return;
                }

                var commentTextElement = commentElement.find('.comment-text');
                var commentActionsElement = commentElement.find('.comment-actions');

                console.log('✅ Elementos encontrados:', {
                    comment: commentElement.length,
                    text: commentTextElement.length,
                    actions: commentActionsElement.length
                });

                // Validar contenido actual y escapar para HTML
                var contenidoParaTextarea = contenidoActual || '';
                // Desescapar para el textarea (convertir &amp; → &, etc.)
                contenidoParaTextarea = unescapeHtml(contenidoParaTextarea);

                // Guardar el contenido original para restaurar si se cancela
                var contenidoOriginal = commentTextElement.html();

                // Crear formulario de edición - Estructura mejorada
                var editForm = '<div class="edit-comment-form">' +
                    '<div class="mb-2">' +
                        '<textarea class="form-control edit-comment-input" maxlength="500" rows="3" placeholder="Edita tu comentario...">' + 
                        escapeHtml(contenidoParaTextarea) + 
                        '</textarea>' +
                    '</div>' +
                    '<div class="d-flex justify-content-between align-items-center">' +
                        '<small class="text-muted">' +
                            '<span class="edit-char-count">0</span>/500 caracteres' +
                        '</small>' +
                        '<div class="btn-group">' +
                            '<button class="btn btn-success btn-sm save-edit-btn" type="button">' +
                                '<i class="fas fa-check"></i> Guardar' +
                            '</button>' +
                            '<button class="btn btn-secondary btn-sm cancel-edit-btn" type="button">' +
                                '<i class="fas fa-times"></i> Cancelar' +
                            '</button>' +
                        '</div>' +
                    '</div>' +
                '</div>';

                console.log('📝 HTML del formulario a insertar:');
                console.log(editForm);

                // Reemplazar contenido con formulario
                commentTextElement.html(editForm);
                commentActionsElement.hide();

                console.log('📝 Formulario insertado en el DOM');

                // BUSCAR INMEDIATAMENTE - No esperar
                var textarea = commentTextElement.find('.edit-comment-input');
                var saveBtn = commentTextElement.find('.save-edit-btn');
                var cancelBtn = commentTextElement.find('.cancel-edit-btn');
                var charCountElement = commentTextElement.find('.edit-char-count');

                console.log('🔍 Elementos del formulario encontrados:', {
                    textarea: textarea.length,
                    saveBtn: saveBtn.length,
                    cancelBtn: cancelBtn.length,
                    charCount: charCountElement.length
                });

                if (textarea.length === 0) {
                    console.error('❌ ERROR: Textarea no encontrado');
                    console.log('🔍 HTML actual del comentario:', commentTextElement.html());
                    console.log('🔍 Selector usado:', '.edit-comment-input');

                    // Intentar encontrar cualquier textarea
                    var anyTextarea = commentTextElement.find('textarea');
                    console.log('🔍 Cualquier textarea encontrado:', anyTextarea.length);

                    return;
                }

                // Función para guardar
                function guardarEdicion() {
                    console.log('💾 Guardando edición...');
                    var nuevoContenido = textarea.val().trim();

                    console.log('📝 Contenido a guardar:', {
                        original: textarea.val(),
                        trimmed: nuevoContenido,
                        length: nuevoContenido.length
                    });

                    if (nuevoContenido === '') {
                        alert('El comentario no puede estar vacío');
                        textarea.focus();
                        return;
                    }

                    if (nuevoContenido.length > 500) {
                        alert('El comentario no puede exceder 500 caracteres');
                        return;
                    }

                    // Verificar que realmente hay contenido
                    if (nuevoContenido === contenidoParaTextarea.trim()) {
                        console.log('📝 Contenido no cambió, cancelando edición');
                        cancelarEdicion();
                        return;
                    }

                    // Deshabilitar controles mientras se guarda
                    textarea.prop('disabled', true);
                    saveBtn.prop('disabled', true);
                    cancelBtn.prop('disabled', true);

                    // Mostrar indicador de carga
                    saveBtn.html('<i class="fas fa-spinner fa-spin"></i> Guardando...');

                    console.log('📤 Enviando al servidor:', {
                        idComentario: idComentario,
                        contenido: nuevoContenido
                    });

                    // Llamar a función de guardar en el servidor
                    guardarEdicionComentario(idComentario, nuevoContenido, function(success, message) {
                        if (success) {
                            // Restaurar el texto normal (no el formulario)
                            var nombreUsuario = commentElement.attr('data-author-name') || 'Usuario';
                            commentTextElement.html('<strong>' + nombreUsuario + '</strong>: ' + escapeHtml(nuevoContenido));
                            commentActionsElement.show();
                            console.log('✅ Comentario guardado y vista restaurada');

                            // Mostrar notificación de éxito
                            if (typeof showNotification === 'function') {
                                showNotification('Comentario actualizado', 'success', 2000);
                            }
                        } else {
                            // Restaurar botón y re-habilitar controles si falla
                            saveBtn.html('<i class="fas fa-check"></i> Guardar');
                            textarea.prop('disabled', false);
                            saveBtn.prop('disabled', false);
                            cancelBtn.prop('disabled', false);
                            textarea.focus();

                            // Mostrar error específico
                            var errorMsg = message || 'Error al guardar el comentario';
                            alert('Error: ' + errorMsg);
                            console.error('❌ Error al guardar:', errorMsg);
                        }
                    });
                }

                // Función para cancelar
                function cancelarEdicion() {
                    console.log('❌ Cancelando edición...');
                    commentTextElement.html(contenidoOriginal);
                    commentActionsElement.show();
                }

                // Agregar eventos - usando .off() primero para evitar duplicados
                saveBtn.off('click').on('click', guardarEdicion);
                cancelBtn.off('click').on('click', cancelarEdicion);

                // Enfocar textarea inmediatamente
                textarea.focus();

                // Posicionar cursor al final
                setTimeout(function() {
                    try {
                        var textareaElement = textarea[0];
                        if (textareaElement && typeof textareaElement.setSelectionRange === 'function') {
                            var textLength = textarea.val().length;
                            textareaElement.setSelectionRange(textLength, textLength);
                            console.log('✅ Cursor posicionado al final');
                        }
                    } catch (e) {
                        console.warn('⚠️ Error al posicionar cursor:', e.message);
                    }
                }, 50);

                // Contador de caracteres
                textarea.off('input').on('input', function() {
                    var charCount = $(this).val().length;
                    charCountElement.text(charCount);

                    if (charCount > 500) {
                        $(this).val($(this).val().substring(0, 500));
                        charCountElement.text(500);
                    }
                });

                // Trigger inicial del contador
                textarea.trigger('input');

                // Atajos de teclado
                textarea.off('keydown').on('keydown', function(e) {
                    if (e.ctrlKey && e.key === 'Enter') {
                        e.preventDefault();
                        guardarEdicion();
                    } else if (e.key === 'Escape') {
                        e.preventDefault();
                        cancelarEdicion();
                    }
                });

                console.log('✅ Edición configurada correctamente');
            }


            function guardarEdicionComentario(idComentario, nuevoContenido, callback) {
                console.log('🌐 Enviando AJAX para editar comentario:', {
                    id: idComentario,
                    contenido: nuevoContenido,
                    length: nuevoContenido.length
                });

                // Aquí harías tu AJAX call al servidor
                $.ajax({
                    url: 'HomeServlet',
                    type: 'POST',
                    data: {
                        action: 'editComment',
                        idComentario: idComentario,
                        nuevoContenido: nuevoContenido,
                        contenido: nuevoContenido  // Por si tu servlet espera 'contenido'
                    },
                    dataType: 'json',
                    success: function(response) {
                        console.log('📦 Respuesta del servidor:', response);

                        if (response.success) {
                            console.log('✅ Comentario guardado en servidor');
                            callback(true, response.message);
                        } else {
                            console.error('❌ Error del servidor:', response.message);
                            callback(false, response.message || 'Error desconocido');
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error('❌ Error AJAX:', {
                            status: status,
                            error: error,
                            responseText: xhr.responseText,
                            statusCode: xhr.status
                        });

                        var errorMessage = 'Error de conexión al guardar el comentario';
                        if (xhr.responseText) {
                            try {
                                var errorResponse = JSON.parse(xhr.responseText);
                                errorMessage = errorResponse.message || errorMessage;
                            } catch (e) {
                                console.log('No se pudo parsear la respuesta de error');
                            }
                        }

                        callback(false, errorMessage);
                    }
                });
            }
            function unescapeHtml(text) {
                if (!text) return '';
                var map = {
                    '&amp;': '&',
                    '&lt;': '<',
                    '&gt;': '>',
                    '&quot;': '"',
                    '&#039;': "'"
                };
                return text.replace(/&amp;|&lt;|&gt;|&quot;|&#039;/g, function(m) { return map[m]; });
            }
            // Función para cancelar la edición
            function cancelarEdicionComentario(idComentario, contenidoOriginal) {
                var commentElement = $(`[data-comment-id="${idComentario}"]`);
                var commentTextElement = commentElement.find('.comment-text');
                var commentActionsElement = commentElement.find('.comment-actions');

                // Restaurar contenido original
                var nombreAutor = 'Usuario';
                if (commentElement.data('author-name')) {
                    nombreAutor = commentElement.data('author-name');
                }

                var contenidoEscapado = '';
                if (contenidoOriginal) {
                    contenidoEscapado = escapeHtml(contenidoOriginal);
                }

                // Restaurar contenido original
                var originalHTML = `
                    <strong>${nombreAutor}</strong>: ${contenidoEscapado}
                `;

                commentTextElement.html(originalHTML);
                commentActionsElement.show();
            }


            function eliminarComentario(idComentario, nombreAutor) {
                // DEBUG: Verificar qué parámetros llegan
                console.log('🗑️ Eliminando comentario:', {
                    idComentario: idComentario,
                    nombreAutor: nombreAutor,
                    tipoNombre: typeof nombreAutor
                });

                // Validar parámetros
                if (!idComentario || idComentario <= 0) {
                    showError('ID de comentario inválido');
                    return;
                }

                var nombreParaMostrar = 'Usuario desconocido';
                if (nombreAutor) {
                    if (typeof nombreAutor === 'string' && nombreAutor.trim() !== '') {
                        nombreParaMostrar = nombreAutor.trim();
                    } else if (typeof nombreAutor !== 'string') {
                        nombreParaMostrar = String(nombreAutor).trim();
                    }
                }

                // Crear modal de confirmación
                mostrarModalEliminarComentario(idComentario, nombreParaMostrar);
            }

            function mostrarModalEliminarComentario(idComentario, nombreAutor) {
                // Crear el modal HTML
                var modalHtml = '<div class="modal fade" id="modalEliminarComentario" tabindex="-1" role="dialog">' +
                    '<div class="modal-dialog modal-dialog-centered" role="document">' +
                        '<div class="modal-content">' +
                            '<div class="modal-header bg-danger text-white">' +
                                '<h5 class="modal-title">' +
                                    '<i class="fas fa-exclamation-triangle"></i> Confirmar Eliminación' +
                                '</h5>' +
                                '<button type="button" class="close text-white" data-dismiss="modal">' +
                                    '<span>&times;</span>' +
                                '</button>' +
                            '</div>' +
                            '<div class="modal-body">' +
                                '<p class="mb-3">' +
                                    '¿Estás seguro de que deseas eliminar el comentario de <strong>' + escapeHtml(nombreAutor) + '</strong>?' +
                                '</p>' +
                                '<div class="alert alert-warning">' +
                                    '<i class="fas fa-info-circle"></i> ' +
                                    'Esta acción no se puede deshacer.' +
                                '</div>' +
                            '</div>' +
                            '<div class="modal-footer">' +
                                '<button type="button" class="btn btn-secondary" data-dismiss="modal">' +
                                    '<i class="fas fa-times"></i> Cancelar' +
                                '</button>' +
                                '<button type="button" class="btn btn-danger" id="btnConfirmarEliminar">' +
                                    '<i class="fas fa-trash"></i> Eliminar Comentario' +
                                '</button>' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                '</div>';

                // Eliminar modal anterior si existe
                $('#modalEliminarComentario').remove();

                // Agregar modal al DOM
                $('body').append(modalHtml);

                // Mostrar modal
                $('#modalEliminarComentario').modal('show');

                // Manejar confirmación
                $('#btnConfirmarEliminar').off('click').on('click', function() {
                    ejecutarEliminacionComentario(idComentario);
                });

                // Limpiar modal cuando se cierre
                $('#modalEliminarComentario').on('hidden.bs.modal', function() {
                    $(this).remove();
                });
            }

            function ejecutarEliminacionComentario(idComentario) {
                console.log('🚀 Ejecutando eliminación del comentario:', idComentario);

                // Encontrar el elemento del comentario en el DOM
                var commentElement = $('[data-comment-id="' + idComentario + '"]');

                if (commentElement.length === 0) {
                    console.error('❌ No se encontró el comentario en el DOM');
                    showError('No se pudo encontrar el comentario a eliminar');
                    $('#modalEliminarComentario').modal('hide');
                    return;
                }

                // Encontrar la publicación padre para actualizar contador
                var publicacionContainer = commentElement.closest('[data-post-id]');
                var idPublicacion = publicacionContainer.attr('data-post-id');

                console.log('📍 Comentario encontrado en publicación:', idPublicacion);

                // Deshabilitar botón mientras se procesa
                var btnConfirmar = $('#btnConfirmarEliminar');
                var originalButtonText = btnConfirmar.html();
                btnConfirmar.html('<i class="fas fa-spinner fa-spin"></i> Eliminando...').prop('disabled', true);

                // Realizar petición AJAX
                $.ajax({
                    url: 'HomeServlet',
                    type: 'POST',
                    data: {
                        action: 'deleteComment',
                        idComentario: idComentario
                    },
                    dataType: 'json',
                    success: function(response) {
                        console.log('📦 Respuesta del servidor:', response);

                        if (response.success) {
                            console.log('✅ Comentario eliminado del servidor');

                            // Cerrar modal
                            $('#modalEliminarComentario').modal('hide');

                            // Animar y eliminar del DOM
                            commentElement.fadeOut(300, function() {
                                $(this).remove();

                                // Actualizar contador de comentarios
                                if (idPublicacion) {
                                    actualizarContadorComentarios(idPublicacion, -1);
                                }

                                console.log('✅ Comentario eliminado del DOM');
                            });

                            // Mostrar notificación de éxito
                            if (typeof showNotification === 'function') {
                                showNotification('Comentario eliminado', 'success', 3000);
                            } else if (typeof showSuccess === 'function') {
                                showSuccess('Comentario eliminado exitosamente');
                            } else {
                                // Fallback
                                console.log('✅ Comentario eliminado exitosamente');
                            }

                        } else {
                            console.error('❌ Error del servidor:', response.message);

                            // Restaurar botón
                            btnConfirmar.html(originalButtonText).prop('disabled', false);

                            // Mostrar error
                            var errorMsg = response.message || 'Error al eliminar el comentario';
                            if (typeof showError === 'function') {
                                showError(errorMsg);
                            } else {
                                alert('Error: ' + errorMsg);
                            }
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error('❌ Error AJAX:', {
                            status: status,
                            error: error,
                            responseText: xhr.responseText,
                            statusCode: xhr.status
                        });

                        // Restaurar botón
                        btnConfirmar.html(originalButtonText).prop('disabled', false);

                        // Mostrar error
                        var errorMessage = 'Error de conexión al eliminar el comentario';
                        if (xhr.responseText) {
                            try {
                                var errorResponse = JSON.parse(xhr.responseText);
                                errorMessage = errorResponse.message || errorMessage;
                            } catch (e) {
                                console.log('No se pudo parsear la respuesta de error');
                            }
                        }

                        if (typeof showError === 'function') {
                            showError(errorMessage);
                        } else {
                            alert('Error: ' + errorMessage);
                        }
                    }
                });
            }

            function actualizarContadorComentarios(idPublicacion, cambio) {
                console.log('📊 Actualizando contador de comentarios:', {
                    publicacion: idPublicacion,
                    cambio: cambio
                });

                // Encontrar el elemento del contador
                var contadorElement = $('#commentCount_' + idPublicacion);

                if (contadorElement.length > 0) {
                    var contadorActual = parseInt(contadorElement.text()) || 0;
                    var nuevoContador = Math.max(0, contadorActual + cambio);

                    contadorElement.text(nuevoContador);

                    console.log('📊 Contador actualizado:', {
                        anterior: contadorActual,
                        nuevo: nuevoContador
                    });

                    // Animar el cambio
                    contadorElement.addClass('text-primary').delay(500).queue(function() {
                        $(this).removeClass('text-primary').dequeue();
                    });
                } else {
                    console.warn('⚠️ No se encontró contador para publicación:', idPublicacion);
                }
            }

            function showSuccess(message) { showNotification(message, 'success'); }
            function showError(message) { showNotification(message, 'error'); }
            
            // Función para seguir comunidad
            function seguirComunidad(idComunidad, button) {

                // Mostrar loading
                const originalContent = button.innerHTML;
                button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Cargando...';
                button.disabled = true;

                $.ajax({
                    url: 'ComunidadServlet',
                    type: 'POST',
                    data: {
                        action: 'join',
                        idComunidad: idComunidad
                    },
                    success: function(response) {
                        if (response.success) {
                            // Ocultar el suggestion-item completamente ya que ahora la sigue
                            button.closest('.suggestion-item').style.display = 'none';

                            // Mostrar notificación
                            showNotification('¡Te has unido a la comunidad!', 'success');
                        } else {
                            // Restaurar botón
                            button.innerHTML = originalContent;
                            button.disabled = false;
                            button.className = 'btn btn-sm btn-primary';
                            alert(response.message || 'Error al unirse a la comunidad');
                        }
                    },
                    error: function() {
                        // Restaurar botón
                        button.innerHTML = originalContent;
                        button.disabled = false;
                        button.className = 'btn btn-sm btn-primary';
                        alert('Error de conexión');
                    }
                });
            }

        </script>
    </body>
</html>