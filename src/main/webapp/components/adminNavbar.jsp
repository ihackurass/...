<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container">
        <!-- Marca del sitio -->
        <a class="navbar-brand" href="${pageContext.request.contextPath}/admin/home.jsp">
            <img src="${pageContext.request.contextPath}/assets/images/logo.jpg" alt="Logo" width="30" height="30" class="d-inline-block align-text-top">
            Agua Bendita
        </a>
        <!-- Botón colapsable para dispositivos pequeños -->
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav"
                aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <!-- Links del menú -->
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/home.jsp">Inicio</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/UsuariosServlet">Usuarios</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/PublicacionesServlet">Publicaciones</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/IngresosServlet">Ingresos</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/lives.jsp">Lives</a>
                </li>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button"
                       data-bs-toggle="dropdown" aria-expanded="false">
                        Administrador
                    </a>
                    <ul class="dropdown-menu" aria-labelledby="navbarDropdown">
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="../LogoutServlet">Cerrar sesión</a></li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</nav>
