<%@page import="java.util.List"%>
<%@page import="pe.aquasocial.entity.Ingreso"%>
<%@page import="pe.aquasocial.entity.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Administración de Ingresos - Agua Bendita</title>
        <!-- Bootstrap CSS -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/assets/css/bootstrap.min.css">
        <!-- Bootstrap Icons -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <!-- DataTables CSS -->
        <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
        <!-- DataTables Responsive CSS -->
        <link rel="stylesheet" href="https://cdn.datatables.net/responsive/2.5.0/css/responsive.bootstrap5.min.css">

        <style>
            .btn-estado-completado {
                background-color: #28a745;
                color: #fff;
                border: none;
                border-radius: 5px;
                padding: 5px 10px;
                cursor: pointer;
            }

            .btn-estado-pendiente {
                background-color: #ffc107;
                color: #000;
                border: none;
                border-radius: 5px;
                padding: 5px 10px;
                cursor: pointer;
            }

            .btn-estado-cancelado {
                background-color: #dc3545;
                color: #fff;
                border: none;
                border-radius: 5px;
                padding: 5px 10px;
                cursor: pointer;
            }

            /* Estilos para centrar el contenido de la tabla */
            #ingresosTable thead th {
                text-align: center;
                vertical-align: middle;
            }

            #ingresosTable tbody td {
                text-align: center;
                vertical-align: middle;
            }
        </style>
    </head>

    <body>
        <!-- Navbar -->
        <jsp:include page="../components/adminNavbar.jsp" />


        <div class="container my-4">
            <h1 class="text-center mb-4">Administración de Ingresos</h1>

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

            <!-- Botón para generar reporte -->
            <div class="text-end mb-3">
                <a href="IngresosServlet?action=generarReporte" class="btn btn-success">
                    <i class="bi bi-file-earmark-excel"></i> Generar Reporte
                </a>
            </div>

            <div class="table-responsive">
                <table id="ingresosTable" class="table table-striped table-bordered dt-responsive nowrap" style="width:100%">
                    <thead class="table-dark">
                        <tr>
                            <th>ID</th>
                            <th>Donador</th>
                            <th>Creador</th>
                            <th>Publicación</th>
                            <th>Cantidad</th>
                            <th>Fecha y Hora</th>
                            <th>Estado</th>
                            <th>Método de Pago</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<Ingreso> ingresos = (List<Ingreso>) request.getAttribute("ingresos");
                            if (ingresos != null) {
                                for (Ingreso ingreso : ingresos) {
                        %>
                        <tr>
                            <td><%= ingreso.getIdIngreso() %></td>
                            <td><%= ingreso.getIdDonador() %></td>
                            <td><%= ingreso.getIdCreador() %></td>
                            <td><%= ingreso.getIdPublicacion() != 0 ? ingreso.getIdPublicacion() : "N/A" %></td>
                            <td><%= ingreso.getCantidad() %></td>
                            <td><%= ingreso.getFechaHora() %></td>
                            <td>
                                <button class="<%= ingreso.getEstado().equals("Completado") ? "btn-estado-completado" : 
                                                  ingreso.getEstado().equals("Pendiente") ? "btn-estado-pendiente" : 
                                                  "btn-estado-cancelado" %>">
                                    <%= ingreso.getEstado() %>
                                </button>
                            </td>
                            <td><%= ingreso.getMetodoPago() %></td>
                            <td>
                                <button class="btn btn-warning btn-sm" title="Actualizar Estado"
                                        data-bs-toggle="modal"
                                        data-bs-target="#actualizarEstadoModal"
                                        data-id="<%= ingreso.getIdIngreso() %>"
                                        data-estado="<%= ingreso.getEstado() %>">
                                    <i class="bi bi-pencil-fill"></i>
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

        <!-- Modal de Actualización de Estado -->
        <div class="modal fade" id="actualizarEstadoModal" tabindex="-1" aria-labelledby="actualizarEstadoModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="actualizarEstadoModalLabel">Actualizar Estado del Ingreso</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form id="formActualizarEstado">
                            <input type="hidden" id="ingresoIdActualizar">

                            <div class="mb-3">
                                <label for="estadoIngreso" class="form-label">Estado</label>
                                <select class="form-select" id="estadoIngreso" name="estado">
                                    <option value="Completado">Completado</option>
                                    <option value="Pendiente">Pendiente</option>
                                    <option value="Cancelado">Cancelado</option>
                                </select>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer d-flex justify-content-center">
                        <button type="button" class="btn btn-secondary me-3" data-bs-dismiss="modal">
                            <i class="bi bi-x-circle"></i> Cerrar
                        </button>
                        <button type="button" class="btn btn-warning ms-3" id="btnActualizarEstado">
                            <i class="bi bi-check-circle"></i> Actualizar Estado
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
                $('#ingresosTable').DataTable({
                    responsive: true,
                    language: {
                        url: '//cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json'
                    },
                    columnDefs: [
                        // Responsividad para columnas específicas
                        {responsivePriority: 1, targets: 0}, // ID
                        {responsivePriority: 2, targets: 6}, // Estado
                        {responsivePriority: 3, targets: 8}, // Acciones
                        {responsivePriority: 4, targets: 4}, // Cantidad
                        {responsivePriority: 10, targets: 3} // Publicación
                    ]
                });

                // Evento para el modal de actualización de estado
                $('#actualizarEstadoModal').on('show.bs.modal', function (event) {
                    var button = $(event.relatedTarget);
                    var ingresoId = button.data('id');
                    var estado = button.data('estado');

                    var modal = $(this);
                    modal.find('#ingresoIdActualizar').val(ingresoId);
                    modal.find('#estadoIngreso').val(estado);
                });

                // Manejar el botón de actualizar estado
                $('#btnActualizarEstado').click(function () {
                    var ingresoId = $('#ingresoIdActualizar').val();
                    var nuevoEstado = $('#estadoIngreso').val();

                    // Mostrar indicador de carga
                    $(this).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Actualizando...');
                    $(this).prop('disabled', true);

                    // Enviar la solicitud AJAX
                    $.ajax({
                        url: 'IngresosServlet',
                        type: 'POST',
                        data: {
                            action: 'updateEstado',
                            ingresoId: ingresoId,
                            estado: nuevoEstado
                        },
                        dataType: 'json',
                        success: function (response) {
                            // Ocultar el modal
                            $('#actualizarEstadoModal').modal('hide');

                            if (response.success) {
                                // Mostrar mensaje de éxito
                                var alertHTML = '<div class="alert alert-success alert-dismissible fade show" role="alert">' +
                                        response.message +
                                        '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>' +
                                        '</div>';
                                $('.container').eq(1).prepend(alertHTML);

                                // Recargar la página después de un breve retraso
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
                            var alertHTML = '<div class="alert alert-danger alert-dismissible fade show" role="alert">' +
                                    'Error en la actualización: ' + error +
                                    '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>' +
                                    '</div>';
                            $('.container').eq(1).prepend(alertHTML);
                            $('#actualizarEstadoModal').modal('hide');
                        },
                        complete: function () {
                            // Restaurar el botón
                            $('#btnActualizarEstado').html('<i class="bi bi-check-circle"></i> Actualizar Estado');
                            $('#btnActualizarEstado').prop('disabled', false);
                        }
                    });
                });
            });
        </script>
    </body>

</html>