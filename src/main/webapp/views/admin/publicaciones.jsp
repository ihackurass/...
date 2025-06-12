<%-- 
    Document   : publicaciones
    Created on : 1 may. 2025, 12:00:00
    Author     : Home
--%>


<%@page import="java.util.List"%>
<%@page import="pe.aquasocial.entity.Publicacion"%>
<%@page import="pe.aquasocial.entity.Usuario"%>
<%@page import="pe.aquasocial.util.FuncionesDB"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Administración de Publicaciones - Agua Bendita</title>
        <!-- Bootstrap CSS -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/assets/css/bootstrap.min.css">
        <!-- Bootstrap Icons -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <!-- DataTables CSS -->
        <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
        <!-- DataTables Responsive CSS -->
        <link rel="stylesheet" href="https://cdn.datatables.net/responsive/2.5.0/css/responsive.bootstrap5.min.css">
        <style>

            /* Estilos para un checkbox más flat y moderno */
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
                display: inline-flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto;
            }

            .btn-revisar-disabled {
                background-color: #080808;
                padding: 5px 10px;
                color: #dddbdb;
                border: none;
                border-radius: 5px;
                cursor: not-allowed;
            }

            #publicacionesTable thead th {
                text-align: center;
                vertical-align: middle;
            }

            #publicacionesTable tbody td {
                text-align: center;
                vertical-align: middle;
            }

            /* Excepción para el texto de la publicación (alineado a la izquierda) */
            #publicacionesTable tbody td:nth-child(4) {
                text-align: left;
            }
        </style>
    </head>

    <body>

        <!-- Navbar -->
        <jsp:include page="../components/adminNavbar.jsp" />


        <div class="container my-4">
            <h1 class="text-center mb-4">Administración de Publicaciones</h1>

            <% if (request.getSession().getAttribute("successMessage") != null) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <%= request.getSession().getAttribute("successMessage") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% request.getSession().removeAttribute("successMessage"); %>
            <% } %>

            <% if (request.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <%= request.getAttribute("errorMessage") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% } %>


            <div class="table-responsive">

                <table id="publicacionesTable" class="table table-striped table-bordered" style="width:100%">
                    <thead class="table-dark">
                        <tr>
                            <th>ID</th>
                            <th>ID Publicación</th>
                            <th>Autor</th>
                            <th>Texto</th>
                            <th>Revisar</th>
                            <th>Aprobado</th>
                            <th>Permite Donación</th>
                            <th>Fecha y Hora</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<Publicacion> publicaciones = (List<Publicacion>) request.getAttribute("publicaciones");
                            if (publicaciones != null) {
                                for (Publicacion publicacion : publicaciones) {
                                    // Verificar si es el usuario "eliminado"
                                    boolean esUsuarioEliminado = (publicacion.getIdUsuario() == 999);
                                
                                    // Obtener el nombre de usuario si está disponible
                                    String nombreUsuario = "@usuario";
                                    FuncionesDB funcionesDB = new FuncionesDB();
                                    if (esUsuarioEliminado || funcionesDB.getUsernameById(publicacion.getIdUsuario()).contains("usuario_eliminado")) {
                                        nombreUsuario = "<span class=\"text-danger\">@usuario_eliminado</span>";
                                    } else {
                                        Object usuariosAttr = request.getAttribute("usuarios");
                                        if (usuariosAttr != null && usuariosAttr instanceof List) {
                                            List<Usuario> usuarios = (List<Usuario>) usuariosAttr;
                                            for (Usuario usuario : usuarios) {
                                                if (usuario.getId() == publicacion.getIdUsuario()) {
                                                    nombreUsuario = "@" + usuario.getUsername();
                                                    break;
                                                }
                                            }
                                        }
                                    }
                        %>
                        <tr>
                            <td><%= publicacion.getIdUsuario() %></td>
                            <td><%= publicacion.getIdPublicacion() %></td>
                            <td><%= nombreUsuario %></td>
                            <td><%= publicacion.getTexto().length() > 50 ? publicacion.getTexto().substring(0, 50) + "..." : publicacion.getTexto() %></td>
                            <td>
                                <button class="btn-revisar" 
                                        data-bs-toggle="modal" 
                                        data-bs-target="#revisarModal"
                                        data-id="<%= publicacion.getIdPublicacion() %>"
                                        data-texto="<%= publicacion.getTexto() %>"
                                        data-imagen="<%= publicacion.getImagenUrl() != null ? publicacion.getImagenUrl() : "" %>"
                                        data-fecha="<%= publicacion.getFechaPublicacion() %>"
                                        data-aprobado="<%= publicacion.isEstaAprobado() %>"
                                        data-donacion="<%= publicacion.isPermiteDonacion() %>"
                                        title="Revisar">
                                    <i class="bi bi-eye-fill"></i>
                                </button>
                            </td>
                            <td>
                                <button class="<%= publicacion.isEstaAprobado() ? "btn-privilegio" : "btn-privilegio-no" %>">
                                    <%= publicacion.isEstaAprobado() ? "Sí" : "No" %>
                                </button>
                            </td>
                            <td><%= publicacion.isPermiteDonacion() ? "Sí" : "No" %></td>
                            <td><%= publicacion.getFechaPublicacion() %></td>
                            <td>
                                <% if (esUsuarioEliminado) { %>
                                <button class="btn btn-secondary btn-sm" title="Publicación de usuario eliminado" disabled>
                                    <i class="bi bi-person-x-fill"></i>
                                </button>
                                <button class="btn btn-danger btn-sm usuario-eliminado"
                                        data-bs-toggle="modal"
                                        data-bs-target="#eliminarModal"
                                        data-id="<%= publicacion.getIdPublicacion() %>"
                                        data-eliminado="true"
                                        title="Eliminar">
                                    <i class="bi bi-trash-fill"></i>
                                </button>
                                <% } else { %>
                                <button class="btn btn-warning btn-sm" title="Editar"
                                        data-bs-toggle="modal"
                                        data-bs-target="#actualizarModal"
                                        data-id="<%= publicacion.getIdPublicacion() %>"
                                        data-aprobado="<%= publicacion.isEstaAprobado() %>"
                                        data-donacion="<%= publicacion.isPermiteDonacion() %>"
                                        data-texto="<%= publicacion.getTexto() %>">
                                    <i class="bi bi-pencil-fill"></i>
                                </button>
                                <button class="btn btn-danger btn-sm"
                                        data-bs-toggle="modal"
                                        data-bs-target="#eliminarModal"
                                        data-id="<%= publicacion.getIdPublicacion() %>"
                                        data-eliminado="false"
                                        title="Eliminar">
                                    <i class="bi bi-trash-fill"></i>
                                </button>
                                <% } %>
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
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="actualizarModalLabel">Actualizar Publicación</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body text-center"">
                        <form action="PublicacionesServlet" method="post">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="publicacionId" id="publicacionIdActualizar">

                            <div class="mb-3">
                                <label for="textoPublicacion" class="form-label">Texto de la publicación</label>
                                <textarea class="form-control" id="textoPublicacion" name="texto" rows="4" required></textarea>
                            </div>

                            <div class="mb-3">
                                <label for="imagenUrl" class="form-label">URL de la imagen (opcional)</label>
                                <input type="text" class="form-control" id="imagenUrl" name="imagenUrl">
                            </div>

                            <div class="flat-checkbox">
                                <input type="checkbox" class="form-check-input" id="permiteDonacion" name="permiteDonacion">
                                <label class="form-check-label" for="permiteDonacion">Permite donación</label>
                            </div>

                            <div class="flat-checkbox">                           
                                <input type="checkbox" class="form-check-input" id="estaAprobado" name="estaAprobado">
                                <label class="form-check-label" for="estaAprobado">Aprobar publicación</label>
                            </div>

                        </form>
                    </div>
                    <div class="modal-footer d-flex justify-content-center">
                        <!-- Botón de cerrar -->
                        <button type="button" class="btn btn-secondary me-3" data-bs-dismiss="modal">
                            <i class="bi bi-x-circle"></i> Cerrar
                        </button>

                        <!-- Botón de actualizar -->
                        <button type="button" class="btn btn-warning ms-3" id="btnActualizarPublicacion">
                            <i class="bi bi-check-circle"></i> Actualizar
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
                        <h5 class="modal-title" id="eliminarModalLabel">Eliminar Publicación</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p>¿Estás seguro de que deseas eliminar esta publicación?</p>
                        <p id="mensajeUsuarioEliminado" class="text-danger d-none">
                            <i class="bi bi-exclamation-triangle-fill"></i> Esta publicación pertenece a un usuario que ya ha sido eliminado.
                        </p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="bi bi-x-circle"></i> Cancelar
                        </button>
                        <form action="PublicacionesServlet" method="post">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" id="publicacionIdEliminar" name="publicacionId">
                            <input type="hidden" id="esUsuarioEliminado" name="esUsuarioEliminado" value="false">
                            <button type="submit" class="btn btn-danger">
                                <i class="bi bi-trash-fill"></i> Eliminar
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal de Revisión -->
        <div class="modal fade" id="revisarModal" tabindex="-1" aria-labelledby="revisarModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="revisarModalLabel">Detalles de la Publicación</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body text-center"">
                        <h3><b>Contenido de la Publicación</b></h3>
                        <p id="textoCompleto"></p>

                        <div id="imagenContainer">
                            <h6><b>Imagen de la Publicación</b></h6>
                            <img id="imagenPublicacion" src="" alt="Imagen de la publicación" class="img-fluid mb-3">
                        </div>

                        <h6><b>Fecha de publicación</b></h6>
                        <p id="fechaPublicacion"></p>

                        <form action="PublicacionesServlet" method="post" id="aprobarForm">
                            <input type="hidden" name="action" value="aprobar">
                            <input type="hidden" name="publicacionId" id="publicacionIdAprobar">
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="bi bi-x-circle"></i> Cerrar
                        </button>
                        <button type="button" class="btn btn-danger" id="btnEliminarRevisar">
                            <i class="bi bi-trash-fill"></i> Eliminar
                        </button>
                        <button type="button" class="btn btn-primary" id="btnAprobarRevisar">
                            <i class="bi bi-check-circle-fill"></i> Aprobar
                        </button>
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
                // Inicializar DataTables
                $('#publicacionesTable').DataTable({
                    responsive: true,
                    language: {
                        url: '//cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json'
                    }
                });
                $('#btnActualizarPublicacion').click(function () {
                    $(this).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Actualizando...');
                    $(this).prop('disabled', true);
                    var publicacionId = $('#publicacionIdActualizar').val();
                    var texto = $('#textoPublicacion').val();
                    var imagenUrl = $('#imagenUrl').val();
                    var permiteDonacion = $('#permiteDonacion').is(':checked');
                    var estaAprobado = $('#estaAprobado').is(':checked');
                    $.ajax({
                        url: 'PublicacionesServlet',
                        type: 'POST',
                        data: {
                            action: 'update',
                            publicacionId: publicacionId,
                            texto: texto,
                            imagenUrl: imagenUrl,
                            permiteDonacion: permiteDonacion,
                            estaAprobado: estaAprobado
                        },
                        dataType: 'json',
                        success: function (response) {
                            $('#actualizarModal').modal('hide');
                            if (response.success) {
                                // Mostrar mensaje de éxito
                                var alertHTML = '<div class="alert alert-success alert-dismissible fade show" role="alert">' +
                                        response.message +
                                        '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>' +
                                        '</div>';
                                $('.container').eq(1).prepend(alertHTML);
                                var fila = $('button[data-id="' + publicacionId + '"]').closest('tr');
                                fila.find('td:eq(3)').text(texto.length > 50 ? texto.substring(0, 50) + '...' : texto);
                                fila.find('td:eq(5)').html('<button class="' + (estaAprobado ? 'btn-privilegio' : 'btn-privilegio-no') + '">' +
                                        (estaAprobado ? 'Sí' : 'No') + '</button>');
                                fila.find('td:eq(6)').text(permiteDonacion ? 'Sí' : 'No');
                            } else {
                                var alertHTML = '<div class="alert alert-danger alert-dismissible fade show" role="alert">' +
                                        'Error: ' + response.message +
                                        '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>' +
                                        '</div>';
                                $('.container').eq(1).prepend(alertHTML);
                            }
                        },
                        error: function (xhr, status, error) {
                            var alertHTML = '<div class="alert alert-danger alert-dismissible fade show" role="alert">' +
                                    'Error en la actualización: ' + error +
                                    '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>' +
                                    '</div>';
                            $('.container').eq(1).prepend(alertHTML);
                            $('#actualizarModal').modal('hide');
                        },
                        complete: function () {
                            // Restaurar el botón
                            $('#btnActualizarPublicacion').html('<i class="bi bi-check-circle"></i> Actualizar');
                            $('#btnActualizarPublicacion').prop('disabled', false);
                        }
                    });
                });
                // Evento para el modal de actualización
                $('#actualizarModal').on('show.bs.modal', function (event) {
                    var button = $(event.relatedTarget);
                    var modal = $(this);
                    var publicacionId = button.data('id');
                    var texto = button.data('texto');
                    var aprobado = button.data('aprobado');
                    var donacion = button.data('donacion');
                    if (aprobado == true)
                    {
                        $('#estaAprobado').prop('checked', true);
                    } else {
                        $('#estaAprobado').prop('checked', false);
                    }
                    if (donacion == true)
                    {
                        $('#permiteDonacion').prop('checked', true);
                    } else {
                        $('#permiteDonacion').prop('checked', false);
                    }
                    modal.find('#publicacionIdActualizar').val(publicacionId);
                    modal.find('#textoPublicacion').val(texto);
                });

                $('#eliminarModal').on('show.bs.modal', function (event) {
                    $('#revisarModal').modal('hide');
                    var button = $(event.relatedTarget);
                    var publicacionId = button.data('id');
                    // Obtener el valor de data-eliminado
                    var esUsuarioEliminado = button.data('eliminado') === true || button.data('eliminado') === "true";
                    // Configurar el modal según el tipo de usuario
                    $(this).find('#publicacionIdEliminar').val(publicacionId);
                    $(this).find('#esUsuarioEliminado').val(esUsuarioEliminado);
                    // Mostrar u ocultar mensaje especial para usuarios eliminados
                    if (esUsuarioEliminado) {
                        $(this).find('#mensajeUsuarioEliminado').removeClass('d-none');
                    } else {
                        $(this).find('#mensajeUsuarioEliminado').addClass('d-none');
                    }
                });
                // Evento para el modal de revisión
                $('#revisarModal').on('show.bs.modal', function (event) {
                    var button = $(event.relatedTarget);
                    var publicacionId = button.data('id');
                    var texto = button.data('texto');
                    var imagen = button.data('imagen');
                    var fecha = button.data('fecha');
                    var aprobado = button.data('aprobado');
                    $(this).find('#textoCompleto').text(texto);
                    $(this).find('#fechaPublicacion').text(fecha);
                    $(this).find('#publicacionIdAprobar').val(publicacionId);
                    // Mostrar u ocultar imagen según corresponda
                    if (imagen && imagen !== "") {
                        $(this).find('#imagenPublicacion').attr('src', "../"+imagen);
                        $(this).find('#imagenContainer').show();
                    } else {
                        $(this).find('#imagenContainer').hide();
                    }

                    if (aprobado == true)
                    {
                        $('#btnAprobarRevisar').attr('disabled', 'disabled');
                    } else {
                        $('#btnAprobarRevisar').removeAttr('disabled');
                    }
                    // Configurar botones de aprobar y eliminar
                    $('#btnAprobarRevisar').click(function () {
                        $('#aprobarForm').submit();
                    });
                    $('#btnEliminarRevisar').click(function () {
                        $('#publicacionIdEliminar').val(publicacionId);
                        $('#eliminarModal').modal('show');
                    });
                });
            });
        </script>
    </body>

</html>