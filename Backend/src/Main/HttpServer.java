package Main;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.util.concurrent.Executors;
import java.util.logging.Logger;

import com.sun.net.httpserver.HttpServer;

import Controllers.LoginController;

public class HttpServer {
    private static final Logger logger = Logger.getLogger(HttpServer.class.getName());

    public static void main(String[] args) throws IOException {
        int port = 8080;

        // Create server with backlog
        HttpServer server = HttpServer.create(new InetSocketAddress(port), 100);

        LoginController loginController = new LoginController();

        // Set up login endpoint
        server.createContext("/login", exchange -> {
            try {
                loginController.handleLogin(exchange);
            } catch (Exception e) {
                logger.severe("Error handling login request: " + e.getMessage());
                // Send generic error response
                exchange.sendResponseHeaders(500, -1);
            }
        });

        // Health check endpoint
        server.createContext("/health", exchange -> {
            if ("GET".equals(exchange.getRequestMethod())) {
                String response = "{\"status\":\"healthy\"}";
                exchange.getResponseHeaders().set("Content-Type", "application/json");
                exchange.sendResponseHeaders(200, response.length());
                exchange.getResponseBody().write(response.getBytes());
                exchange.getResponseBody().close();
            } else {
                exchange.sendResponseHeaders(405, -1);
            }
        });

        // Use a thread pool for better performance
        server.setExecutor(Executors.newFixedThreadPool(10));
        server.start();

        logger.info("Server started on port " + port);
        System.out.println("Server started on port " + port);

        // Graceful shutdown hook
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            logger.info("Shutting down server...");
            server.stop(5);
        }));
    }
}