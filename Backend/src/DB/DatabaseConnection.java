package DB;

import java.sql.*;

public class DatabaseConnection {
    private static Connection instance;
    
    private DatabaseConnection() {} // Private constructor
    
    public static Connection getInstance() throws SQLException {
        if (instance == null || instance.isClosed()) {
            String url = "jdbc:mysql://localhost:3306/bookshop";
            String user = "root";
            String password = "";
            instance = DriverManager.getConnection(url, user, password);
        }
        return instance;
    }
}