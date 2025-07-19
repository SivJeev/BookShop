// Main Server Class - HttpServer.java
package com.bookshop.server;

import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;
import com.bookshop.controller.AuthController;
import com.bookshop.database.DatabaseInitializer;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.util.concurrent.Executors;

public class HttpServer {
    private HttpServer server;
    private static final int PORT = 8080;
    
    public static void main(String[] args) {
        new HttpServer().start();
    }
    
    public void start() {
        try {
            // Initialize database
            DatabaseInitializer.initialize();
            
            // Create HTTP server
            server = HttpServer.create(new InetSocketAddress(PORT), 0);
            
            // Set up routes
            setupRoutes();
            
            // Set executor
            server.setExecutor(Executors.newFixedThreadPool(10));
            
            // Start server
            server.start();
            System.out.println("Bookshop Server started on port " + PORT);
            
        } catch (IOException e) {
            System.err.println("Failed to start server: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private void setupRoutes() {
        // Auth routes
        server.createContext("/api/auth/login", new AuthController());
        server.createContext("/api/auth/logout", new AuthController());
        
        // CORS preflight handler
        server.createContext("/api/", new CorsHandler());
    }
    
    public void stop() {
        if (server != null) {
            server.stop(0);
        }
    }
}

// CORS Handler - CorsHandler.java
package com.bookshop.server;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import java.io.IOException;

public class CorsHandler implements HttpHandler {
    @Override
    public void handle(HttpExchange exchange) throws IOException {
        // Add CORS headers
        exchange.getResponseHeaders().add("Access-Control-Allow-Origin", "*");
        exchange.getResponseHeaders().add("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        exchange.getResponseHeaders().add("Access-Control-Allow-Headers", "Content-Type, Authorization");
        
        // Handle preflight requests
        if ("OPTIONS".equals(exchange.getRequestMethod())) {
            exchange.sendResponseHeaders(204, -1);
            return;
        }
        
        // For non-OPTIONS requests, return 404
        String response = "Not Found";
        exchange.sendResponseHeaders(404, response.length());
        exchange.getResponseBody().write(response.getBytes());
        exchange.getResponseBody().close();
    }
}

// Authentication Controller - AuthController.java
package com.bookshop.controller;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.bookshop.dao.UserDAO;
import com.bookshop.model.User;
import com.bookshop.model.Response;
import com.bookshop.util.JsonUtil;
import com.bookshop.util.PasswordUtil;
import com.bookshop.util.JwtUtil;
import org.json.JSONObject;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

public class AuthController implements HttpHandler {
    private UserDAO userDAO;
    
    public AuthController() {
        this.userDAO = new UserDAO();
    }
    
    @Override
    public void handle(HttpExchange exchange) throws IOException {
        // Add CORS headers
        exchange.getResponseHeaders().add("Access-Control-Allow-Origin", "*");
        exchange.getResponseHeaders().add("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        exchange.getResponseHeaders().add("Access-Control-Allow-Headers", "Content-Type, Authorization");
        
        String method = exchange.getRequestMethod();
        String path = exchange.getRequestURI().getPath();
        
        // Handle preflight requests
        if ("OPTIONS".equals(method)) {
            exchange.sendResponseHeaders(204, -1);
            return;
        }
        
        try {
            if ("POST".equals(method) && path.endsWith("/login")) {
                handleLogin(exchange);
            } else if ("POST".equals(method) && path.endsWith("/logout")) {
                handleLogout(exchange);
            } else {
                sendResponse(exchange, 404, new Response(false, "Not Found", null));
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendResponse(exchange, 500, new Response(false, "Internal Server Error", null));
        }
    }
    
    private void handleLogin(HttpExchange exchange) throws IOException {
        String requestBody = readRequestBody(exchange);
        
        try {
            JSONObject json = new JSONObject(requestBody);
            String username = json.getString("username");
            String password = json.getString("password");
            
            // Validate input
            if (username == null || username.trim().isEmpty()) {
                sendResponse(exchange, 400, new Response(false, "Username is required", null));
                return;
            }
            
            if (password == null || password.trim().isEmpty()) {
                sendResponse(exchange, 400, new Response(false, "Password is required", null));
                return;
            }
            
            // Authenticate user
            User user = userDAO.findByUsername(username.trim());
            
            if (user == null) {
                sendResponse(exchange, 401, new Response(false, "Invalid username or password", null));
                return;
            }
            
            if (!user.isActive()) {
                sendResponse(exchange, 401, new Response(false, "Account is deactivated", null));
                return;
            }
            
            // Verify password
            if (!PasswordUtil.verifyPassword(password, user.getPasswordHash())) {
                sendResponse(exchange, 401, new Response(false, "Invalid username or password", null));
                return;
            }
            
            // Generate JWT token
            String token = JwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());
            
            // Prepare response data
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("token", token);
            
            Map<String, Object> userData = new HashMap<>();
            userData.put("id", user.getId());
            userData.put("username", user.getUsername());
            userData.put("email", user.getEmail());
            userData.put("firstName", user.getFirstName());
            userData.put("lastName", user.getLastName());
            userData.put("role", user.getRole());
            
            responseData.put("user", userData);
            
            sendResponse(exchange, 200, new Response(true, "Login successful", responseData));
            
        } catch (Exception e) {
            e.printStackTrace();
            sendResponse(exchange, 400, new Response(false, "Invalid request data", null));
        }
    }
    
    private void handleLogout(HttpExchange exchange) throws IOException {
        // For JWT tokens, logout is handled client-side by removing the token
        // In a production system, you might want to maintain a blacklist of tokens
        sendResponse(exchange, 200, new Response(true, "Logout successful", null));
    }
    
    private String readRequestBody(HttpExchange exchange) throws IOException {
        InputStream inputStream = exchange.getRequestBody();
        byte[] bytes = inputStream.readAllBytes();
        return new String(bytes, StandardCharsets.UTF_8);
    }
    
    private void sendResponse(HttpExchange exchange, int statusCode, Response response) throws IOException {
        String jsonResponse = JsonUtil.toJson(response);
        
        exchange.getResponseHeaders().add("Content-Type", "application/json");
        exchange.sendResponseHeaders(statusCode, jsonResponse.length());
        
        OutputStream outputStream = exchange.getResponseBody();
        outputStream.write(jsonResponse.getBytes());
        outputStream.close();
    }
}

// User Model - User.java
package com.bookshop.model;

import java.time.LocalDateTime;

public class User {
    private int id;
    private String username;
    private String email;
    private String passwordHash;
    private String role;
    private String firstName;
    private String lastName;
    private String phone;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private boolean isActive;
    
    // Constructors
    public User() {}
    
    public User(String username, String email, String passwordHash, String role, 
                String firstName, String lastName, String phone) {
        this.username = username;
        this.email = email;
        this.passwordHash = passwordHash;
        this.role = role;
        this.firstName = firstName;
        this.lastName = lastName;
        this.phone = phone;
        this.isActive = true;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
}

// Response Model - Response.java
package com.bookshop.model;

public class Response {
    private boolean success;
    private String message;
    private Object data;
    
    public Response(boolean success, String message, Object data) {
        this.success = success;
        this.message = message;
        this.data = data;
    }
    
    // Getters and Setters
    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }
    
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    
    public Object getData() { return data; }
    public void setData(Object data) { this.data = data; }
}

// User DAO - UserDAO.java
package com.bookshop.dao;

import com.bookshop.model.User;
import com.bookshop.database.DatabaseConnection;
import java.sql.*;
import java.time.LocalDateTime;

public class UserDAO {
    
    public User findByUsername(String username) {
        String sql = "SELECT * FROM users WHERE username = ? AND is_active = 1";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToUser(rs);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    public User findById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToUser(rs);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    public boolean create(User user) {
        String sql = "INSERT INTO users (username, email, password_hash, role, first_name, last_name, phone) VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPasswordHash());
            stmt.setString(4, user.getRole());
            stmt.setString(5, user.getFirstName());
            stmt.setString(6, user.getLastName());
            stmt.setString(7, user.getPhone());
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    user.setId(generatedKeys.getInt(1));
                }
                return true;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setEmail(rs.getString("email"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setRole(rs.getString("role"));
        user.setFirstName(rs.getString("first_name"));
        user.setLastName(rs.getString("last_name"));
        user.setPhone(rs.getString("phone"));
        user.setActive(rs.getBoolean("is_active"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            user.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            user.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        
        return user;
    }
}

// Database Connection - DatabaseConnection.java
package com.bookshop.database;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.io.InputStream;
import java.io.IOException;

public class DatabaseConnection {
    private static final String CONFIG_FILE = "/config.properties";
    private static String URL;
    private static String USERNAME;
    private static String PASSWORD;
    
    static {
        loadConfig();
    }
    
    private static void loadConfig() {
        try (InputStream input = DatabaseConnection.class.getResourceAsStream(CONFIG_FILE)) {
            Properties props = new Properties();
            
            if (input == null) {
                // Default configuration
                URL = "jdbc:mysql://localhost:3306/bookshop_db";
                USERNAME = "root";
                PASSWORD = "password";
                System.out.println("Using default database configuration");
            } else {
                props.load(input);
                URL = props.getProperty("db.url", "jdbc:mysql://localhost:3306/bookshop_db");
                USERNAME = props.getProperty("db.username", "root");
                PASSWORD = props.getProperty("db.password", "password");
            }
            
        } catch (IOException e) {
            e.printStackTrace();
            // Use default values
            URL = "jdbc:mysql://localhost:3306/bookshop_db";
            USERNAME = "root";
            PASSWORD = "password";
        }
    }
    
    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(URL, USERNAME, PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found", e);
        }
    }
    
    public static void testConnection() {
        try (Connection conn = getConnection()) {
            System.out.println("Database connection successful!");
        } catch (SQLException e) {
            System.err.println("Database connection failed: " + e.getMessage());
        }
    }
}

// Database Initializer - DatabaseInitializer.java
package com.bookshop.database;

import com.bookshop.util.PasswordUtil;
import java.sql.*;

public class DatabaseInitializer {
    
    public static void initialize() {
        try {
            createTables();
            insertDefaultData();
            System.out.println("Database initialized successfully!");
        } catch (SQLException e) {
            System.err.println("Failed to initialize database: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private static void createTables() throws SQLException {
        String[] createTableQueries = {
            // Users table
            """
            CREATE TABLE IF NOT EXISTS users (
                id INT PRIMARY KEY AUTO_INCREMENT,
                username VARCHAR(50) UNIQUE NOT NULL,
                email VARCHAR(100) UNIQUE NOT NULL,
                password_hash VARCHAR(255) NOT NULL,
                role ENUM('admin', 'manager', 'employee') DEFAULT 'employee',
                first_name VARCHAR(50) NOT NULL,
                last_name VARCHAR(50) NOT NULL,
                phone VARCHAR(20),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                is_active BOOLEAN DEFAULT TRUE
            )
            """,
            
            // Books table
            """
            CREATE TABLE IF NOT EXISTS books (
                id INT PRIMARY KEY AUTO_INCREMENT,
                isbn VARCHAR(20) UNIQUE,
                title VARCHAR(200) NOT NULL,
                author VARCHAR(200) NOT NULL,
                publisher VARCHAR(100),
                category VARCHAR(50),
                price DECIMAL(10,2) NOT NULL,
                cost_price DECIMAL(10,2) NOT NULL,
                stock_quantity INT DEFAULT 0,
                description TEXT,
                publication_date DATE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )
            """,
            
            // Orders table
            """
            CREATE TABLE IF NOT EXISTS orders (
                id INT PRIMARY KEY AUTO_INCREMENT,
                user_id INT,
                customer_name VARCHAR(100) NOT NULL,
                customer_email VARCHAR(100),
                customer_phone VARCHAR(20),
                total_amount DECIMAL(10,2) NOT NULL,
                status ENUM('pending', 'completed', 'cancelled') DEFAULT 'pending',
                order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id)
            )
            """,
            
            // Order items table
            """
            CREATE TABLE IF NOT EXISTS order_items (
                id INT PRIMARY KEY AUTO_INCREMENT,
                order_id INT,
                book_id INT,
                quantity INT NOT NULL,
                unit_price DECIMAL(10,2) NOT NULL,
                total_price DECIMAL(10,2) NOT NULL,
                FOREIGN KEY (order_id) REFERENCES orders(id),
                FOREIGN KEY (book_id) REFERENCES books(id)
            )
            """
        };
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            for (String query : createTableQueries) {
                try (Statement stmt = conn.createStatement()) {
                    stmt.execute(query);
                }
            }
        }
    }
    
    private static void insertDefaultData() throws SQLException {
        try (Connection conn = DatabaseConnection.getConnection()) {
            // Check if admin user exists
            String checkAdminQuery = "SELECT COUNT(*) FROM users WHERE username = 'admin'";
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery(checkAdminQuery)) {
                
                if (rs.next() && rs.getInt(1) == 0) {
                    // Insert default admin user
                    String adminPassword = PasswordUtil.hashPassword("admin123");
                    String insertAdminQuery = """
                        INSERT INTO users (username, email, password_hash, role, first_name, last_name, phone)
                        VALUES ('admin', 'admin@bookshop.com', ?, 'admin', 'System', 'Administrator', '+1234567890')
                    """;
                    
                    try (PreparedStatement pstmt = conn.prepareStatement(insertAdminQuery)) {
                        pstmt.setString(1, adminPassword);
                        pstmt.executeUpdate();
                        System.out.println("Default admin user created: admin/admin123");
                    }
                }
            }
        }
    }
}

// Password Utility - PasswordUtil.java
package com.bookshop.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

public class PasswordUtil {
    private static final String ALGORITHM = "SHA-256";
    private static final int SALT_LENGTH = 16;
    
    public static String hashPassword(String password) {
        try {
            // Generate salt
            SecureRandom random = new SecureRandom();
            byte[] salt = new byte[SALT_LENGTH];
            random.nextBytes(salt);
            
            // Hash password with salt
            MessageDigest md = MessageDigest.getInstance(ALGORITHM);
            md.update(salt);
            byte[] hashedPassword = md.digest(password.getBytes());
            
            // Combine salt and hash
            byte[] combined = new byte[salt.length + hashedPassword.length];
            System.arraycopy(salt, 0, combined, 0, salt.length);
            System.arraycopy(hashedPassword, 0, combined, salt.length, hashedPassword.length);
            
            return Base64.getEncoder().encodeToString(combined);
            
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password", e);
        }
    }
    
    public static boolean verifyPassword(String password, String hashedPassword) {
        try {
            // Decode the stored hash
            byte[] combined = Base64.getDecoder().decode(hashedPassword);
            
            // Extract salt
            byte[] salt = new byte[SALT_LENGTH];
            System.arraycopy(combined, 0, salt, 0, SALT_LENGTH);
            
            // Extract hash
            byte[] hash = new byte[combined.length - SALT_LENGTH];
            System.arraycopy(combined, SALT_LENGTH, hash, 0, hash.length);
            
            // Hash the provided password with the same salt
            MessageDigest md = MessageDigest.getInstance(ALGORITHM);
            md.update(salt);
            byte[] testHash = md.digest(password.getBytes());
            
            // Compare hashes
            return MessageDigest.isEqual(hash, testHash);
            
        } catch (Exception e) {
            return false;
        }
    }
}

// JWT Utility - JwtUtil.java
package com.bookshop.util;

import java.util.Base64;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import org.json.JSONObject;

public class JwtUtil {
    private static final String SECRET_KEY = "bookshop_secret_key_2024";
    private static final long EXPIRATION_TIME = 24 * 60 * 60 * 1000; // 24 hours
    
    public static String generateToken(int userId, String username, String role) {
        try {
            // Create header
            Map<String, Object> header = new HashMap<>();
            header.put("alg", "HS256");
            header.put("typ", "JWT");
            
            // Create payload
            Map<String, Object> payload = new HashMap<>();
            payload.put("userId", userId);
            payload.put("username", username);
            payload.put("role", role);
            payload.put("iat", System.currentTimeMillis() / 1000);
            payload.put("exp", (System.currentTimeMillis() + EXPIRATION_TIME) / 1000);
            
            // Encode header and payload
            String encodedHeader = Base64.getUrlEncoder().withoutPadding()
                .encodeToString(new JSONObject(header).toString().getBytes());
            String encodedPayload = Base64.getUrlEncoder().withoutPadding()
                .encodeToString(new JSONObject(payload).toString().getBytes());
            
            // Create signature (simplified - in production use proper HMAC)
            String signature = createSignature(encodedHeader + "." + encodedPayload);
            
            return encodedHeader + "." + encodedPayload + "." + signature;
            
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    private static String createSignature(String data) {
        try {
            String combined = data + SECRET_KEY;
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(combined.getBytes());
            return Base64.getUrlEncoder().withoutPadding().encodeToString(hash);
        } catch (Exception e) {
            return "";
        }
    }
    
    public static boolean validateToken(String token) {
        try {
            String[] parts = token.split("\\.");
            if (parts.length != 3) {
                return false;
            }
            
            String header = parts[0];
            String payload = parts[1];
            String signature = parts[2];
            
            // Verify signature
            String expectedSignature = createSignature(header + "." + payload);
            if (!signature.equals(expectedSignature)) {
                return false;
            }
            
            // Check expiration
            String decodedPayload = new String(Base64.getUrlDecoder().decode(payload));
            JSONObject payloadJson = new JSONObject(decodedPayload);
            long exp = payloadJson.getLong("exp");
            long currentTime = System.currentTimeMillis() / 1000;
            
            return currentTime < exp;
            
        } catch (Exception e) {
            return false;
        }
    }
}

// JSON Utility - JsonUtil.java
package com.bookshop.util;

import com.bookshop.model.Response;
import org.json.JSONObject;
import java.util.Map;

public class JsonUtil {
    
    public static String toJson(Response response) {
        JSONObject json = new JSONObject();
        json.put("success", response.isSuccess());
        json.put("message", response.getMessage());
        
        if (response.getData() != null) {
            json.put("data", response.getData());
        }
        
        return json.toString();
    }
    
    public static String toJson(Object obj) {
        if (obj instanceof Map) {
            return new JSONObject((Map<?, ?>) obj).toString();
        }
        return new JSONObject(obj).toString();
    }
}