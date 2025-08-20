package dao;

import model.Permission;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PermissionDAO {
    private final DBConnection dbConnection;
    
    public PermissionDAO() throws SQLException {
        this.dbConnection = DBConnection.getInstance();
        System.out.println("PermissionDAO initialized with DBConnection");
    }
    
    public List<Permission> getAllPermissions() {
        List<Permission> permissions = new ArrayList<>();
        String sql = "SELECT * FROM permissions ORDER BY name";
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = dbConnection.getConnection();
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                Permission permission = mapResultSetToPermission(rs);
                permissions.add(permission);
            }
        } catch (SQLException e) {
            System.err.println("Error getting all permissions: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                System.err.println("Error closing resources in getAllPermissions: " + e.getMessage());
            }
        }
        return permissions;
    }
    
    public Permission getPermissionById(int id) {
        String sql = "SELECT * FROM permissions WHERE id = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = dbConnection.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, id);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToPermission(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error getting permission by ID: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                System.err.println("Error closing resources in getPermissionById: " + e.getMessage());
            }
        }
        return null;
    }
    
    public List<Permission> getUserPermissions(int userId) {
        List<Permission> permissions = new ArrayList<>();
        String sql = "SELECT DISTINCT p.* FROM permissions p " +
                    "JOIN role_permissions rp ON p.id = rp.permission_id " +
                    "JOIN user_roles ur ON rp.role_id = ur.role_id " +
                    "WHERE ur.user_id = ?";
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = dbConnection.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                Permission permission = mapResultSetToPermission(rs);
                permissions.add(permission);
            }
        } catch (SQLException e) {
            System.err.println("Error getting user permissions: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                System.err.println("Error closing resources in getUserPermissions: " + e.getMessage());
            }
        }
        return permissions;
    }
    
    public boolean hasPermission(int userId, String permissionName) {
        String sql = "SELECT COUNT(*) FROM permissions p " +
                    "JOIN role_permissions rp ON p.id = rp.permission_id " +
                    "JOIN user_roles ur ON rp.role_id = ur.role_id " +
                    "WHERE ur.user_id = ? AND p.name = ?";
        
        System.out.println("Checking permission '" + permissionName + "' for user ID: " + userId);
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = dbConnection.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            stmt.setString(2, permissionName);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                boolean hasPermission = rs.getInt(1) > 0;
                System.out.println("Permission check result: " + hasPermission);
                return hasPermission;
            }
        } catch (SQLException e) {
            System.err.println("Error checking permission: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                System.err.println("Error closing resources in hasPermission: " + e.getMessage());
            }
        }
        
        System.out.println("Permission check failed, returning false");
        return false;
    }
    
    // Helper method to create basic permissions if they don't exist
    public void createBasicPermissions() {
        String[] basicPermissions = {
            "VIEW_DASHBOARD",
            "MANAGE_USERS", 
            "MANAGE_ROLES",
            "MANAGE_BOOKS",
            "VIEW_REPORTS",
            "MANAGE_INVENTORY"
        };
        
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = dbConnection.getConnection();
            String sql = "INSERT IGNORE INTO permissions (name, description, created_at) VALUES (?, ?, NOW())";
            stmt = conn.prepareStatement(sql);
            
            for (String permission : basicPermissions) {
                stmt.setString(1, permission);
                stmt.setString(2, "System permission: " + permission);
                stmt.executeUpdate();
            }
            
            System.out.println("Basic permissions created/verified");
        } catch (SQLException e) {
            System.err.println("Error creating basic permissions: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                System.err.println("Error closing resources in createBasicPermissions: " + e.getMessage());
            }
        }
    }
    
    private Permission mapResultSetToPermission(ResultSet rs) throws SQLException {
        Permission permission = new Permission();
        permission.setId(rs.getInt("id"));
        permission.setName(rs.getString("name"));
        permission.setDescription(rs.getString("description"));
        permission.setCreatedAt(rs.getTimestamp("created_at"));
        return permission;
    }
}