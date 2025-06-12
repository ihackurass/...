<%-- 
    Document   : home
    Created on : 1 may. 2025, 11:45:59
    Author     : Rodrigo
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Panel de Administración - Agua Bendita</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/assets/css/bootstrap.min.css">
        <!-- DataTables CSS -->
        <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
        <style>
            .avatar {
                width: 40px;
                height: 40px;
                border-radius: 50%;
            }
            .main-content {
                flex: 1;
                padding: 20px;
                background-color: #fff;
                overflow-y: auto;
            }

            .main-content h1 {
                font-size: 24px;
                margin-bottom: 20px;
                color: #333;
            }

            .search-bar {
                display: flex;
                justify-content: space-between;
                margin-bottom: 20px;
            }

            .search-bar input {
                width: 250px;
                padding: 10px;
                border: 1px solid #ddd;
                border-radius: 4px;
            }

            .stats-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 20px;
            }

            .card {
                background-color: #f9f9f9;
                padding: 20px;
                border: 1px solid #ddd;
                border-radius: 8px;
                text-align: center;
            }

            .card h3 {
                font-size: 18px;
                margin-bottom: 10px;
                color: #333;
            }

            .card p {
                font-size: 16px;
                color: #555;
            }

            .chart {
                margin-top: 50px;
                text-align: center;
            }

            .chart img {
                width: 100%;
                max-width: 400px;
                border-radius: 8px;
            }

            .chart-pie img {
                width: 100%;
                max-width: 150px;
                border-radius: 8px;
            }
        </style>
    </head>
    <body>
        <!-- Navbar -->
        <jsp:include page="../components/adminNavbar.jsp" />

        <div class="main-content">
            <h1>Estadísticas de la plataforma</h1>
            <div class="search-bar">
                <input type="text" placeholder="Buscar...">
            </div>
            <div class="stats-grid">
                <div class="card">
                    <h3>Últimas 24 horas</h3>
                    <p>Usuarios registrados: 8</p>
                    <p>Nuevas publicaciones: 3</p>
                </div>
                <div class="card">
                    <h3>Donaciones</h3>
                    <p>Ingreso por publicación: 8795</p>
                    <p>Transacción total: 8795</p>
                    <p>Monto total ganado: $631586.09</p>
                </div>
                <div class="card">
                    <h3>Contenido</h3>
                    <p>Total de mensajes: 3625</p>
                    <p>Comentarios: 1049</p>
                    <p>Total de reacciones: 987</p>
                </div>
                <div class="card">
                    <h3>Nuevos usuarios</h3>
                    <p>158</p>
                    <p style="color: green;">⬆ 12% aumentando</p>
                </div>
                <div class="card chart-pie">
                    <h3>Usuarios verificados</h3>
                    <img src="../assets/images/pastel.png" alt="Gráfico de pastel">
                    <p>Confirmados: 4000</p>
                    <p>Sin verificar: 100</p>
                </div>
            </div>
            <div class="chart">
                <h3>Gráfico de crecimiento</h3>
                <img src="../assets/images/crecimiento.jpg" alt="Gráfico de crecimiento">
            </div>
        </div>

    </body>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <!-- Bootstrap Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- DataTables JS -->
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
</html>
