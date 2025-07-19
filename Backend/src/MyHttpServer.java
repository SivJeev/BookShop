import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;
import java.io.*;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.*;

public class MyHttpServer {
   
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("MySQL JDBC Driver Registered");
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL JDBC Driver not found");
            e.printStackTrace();
            System.exit(1);
        }
    }

    public static void main(String[] args) throws IOException {
        int port = 8080;
        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
        
        server.createContext("/login", new LoginHandler());
        server.setExecutor(null);
        server.start();
        System.out.println("Server started on port " + port);
    }

    static class LoginHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            
            if ("OPTIONS".equals(exchange.getRequestMethod())) {
                handleOptionsRequest(exchange);
                return;
            }

            // Set CORS headers for all responses
            exchange.getResponseHeaders().add("Access-Control-Allow-Origin", "*");
            exchange.getResponseHeaders().add("Access-Control-Allow-Methods", "POST, OPTIONS");
            exchange.getResponseHeaders().add("Access-Control-Allow-Headers", "Content-Type");

            if ("POST".equals(exchange.getRequestMethod())) {
                String requestBody = new String(exchange.getRequestBody().readAllBytes(), StandardCharsets.UTF_8);

                try {
                  
                    Map<String, String> params = parseJson(requestBody);
                    String username = params.get("username");
                    String password = params.get("password");

                    boolean isAuthenticated = authenticateUser(username, password);

                    
                    String response = String.format("{\"success\":%b,\"message\":\"%s\"}",
                            isAuthenticated,
                            isAuthenticated ? "Login successful" : "Invalid credentials");

                    exchange.getResponseHeaders().set("Content-Type", "application/json");
                    exchange.sendResponseHeaders(200, response.length());
                    OutputStream os = exchange.getResponseBody();
                    os.write(response.getBytes());
                    os.close();
                } catch (Exception e) {
                    e.printStackTrace();
                    String errorResponse = "{\"success\":false,\"message\":\"Server error\"}";
                    exchange.sendResponseHeaders(500, errorResponse.length());
                    OutputStream os = exchange.getResponseBody();
                    os.write(errorResponse.getBytes());
                    os.close();
                }
            } else {
                exchange.sendResponseHeaders(405, -1);
            }
        }

        private void handleOptionsRequest(HttpExchange exchange) throws IOException {
            exchange.getResponseHeaders().add("Access-Control-Allow-Origin", "*");
            exchange.getResponseHeaders().add("Access-Control-Allow-Methods", "POST, OPTIONS");
            exchange.getResponseHeaders().add("Access-Control-Allow-Headers", "Content-Type");
            exchange.sendResponseHeaders(204, -1);
        }

        private Map<String, String> parseJson(String json) {
            Map<String, String> result = new HashMap<>();
            json = json.replaceAll("[{}\"]", "");
            String[] pairs = json.split(",");
            for (String pair : pairs) {
                String[] kv = pair.split(":");
                result.put(kv[0].trim(), kv[1].trim());
            }
            return result;
        }

        private boolean authenticateUser(String username, String password) {
            String url = "jdbc:mysql://localhost:3306/bookshop";
            String dbUser = "root";
            String dbPassword = "";

            try (Connection conn = DriverManager.getConnection(url, dbUser, dbPassword)) {
                System.out.println("Connected to database successfully");
                
                String sql = "SELECT password FROM users WHERE username = ?";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setString(1, username);
                    ResultSet rs = stmt.executeQuery();

                    if (rs.next()) {
                        dbPassword = rs.getString("password");
                        System.out.println("Comparing passwords");
                        return password.equals(dbPassword);
                    }
                }
            } catch (SQLException e) {
                System.err.println("Database connection error:");
                e.printStackTrace();
            }
            return false;
        }
    }
}