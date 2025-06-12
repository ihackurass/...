<%-- 
    Document   : mi-perfil
    Created on : 1 may. 2025, 12:51:07
    Author     : Rodrigo
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">

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
            /*border-radius: 10px;*/
            padding: 20px;
            /*box-shadow: 0 15px 50px rgba(0, 0, 0, 0.2);
            border: 1px solid #ddd*/
        }

        .container2 {
            margin-bottom: 30px;
            background-color: #ffffff;
            border-radius: 10px;
            padding: 20px;
            /*box-shadow: 0 15px 50px rgba(0, 0, 0, 0.2);
            border: 1px solid #ddd*/
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
                            <div class="container2 text-center">
                                <!-- Main Content - Mi Perfil -->
                                <div class="card p-4 shadow-lg mx-auto" style="max-width: 500px;">
                                    <h2 class="text-center bg-dark text-white p-3 rounded">Mi PERFIL</h2>

                                    <!-- Opciones de Perfil -->
                                    <div class="list-group mt-4">
                                        <!-- Botón Cambiar nombre de usuario -->
                                        <a href="#" class="list-group-item list-group-item-action" data-toggle="modal"
                                           data-target="#cambiarNombreModal">
                                            <i class="fas fa-edit"></i> Cambiar nombre de usuario
                                        </a>

                                        <!-- Modal Cambiar nombre de usuario -->
                                        <div class="modal fade" id="cambiarNombreModal" tabindex="-1" role="dialog"
                                             aria-labelledby="userModalLabel" aria-hidden="true">
                                            <div class="modal-dialog" role="document">
                                                <div class="modal-content">
                                                    <!-- Modal Header (alineado a la izquierda por defecto) -->
                                                    <div class="modal-header">
                                                        <h5 class="modal-title" id="userModalLabel">Cambiar Nombre de
                                                            Usuario</h5>
                                                        <button type="button" class="close" data-dismiss="modal"
                                                                aria-label="Cerrar">
                                                            <span aria-hidden="true">&times;</span>
                                                        </button>
                                                    </div>

                                                    <!-- Modal Body (sin centrado) -->
                                                    <div class="modal-body">
                                                        <form>
                                                            <div class="form-group">
                                                                <label for="newUsername">Nuevo Nombre de Usuario</label>
                                                                <input type="text" class="form-control" id="newUsername"
                                                                       placeholder="Escribe el nuevo nombre de usuario">
                                                            </div>
                                                            <div class="form-group">
                                                                <label for="confirmPassword">Confirmar Contraseña</label>
                                                                <input type="password" class="form-control"
                                                                       id="confirmPassword"
                                                                       placeholder="Confirma la contraseña">
                                                            </div>
                                                        </form>
                                                    </div>

                                                    <!-- Modal Footer (alineado a la derecha con ml-auto) -->
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-danger"
                                                                data-dismiss="modal">Cancelar</button>
                                                        <button type="button" class="btn btn-success">Guardar
                                                            Cambios</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>



                                        <!-- Botón Cambiar Contraseña -->
                                        <a href="#" class="list-group-item list-group-item-action" data-toggle="modal"
                                           data-target="#cambiarContraseñaModal">
                                            <i class="fas fa-lock"></i> Cambiar contraseña
                                        </a>

                                        <!-- Modal Cambiar Contraseña -->
                                        <div class="modal fade" id="cambiarContraseñaModal" tabindex="-1" role="dialog"
                                             aria-labelledby="cambiarContraseñaModalLabel" aria-hidden="true">
                                            <div class="modal-dialog" role="document">
                                                <div class="modal-content">
                                                    <!-- Modal Header -->
                                                    <div class="modal-header">
                                                        <h5 class="modal-title" id="cambiarContraseñaModalLabel">Cambiar
                                                            Contraseña</h5>
                                                        <button type="button" class="close" data-dismiss="modal"
                                                                aria-label="Cerrar">
                                                            <span aria-hidden="true">&times;</span>
                                                        </button>
                                                    </div>
                                                    <!-- Modal Body -->
                                                    <div class="modal-body">
                                                        <form>
                                                            <div class="form-group">
                                                                <label for="currentPassword">Contraseña Actual</label>
                                                                <input type="password" class="form-control"
                                                                       id="currentPassword"
                                                                       placeholder="Ingresa tu contraseña actual">
                                                            </div>
                                                            <div class="form-group">
                                                                <label for="newPassword">Nueva Contraseña</label>
                                                                <input type="password" class="form-control" id="newPassword"
                                                                       placeholder="Ingresa la nueva contraseña">
                                                            </div>
                                                            <div class="form-group">
                                                                <label for="confirmNewPassword">Confirmar Nueva
                                                                    Contraseña</label>
                                                                <input type="password" class="form-control"
                                                                       id="confirmNewPassword"
                                                                       placeholder="Confirma la nueva contraseña">
                                                            </div>
                                                        </form>
                                                    </div>
                                                    <!-- Modal Footer -->
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-danger"
                                                                data-dismiss="modal">Cancelar</button>
                                                        <button type="button" class="btn btn-success">Guardar
                                                            Cambios</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Botón Cambiar Correo Electrónico -->
                                        <a href="#" class="list-group-item list-group-item-action" data-toggle="modal"
                                           data-target="#cambiarCorreoModal">
                                            <i class="fas fa-envelope"></i> Cambiar dirección de correo electrónico
                                        </a>

                                        <!-- Modal Cambiar Correo Electrónico -->
                                        <div class="modal fade" id="cambiarCorreoModal" tabindex="-1" role="dialog"
                                             aria-labelledby="cambiarCorreoModalLabel" aria-hidden="true">
                                            <div class="modal-dialog" role="document">
                                                <div class="modal-content">
                                                    <!-- Modal Header -->
                                                    <div class="modal-header">
                                                        <h5 class="modal-title" id="cambiarCorreoModalLabel">Cambiar
                                                            Dirección de Correo Electrónico</h5>
                                                        <button type="button" class="close" data-dismiss="modal"
                                                                aria-label="Cerrar">
                                                            <span aria-hidden="true">&times;</span>
                                                        </button>
                                                    </div>
                                                    <!-- Modal Body -->
                                                    <div class="modal-body">
                                                        <form>
                                                            <div class="form-group">
                                                                <label for="newEmail">Nuevo Correo Electrónico</label>
                                                                <input type="email" class="form-control" id="newEmail"
                                                                       placeholder="Ingresa tu nuevo correo">
                                                            </div>

                                                            <div class="form-group">
                                                                <label for="currentPassword">Contraseña Actual</label>
                                                                <input type="password" class="form-control"
                                                                       id="currentPassword"
                                                                       placeholder="Ingresa tu contraseña actual">
                                                            </div>

                                                        </form>
                                                    </div>
                                                    <!-- Modal Footer -->
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-danger"
                                                                data-dismiss="modal">Cancelar</button>
                                                        <button type="button" class="btn btn-success">Guardar
                                                            Cambios</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Botón Cambiar número de contacto -->
                                        <a href="#" class="list-group-item list-group-item-action" data-toggle="modal"
                                           data-target="#cambiarNumeroModal">
                                            <i class="fas fa-phone"></i> Cambiar número de contacto
                                        </a>

                                        <!-- Modal Cambiar número de contacto -->
                                        <div class="modal fade" id="cambiarNumeroModal" tabindex="-1" role="dialog"
                                             aria-labelledby="numeroModalLabel" aria-hidden="true">
                                            <div class="modal-dialog" role="document">
                                                <div class="modal-content">
                                                    <!-- Modal Header -->
                                                    <div class="modal-header">
                                                        <h5 class="modal-title" id="numeroModalLabel">Cambiar Número de
                                                            Contacto</h5>
                                                        <button type="button" class="close" data-dismiss="modal"
                                                                aria-label="Close">
                                                            <span aria-hidden="true">&times;</span>
                                                        </button>
                                                    </div>
                                                    <!-- Modal Body -->
                                                    <div class="modal-body">
                                                        <form>
                                                            <div class="form-group">
                                                                <label for="newPhoneNumber">Nuevo Número de Teléfono</label>
                                                                <input type="text" class="form-control" id="newPhoneNumber"
                                                                       placeholder="Escribe el nuevo número de teléfono">
                                                            </div>
                                                            <div class="form-group">
                                                                <label for="currentPassword">Contraseña Actual</label>
                                                                <input type="password" class="form-control"
                                                                       id="currentPassword"
                                                                       placeholder="Confirma la contraseña actual">
                                                            </div>
                                                        </form>
                                                    </div>
                                                    <!-- Modal Footer -->
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-danger"
                                                                data-dismiss="modal">Cancelar</button>
                                                        <button type="button" class="btn btn-success">Guardar
                                                            Cambios</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Botón Solicitar verificación -->
                                        <a href="#" class="list-group-item list-group-item-action" data-toggle="modal"
                                           data-target="#solicitarVerificacionModal">
                                            <i class="fas fa-check-circle"></i> Solicitar verificación
                                        </a>

                                        <a href="ver-transacciones.html" class="list-group-item list-group-item-action">
                                            <i class="fas fa-dollar-sign"></i> Ver Transacciones
                                        </a>

                                        <!-- Modal Solicitar verificación -->
                                        <div class="modal fade" id="solicitarVerificacionModal" tabindex="-1" role="dialog"
                                             aria-labelledby="verificacionModalLabel" aria-hidden="true">
                                            <div class="modal-dialog" role="document">
                                                <div class="modal-content">
                                                    <!-- Modal Header -->
                                                    <div class="modal-header">
                                                        <h5 class="modal-title" id="verificacionModalLabel">Solicitar
                                                            Verificación</h5>
                                                        <button type="button" class="close" data-dismiss="modal"
                                                                aria-label="Close">
                                                            <span aria-hidden="true">&times;</span>
                                                        </button>
                                                    </div>
                                                    <!-- Modal Body -->
                                                    <div class="modal-body">
                                                        <form action="/SolicitarVerificacionServlet" method="post" enctype="multipart/form-data">
                                                            <div>
                                                                <label for="motivo">Motivo de la solicitud</label>
                                                                <textarea id="motivo" name="motivo"></textarea>
                                                            </div>
                                                            <div>
                                                                <label for="contrasena">Contraseña Actual</label>
                                                                <input type="password" id="contrasena" name="contrasena">
                                                            </div>
                                                            <div>
                                                                <label for="documento">Documento de verificación</label>
                                                                <input type="file" id="documento" name="documento">
                                                            </div>
                                                            <div>
                                                                <button type="button" data-dismiss="modal">Cancelar</button>
                                                                <button type="submit">Solicitar Verificación</button>
                                                            </div>
                                                        </form>
                                                    </div>
                                                    <!-- Modal Footer -->
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-danger"
                                                                data-dismiss="modal">Cancelar</button>
                                                        <button type="button" class="btn btn-success">Solicitar
                                                            Verificación</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>


                                    </div>

                                    <!-- Botón Regresar (menos ancho) -->
                                    <a href="home.html" class="btn btn-danger mt-4">Regresar</a>
                                </div>
                            </div>
                        </div>

                    </div>
                    </main>


                    <jsp:include page="/components/js_imports.jsp" />
                    </body>

                    </html>