<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="pe.aquasocial.entity.Usuario" %>
<%@ page import="pe.aquasocial.util.SessionUtil" %>

<%
    Usuario usuario = SessionUtil.getLoggedUser(request);
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
    <title>Notificaciones - AquaSocial</title>
    <jsp:include page="/components/css_imports.jsp" />
    
    <style>
        .container {
            margin-bottom: 30px;
            background-color: #ffffff;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 15px 50px rgba(0, 0, 0, 0.2);
            border: 1px solid #ddd;
        }

        .notification-header {
            font-size: 24px;
            color: #333;
            font-weight: bold;
            margin-bottom: 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header-actions {
            display: flex;
            gap: 10px;
        }

        .btn-header {
            padding: 8px 16px;
            border-radius: 20px;
            border: none;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-mark-all {
            background: #28a745;
            color: white;
        }

        .btn-mark-all:hover {
            background: #218838;
            color: white;
        }

        .btn-refresh {
            background: #007bff;
            color: white;
        }

        .btn-refresh:hover {
            background: #0056b3;
            color: white;
        }

        /* Tabs mejorados */
        .tabs {
            display: flex;
            justify-content: space-around;
            margin-bottom: 20px;
            border-bottom: 2px solid #e9ecef;
            padding-bottom: 0;
            background: #f8f9fa;
            border-radius: 10px 10px 0 0;
            overflow: hidden;
        }

        .tab {
            flex: 1;
            text-align: center;
            cursor: pointer;
            font-weight: 600;
            color: #6c757d;
            position: relative;
            padding: 15px 10px;
            transition: all 0.3s ease;
            background: transparent;
            border: none;
        }

        .tab:hover {
            background: rgba(0, 123, 255, 0.1);
            color: #007bff;
        }

        .tab.active {
            color: #007bff;
            background: white;
            box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
        }

        .tab .badge {
            position: absolute;
            top: 8px;
            right: 20px;
            background-color: #dc3545;
            color: white;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: bold;
            min-width: 20px;
            height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* Lista de notificaciones */
        .notification-list {
            max-height: 600px;
            overflow-y: auto;
            padding: 10px 0;
            scrollbar-width: thin;
            scrollbar-color: #007bff #f1f1f1;
        }

        .notification-list::-webkit-scrollbar {
            width: 6px;
        }

        .notification-list::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 3px;
        }

        .notification-list::-webkit-scrollbar-thumb {
            background: #007bff;
            border-radius: 3px;
        }

        .notification-item {
            display: flex;
            align-items: flex-start;
            padding: 15px;
            border-bottom: 1px solid #e9ecef;
            transition: all 0.3s ease;
            cursor: pointer;
            position: relative;
            margin-bottom: 5px;
            border-radius: 8px;
        }

        .notification-item:hover {
            background-color: #f8f9fa;
            transform: translateX(5px);
        }

        .notification-item.unread {
            background-color: #f0f8ff;
            border-left: 4px solid #007bff;
            font-weight: 500;
        }

        .notification-item.unread::before {
            content: '';
            position: absolute;
            right: 15px;
            top: 20px;
            width: 8px;
            height: 8px;
            background: #007bff;
            border-radius: 50%;
        }

        .notification-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            margin-right: 15px;
            object-fit: cover;
            border: 2px solid #e9ecef;
        }

        .notification-avatar.system {
            background: linear-gradient(45deg, #007bff, #0056b3);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 20px;
            font-weight: bold;
        }

        .notification-content {
            flex: 1;
            min-width: 0;
        }

        .notification-title {
            font-weight: bold;
            color: #333;
            margin-bottom: 5px;
            font-size: 15px;
        }

        .notification-message {
            color: #6c757d;
            font-size: 14px;
            line-height: 1.4;
            margin-bottom: 8px;
        }

        .notification-time {
            font-size: 12px;
            color: #999;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .notification-actions {
            display: flex;
            gap: 5px;
            margin-left: 10px;
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .notification-item:hover .notification-actions {
            opacity: 1;
        }

        .btn-action {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            border: none;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            transition: all 0.3s ease;
        }

        .btn-mark-read {
            background: #28a745;
            color: white;
        }

        .btn-mark-read:hover {
            background: #218838;
            transform: scale(1.1);
        }

        .btn-delete {
            background: #dc3545;
            color: white;
        }

        .btn-delete:hover {
            background: #c82333;
            transform: scale(1.1);
        }

        /* Estados de carga */
        .loading {
            text-align: center;
            padding: 40px;
            color: #6c757d;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #6c757d;
        }

        .empty-state i {
            font-size: 60px;
            margin-bottom: 20px;
            opacity: 0.5;
        }

        /* Paginación */
        .pagination-container {
            display: flex;
            justify-content: center;
            align-items: center;
            margin-top: 20px;
            gap: 10px;
        }

        .btn-pagination {
            padding: 8px 16px;
            border: 1px solid #007bff;
            background: white;
            color: #007bff;
            border-radius: 5px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-pagination:hover {
            background: #007bff;
            color: white;
        }

        .btn-pagination:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        /* Filtros adicionales */
        .filters {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }

        .filter-chip {
            padding: 6px 12px;
            background: #e9ecef;
            border: none;
            border-radius: 20px;
            cursor: pointer;
            font-size: 12px;
            transition: all 0.3s ease;
        }

        .filter-chip.active {
            background: #007bff;
            color: white;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .notification-header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }

            .tabs {
                flex-direction: column;
            }

            .tab {
                padding: 12px;
                border-bottom: 1px solid #e9ecef;
            }

            .notification-item {
                flex-direction: column;
                text-align: center;
            }

            .notification-avatar {
                margin: 0 auto 10px auto;
            }

            .notification-actions {
                opacity: 1;
                justify-content: center;
                margin: 10px 0 0 0;
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
            <div class="container">
                <!-- Header -->
                <div class="notification-header">
                    <div>
                        <i class="fas fa-bell me-2 text-primary"></i>
                        Notificaciones
                        <span class="badge bg-primary ms-2" id="totalNotificaciones">0</span>
                    </div>
                    <div class="header-actions">
                        <button class="btn btn-header btn-mark-all" onclick="marcarTodasComoLeidas()">
                            <i class="fas fa-check-double me-1"></i> Marcar todas como leídas
                        </button>
                        <button class="btn btn-header btn-refresh" onclick="cargarNotificaciones()">
                            <i class="fas fa-sync-alt me-1"></i> Actualizar
                        </button>
                    </div>
                </div>

                <!-- Filtros rápidos -->
                <div class="filters" id="filtrosContainer">
                    <button class="filter-chip active" data-filter="all">Todas</button>
                    <button class="filter-chip" data-filter="unread">No leídas</button>
                    <button class="filter-chip" data-filter="comunidad">Comunidades</button>
                    <button class="filter-chip" data-filter="publicacion">Publicaciones</button>
                    <button class="filter-chip" data-filter="sistema">Sistema</button>
                </div>

                <!-- Tabs principales -->
                <div class="tabs">
                    <button class="tab active" data-tab="todas" onclick="cambiarTab('todas')">
                        <i class="fas fa-list me-2"></i> Todas
                        <span class="badge" id="badgeTodas">0</span>
                    </button>
                    <button class="tab" data-tab="comunidades" onclick="cambiarTab('comunidades')">
                        <i class="fas fa-users me-2"></i> Comunidades
                        <span class="badge" id="badgeComunidades">0</span>
                    </button>
                    <button class="tab" data-tab="publicaciones" onclick="cambiarTab('publicaciones')">
                        <i class="fas fa-heart me-2"></i> Publicaciones
                        <span class="badge" id="badgePublicaciones">0</span>
                    </button>
                    <button class="tab" data-tab="sistema" onclick="cambiarTab('sistema')">
                        <i class="fas fa-cog me-2"></i> Sistema
                        <span class="badge" id="badgeSistema">0</span>
                    </button>
                </div>

                <!-- Lista de notificaciones -->
                <div class="notification-list" id="notificationList">
                    <!-- Loading inicial -->
                    <div class="loading">
                        <i class="fas fa-spinner fa-spin fa-2x mb-3"></i>
                        <p>Cargando notificaciones...</p>
                    </div>
                </div>

                <!-- Paginación -->
                <div class="pagination-container" id="paginationContainer" style="display: none;">
                    <button class="btn-pagination" id="btnAnterior" onclick="paginaAnterior()">
                        <i class="fas fa-chevron-left"></i> Anterior
                    </button>
                    <span id="paginaInfo">Página 1 de 1</span>
                    <button class="btn-pagination" id="btnSiguiente" onclick="paginaSiguiente()">
                        Siguiente <i class="fas fa-chevron-right"></i>
                    </button>
                </div>
            </div>
        </div>
    </main>

    <!-- Scripts -->
    <jsp:include page="/components/js_imports.jsp" />
    
    <script>
        // Variables globales
        let notificacionesData = [];
        let filtroActual = 'all';
        let tabActual = 'todas';
        let paginaActual = 1;
        let totalPaginas = 1;
        const notificacionesPorPagina = 10;

        // Inicializar al cargar la página
        $(document).ready(function() {
            cargarNotificaciones();
            inicializarFiltros();
            
            // Auto-refresh cada 60 segundos
            setInterval(cargarNotificaciones, 60000);
        });

        /**
         * Cargar notificaciones desde el servidor
         */
        function cargarNotificaciones() {
            const url = tabActual === 'todas' ? 'NotificacionServlet' : 'NotificacionServlet?tipo=' + tabActual;
            
            $.ajax({
                url: url,
                type: 'GET',
                data: { 
                    action: 'list',
                    limite: 100 // Cargamos más para manejar filtros localmente
                },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        notificacionesData = response.notificaciones || [];
                        actualizarContadores(response);
                        aplicarFiltroYMostrar();
                    } else {
                        mostrarError('Error al cargar notificaciones');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Error al cargar notificaciones:', error);
                    mostrarError('Error de conexión al cargar notificaciones');
                }
            });
        }

        /**
         * Actualizar contadores en tabs y badges
         */
        function actualizarContadores(response) {
            $('#totalNotificaciones').text(response.total || 0);
            $('#badgeTodas').text(response.noLeidas || 0);
            
            // Contar por tipo
            const contadores = {
                comunidad: 0,
                publicacion: 0,
                sistema: 0
            };
            
            notificacionesData.forEach(notif => {
                if (!notif.esLeida && contadores.hasOwnProperty(notif.tipo)) {
                    contadores[notif.tipo]++;
                }
            });
            
            $('#badgeComunidades').text(contadores.comunidad);
            $('#badgePublicaciones').text(contadores.publicacion);
            $('#badgeSistema').text(contadores.sistema);
        }

        /**
         * Aplicar filtro actual y mostrar notificaciones
         */
        function aplicarFiltroYMostrar() {
            let notificacionesFiltradas = [...notificacionesData];
            
            // Filtrar por tab actual
            if (tabActual !== 'todas') {
                notificacionesFiltradas = notificacionesFiltradas.filter(n => n.tipo === tabActual);
            }
            
            // Aplicar filtro adicional
            switch (filtroActual) {
                case 'unread':
                    notificacionesFiltradas = notificacionesFiltradas.filter(n => !n.esLeida);
                    break;
                case 'comunidad':
                case 'publicacion':
                case 'sistema':
                    notificacionesFiltradas = notificacionesFiltradas.filter(n => n.tipo === filtroActual);
                    break;
            }
            
            // Calcular paginación
            totalPaginas = Math.ceil(notificacionesFiltradas.length / notificacionesPorPagina);
            const inicio = (paginaActual - 1) * notificacionesPorPagina;
            const fin = inicio + notificacionesPorPagina;
            const notificacionesPagina = notificacionesFiltradas.slice(inicio, fin);
            
            mostrarNotificaciones(notificacionesPagina);
            actualizarPaginacion();
        }

        /**
         * Mostrar notificaciones en la UI
         */
        function mostrarNotificaciones(notificaciones) {
            const container = $('#notificationList');
            
            if (!notificaciones || notificaciones.length === 0) {
                container.html(
                    '<div class="empty-state">' +
                        '<i class="fas fa-inbox"></i>' +
                        '<h5>No hay notificaciones</h5>' +
                        '<p>No tienes notificaciones en esta categoría</p>' +
                    '</div>'
                );
                return;
            }
            
            let html = '';
            
            notificaciones.forEach(function(notif) {
                const esLeida = notif.esLeida;
                const tiempoTranscurrido = notif.tiempoTranscurrido || 'hace un momento';
                const icono = notif.icono || 'fa-bell';
                const avatar = getAvatarNotificacion(notif);
                
                html += 
                    '<div class="notification-item ' + (!esLeida ? 'unread' : '') + '" data-id="' + notif.idNotificacion + '">' +
                        avatar +
                        '<div class="notification-content">' +
                            '<div class="notification-title">' + notif.titulo + '</div>' +
                            '<div class="notification-message">' + notif.mensaje + '</div>' +
                            '<div class="notification-time">' +
                                '<i class="fas fa-clock me-1"></i> ' + tiempoTranscurrido +
                                getTipoNotificacion(notif.tipo, notif.subtipo) +
                            '</div>' +
                        '</div>' +
                        '<div class="notification-actions">' +
                            (!esLeida ? '<button class="btn-action btn-mark-read" onclick="marcarComoLeida(' + notif.idNotificacion + ')" title="Marcar como leída">' +
                                '<i class="fas fa-check"></i>' +
                            '</button>' : '') +
                            '<button class="btn-action btn-delete" onclick="eliminarNotificacion(' + notif.idNotificacion + ')" title="Eliminar">' +
                                '<i class="fas fa-trash"></i>' +
                            '</button>' +
                        '</div>' +
                    '</div>';
            });
            
            container.html(html);
        }

        /**
         * Obtener avatar para la notificación
         */
        function getAvatarNotificacion(notif) {
            if (notif.avatarUsuarioOrigen) {
                return '<img class="notification-avatar" src="' + notif.avatarUsuarioOrigen + '" alt="Avatar">';
            } else {
                const icono = notif.icono || 'fa-bell';
                return '<div class="notification-avatar system"><i class="fas ' + icono + '"></i></div>';
            }
        }

        /**
         * Obtener badge de tipo de notificación
         */
        function getTipoNotificacion(tipo, subtipo) {
            const tipos = {
                'comunidad': '<span class="badge bg-primary ms-2">Comunidad</span>',
                'publicacion': '<span class="badge bg-success ms-2">Publicación</span>',
                'sistema': '<span class="badge bg-warning ms-2">Sistema</span>',
                'social': '<span class="badge bg-info ms-2">Social</span>'
            };
            return tipos[tipo] || '';
        }

        /**
         * Cambiar tab activo
         */
        function cambiarTab(tab) {
            tabActual = tab;
            paginaActual = 1;
            
            // Actualizar UI de tabs
            $('.tab').removeClass('active');
            $('.tab[data-tab="' + tab + '"]').addClass('active');
            
            aplicarFiltroYMostrar();
        }

        /**
         * Inicializar filtros
         */
        function inicializarFiltros() {
            $('.filter-chip').click(function() {
                const filtro = $(this).data('filter');
                
                $('.filter-chip').removeClass('active');
                $(this).addClass('active');
                
                filtroActual = filtro;
                paginaActual = 1;
                aplicarFiltroYMostrar();
            });
        }

        /**
         * Marcar notificación como leída
         */
        function marcarComoLeida(idNotificacion) {
            $.ajax({
                url: 'NotificacionServlet',
                type: 'POST',
                data: { action: 'markRead', id: idNotificacion },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        // Actualizar estado local
                        const notif = notificacionesData.find(n => n.idNotificacion === idNotificacion);
                        if (notif) {
                            notif.esLeida = true;
                        }
                        
                        aplicarFiltroYMostrar();
                        cargarNotificaciones(); // Refrescar contadores
                        showToast('Notificación marcada como leída', 'success');
                    } else {
                        showToast('Error al marcar como leída', 'error');
                    }
                },
                error: function() {
                    showToast('Error de conexión', 'error');
                }
            });
        }

        /**
         * Marcar todas como leídas
         */
        function marcarTodasComoLeidas() {
            if (!confirm('¿Marcar todas las notificaciones como leídas?')) {
                return;
            }
            
            $.ajax({
                url: 'NotificacionServlet',
                type: 'POST',
                data: { action: 'markAllRead' },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        cargarNotificaciones();
                        showToast('Todas las notificaciones marcadas como leídas', 'success');
                    } else {
                        showToast('Error al marcar notificaciones', 'error');
                    }
                },
                error: function() {
                    showToast('Error de conexión', 'error');
                }
            });
        }

        /**
         * Eliminar notificación
         */
        function eliminarNotificacion(idNotificacion) {
            if (!confirm('¿Eliminar esta notificación?')) {
                return;
            }
            
            $.ajax({
                url: 'NotificacionServlet',
                type: 'POST',
                data: { action: 'delete', id: idNotificacion },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        // Remover de array local
                        notificacionesData = notificacionesData.filter(n => n.idNotificacion !== idNotificacion);
                        aplicarFiltroYMostrar();
                        cargarNotificaciones(); // Refrescar contadores
                        showToast('Notificación eliminada', 'success');
                    } else {
                        showToast('Error al eliminar notificación', 'error');
                    }
                },
                error: function() {
                    showToast('Error de conexión', 'error');
                }
            });
        }

        /**
         * Paginación
         */
        function actualizarPaginacion() {
            const container = $('#paginationContainer');
            
            if (totalPaginas <= 1) {
                container.hide();
                return;
            }
            
            container.show();
            $('#paginaInfo').text('Página ' + paginaActual + ' de ' + totalPaginas);
            $('#btnAnterior').prop('disabled', paginaActual <= 1);
            $('#btnSiguiente').prop('disabled', paginaActual >= totalPaginas);
        }

        function paginaAnterior() {
            if (paginaActual > 1) {
                paginaActual--;
                aplicarFiltroYMostrar();
            }
        }

        function paginaSiguiente() {
            if (paginaActual < totalPaginas) {
                paginaActual++;
                aplicarFiltroYMostrar();
            }
        }

        /**
         * Utilidades
         */
        function mostrarError(mensaje) {
            $('#notificationList').html(
                '<div class="empty-state">' +
                    '<i class="fas fa-exclamation-triangle text-danger"></i>' +
                    '<h5>Error</h5>' +
                    '<p>' + mensaje + '</p>' +
                    '<button class="btn btn-primary" onclick="cargarNotificaciones()">Reintentar</button>' +
                '</div>'
            );
        }

        function showToast(mensaje, tipo) {
            tipo = tipo || 'info';
            // Usar tu sistema de notificaciones existente
            console.log(tipo.toUpperCase() + ': ' + mensaje);
            
            // Crear toast simple
            var colorFondo = tipo === 'success' ? '#28a745' : tipo === 'error' ? '#dc3545' : '#007bff';
            var icono = tipo === 'success' ? 'check' : tipo === 'error' ? 'times' : 'info';
            
            const toast = $(
                '<div class="toast-notification position-fixed" style="top: 20px; right: 20px; z-index: 9999; ' +
                     'background: ' + colorFondo + '; color: white; padding: 15px 20px; border-radius: 5px; box-shadow: 0 4px 12px rgba(0,0,0,0.3);">' +
                    '<i class="fas fa-' + icono + '-circle me-2"></i>' +
                    mensaje +
                '</div>'
            );
            
            $('body').append(toast);
            
            setTimeout(function() {
                toast.fadeOut(function() { 
                    toast.remove(); 
                });
            }, 3000);
        }
    </script>
</body>
</html>