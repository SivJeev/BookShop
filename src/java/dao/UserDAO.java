package dao;

import util.DBConnection;
import model.User;
import model.Role;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    private final DBConnection dbConnection;

    public UserDAO() throws SQLException {
        this.dbConnection = DBConnection.getInstance();
        System.out.println("UserDAO initialized with DBConnection");
    }

    public User authenticateUser(String username, String password) {
        String sql = "SELECT * FROM users WHERE username = ? AND password = ? AND is_active = 1";
        System.out.println("=== AUTHENTICATION DEBUG ===");
        System.out.println("SQL Query: " + sql);
        System.out.println("Input username: '" + username + "'");
        System.out.println("Password provided: " + (password != null && !password.isEmpty()));

        // Use try-with-resources for automatic resource management
        try (Connection conn = DBConnection.getInstance().getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username.trim());
            stmt.setString(2, password); // Consider using hashed passwords

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    System.out.println("✓ User found in database");
                    User user = mapResultSetToUser(rs);

                    // Load roles - this is critical for dashboard permissions
                    List<Role> roles = getUserRoles(user.getId());
                    user.setRoles(roles);

                    System.out.println("User loaded: ID=" + user.getId() + ", Username=" + user.getUsername());
                    System.out.println("Roles loaded: " + roles.size());
                    for (Role role : roles) {
                        System.out.println("  - Role: " + role.getName());
                    }
                    return user;
                } else {
                    System.out.println("✗ No matching user found");
                    // Debug: Check what's in the database
                    checkExistingUsers(username);
                }
            }

        } catch (SQLException e) {
            System.err.println("Database error during authentication: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    private void checkExistingUsers(String searchUsername) {
        String checkSql = "SELECT username, password, is_active FROM users WHERE username = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = dbConnection.getConnection();
            stmt = conn.prepareStatement(checkSql);
            stmt.setString(1, searchUsername);
            rs = stmt.executeQuery();

            if (rs.next()) {
                System.out.println("--- USER EXISTS BUT AUTHENTICATION FAILED ---");
                System.out.println("Found username: '" + rs.getString("username") + "'");
                System.out.println("Stored password: '" + rs.getString("password") + "'");
                System.out.println("Is active: " + rs.getBoolean("is_active"));
            } else {
                System.out.println("--- NO USER FOUND WITH USERNAME: " + searchUsername + " ---");

                // Let's see all users with a new statement
                PreparedStatement allStmt = null;
                ResultSet allRs = null;
                try {
                    String allUsersSql = "SELECT username FROM users LIMIT 5";
                    allStmt = conn.prepareStatement(allUsersSql);
                    allRs = allStmt.executeQuery();

                    System.out.println("Existing usernames in database:");
                    while (allRs.next()) {
                        System.out.println("  - '" + allRs.getString("username") + "'");
                    }
                } finally {
                    if (allRs != null) {
                        allRs.close();
                    }
                    if (allStmt != null) {
                        allStmt.close();
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in checkExistingUsers: " + e.getMessage());
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (stmt != null) {
                    stmt.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                System.err.println("Error closing resources in checkExistingUsers: " + e.getMessage());
            }
        }
    }

    public boolean createUser(User user) {
        String sql = "INSERT INTO users (username, email, password, full_name, is_active) VALUES (?, ?, ?, ?, ?)";
        System.out.println("Creating user: " + user.getUsername());

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = dbConnection.getConnection();
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPassword());
            stmt.setString(4, user.getFullName());
            stmt.setBoolean(5, user.isActive());

            int result = stmt.executeUpdate();
            System.out.println("User creation result: " + (result > 0 ? "SUCCESS" : "FAILED"));
            return result > 0;
        } catch (SQLException e) {
            System.err.println("Error creating user: " + e.getMessage());
            return false;
        } finally {
            try {
                if (stmt != null) {
                    stmt.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                System.err.println("Error closing resources in createUser: " + e.getMessage());
            }
        }
    }

    public User getUserById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = dbConnection.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, id);
            rs = stmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToUser(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error getting user by ID: " + e.getMessage());
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (stmt != null) {
                    stmt.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                System.err.println("Error closing resources in getUserById: " + e.getMessage());
            }
        }
        return null;
    }

    public User getUserByUsername(String username) {
        String sql = "SELECT * FROM users WHERE username = ?";
        System.out.println("Looking for user with username: '" + username + "'");

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = dbConnection.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, username);
            rs = stmt.executeQuery();

            if (rs.next()) {
                User user = mapResultSetToUser(rs);
                System.out.println("Found user: ID=" + user.getId() + ", Active=" + user.isActive());
                return user;
            } else {
                System.out.println("No user found with username: " + username);
            }
        } catch (SQLException e) {
            System.err.println("Error getting user by username: " + e.getMessage());
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (stmt != null) {
                    stmt.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                System.err.println("Error closing resources in getUserByUsername: " + e.getMessage());
            }
        }
        return null;
    }

    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY created_at DESC";

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = dbConnection.getConnection();
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();

            while (rs.next()) {
                User user = mapResultSetToUser(rs);
                user.setRoles(getUserRoles(user.getId()));
                users.add(user);
            }
        } catch (SQLException e) {
            System.err.println("Error getting all users: " + e.getMessage());
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (stmt != null) {
                    stmt.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                System.err.println("Error closing resources in getAllUsers: " + e.getMessage());
            }
        }
        return users;
    }

    public boolean updateUser(User user) {
        String sql = "UPDATE users SET username = ?, email = ?, full_name = ?, is_active = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = dbConnection.getConnection();
            stmt = conn.prepareStatement(sql);

            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getFullName());
            stmt.setBoolean(4, user.isActive());
            stmt.setInt(5, user.getId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error updating user: " + e.getMessage());
            return false;
        } finally {
            try {
                if (stmt != null) {
                    stmt.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                System.err.println("Error closing resources in updateUser: " + e.getMessage());
            }
        }
    }

    public boolean deleteUser(int id) {
        String sql = "DELETE FROM users WHERE id = ?";
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = dbConnection.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error deleting user: " + e.getMessage());
            return false;
        } finally {
            try {
                if (stmt != null) {
                    stmt.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                System.err.println("Error closing resources in deleteUser: " + e.getMessage());
            }
        }
    }

    public boolean assignRoleToUser(int userId, int roleId) {
        String sql = "INSERT INTO user_roles (user_id, role_id) VALUES (?, ?) ON DUPLICATE KEY UPDATE assigned_at = CURRENT_TIMESTAMP";
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = dbConnection.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            stmt.setInt(2, roleId);

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error assigning role to user: " + e.getMessage());
            return false;
        } finally {
            try {
                if (stmt != null) {
                    stmt.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                System.err.println("Error closing resources in assignRoleToUser: " + e.getMessage());
            }
        }
    }

    public boolean removeRoleFromUser(int userId, int roleId) {
        String sql = "DELETE FROM user_roles WHERE user_id = ? AND role_id = ?";
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = dbConnection.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            stmt.setInt(2, roleId);

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error removing role from user: " + e.getMessage());
            return false;
        } finally {
            try {
                if (stmt != null) {
                    stmt.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                System.err.println("Error closing resources in removeRoleFromUser: " + e.getMessage());
            }
        }
    }

    private List<Role> getUserRoles(int userId) {
        List<Role> roles = new ArrayList<>();
        String sql = "SELECT r.* FROM roles r JOIN user_roles ur ON r.id = ur.role_id WHERE ur.user_id = ?";

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = dbConnection.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            rs = stmt.executeQuery();

            while (rs.next()) {
                Role role = new Role();
                role.setId(rs.getInt("id"));
                role.setName(rs.getString("name"));
                role.setDescription(rs.getString("description"));
                role.setCreatedAt(rs.getTimestamp("created_at"));
                role.setUpdatedAt(rs.getTimestamp("updated_at"));
                roles.add(role);
            }
        } catch (SQLException e) {
            System.err.println("Error getting user roles: " + e.getMessage());
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (stmt != null) {
                    stmt.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                System.err.println("Error closing resources in getUserRoles: " + e.getMessage());
            }
        }
        return roles;
    }

    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setEmail(rs.getString("email"));
        user.setPassword(rs.getString("password"));
        user.setFullName(rs.getString("full_name"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setUpdatedAt(rs.getTimestamp("updated_at"));
        user.setActive(rs.getBoolean("is_active"));
        return user;
    }

    private void closeResources(ResultSet rs, PreparedStatement stmt, Connection conn) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}
