<%-- 
    Document   : notificaciones
    Created on : 1 may. 2025, 12:55:24
    Author     : Rodrigo
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notificaciones</title>
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
    .main-content {
        width: 800px;
        background-color: #ffffff;
        padding: 20px;
        border-radius: 10px;
        box-shadow: 2px 15px 50px rgba(0, 0, 0, 0.1);
    }

    .notification-header {
        font-size: 20px;
        color: #333;
        font-weight: bold;
        margin-bottom: 25px;
    }

    /* Tabs */
    .tabs {
        display: flex;
        justify-content: space-around;
        margin-bottom: 20px;
        border-bottom: 2px solid #ccc;
        padding-bottom: 10px;
    }

    .tab {
        text-align: center;
        cursor: pointer;
        font-weight: bold;
        color: #333;
        position: relative;
    }

    .tab.active {
        color: #0099ff;
    }

    .tab .badge {
        position: absolute;
        top: -8px;
        right: -8px;
        background-color: #ff0000;
        color: white;
        padding: 2px 5px;
        border-radius: 50%;
        font-size: 12px;
    }

    .notification-list {
        max-height: 400px;
        overflow-y: auto;
        padding: 10px 0;
    }

    .notification-item {
        display: flex;
        align-items: flex-start;
        padding: 10px 0;
        border-bottom: 1px solid #ddd;
    }

    .notification-item img {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        margin-right: 10px;
    }

    .notification-item p {
        color: #333;
        font-size: 14px;
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

    .container-ads {
      width: 300px;
      background-color: #ffffff;
      color: #333;
      border-radius: 10px;
      padding: 15px;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 20px;
      box-shadow: 0 15px 50px rgba(0, 0, 0, 0.3);
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
                        <div class="notification-header">Notificaciones</div>
    
                        <!-- Tabs -->
                        <div class="tabs">
                            <div class="tab active"><i class="fas fa-list"></i> Todo</div>
                            <div class="tab"><i class="fas fa-users"></i> Mensajes</div>
                            <div class="tab"><i class="fas fa-heart"></i> Me Gustas</div>
                        </div>
    
                        <!-- Notification List -->
                        <div class="notification-list">
                            <div class="notification-item">
                                <img src="assets/images/campana.jpg" alt="Avatar">
                                <p>Nuevo punto de abastecimiento de agua disponible en [Ubicación]. Visítalo y asegura
                                    tu suministro de agua potable.</p>
                            </div>
                            <div class="notification-item">
                                <img src="assets/images/campana.jpg" alt="Avatar">
                                <p>¡Aviso importante! El punto de abastecimiento en [Ubicación] presenta baja
                                    disponibilidad de agua. Por favor, planea tu visita con anticipación.</p>
                            </div>
                            <div class="notification-item">
                                <img src="assets/images/campana.jpg" alt="Avatar">
                                <p>Mantenimiento programado en el punto de abastecimiento en [Ubicación] el [Fecha y
                                    hora]. Estará fuera de servicio temporalmente.</p>
                            </div>
                            <div class="notification-item">
                                <img src="assets/images/campana.jpg" alt="Avatar">
                                <p>Actualización de calidad de agua: El punto de abastecimiento en [Ubicación] ha sido
                                    evaluado y cumple con los estándares de calidad. ¡Agua segura para tu consumo!</p>
                            </div>
                            <div class="notification-item">
                                <img src="assets/images/campana.jpg" alt="Avatar">
                                <p>Recuerda que el punto de abastecimiento en [Ubicación] opera de [Hora de apertura] a
                                    [Hora de cierre]. ¡Planifica tu recolección!</p>
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