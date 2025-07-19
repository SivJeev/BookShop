package Repositories;

import java.sql.*;

public class UserRepository {
    public boolean authenticate(String username, String password) throws SQLException {
        Connection conn = DatabaseConnection.getInstance();
        String sql = "SELECT password FROM users WHERE username = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            return rs.next() && password.equals(rs.getString("password"));
        }
    }
}