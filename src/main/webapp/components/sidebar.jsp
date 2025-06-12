<%@page contentType="text/html" pageEncoding="UTF-8"%>
<aside class="sidebar">
    <div class="toggle">
        <a href="#" class="burger js-menu-toggle" data-toggle="collapse" data-target="#main-navbar">
            <span></span>
        </a>
    </div>
    <div class="side-inner">
        <div class="profile">
            <img src="assets/images/avatars/default.png" alt="Image" class="img-fluid">
            <h3 class="name">${sessionScope.usuarioLogueado.nombreCompleto}</h3>
            <span class="country">@${sessionScope.usuarioLogueado.username}</span>

        </div>
        <div class="nav-menu">
            <%
                String uri = request.getRequestURI();
            %>
            <ul>
                <li class="<%= uri.endsWith("home.jsp") ? "active" : ""%>">
                    <a href="HomeServlet"><span class="fas fa-home mr-3"></span>Home</a>
                </li>
                <li class="<%= uri.endsWith("buscar.jsp") ? "active" : ""%>">
                    <a href="buscar.jsp"><span class="fas fa-search mr-3"></span>Buscar</a>
                </li>
                <li class="<%= uri.endsWith("notificaciones.jsp") ? "active" : ""%>">
                    <a href="notificaciones.jsp"><span class="fas fa-bell mr-3"></span>Notificaciones <span class="badge">10</span></a>
                </li>
                <li class="<%= uri.endsWith("transmisiones.jsp") ? "active" : ""%>">
                    <a href="transmisiones.jsp"><span class="fas fa-broadcast-tower mr-3"></span>Transmisiones <span class="badge">1</span></a>
                </li>
                <li class="nav-item comunidades-nav <%= uri.endsWith("list.jsp") ? "active" : ""%>"">
                    <a href="#" class="nav-link" onclick="toggleComunidadesMenu(event)">
                        <i class="fas fa-users"></i>
                        <span>Comunidades</span>
                        <i class="fas fa-chevron-down menu-arrow"></i>
                    </a>

                    <!-- Submenú de comunidades -->
                <ul class="submenu-comunidades">
                   <li>
                       <a href="ComunidadServlet" class="submenu-link" style="padding-left: 50px;">
                           <i class="fas fa-globe"></i> Explorar Todas
                       </a>
                   </li>
                   <c:if test="${sessionScope.usuario != null}">
                       <li>
                           <a href="ComunidadServlet?action=myCommunities" class="submenu-link" style="padding-left: 50px;">
                               <i class="fas fa-heart"></i> Mis Comunidades
                           </a>
                       </li>
                       <li>
                           <a href="ComunidadServlet?action=managedCommunities" class="submenu-link" style="padding-left: 50px;">
                               <i class="fas fa-crown"></i> Que Administro
                           </a>
                       </li>
                   </c:if>
                </ul>
                </li>
                <li class="<%= uri.endsWith("mi-perfil.jsp") ? "active" : ""%>">
                    <a href="mi-perfil.jsp"><span class="fas fa-user mr-3"></span>Mi Perfil</a>
                </li>
                <li><a href="LogoutServlet" class="text-danger"><span class="fas fa-sign-out-alt mr-3"></span>Cerrar Sesión</a></li>
                
                <% if (uri.endsWith("home.jsp")) { %>
                <li>
                    <button type="button" class="btn btn-cuadrado btn-cuadrado-crear-post" data-toggle="modal"
                            data-target="#postModal">Crear Post</button>
                </li>
                <li>
                    <button type="button" class="btn btn-cuadrado btn-cuadrado-crear-live" data-toggle="modal"
                            data-target="#streamModal">Crear Live</button>
                <% }else if (uri.endsWith("list.jsp")){%>
                    <button type="button" class="btn btn-cuadrado btn-cuadrado-crear-post" data-toggle="modal"
                            data-target="#communityModal">Crear Comunidad</button>
                </li>
                <% }%>
            </ul>

        </div>
    </div>
</aside>
<style>
    
    .comunidades-nav.active > .nav-link {
        background-color: #e3f2fd;
        color: #1976d2;
    }

    .comunidades-nav .menu-arrow {
        margin-left: auto;
        padding-left: 75px;
        transition: transform 0.2s ease;
    }

    .comunidades-nav.active .menu-arrow {
        transform: translateX(75px) rotate(180deg);
    }

    .submenu-comunidades {
        list-style: none;
        padding: 0 20px;
        margin: 0;
        max-height: 0;
        opacity: 0;
        overflow: hidden;
        transition: 
            max-height 0.4s ease-in-out,
            opacity 0.3s ease-in-out,
            padding 0.4s ease-in-out;
        background-color: #f8f9fa;
        border-radius: 0 0 8px 8px;
    }

    .submenu-comunidades.show {
        max-height: 200px;
        opacity: 1;
        padding: 10px 20px;
    }

    .submenu-comunidades li {
        margin: 5px 0;
    }

    /* Solo una definición para los enlaces del submenú */
    .submenu-comunidades .submenu-link {
        display: flex;
        align-items: center;
        padding: 8px 15px;
        background-color: transparent;
        color: #666;
        text-decoration: none;
        border-radius: 5px;
        transition: background-color 0.2s;
    }

    .submenu-comunidades .submenu-link:hover {
        background-color: #e9ecef;
        color: #007bff;
        text-decoration: none;
    }

    .submenu-comunidades .submenu-link i {
        margin-right: 10px;
        width: 16px;
    }
    /* Botón crear comunidad */
    .btn-cuadrado-crear-comunidad {
        background-color: #28a745;
        color: white;
        border-color: #28a745;
    }
    
    .btn-cuadrado-crear-comunidad:hover {
        background-color: #218838;
        border-color: #1e7e34;
        color: white;
        text-decoration: none;
    }
    
    /* Avatar pequeño para sugerencias */
    .community-avatar-small {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: linear-gradient(135deg, #007bff, #28a745);
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-weight: bold;
        font-size: 16px;
        margin-right: 10px;
        flex-shrink: 0;
    }
    
    /* Botón seguir */
    .follow-btn {
        background-color: #007bff;
        color: white;
        border: none;
        padding: 5px 12px;
        border-radius: 15px;
        font-size: 12px;
        cursor: pointer;
        transition: background-color 0.2s;
    }
    
    .follow-btn:hover {
        background-color: #0056b3;
    }
    
    .btn-following {
        background-color: #28a745;
        color: white;
        border: none;
        padding: 5px 12px;
        border-radius: 15px;
        font-size: 12px;
        cursor: default;
    }
    
    /* Ver todas */
    .btn-ver-todas {
        display: block;
        text-align: center;
        padding: 8px;
        background-color: #f8f9fa;
        color: #007bff;
        text-decoration: none;
        border-radius: 5px;
        font-size: 12px;
        border: 1px solid #dee2e6;
        transition: background-color 0.2s;
    }
    
    .btn-ver-todas:hover {
        background-color: #e9ecef;
        text-decoration: none;
    }
    
    .loading-placeholder {
        font-size: 12px;
    }
    
    /* Ajustar suggestion-item existente para el avatar */
    .suggestion-item {
        display: flex;
        align-items: center;
        padding: 8px 0;
        gap: 10px;
    }
    
    .suggestion-item > div {
        flex: 1;
    }
    
    .suggestion-item p {
        margin: 0;
        font-size: 14px;
        font-weight: 500;
    }
    
    .suggestion-item span {
        font-size: 12px;
        color: #666;
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
    .badge {
        background-color: #0099ff;
        color: white;
        padding: 2px 6px;
        border-radius: 12px;
        font-size: 12px;
        margin-left: 60px;
    }
</style>
<script>
    // Función para toggle del menú de comunidades
    function toggleComunidadesMenu(event) {
        event.preventDefault();

        const navItem = event.currentTarget.closest('.comunidades-nav');
        const submenu = navItem.querySelector('.submenu-comunidades');

        // Toggle clases para activar animaciones CSS
        navItem.classList.toggle('active');
        submenu.classList.toggle('show');
    }
    
    // Función para unirse a comunidad desde sugerencias
    function unirseAComunidad(idComunidad) {
        if (!${sessionScope.usuario != null}) {
            alert('Debes iniciar sesión para unirte a una comunidad');
            return;
        }
        
        // Mostrar loading
        event.target.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
        event.target.disabled = true;
        
        $.ajax({
            url: 'ComunidadServlet',
            type: 'POST',
            data: {
                action: 'join',
                id: idComunidad
            },
            success: function(response) {
                if (response.success) {
                    // Mostrar notificación
                    if (typeof showNotification === 'function') {
                        showNotification('¡Te has unido a la comunidad!', 'success');
                    } else {
                        alert('¡Te has unido a la comunidad!');
                    }
                    
                    // Cambiar botón
                    event.target.innerHTML = '<i class="fas fa-check"></i> Siguiendo';
                    event.target.className = 'btn-following';
                    event.target.disabled = true;
                } else {
                    event.target.innerHTML = 'Seguir';
                    event.target.disabled = false;
                    alert(response.message || 'Error al unirse a la comunidad');
                }
            },
            error: function() {
                event.target.innerHTML = 'Seguir';
                event.target.disabled = false;
                alert('Error de conexión');
            }
        });
    }
   

</script>