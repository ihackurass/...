<%-- 
    Document   : index
    Created on : 1 may. 2025, 14:52:54
    Author     : Home
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="0; URL=LoginServlet">
    <title>Agua Bendita - Redireccionando</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .loader {
            border: 16px solid #f3f3f3;
            border-radius: 50%;
            border-top: 16px solid #0099ff;
            width: 120px;
            height: 120px;
            animation: spin 2s linear infinite;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .container {
            text-align: center;
        }
        h2 {
            color: #333;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Bienvenido a Agua Bendita</h2>
        <p>Redireccionando a la página de inicio de sesión...</p>
        <div class="loader"></div>
    </div>
    
    <script type="text/javascript">
        // Redirección JavaScript como respaldo
        window.location.href = "LoginServlet";
    </script>
</body>
</html>