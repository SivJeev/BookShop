package Controllers;
import com.sun.net.httpserver.HttpExchange;
import Services.AuthService;
import java.io.*;
import java.util.Map;
import java.util.HashMap;
import java.util.logging.Logger;
import java.util.logging.Level;

public class LoginController {
    private final AuthService authService = new AuthService();
    private static final Logger logger = Logger.getLogger(LoginController.class.getName());

    public void handleLogin(HttpExchange exchange) throws IOException {
        String method = exchange.getRequestMethod();

        // Handle CORS preflight
        if ("OPTIONS".equals(method)) {
            handleOptionsRequest(exchange);
            return;
        }

        if (!"POST".equals(method)) {
            sendErrorResponse(exchange, 405, "Method not allowed");
            return;
        }

        try {
            String requestBody = readRequestBody(exchange);

            // Validate request body
            if (requestBody == null || requestBody.trim().isEmpty()) {
                sendErrorResponse(exchange, 400, "Request body is required");
                return;
            }

            Map<String, String> params = parseJson(requestBody);

            // Validate required parameters
            String username = params.get("username");
            String password = params.get("password");

            if (username == null || username.trim().isEmpty() ||
                    password == null || password.trim().isEmpty()) {
                sendErrorResponse(exchange, 400, "Username and password are required");
                return;
            }

            // Sanitize input
            username = sanitizeInput(username);

            boolean isAuthenticated = authService.login(username, password);

            if (isAuthenticated) {
                sendSuccessResponse(exchange, "Login successful");
                logger.info("Successful login for user: " + username);
            } else {
                sendErrorResponse(exchange, 401, "Invalid credentials");
                logger.warning("Failed login attempt for user: " + username);
            }

        } catch (JsonParseException e) {
            logger.log(Level.WARNING, "Invalid JSON in request", e);
            sendErrorResponse(exchange, 400, "Invalid JSON format");
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Unexpected error during login", e);
            sendErrorResponse(exchange, 500, "Internal server error");
        }
    }

    private void handleOptionsRequest(HttpExchange exchange) throws IOException {
        setCorsHeaders(exchange);
        exchange.sendResponseHeaders(200, -1);
    }

    private String readRequestBody(HttpExchange exchange) throws IOException {
        try (InputStream is = exchange.getRequestBody();
             BufferedReader reader = new BufferedReader(new InputStreamReader(is))) {
            StringBuilder body = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                body.append(line);
            }
            return body.toString();
        }
    }

    private void sendSuccessResponse(HttpExchange exchange, String message) throws IOException {
        String response = String.format("{\"success\":true,\"message\":\"%s\"}", message);
        setCorsHeaders(exchange);
        exchange.getResponseHeaders().set("Content-Type", "application/json");
        exchange.sendResponseHeaders(200, response.length());
        try (OutputStream os = exchange.getResponseBody()) {
            os.write(response.getBytes());
        }
    }

    private void sendErrorResponse(HttpExchange exchange, int status, String message) throws IOException {
        String response = String.format("{\"success\":false,\"error\":\"%s\"}", message);
        setCorsHeaders(exchange);
        exchange.getResponseHeaders().set("Content-Type", "application/json");
        exchange.sendResponseHeaders(status, response.length());
        try (OutputStream os = exchange.getResponseBody()) {
            os.write(response.getBytes());
        }
    }

    private void setCorsHeaders(HttpExchange exchange) {
        // More restrictive CORS - replace with your actual domain in production
        exchange.getResponseHeaders().add("Access-Control-Allow-Origin", "http://localhost:3000");
        exchange.getResponseHeaders().add("Access-Control-Allow-Methods", "POST, OPTIONS");
        exchange.getResponseHeaders().add("Access-Control-Allow-Headers", "Content-Type, Authorization");
        exchange.getResponseHeaders().add("Access-Control-Max-Age", "3600");
    }

    private String sanitizeInput(String input) {
        if (input == null) return null;
        // Basic sanitization - remove potentially dangerous characters
        return input.replaceAll("[<>\"'&]", "").trim();
    }

    // Simple JSON parser implementation (for basic use cases)
    // For production, consider using a proper JSON library like Jackson or Gson
    private Map<String, String> parseJson(String json) throws JsonParseException {
        Map<String, String> result = new HashMap<>();

        if (json == null || json.trim().isEmpty()) {
            throw new JsonParseException("Empty JSON string");
        }

        json = json.trim();
        if (!json.startsWith("{") || !json.endsWith("}")) {
            throw new JsonParseException("Invalid JSON format");
        }

        // Remove curly braces
        json = json.substring(1, json.length() - 1);

        // Split by comma (simple approach - doesn't handle nested objects)
        String[] pairs = json.split(",(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)");

        for (String pair : pairs) {
            String[] keyValue = pair.split(":", 2);
            if (keyValue.length == 2) {
                String key = keyValue[0].trim().replaceAll("\"", "");
                String value = keyValue[1].trim().replaceAll("\"", "");
                result.put(key, value);
            }
        }

        return result;
    }

    // Custom exception for JSON parsing errors
    private static class JsonParseException extends Exception {
        public JsonParseException(String message) {
            super(message);
        }
    }
}
