<%-- 
    Document   : buscar
    Created on : 1 may. 2025, 12:52:27
    Author     : Rodrigo
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Buscar</title>
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
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 15px 50px rgba(0, 0, 0, 0.2);
            border: 1px solid #ddd
        }

        .search-bar {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #ccc;
        }

        .search-bar input[type="text"] {
            width: 100%;
            padding: 10px;
            font-size: 16px;
            border: 1px solid #ccc;
            border-radius: 5px 0 0 5px;
        }

        .search-bar button {
            background: none;
            border: 1px solid #ccc;
            border-left: none;
            padding: 10px;
            cursor: pointer;
            border-radius: 0 5px 5px 0;
            color: #666;
            font-size: 16px;
        }

        .results-section {
            margin-top: 20px;
        }

        .result-item {
            display: flex;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px solid #ddd;
        }

        .result-item img {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            margin-right: 10px;
        }

        .result-info {
            font-size: 14px;
            color: #333;
        }

        .result-info p {
            margin: 2px 0;
        }

        .result-btn {
            margin-left: auto;
            padding: 5px 10px;
            border-radius: 5px;
            font-size: 14px;
            cursor: pointer;
            border: none;
            background-color: #0099ff;
            color: white;
        }

        .result-btn:hover {
            background-color: #007acc;
        }
        .logout-icon {
            position: absolute;
            top: 20px;
            right: 60px;
            color: #333;
            font-size: 30px;
            cursor: pointer;
            transition: color 0.3s;
        }

        .logout-icon:hover {
            color: #0099ff;
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
        <!-- Sidebar -->
        <jsp:include page="components/sidebar.jsp" />

        <!-- Main -->
        <main>
            <div class="site-section">
                <div class="container">
                    <div class="row"> <!-- Usamos g-4 para dar un espaciado entre las columnas -->
                        <!-- Columna de Notificaciones (8/12) -->
                        <div class="col-md-12">
                            <!-- Search Bar -->
                            <div class="search-bar">
                                <input type="text" placeholder="Buscar usuarios o contenido...">
                                <button><i class="fas fa-search"></i></button>
                            </div>

                            <!-- Results Section -->
                            <div class="results-section">
                                <h3>Resultados de búsqueda</h3>

                                <div class="result-item">
                                    <i class="fas fa-user icon"></i>
                                    <div class="result-info">
                                        <p><strong>Pedro Quispe</strong></p>
                                        <p>@pedro_quispe</p>
                                    </div>
                                    <button class="result-btn">Seguir</button>
                                </div>

                                <div class="result-item">
                                    <i class="fas fa-tint icon"></i>
                                    <div class="result-info">
                                        <p><strong>Agua Pura Perú</strong></p>
                                        <p>@aguapura_peru</p>
                                    </div>
                                    <button class="result-btn">Seguir</button>
                                </div>

                                <div class="result-item">
                                    <i class="fas fa-user icon"></i>
                                    <div class="result-info">
                                        <p><strong>María Huamán</strong></p>
                                        <p>@maria_huaman</p>
                                    </div>
                                    <button class="result-btn">Seguir</button>
                                </div>

                                <div class="result-item">
                                    <i class="fas fa-tint icon"></i>
                                    <div class="result-info">
                                        <p><strong>Red de Agua Andina</strong></p>
                                        <p><a href="https://redaguaandina.com" target="_blank">@redaguaandina</a></p>
                                    </div>
                                    <button class="result-btn">Seguir</button>
                                </div>

                                <div class="result-item">
                                    <i class="fas fa-user icon"></i>
                                    <div class="result-info">
                                        <p><strong>José Alarcón</strong></p>
                                        <p>@jose_alarcon</p>
                                    </div>
                                    <button class="result-btn">Seguir</button>
                                </div>

                                <div class="result-item">
                                    <i class="fas fa-tint icon"></i>
                                    <div class="result-info">
                                        <p><strong>Agua Segura Lima</strong></p>
                                        <p>@aguaseguralima</p>
                                    </div>
                                    <button class="result-btn">Seguir</button>
                                </div>

                                <div class="result-item">
                                    <i class="fas fa-user icon"></i>
                                    <div class="result-info">
                                        <p><strong>Ana Quispe</strong></p>
                                        <p>@ana_quispe</p>
                                    </div>
                                    <button class="result-btn">Seguir</button>
                                </div>

                                <div class="result-item">
                                    <i class="fas fa-tint icon"></i>
                                    <div class="result-info">
                                        <p><strong>Ríos Limpios Perú</strong></p>
                                        <p>@rioslimpios</p>
                                    </div>
                                    <button class="result-btn">Seguir</button>
                                </div>

                                <div class="result-item">
                                    <i class="fas fa-user icon"></i>
                                    <div class="result-info">
                                        <p><strong>Diego Cahuana</strong></p>
                                        <p>@diego_cahuana</p>
                                    </div>
                                    <button class="result-btn">Seguir</button>
                                </div>

                                <div class="result-item">
                                    <i class="fas fa-tint icon"></i>
                                    <div class="result-info">
                                        <p><strong>Agua Viva Andina</strong></p>
                                        <p>@aguavivaandina</p>
                                    </div>
                                    <button class="result-btn">Seguir</button>
                                </div>
                            </div>

                        </div>

                    </div>
                </div>

            </div>
        </main>


        <jsp:include page="/components/js_imports.jsp" />
    </body>

</html>