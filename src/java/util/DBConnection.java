package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Improved Database Connection Class
 */
public class DBConnection {
    private static volatile DBConnection instance;
    
    private static final String URL = "jdbc:mysql://localhost:3306/bookshop?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String USERNAME = "root";
    private static final String PASSWORD = ""; // Update with your MySQL password
    
    private DBConnection() {
        // Load MySQL driver once during initialization
        try {
            String[] drivers = {
                "com.mysql.cj.jdbc.Driver",     // MySQL 8.0+
                "com.mysql.jdbc.Driver"         // MySQL 5.x
            };
            
            boolean driverLoaded = false;
            for (String driver : drivers) {
                try {
                    Class.forName(driver);
                    driverLoaded = true;
                    System.out.println("Loaded MySQL driver: " + driver);
                    break;
                } catch (ClassNotFoundException e) {
                    // Continue to next driver
                }
            }
            
            if (!driverLoaded) {
                throw new RuntimeException("No MySQL driver found");
            }
            
        } catch (Exception ex) {
            throw new RuntimeException("Failed to initialize database connection", ex);
        }
    }
    
    // Thread-safe singleton with double-checked locking
    public static DBConnection getInstance() {
        if (instance == null) {
            synchronized (DBConnection.class) {
                if (instance == null) {
                    instance = new DBConnection();
                }
            }
        }
        return instance;
    }
    
    // Create a new connection each time (recommended approach)
    public Connection getConnection() throws SQLException {
        try {
            Connection conn = DriverManager.getConnection(URL, USERNAME, PASSWORD);
            
            // Test the connection
            if (!conn.isValid(5)) { // 5 second timeout
                throw new SQLException("Connection is not valid");
            }
            
            return conn;
        } catch (SQLException e) {
            System.err.println("Failed to create database connection: " + e.getMessage());
            throw e;
        }
    }
    
    // Utility method to close connection safely
    public static void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                if (!connection.isClosed()) {
                    connection.close();
                }
            } catch (SQLException e) {
                System.err.println("Error closing connection: " + e.getMessage());
            }
        }
    }
    
    // Test database connectivity
    public boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && conn.isValid(5);
        } catch (SQLException e) {
            System.err.println("Connection test failed: " + e.getMessage());
            return false;
        }
    }
}