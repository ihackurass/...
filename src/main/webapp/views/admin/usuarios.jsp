<%-- 
    Document   : usuarios
    Created on : 29 abr. 2025, 21:16:59
    Author     : Rodrigo
--%>

<%@page import="java.util.List"%>
<%@page import="pe.aquasocial.entity.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Administración de Usuarios - Agua Bendita</title>
        <!-- Bootstrap CSS -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/assets/css/bootstrap.min.css">
        <!-- Bootstrap Icons -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <!-- DataTables CSS -->
        <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
        <!-- DataTables Responsive CSS -->
        <link rel="stylesheet" href="https://cdn.datatables.net/responsive/2.5.0/css/responsive.bootstrap5.min.css">
        <style>
            .flat-checkbox {
                padding: 4px 0;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 15px auto;
            }

            .flat-checkbox input[type="checkbox"] {
                appearance: none;
                -webkit-appearance: none;
                width: 20px;
                height: 20px;
                background: #f0f0f0;
                border: 1px solid #ccc;
                border-radius: 3px;
                outline: none;
                cursor: pointer;
                position: relative;
                margin-right: 15px; 
            }

            .flat-checkbox input[type="checkbox"]:checked {
                background: #007bff;
                border-color: #007bff;
            }

            .flat-checkbox input[type="checkbox"]:checked::after {
                content: '✓';
                color: white;
                position: absolute;
                left: 50%;
                top: 50%;
                transform: translate(-50%, -50%);
                font-size: 14px;
            }

            .flat-checkbox label {
                font-size: 16px;
                cursor: pointer;
            }
            .avatar {
                width: 40px;
                height: 40px;
                border-radius: 50%;
            }

            .btn-privilegio,
            .btn-privilegio-no,
            .btn-baneo,
            .btn-revisar {
                padding: 5px 10px;
                color: #fff;
                border: none;
                border-radius: 5px;
                cursor: pointer;
            }

            .btn-privilegio {
                background-color: #28a745;
            }

            .btn-privilegio-no {
                background-color: #dc3545;
            }

            .btn-baneo {
                background-color: #dc3545;
            }

            .btn-revisar {
                background-color: #007bff;
            }

            .btn-revisar-disabled {
                background-color: #080808;
                padding: 5px 10px;
                color: #dddbdb;
                border: none;
                border-radius: 5px;
                cursor: not-allowed;
            }
            #usuariosTable thead th {
                text-align: center;
                vertical-align: middle;
            }

            #usuariosTable tbody td {
                text-align: center;
                vertical-align: middle;
            }

        </style>
    </head>

    <body>

        <!-- Navbar -->
        <jsp:include page="../components/adminNavbar.jsp" />

        <!-- Modal de Revisión -->
        <div class="modal fade" id="revisarModal" tabindex="-1" aria-labelledby="revisarModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="revisarModalLabel">Detalles de la Solicitud de Verificación</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <h3><b>Descripción de la Solicitud</b></h3>
                        <p>Hola deseo obtener privilegios para poder ayudar a la comunidad del Perú.</p>

                        <h6><b>Foto del Documento</b></h6>
                        <img src="../assets/images/dni.jpg" alt="Documento" class="img-fluid">
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                        <button type="button" class="btn btn-primary">Verificar</button>
                    </div>
                </div>
            </div>
        </div>
        <div class="container my-4">
            <h1 class="text-center mb-4">Administración de Usuarios</h1>

            <div class="table-responsive">

                <table id="usuariosTable" class="table table-striped table-bordered">
                    <thead class="table-dark">

                        <tr>
                            <th>ID</th>
                            <th>Avatar</th>
                            <th>Usuario</th>
                            <th>Email</th>
                            <th>Telefono</th>
                            <th>Rol</th>
                            <th>Solicito Verificacion</th>
                            <th>Verificado</th>
                            <th>Privilegio</th>
                            <th>Banear</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<Usuario> usuarios = (List<Usuario>) request.getAttribute("usuarios");
                            if (usuarios != null) {
                                for (Usuario usuario : usuarios) {
                        %>
                        <tr>
                            <td><%= usuario.getId()%></td>
                            <td><img src="<%= usuario.getAvatar()%>" alt="Avatar" class="avatar"></td>
                            <td class="<%= usuario.getUsername().contains("usuario_eliminado") ? "bg-danger text-white" : ""%>">
                                <%= usuario.getUsername()%>
                            </td>                            <td><%= usuario.getEmail()%></td>
                            <td><%= usuario.getTelefono()%></td>
                            <td><%= usuario.getRol()%></td>
                            <td><%= usuario.isSolicitoVerificacion() ? "Sí" : "No"%></td>
                            <td>
                                <button class="<%= usuario.isVerificado() ? "btn-privilegio" : "btn-privilegio-no"%>">
                                    <%= usuario.isVerificado() ? "Sí" : "No"%>
                                </button>
                            </td>
                            <td>
                                <button class="<%= usuario.isPrivilegio() ? "btn-privilegio" : "btn-privilegio-no"%>">
                                    <%= usuario.isPrivilegio() ? "Sí" : "No"%>
                                </button>
                            </td>
                            <td>
                                <button class="<%= usuario.isBaneado() ? "btn-privilegio" : "btn-baneo"%>">
                                    <%= usuario.isBaneado() ? "Sí" : "No"%>
                                </button>
                            </td>
                            <td>
                                <button class="btn btn-warning btn-sm" title="Editar"
                                        data-bs-toggle="modal"
                                        data-bs-target="#actualizarModal"
                                        data-id="<%= usuario.getId()%>"
                                        data-email="<%= usuario.getEmail()%>"
                                        data-username="<%= usuario.getUsername()%>"
                                        data-rol="<%= usuario.getRol()%>"
                                        data-solicito_ve="<%= usuario.isSolicitoVerificacion()%>"
                                        data-verificado="<%= usuario.isVerificado()%>"
                                        data-privilegio="<%= usuario.isPrivilegio()%>"
                                        data-baneado="<%= usuario.isBaneado()%>"
                                        data-telefono="<%= usuario.getTelefono()%>">
                                    <i class="bi bi-pencil-fill"></i>
                                </button>

                                <button class="btn btn-danger btn-sm" title="Eliminar"

                                        data-bs-toggle="modal" 
                                        data-bs-target="#eliminarModal" 
                                        data-id="<%= usuario.getId()%>">
                                    <i class="bi bi-trash-fill"></i>
                                </button>
                            </td>
                        </tr>
                        <%
                                }
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Modal de Actualización -->
        <div class="modal fade" id="actualizarModal" tabindex="-1" aria-labelledby="actualizarModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="actualizarModalLabel">Actualizar Usuario</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form id="formActualizarUsuario">
                            <input type="hidden" id="usuarioIdActualizar">

                            <div class="mb-3">
                                <label for="usuarioNombre" class="form-label">Nombre de Usuario</label>
                                <input type="text" class="form-control" id="usuarioNombre" placeholder="Dejar vacío para no modificar">
                            </div>

                            <div class="mb-3">
                                <label for="usuarioEmail" class="form-label">Email</label>
                                <input type="email" class="form-control" id="usuarioEmail" placeholder="Dejar vacío para no modificar">
                            </div>

                            <div class="mb-3">
                                <label for="usuarioTelefono" class="form-label">Teléfono</label>
                                <input type="text" class="form-control" id="usuarioTelefono" placeholder="Dejar vacío para no modificar">
                            </div>

                            <div class="mb-3">
                                <label for="usuarioRol" class="form-label">Rol</label>
                                <select class="form-control" id="usuarioRol">
                                    <option value="">-- No modificar --</option>
                                    <option value="user">Usuario</option>
                                    <option value="admin">Administrador</option>
                                </select>
                            </div>

                            <div class="mb-3 flat-checkbox">
                                <input type="checkbox" id="usuarioSolicitud">
                                <label for="usuarioSolicitud">Solicito Verificación</label>
                            </div>

                            <div class="mb-3 flat-checkbox">
                                <input type="checkbox" id="usuarioVerificado">
                                <label for="usuarioVerificado">Verificado</label>
                            </div>

                            <div class="mb-3 flat-checkbox">
                                <input type="checkbox" id="usuarioPrivilegio">
                                <label for="usuarioPrivilegio">Privilegio</label>
                            </div>

                            <div class="mb-3 flat-checkbox">
                                <input type="checkbox" id="usuarioBaneado">
                                <label for="usuarioBaneado">Baneado</label>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer d-flex justify-content-center">
                        <button type="button" class="btn btn-secondary me-3" data-bs-dismiss="modal">
                            <i class="bi bi-x-circle"></i> Cerrar
                        </button>
                        <button type="button" class="btn btn-warning ms-3" id="btnActualizarUsuario">
                            <i class="bi bi-check-circle"></i> Actualizar Usuario
                        </button>
                    </div>
                </div>
            </div>
        </div>



        <!-- Modal de Eliminación -->
        <div class="modal fade" id="eliminarModal" tabindex="-1" aria-labelledby="eliminarModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="eliminarModalLabel">Eliminar Usuario</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p>¿Estás seguro de que deseas eliminar a este usuario?</p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                        <!-- Agregamos el formulario de eliminación -->
                        <form action="UsuariosServlet" method="post">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" id="usuarioIdEliminar" name="usuarioId">
                            <button type="submit" class="btn btn-danger">Eliminar</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>




        <!-- jQuery -->
        <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
        <!-- Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <!-- DataTables JS -->
        <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
        <script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
        <!-- DataTables Responsive JS -->
        <script src="https://cdn.datatables.net/responsive/2.5.0/js/dataTables.responsive.min.js"></script>
        <script src="https://cdn.datatables.net/responsive/2.5.0/js/responsive.bootstrap5.min.js"></script>
        <script>
            $(document).ready(function () {
                $('#usuariosTable').DataTable({
                    language: {
                        url: '//cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json'
                    }
                });

                // Manejar el envío del formulario de actualización
                $('#btnActualizarUsuario').click(function (e) {
                    e.preventDefault();

                    // Mostrar indicador de carga
                    $(this).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Actualizando...');
                    $(this).prop('disabled', true);

                    // Obtener el ID del usuario (obligatorio)
                    var usuarioId = $('#usuarioIdActualizar').val();
                    if (!usuarioId) {
                        alert("Error: ID de usuario no válido");
                        $(this).html('<i class="bi bi-check-circle"></i> Actualizar Usuario');
                        $(this).prop('disabled', false);
                        return;
                    }

                    // Crear objeto para los datos
                    var formData = {
                        action: 'update',
                        usuarioId: usuarioId
                    };

                    // Recopilar solo campos con valores
                    var username = $('#usuarioNombre').val();
                    if (username && username.trim() !== '') {
                        formData.username = username;
                    }

                    var email = $('#usuarioEmail').val();
                    if (email && email.trim() !== '') {
                        formData.email = email;
                    }

                    var telefono = $('#usuarioTelefono').val();
                    if (telefono && telefono.trim() !== '') {
                        formData.telefono = telefono;
                    }

                    var rol = $('#usuarioRol').val();
                    if (rol && rol !== '') {
                        formData.rol = rol;
                    }

                    // Para checkboxes, siempre enviamos su estado actual
                    formData.solicito_verificacion = $('#usuarioSolicitud').is(':checked');
                    formData.verificado = $('#usuarioVerificado').is(':checked');
                    formData.privilegio = $('#usuarioPrivilegio').is(':checked');
                    formData.baneado = $('#usuarioBaneado').is(':checked');

                    // Verificar si hay al menos un campo para actualizar además del ID y action
                    if (Object.keys(formData).length <= 2) {
                        alert("Debes modificar al menos un campo para actualizar");
                        $(this).html('<i class="bi bi-check-circle"></i> Actualizar Usuario');
                        $(this).prop('disabled', false);
                        return;
                    }

                    // Enviar la solicitud AJAX
                    $.ajax({
                        url: 'UsuariosServlet',
                        type: 'POST',
                        data: formData,
                        dataType: 'json',
                        success: function (response) {
                            // Ocultar el modal
                            $('#actualizarModal').modal('hide');

                            if (response.success) {
                                // Mostrar mensaje de éxito
                                var alertHTML = '<div class="alert alert-success alert-dismissible fade show" role="alert">' +
                                        response.message +
                                        '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>' +
                                        '</div>';
                                $('.container').eq(1).prepend(alertHTML);

                                // Recargar la tabla después de un breve retraso
                                setTimeout(function () {
                                    location.reload();
                                }, 1500);
                            } else {
                                // Mostrar mensaje de error
                                var alertHTML = '<div class="alert alert-danger alert-dismissible fade show" role="alert">' +
                                        'Error: ' + response.message +
                                        '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>' +
                                        '</div>';
                                $('.container').eq(1).prepend(alertHTML);
                            }
                        },
                        error: function (xhr, status, error) {
                            // Mostrar mensaje de error
                            $('#actualizarModal').modal('hide');
                            var alertHTML = '<div class="alert alert-danger alert-dismissible fade show" role="alert">' +
                                    'Error en la actualización: ' + error +
                                    '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>' +
                                    '</div>';
                            $('.container').eq(1).prepend(alertHTML);
                        },
                        complete: function () {
                            // Restaurar el botón
                            $('#btnActualizarUsuario').html('<i class="bi bi-check-circle"></i> Actualizar Usuario');
                            $('#btnActualizarUsuario').prop('disabled', false);
                        }
                    });
                });
                $('#actualizarModal').on('show.bs.modal', function (event) {
                    var button = $(event.relatedTarget);
                    var modal = $(this);
                    var usuarioId = button.data('id');
                    $(this).find('#usuarioIdActualizar').val(usuarioId);
                    var solicito_ve = button.data('solicito_ve');
                    var verificado = button.data('verificado');
                    var privilegio = button.data('privilegio');
                    var baneado = button.data('baneado');

                    if (solicito_ve === true) {
                        $('#usuarioSolicitud').prop('checked', true);
                    } else {
                        $('#usuarioSolicitud').prop('checked', false);
                    }

                    if (verificado === true) {
                        $('#usuarioVerificado').prop('checked', true);
                    } else {
                        $('#usuarioVerificado').prop('checked', false);
                    }

                    if (privilegio === true) {
                        $('#usuarioPrivilegio').prop('checked', true);
                    } else {
                        $('#usuarioPrivilegio').prop('checked', false);
                    }

                    if (baneado === true) {
                        $('#usuarioBaneado').prop('checked', true);
                    } else {
                        $('#usuarioBaneado').prop('checked', false);
                    }
                });

                $('#eliminarModal').on('show.bs.modal', function (event) {
                    var button = $(event.relatedTarget);
                    var usuarioId = button.data('id');
                    console.log("ID a eliminar: " + usuarioId);
                    $(this).find('#usuarioIdEliminar').val(usuarioId);
                });

            });
        </script>
    </body>

</html>


