package pe.aquasocial.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.mercadopago.MercadoPagoConfig;
import com.mercadopago.client.preference.PreferenceClient;
import com.mercadopago.client.preference.PreferenceRequest;
import com.mercadopago.client.preference.PreferenceItemRequest;
import com.mercadopago.client.preference.PreferenceBackUrlsRequest;
import com.mercadopago.client.preference.PreferencePaymentMethodsRequest;
import com.mercadopago.client.payment.PaymentClient;
import com.mercadopago.exceptions.MPApiException;
import com.mercadopago.resources.preference.Preference;
import com.mercadopago.resources.payment.Payment;

import pe.aquasocial.util.SessionUtil;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import pe.aquasocial.dao.IngresoDAO;
import pe.aquasocial.entity.Ingreso;

/**
 * DonationServlet - Maneja donaciones con Mercado Pago Checkout Pro Compatible
 * con el sistema Aqua Social
 */
@WebServlet("/DonationServlet")
public class DonationServlet extends HttpServlet {

    // ⚠️ CONFIGURA TUS CREDENCIALES AQUÍ
    private static final String MP_ACCESS_TOKEN = "APP_USR-8274247272126959-060722-1bb5a322e995a46b3bf61f08b85ca0b0-2485332684";
    private static final String MP_PUBLIC_KEY = "APP_USR-3cd5a230-fe50-4f29-8792-26f214f8f531";

    private static final String BASE_URL = "https://3871-181-233-26-51.ngrok-free.app/AQUA_SOCIAL";

    private static final long serialVersionUID = 1L;

    private IngresoDAO ingresoDAO;

    @Override
    public void init() throws ServletException {
        super.init();

        try {
            // Configurar Mercado Pago
            MercadoPagoConfig.setAccessToken(MP_ACCESS_TOKEN);

            // ✅ NUEVO: Inicializar DAO
            this.ingresoDAO = new IngresoDAO();

            System.out.println("✅ DonationServlet iniciado correctamente");
            System.out.println("🔧 Mercado Pago configurado con Checkout Pro");
            System.out.println("🗄️ IngresoDAO inicializado");
            System.out.println("🌐 Base URL: " + BASE_URL);

        } catch (Exception e) {
            System.err.println("❌ Error inicializando DonationServlet: " + e.getMessage());
            throw new ServletException("Error de configuración", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Configurar respuesta
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");

        String action = request.getParameter("action");

        System.out.println("📨 DonationServlet recibió acción: " + action);

        try {
            switch (action) {
                case "webhook":
                    handleWebhook(request, response);
                    break;
                case "create_preference":
                    createPaymentPreference(request, response);
                    break;
                default:
                    sendError(response, "Acción no válida: " + action, 400);
            }
        } catch (Exception e) {
            System.err.println("❌ Error en DonationServlet: " + e.getMessage());
            e.printStackTrace();
            sendError(response, "Error interno del servidor: " + e.getMessage(), 500);
        }
    }

    /**
     * Crear preferencia de pago para Checkout Pro
     */
    private void createPaymentPreference(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        System.out.println("💳 Creando preferencia de pago...");

        try {
            // Obtener y validar parámetros
            String amountStr = request.getParameter("amount");
            String publicationId = request.getParameter("publication_id");
            String creatorId = request.getParameter("creator_id");
            String donorName = request.getParameter("donor_name");
            String donorEmail = request.getParameter("donor_email");
            String donorMessage = request.getParameter("donor_message");

            System.out.println("📋 Datos recibidos:");
            System.out.println("   - Monto: " + amountStr);
            System.out.println("   - Creator ID: " + creatorId);
            System.out.println("   - Publication ID: " + publicationId);
            System.out.println("   - Donor: " + donorName + " (" + donorEmail + ")");
            
            
            // Validaciones básicas
            if (amountStr == null || creatorId == null || donorEmail == null || donorName == null) {
                sendError(response, "Parámetros requeridos faltantes (amount, creator_id, donor_email, donor_name)", 400);
                return;
            }

            BigDecimal amount;
            try {
                amount = new BigDecimal(amountStr);
            } catch (NumberFormatException e) {
                sendError(response, "Monto inválido: " + amountStr, 400);
                return;
            }

            // Validar rango de monto
            if (amount.compareTo(BigDecimal.ONE) < 0 || amount.compareTo(new BigDecimal("10000")) > 0) {
                sendError(response, "Monto debe estar entre S/ 1.00 y S/ 10,000.00", 400);
                return;
            }

            // Validar email básico
            if (!donorEmail.contains("@") || !donorEmail.contains(".")) {
                sendError(response, "Email inválido: " + donorEmail, 400);
                return;
            }

            // Obtener usuario donante actual de la sesión usando tu SessionUtil
            Integer currentUserId = SessionUtil.getUserId(request);

            if (currentUserId == null) {
                sendError(response, "No se pudo obtener el ID del usuario logueado", 401);
                return;
            }

            System.out.println("👤 Usuario donante ID: " + currentUserId);

            // Crear item de la preferencia
            String itemTitle = "💧 Donación - Aqua Social";
            String itemDescription = donorMessage != null && !donorMessage.trim().isEmpty()
                    ? donorMessage.trim()
                    : "Donación de " + donorName + " en Aqua Social";

            // Truncar descripción si es muy larga
            if (itemDescription.length() > 200) {
                itemDescription = itemDescription.substring(0, 197) + "...";
            }

            PreferenceItemRequest item = PreferenceItemRequest.builder()
                    .id("donation_" + publicationId + "_" + System.currentTimeMillis())
                    .title(itemTitle)
                    .description(itemDescription)
                    .pictureUrl(BASE_URL + "/assets/images/logo.jpg")
                    .categoryId("charity")
                    .quantity(1)
                    .currencyId("PEN") // Soles peruanos
                    .unitPrice(amount)
                    .build();

            List<PreferenceItemRequest> items = new ArrayList<>();
            items.add(item);

            // URLs de retorno
            PreferenceBackUrlsRequest backUrls = PreferenceBackUrlsRequest.builder()
                    .success(BASE_URL + "/DonationServlet?action=payment_success")
                    .pending(BASE_URL + "/DonationServlet?action=payment_pending")
                    .failure(BASE_URL + "/DonationServlet?action=payment_failure")
                    .build();

            // Configurar métodos de pago
            PreferencePaymentMethodsRequest paymentMethods = PreferencePaymentMethodsRequest.builder()
                    .installments(12) // Máximo 12 cuotas
                    .defaultInstallments(1) // 1 cuota por defecto
                    .build();

            // Metadata para tracking
            Map<String, Object> metadata = new HashMap<>();
            metadata.put("donor_user_id", currentUserId.toString());
            metadata.put("creator_user_id", creatorId);
            metadata.put("publication_id", publicationId != null ? publicationId : "direct");
            metadata.put("donor_name", donorName);
            metadata.put("donor_email", donorEmail.toLowerCase());
            metadata.put("donor_message", donorMessage);
            metadata.put("app_name", "aqua_social");
            metadata.put("donation_type", publicationId != null && !publicationId.isEmpty() ? "publication" : "direct");
            metadata.put("timestamp", System.currentTimeMillis());

            // Referencia externa única
            String externalReference = "AS_" + currentUserId + "_" + creatorId + "_" + System.currentTimeMillis();

            // Crear la preferencia
            PreferenceRequest preferenceRequest = PreferenceRequest.builder()
                    .items(items)
                    .backUrls(backUrls)
                    .paymentMethods(paymentMethods)
                    .autoReturn("approved")
                    .externalReference(externalReference)
                    .metadata(metadata)
                    .expires(true)
                    .expirationDateFrom(OffsetDateTime.now())
                    .expirationDateTo(OffsetDateTime.now().plusHours(24))
                    .build();

            // Debug: Mostrar datos antes de enviar
            System.out.println("🔍 DEBUGGING - Datos de la preferencia:");
            System.out.println("   - External Reference: " + externalReference);
            System.out.println("   - Item Title: " + itemTitle);
            System.out.println("   - Amount: " + amount);
            System.out.println("   - Success URL: " + BASE_URL + "/DonationServlet?action=payment_success");
            System.out.println("   - Metadata size: " + metadata.size());
            System.out.println("   - Access Token (últimos 4): ****" + MP_ACCESS_TOKEN.substring(MP_ACCESS_TOKEN.length() - 4));

            // Crear preferencia usando el cliente CON MANEJO DE ERRORES DETALLADO
            PreferenceClient client = new PreferenceClient();
            Preference preference;

            try {
                preference = client.create(preferenceRequest);
                System.out.println("✅ Preferencia creada exitosamente!");

            } catch (MPApiException apiEx) {
                // Error detallado de la API
                System.err.println("❌ ERROR DE API MERCADO PAGO:");
                System.err.println("   - Status Code: " + apiEx.getStatusCode());
                System.err.println("   - Message: " + apiEx.getMessage());

                // Intentar obtener más detalles del error
                if (apiEx.getApiResponse() != null) {
                    System.err.println("   - API Response: " + apiEx.getApiResponse().getContent());
                }

                // Verificar credenciales
                if (apiEx.getStatusCode() == 401) {
                    System.err.println("🔑 PROBLEMA DE AUTENTICACIÓN:");
                    System.err.println("   - Verifica tu ACCESS_TOKEN");
                    System.err.println("   - ¿Estás usando credenciales TEST o PROD?");
                    sendError(response, "Error de autenticación con Mercado Pago. Verifica tus credenciales.", 401);
                    return;
                } else if (apiEx.getStatusCode() == 400) {
                    System.err.println("📋 PROBLEMA CON LOS DATOS:");
                    System.err.println("   - Revisa los parámetros enviados");
                    System.err.println("   - URLs de retorno deben ser válidas");
                    sendError(response, "Datos inválidos para crear la preferencia: " + apiEx.getMessage(), 400);
                    return;
                } else {
                    sendError(response, "Error de Mercado Pago: " + apiEx.getMessage(), 500);
                    return;
                }

            } catch (Exception generalEx) {
                System.err.println("❌ ERROR GENERAL:");
                generalEx.printStackTrace();
                sendError(response, "Error inesperado: " + generalEx.getMessage(), 500);
                return;
            }

            // Log para debugging
            System.out.println("✅ Preferencia creada exitosamente:");
            System.out.println("   - ID: " + preference.getId());
            System.out.println("   - Init Point: " + preference.getInitPoint());
            System.out.println("   - Sandbox Init Point: " + preference.getSandboxInitPoint());
            System.out.println("   - External Reference: " + externalReference);

            // Respuesta exitosa
            JsonObject jsonResponse = new JsonObject();
            jsonResponse.addProperty("success", true);
            jsonResponse.addProperty("preference_id", preference.getId());
            jsonResponse.addProperty("init_point", preference.getInitPoint());
            jsonResponse.addProperty("sandbox_init_point", preference.getSandboxInitPoint());
            jsonResponse.addProperty("external_reference", externalReference);
            jsonResponse.addProperty("message", "Preferencia creada exitosamente");

            // Headers adicionales para el navegador
            response.setHeader("Cache-Control", "no-cache");
            response.setHeader("Pragma", "no-cache");

            PrintWriter out = response.getWriter();
            out.print(jsonResponse.toString());
            out.flush();

        } catch (Exception e) {
            System.err.println("❌ Error creando preferencia: " + e.getMessage());
            e.printStackTrace();
            sendError(response, "Error al crear preferencia: " + e.getMessage(), 500);
        }
    }

    /**
     * Manejar GET requests (webhooks y retornos)
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        System.out.println("📨 GET request con acción: " + action);

        try {
            switch (action) {
                case "payment_success":
                    handlePaymentReturn(request, response, "success");
                    break;
                case "payment_pending":
                    handlePaymentReturn(request, response, "pending");
                    break;
                case "payment_failure":
                    handlePaymentReturn(request, response, "failure");
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Acción no encontrada: " + action);
            }
        } catch (Exception e) {
            System.err.println("❌ Error en GET request: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error interno");
        }
    }

    /**
     * Manejar webhook de notificaciones de Mercado Pago
     */
    private void handleWebhook(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        System.out.println("📨 Webhook recibido de Mercado Pago");

        try {
            // Leer datos del webhook
            StringBuilder jsonBody = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                jsonBody.append(line);
            }

            String webhookData = jsonBody.toString();
            System.out.println("📋 Webhook data: " + webhookData);

            if (webhookData.isEmpty()) {
                System.out.println("⚠️ Webhook vacío, ignorando");
                response.setStatus(200);
                response.getWriter().write("OK");
                return;
            }

            // Parsear JSON del webhook
            JsonObject data = JsonParser.parseString(webhookData).getAsJsonObject();

            // Verificar que sea una notificación de pago
            if (!data.has("type") || !"payment".equals(data.get("type").getAsString())) {
                System.out.println("⚠️ Webhook no es de tipo payment, ignorando");
                response.setStatus(200);
                response.getWriter().write("OK");
                return;
            }

            // Obtener ID del pago desde el webhook
            if (!data.has("data") || !data.getAsJsonObject("data").has("id")) {
                System.err.println("❌ Webhook sin payment ID");
                response.setStatus(400);
                response.getWriter().write("ERROR: Missing payment ID");
                return;
            }

            Long paymentId = data.getAsJsonObject("data").get("id").getAsLong();
            System.out.println("💳 Procesando pago desde webhook - ID: " + paymentId);

            // Consultar el pago con reintentos (el webhook puede llegar antes que el pago esté disponible)
            Payment payment = getPaymentWithRetryForWebhook(paymentId, 3);

            if (payment == null) {
                System.err.println("❌ No se pudo obtener el pago después de reintentos: " + paymentId);
                response.setStatus(500);
                response.getWriter().write("ERROR: Payment not found after retries");
                return;
            }

            // VERIFICAR SI EL PAGO ES DE NUESTRA APLICACIÓN
            if (!isPaymentFromOurApp(payment)) {
                System.out.println("⚠️ Pago no es de nuestra aplicación, ignorando: " + paymentId);
                response.setStatus(200);
                response.getWriter().write("OK");
                return;
            }

            // Procesar según el estado del pago
            boolean processed = processPaymentFromWebhook(payment);

            if (processed) {
                System.out.println("✅ Pago procesado exitosamente desde webhook: " + paymentId);
                response.setStatus(200);
                response.getWriter().write("OK");
            } else {
                System.err.println("❌ Error procesando pago desde webhook: " + paymentId);
                response.setStatus(500);
                response.getWriter().write("ERROR: Processing failed");
            }

        } catch (Exception e) {
            System.err.println("❌ Error crítico en webhook: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(500);
            response.getWriter().write("ERROR: " + e.getMessage());
        }
    }

    private boolean processPaymentFromWebhook(Payment payment) {
        try {
            Long paymentId = payment.getId();
            String status = payment.getStatus();
            BigDecimal amount = payment.getTransactionAmount();
            String statusDetail = payment.getStatusDetail();

            System.out.println("📋 Procesando pago desde webhook:");
            System.out.println("   - ID: " + paymentId);
            System.out.println("   - Estado: " + status);
            System.out.println("   - Monto: " + amount);
            System.out.println("   - Detalle: " + statusDetail);
            System.out.println("   - External Ref: " + payment.getExternalReference());

            // Verificar si ya procesamos este pago antes (evitar duplicados)
            if (isPaymentAlreadyProcessed(paymentId.toString())) {
                System.out.println("⚠️ Pago ya procesado anteriormente: " + paymentId);
                return true; // No es error, simplemente ya lo procesamos
            }

            switch (status) {
                case "approved":
                    return processApprovedPaymentFromWebhook(payment);

                case "pending":
                    System.out.println("⏳ Pago pendiente desde webhook: " + paymentId);
                    // Opcional: Guardar en tabla de pagos pendientes
                    savePendingPaymentStatus(payment);
                    return true;

                case "rejected":
                    System.out.println("❌ Pago rechazado desde webhook: " + paymentId + " - " + statusDetail);
                    // Opcional: Notificar rechazo
                    saveRejectedPaymentStatus(payment);
                    return true;

                case "cancelled":
                    System.out.println("🚫 Pago cancelado desde webhook: " + paymentId);
                    return true;

                default:
                    System.out.println("❓ Estado desconocido desde webhook: " + status + " para pago " + paymentId);
                    return true; // No es error técnico
            }

        } catch (Exception e) {
            System.err.println("❌ Error procesando pago desde webhook: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    private boolean processApprovedPaymentFromWebhook(Payment payment) {
        try {
            System.out.println("✅ Procesando pago aprobado desde webhook usando DAO...");

            if (payment.getMetadata() == null) {
                System.err.println("❌ Pago aprobado sin metadata: " + payment.getId());
                return false;
            }

            Map<String, Object> metadata = payment.getMetadata();

            String donorId = (String) metadata.get("donor_user_id");
            String creatorId = (String) metadata.get("creator_user_id");
            String publicationId = (String) metadata.get("publication_id");
            String donorName = (String) metadata.get("donor_name");
            String donorEmail = (String) metadata.get("donor_email");
            String donorMessage = (String) metadata.get("donor_message");

            System.out.println("📋 Metadata del pago aprobado:");
            System.out.println("   - Donor ID: " + donorId);
            System.out.println("   - Creator ID: " + creatorId);
            System.out.println("   - Publication ID: " + publicationId);
            System.out.println("   - Donor Name: " + donorName);
            System.out.println("   - Donor Message: " + donorMessage);
            System.out.println("   - Amount: " + payment.getTransactionAmount());

            if (donorId == null || creatorId == null) {
                System.err.println("❌ Metadata incompleta: donorId=" + donorId + ", creatorId=" + creatorId);
                return false;
            }

            // ✅ PROCESAMIENTO MEJORADO DE publicationId
            Integer pubId = null;
            if (publicationId != null && !"direct".equals(publicationId) && !publicationId.isEmpty()) {
                try {
                    pubId = Integer.parseInt(publicationId);
                } catch (NumberFormatException e) {
                    System.out.println("⚠️ Publication ID no numérico, será donación directa: " + publicationId);
                }
            }

            // ✅ CREAR OBJETO INGRESO directamente (método más directo)
            Ingreso ingreso = new Ingreso();

            ingreso.setIdDonador(Integer.parseInt(donorId));
            ingreso.setIdCreador(Integer.parseInt(creatorId));

            if (pubId != null) {
                ingreso.setIdPublicacion(pubId);
            }

            ingreso.setCantidad(payment.getTransactionAmount().doubleValue());
            ingreso.setMetodoPago("Mercado Pago");
            ingreso.setReferenciaPago(payment.getId().toString());
            ingreso.setEstado("Completado");

            // Mensaje del donante
            if (donorMessage != null && !donorMessage.trim().isEmpty()) {
                ingreso.setMensaje(donorMessage.trim());
            }

            // ✅ USAR DAO directamente en lugar del método saveDonationToDatabase
            boolean guardado = ingresoDAO.crear(ingreso);

            if (guardado) {
                System.out.println("✅ Donación desde webhook guardada exitosamente:");
                System.out.println("   - ID Generado: " + ingreso.getIdIngreso());
                System.out.println("   - " + donorName + " (" + donorEmail + ")");
                System.out.println("   - Monto: " + ingreso.getCantidadFormateada());
                System.out.println("   - Referencia MP: " + payment.getId());
                System.out.println("   - Donor ID: " + donorId + " -> Creator ID: " + creatorId);

                if (donorMessage != null && !donorMessage.trim().isEmpty()) {
                    System.out.println("   - Mensaje: \"" + donorMessage + "\"");
                }

                if (pubId != null) {
                    System.out.println("   - Publication ID: " + pubId);
                } else {
                    System.out.println("   - Tipo: Donación directa");
                }

                return true;

            } else {
                System.err.println("❌ DAO no pudo guardar donación desde webhook");
                return false;
            }

        } catch (NumberFormatException e) {
            System.err.println("❌ Error parseando IDs desde webhook: " + e.getMessage());
            return false;
        } catch (Exception e) {
            System.err.println("❌ Error procesando pago aprobado desde webhook: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Verificar si un pago ya fue procesado (evitar duplicados)
     */
    private boolean isPaymentAlreadyProcessed(String paymentId) {
        try {
            // ✅ USAR DAO en lugar de SQL directo
            boolean existe = ingresoDAO.existePorReferenciaPago(paymentId);

            if (existe) {
                System.out.println("⚠️ Pago ya procesado anteriormente: " + paymentId);
            } else {
                System.out.println("✅ Pago nuevo, continuando procesamiento: " + paymentId);
            }

            return existe;

        } catch (Exception e) {
            System.err.println("❌ Error verificando pago duplicado con DAO: " + e.getMessage());
            e.printStackTrace();
            return false; // En caso de error, procesar (mejor duplicado que perdido)
        }
    }

    /**
     * Guardar estado de pago pendiente (opcional)
     */
    private void savePendingPaymentStatus(Payment payment) {
        // Opcional: Guardar en tabla de pagos pendientes para seguimiento
        System.out.println("⏳ Guardando pago pendiente para seguimiento: " + payment.getId());
    }

    /**
     * Guardar estado de pago rechazado (opcional)
     */
    private void saveRejectedPaymentStatus(Payment payment) {
        // Opcional: Guardar rechazo para estadísticas
        System.out.println("❌ Guardando pago rechazado para estadísticas: " + payment.getId());
    }

    /**
     * Simplificar el manejo de retorno para que dependa del webhook
     */
    private void handlePaymentReturn(HttpServletRequest request, HttpServletResponse response, String status)
            throws IOException, ServletException {

        String paymentId = request.getParameter("payment_id");
        String preferenceId = request.getParameter("preference_id");

        System.out.println("🔄 Retorno de Mercado Pago:");
        System.out.println("   - Estado: " + status);
        System.out.println("   - Payment ID: " + paymentId);
        System.out.println("   - Preference ID: " + preferenceId);

        // Obtener sesión
        HttpSession session = request.getSession();

        String message = "";
        String messageType = "";

        switch (status) {
            case "success":
                message = "Tu donacion se esta procesando! Te notificaremos por email cuando se confirme. Gracias por tu generosidad";
                messageType = "success";
                break;
            case "pending":
                message = "Tu donacion esta siendo procesada. Te notificaremos por email cuando se confirme.";
                messageType = "warning";
                break;
            case "failure":
                message = "No se pudo procesar tu donacion. Puedes intentar nuevamente o usar otro metodo de pago.";
                messageType = "error";
                break;
            default:
                message = "Estado de pago desconocido. Por favor verifica tu email o contacta al soporte.";
                messageType = "warning";
        }

        // GUARDAR EN SESIÓN
        session.setAttribute("paymentMessageType", messageType);
        session.setAttribute("paymentMessage", message);

        // Datos adicionales opcionales
        if (paymentId != null) {
            session.setAttribute("paymentId", paymentId);
        }
        if (preferenceId != null) {
            session.setAttribute("preferenceId", preferenceId);
        }

        System.out.println("✅ Mensaje guardado en sesión:");
        System.out.println("   - Tipo: " + messageType);
        System.out.println("   - Mensaje: " + message);

        response.sendRedirect(BASE_URL + "/HomeServlet");
    }

    private boolean isPaymentFromOurApp(Payment payment) {
        try {
            // Verificar por metadata
            if (payment.getMetadata() != null) {
                Object appName = payment.getMetadata().get("app_name");
                if (appName != null && "aqua_social".equals(appName.toString())) {
                    System.out.println("✅ Pago verificado por metadata: app_name = aqua_social");
                    return true;
                }
            }

            // Verificar por external_reference
            String externalRef = payment.getExternalReference();
            if (externalRef != null && externalRef.startsWith("AS_")) {
                System.out.println("✅ Pago verificado por external_reference: " + externalRef);
                return true;
            }

            // Verificar por descripción
            String description = payment.getDescription();
            if (description != null && description.contains("Aqua Social")) {
                System.out.println("✅ Pago verificado por descripción: " + description);
                return true;
            }

            System.out.println("⚠️ Pago no pertenece a nuestra app:");
            System.out.println("   - External Reference: " + externalRef);
            System.out.println("   - Description: " + description);
            System.out.println("   - Metadata: " + payment.getMetadata());

            return false;

        } catch (Exception e) {
            System.err.println("❌ Error verificando origen del pago: " + e.getMessage());
            return false;
        }
    }

    private Payment getPaymentWithRetryForWebhook(Long paymentId, int maxRetries) {
        PaymentClient paymentClient = new PaymentClient();

        for (int attempt = 1; attempt <= maxRetries; attempt++) {
            try {
                System.out.println("🔍 Webhook - Intento " + attempt + "/" + maxRetries + " consultando pago: " + paymentId);

                Payment payment = paymentClient.get(paymentId);
                System.out.println("✅ Pago encontrado desde webhook en intento " + attempt);
                return payment;

            } catch (MPApiException apiEx) {
                System.err.println("❌ Error API en intento " + attempt + ": " + apiEx.getStatusCode() + " - " + apiEx.getMessage());

                if (apiEx.getStatusCode() == 404 && attempt < maxRetries) {
                    // Pago aún no disponible, esperar más tiempo
                    System.out.println("⏳ Pago no encontrado, esperando " + (attempt * 3) + " segundos...");
                    try {
                        Thread.sleep(attempt * 3000); // 3, 6, 9 segundos
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                        break;
                    }
                } else if (attempt == maxRetries) {
                    // Último intento falló
                    System.err.println("❌ Pago no encontrado después de " + maxRetries + " intentos");
                    if (apiEx.getApiResponse() != null) {
                        System.err.println("   - Response: " + apiEx.getApiResponse().getContent());
                    }
                    return null;
                }
            } catch (Exception e) {
                System.err.println("❌ Error general en intento " + attempt + ": " + e.getMessage());
                if (attempt == maxRetries) {
                    return null;
                }

                try {
                    Thread.sleep(2000); // Esperar 2 segundos
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    break;
                }
            }
        }

        return null;
    }

    /**
     * Enviar error como JSON
     */
    private void sendError(HttpServletResponse response, String message, int statusCode) throws IOException {
        JsonObject jsonResponse = new JsonObject();
        jsonResponse.addProperty("success", false);
        jsonResponse.addProperty("error", message);
        jsonResponse.addProperty("timestamp", System.currentTimeMillis());

        response.setStatus(statusCode);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        out.print(jsonResponse.toString());
        out.flush();

        System.err.println("❌ Error enviado (" + statusCode + "): " + message);
    }
}
