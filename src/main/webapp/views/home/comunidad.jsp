<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Comunidad</title>
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

    .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .section-header h2 {
            font-size: 20px;
            color: #333;
        }

        .search-container {
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .search-container input[type="text"] {
            padding: 10px;
            font-size: 16px;
            border: 1px solid #ccc;
            border-radius: 5px 0 0 5px;
            width: 200px;
        }

        .search-container button {
            background: none;
            border: 1px solid #ccc;
            border-left: none;
            padding: 10px;
            cursor: pointer;
            border-radius: 0 5px 5px 0;
            color: #666;
            font-size: 16px;
        }

        .section-title {
            font-size: 20px;
            color: #666;
            margin-top: 10px;
            margin-bottom: 10px;
            font-weight: bold;
        }

        .community-list {
            border-top: 1px solid #ddd;
            padding-top: 10px;
        }

        .community-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px solid #ddd;
        }

        .community-item .info {
            font-size: 14px;
            color: #333;
        }

        .community-item .info p {
            margin: 2px 0;
        }

        .community-item button {
            padding: 5px 10px;
            border-radius: 5px;
            font-size: 14px;
            cursor: pointer;
            border: none;
        }

        .following-btn {
            background-color: #f0f0f0;
            color: #333;
        }

        .follow-btn {
            background-color: #000;
            color: #fff;
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
      <!-- Sidebar Izquierdo -->
        <jsp:include page="components/sidebar.jsp" />
        

    <!-- Main -->
    <main>
        <div class="site-section">
            <div class="container">
                <div class="row"> <!-- Usamos g-4 para dar un espaciado entre las columnas -->
                    <!-- Columna de Notificaciones (8/12) -->
                    <div class="col-md-12">
                        <!-- Search Bar -->
                        <div class="section-header">
                            <h2>Comunidad</h2>
                            <nav class="navbar navbar-light bg-light">
                                <form class="form-inline">
                                  <input class="form-control mr-sm-2" type="search" placeholder="Search" aria-label="Search">
                                  <button class="btn btn-outline-success my-2 my-sm-0" type="submit">Search</button>
                                </form>
                              </nav>
                        </div>
            
                        <div class="section-title">Comunidades seguidas</div>
                        <div class="community-list">
                            <div class="community-item">
                                <div class="info">
                                    <p>Agua Segura</p>
                                    <p>@Agua_Segura</p>
                                </div>
                                <button class="following-btn">Siguiendo</button>
                            </div>
                            <div class="community-item">
                                <div class="info">
                                    <p>Cuidadores del Agua</p>
                                    <p>@Cuidadores_del_Agua</p>
                                </div>
                                <button class="following-btn">Siguiendo</button>
                            </div>
                            <div class="community-item">
                                <div class="info">
                                    <p>Red de Abastecimiento Local</p>
                                    <p>@Red_de_Abastecimiento_Local</p>
                                </div>
                                <button class="following-btn">Siguiendo</button>
                            </div>
                            <div class="community-item">
                                <div class="info">
                                    <p>Hidratación Responsable</p>
                                    <p>@Hidratación_Responsable</p>
                                </div>
                                <button class="following-btn">Siguiendo</button>
                            </div>
                        </div>
            
                        <!-- Suggested Communities -->
                        <div class="section-title">Comunidades quizás de tu interés para seguir</div>
                        <div class="community-list">
                            <div class="community-item">
                                <div class="info">
                                    <p>Aguas Unidas</p>
                                    <p>@Aguas_Unidas</p>
                                </div>
                                <button class="follow-btn">Seguir</button>
                            </div>
                            <div class="community-item">
                                <div class="info">
                                    <p>EcoHidratación</p>
                                    <p>@EcoHidratación</p>
                                </div>
                                <button class="follow-btn">Seguir</button>
                            </div>
                            <div class="community-item">
                                <div class="info">
                                    <p>Red de Agua Potable</p>
                                    <p>@Red_de_Agua_Potable</p>
                                </div>
                                <button class="follow-btn">Seguir</button>
                            </div>
                            <div class="community-item">
                                <div class="info">
                                    <p>Puntos de Vida</p>
                                    <p>@Puntos_de_Vida</p>
                                </div>
                                <button class="follow-btn">Seguir</button>
                            </div>
                            <div class="community-item">
                                <div class="info">
                                    <p>Aliados del Agua</p>
                                    <p>@Aliados_del_Agua</p>
                                </div>
                                <button class="follow-btn">Seguir</button>
                            </div>
                            <div class="community-item">
                                <div class="info">
                                    <p>Agua y Comunidad</p>
                                    <p>@Agua_&_Comunidad</p>
                                </div>
                                <button class="follow-btn">Seguir</button>
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