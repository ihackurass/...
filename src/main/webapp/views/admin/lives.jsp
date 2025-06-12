<%-- 
    Document   : lives
    Created on : 1 may. 2025, 11:56:17
    Author     : Rodrigo
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Administración de Lives - Agua Bendita</title>
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/assets/css/bootstrap.min.css">
    <!-- DataTables CSS -->
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
    <style>
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
    </style>
</head>

<body>

           <!-- Navbar -->
        <jsp:include page="../components/adminNavbar.jsp" />
    
    <div class="container my-4">
        <h1 class="text-center mb-4">Administración de Lives</h1>

        <!-- Botones para Actualizar y Eliminar -->
        <div class="mb-3 text-end">
            <button class="btn btn-warning" data-bs-toggle="modal" data-bs-target="#actualizarModal">Actualizar Live</button>
            <button class="btn btn-danger" data-bs-toggle="modal" data-bs-target="#eliminarModal">Eliminar Live</button>
        </div>
        <div class="modal fade" id="eliminarModal" tabindex="-1" aria-labelledby="eliminarModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="eliminarModalLabel">Eliminar Live</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p>¿Estás seguro de que deseas eliminar esta Live?</p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                        <button type="button" class="btn btn-danger">Eliminar</button>
                    </div>
                </div>
            </div>
        </div>
        <div class="table-responsive">
            <table id="livesTable" class="table table-striped table-bordered">
                <thead>
                    <tr>
                        <th><input type="checkbox"></th>
                        <th>ID</th>
                        <th>Nombre de usuario</th>
                        <th>Estado</th>
                        <th>Texto</th>
                        <th>Fecha y Hora</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><input type="checkbox"></td>
                        <td>4578</td>
                        <td>@juancito12</td>
                        <td>Eliminado</td>
                        <td>Heyyy...</td>
                        <td>2024-11-11 00:28:21</td>
                    </tr>
                    <tr>
                        <td><input type="checkbox"></td>
                        <td>4578</td>
                        <td>@juancito12</td>
                        <td>Terminado</td>
                        <td>Heyyy...</td>
                        <td>2024-11-11 00:28:21</td>
                    </tr>
                    <tr>
                        <td><input type="checkbox"></td>
                        <td>4578</td>
                        <td>@juancito12</td>
                        <td>En vivo</td>
                        <td>Live de prueba</td>
                        <td>2024-11-12 01:30:00</td>
                    </tr>
                    <tr>
                        <td><input type="checkbox"></td>
                        <td>4578</td>
                        <td>@juancito12</td>
                        <td>En espera</td>
                        <td>Conectando...</td>
                        <td>2024-11-12 01:35:00</td>
                    </tr>
                    <tr>
                        <td><input type="checkbox"></td>
                        <td>4578</td>
                        <td>@juancito12</td>
                        <td>Cancelado</td>
                        <td>Problemas tecnicos</td>
                        <td>2024-11-12 01:40:00</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Modal de Actualización -->
    <div class="modal fade" id="actualizarModal" tabindex="-1" aria-labelledby="actualizarModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="actualizarModalLabel">Actualizar Live</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form>
                        <div class="mb-3">
                            <label for="descripcion" class="form-label">Actualizar Descripción</label>
                            <input type="text" class="form-control" id="descripcion" placeholder="Nueva descripción...">
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                    <button type="button" class="btn btn-primary">Actualizar</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal de Eliminación -->
    <div class="modal fade" id="eliminarModal" tabindex="-1" aria-labelledby="eliminarModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="eliminarModalLabel">Eliminar Live</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p>¿Estás seguro de que deseas eliminar esta Live?</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="button" class="btn btn-danger">Eliminar</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal de Revisión -->
    <div class="modal fade" id="revisarModal" tabindex="-1" aria-labelledby="revisarModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="revisarModalLabel">Detalles de la Live</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <h3><b>Descripción de la Live</b></h3>
                    <p>Mira mi nueva Idea para ayudar a los peruanos. Ingresa a este link: sitiomalicioso.com</p>

                    <h6><b>Foto de la Live</b></h6>
                    <img src="../assets/images/virus.jpg" alt="Virus" width="100" height="100">
                    <h6><b>Fecha de Live</b></h6>
                    <p>11/11/2023 15:34</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                    <button type="button" class="btn btn-danger">Eliminar</button>
                    <button type="button" class="btn btn-primary">Permitir</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- DataTables JS -->
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
    <script>
        // Inicializar DataTables
        $(document).ready(function () {
            $('#publicacionesTable').DataTable();
        });
    </script>
</body>

</html>
