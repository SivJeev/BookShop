package dao;

import model.Role;
import model.Permission;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoleDAO {
    private final DBConnection dbConnection;
    
    public RoleDAO() throws SQLException {
        this.dbConnection = DBConnection.getInstance();
    }
    
    public boolean createRole(Role role) {
        String sql = "INSERT INTO roles (name, description) VALUES (?, ?)";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, role.getName());
            stmt.setString(2, role.getDescription());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public Role getRoleById(int id) {
        String sql = "SELECT * FROM roles WHERE id = ?";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Role role = mapResultSetToRole(rs);
                role.setPermissions(getRolePermissions(id));
                return role;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    public List<Role> getAllRoles() {
        List<Role> roles = new ArrayList<>();
        String sql = "SELECT * FROM roles ORDER BY created_at DESC";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Role role = mapResultSetToRole(rs);
                role.setPermissions(getRolePermissions(role.getId()));
                roles.add(role);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return roles;
    }
    
    public boolean updateRole(Role role) {
        String sql = "UPDATE roles SET name = ?, description = ? WHERE id = ?";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, role.getName());
            stmt.setString(2, role.getDescription());
            stmt.setInt(3, role.getId());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean deleteRole(int id) {
        String sql = "DELETE FROM roles WHERE id = ?";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean assignPermissionToRole(int roleId, int permissionId) {
        String sql = "INSERT INTO role_permissions (role_id, permission_id) VALUES (?, ?) ON DUPLICATE KEY UPDATE assigned_at = CURRENT_TIMESTAMP";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, roleId);
            stmt.setInt(2, permissionId);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean removePermissionFromRole(int roleId, int permissionId) {
        String sql = "DELETE FROM role_permissions WHERE role_id = ? AND permission_id = ?";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, roleId);
            stmt.setInt(2, permissionId);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    private List<Permission> getRolePermissions(int roleId) {
        List<Permission> permissions = new ArrayList<>();
        String sql = "SELECT p.* FROM permissions p JOIN role_permissions rp ON p.id = rp.permission_id WHERE rp.role_id = ?";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, roleId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Permission permission = new Permission();
                permission.setId(rs.getInt("id"));
                permission.setName(rs.getString("name"));
                permission.setDescription(rs.getString("description"));
                permission.setCreatedAt(rs.getTimestamp("created_at"));
                permissions.add(permission);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return permissions;
    }
    
    private Role mapResultSetToRole(ResultSet rs) throws SQLException {
        Role role = new Role();
        role.setId(rs.getInt("id"));
        role.setName(rs.getString("name"));
        role.setDescription(rs.getString("description"));
        role.setCreatedAt(rs.getTimestamp("created_at"));
        role.setUpdatedAt(rs.getTimestamp("updated_at"));
        return role;
    }
}