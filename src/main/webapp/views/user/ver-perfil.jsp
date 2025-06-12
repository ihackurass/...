<%-- 
    Document   : ver-perfil
    Created on : 1 may. 2025, 12:35:34
    Author     : Rodrigo
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi Perfil</title>
        <jsp:include page="/components/css_imports.jsp" />
</head>
<style>
    .badge {
        background-color: #0099ff;
        color: white;
        padding: 2px 6px;
        border-radius: 12px;
        font-size: 12px;
        margin-left: 60px;
    }

    .container {
        margin-bottom: 30px;
        background-color: #ffffff;
        padding: 20px;
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
</style>

<body>
    <!-- Sidebar Izquierdo -->
        <jsp:include page="/components/sidebar.jsp" />
        
    <main>
    </main>

        <jsp:include page="/components/js_imports.jsp" />
</body>

</html>
