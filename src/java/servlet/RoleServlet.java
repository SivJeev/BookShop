package servlet;

import dao.RoleDAO;
import dao.PermissionDAO;
import model.Role;
import model.Permission;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.annotation.WebServlet;

@WebServlet("/role")
public class RoleServlet extends HttpServlet {
    private RoleDAO roleDAO;
    private PermissionDAO permissionDAO;
    
    @Override
    public void init() throws ServletException {
        try {
            roleDAO = new RoleDAO();
        } catch (SQLException ex) {
            Logger.getLogger(RoleServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
        try {
            permissionDAO = new PermissionDAO();
        } catch (SQLException ex) {
            Logger.getLogger(RoleServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "list";
        }
        
        switch (action) {
            case "list":
                listRoles(request, response);
                break;
            case "add":
                showAddForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteRole(request, response);
                break;
            case "permissions":
                showPermissions(request, response);
                break;
            default:
                listRoles(request, response);
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if (action == null) {
            response.sendRedirect("role?action=list");
            return;
        }
        
        switch (action) {
            case "create":
                createRole(request, response);
                break;
            case "update":
                updateRole(request, response);
                break;
            case "assignPermission":
                assignPermission(request, response);
                break;
            case "removePermission":
                removePermission(request, response);
                break;
            default:
                response.sendRedirect("role?action=list");
                break;
        }
    }
    
    private void listRoles(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_ROLES")) {
            request.setAttribute("errorMessage", "You don't have permission to view roles.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        List<Role> roles = roleDAO.getAllRoles();
        request.setAttribute("roles", roles);
        request.getRequestDispatcher("role_list.jsp").forward(request, response);
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_ROLES")) {
            request.setAttribute("errorMessage", "You don't have permission to add roles.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        request.getRequestDispatcher("role-add.jsp").forward(request, response);
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_ROLES")) {
            request.setAttribute("errorMessage", "You don't have permission to edit roles.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        int roleId = Integer.parseInt(request.getParameter("id"));
        Role role = roleDAO.getRoleById(roleId);
        
        if (role != null) {
            request.setAttribute("role", role);
            request.getRequestDispatcher("role-edit.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Role not found.");
            response.sendRedirect("role?action=list");
        }
    }
    
    private void showPermissions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_ROLES")) {
            request.setAttribute("errorMessage", "You don't have permission to manage role permissions.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        int roleId = Integer.parseInt(request.getParameter("id"));
        Role role = roleDAO.getRoleById(roleId);
        List<Permission> allPermissions = permissionDAO.getAllPermissions();
        
        if (role != null) {
            request.setAttribute("role", role);
            request.setAttribute("allPermissions", allPermissions);
            request.getRequestDispatcher("role-permissions.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Role not found.");
            response.sendRedirect("role?action=list");
        }
    }
    
    private void createRole(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_ROLES")) {
            request.setAttribute("errorMessage", "You don't have permission to create roles.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        
        if (name == null || name.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Role name is required.");
            showAddForm(request, response);
            return;
        }
        
        Role newRole = new Role(name.trim(), description != null ? description.trim() : "");
        
        if (roleDAO.createRole(newRole)) {
            request.setAttribute("successMessage", "Role created successfully!");
            response.sendRedirect("role?action=list");
        } else {
            request.setAttribute("errorMessage", "Failed to create role.");
            showAddForm(request, response);
        }
    }
    
    private void updateRole(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_ROLES")) {
            request.setAttribute("errorMessage", "You don't have permission to update roles.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        int roleId = Integer.parseInt(request.getParameter("id"));
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        
        Role role = roleDAO.getRoleById(roleId);
        if (role != null) {
            role.setName(name.trim());
            role.setDescription(description != null ? description.trim() : "");
            
            if (roleDAO.updateRole(role)) {
                request.setAttribute("successMessage", "Role updated successfully!");
                response.sendRedirect("role?action=list");
            } else {
                request.setAttribute("errorMessage", "Failed to update role.");
                showEditForm(request, response);
            }
        } else {
            request.setAttribute("errorMessage", "Role not found.");
            response.sendRedirect("role?action=list");
        }
    }
    
    private void deleteRole(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_ROLES")) {
            request.setAttribute("errorMessage", "You don't have permission to delete roles.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        int roleId = Integer.parseInt(request.getParameter("id"));
        
        if (roleDAO.deleteRole(roleId)) {
            request.setAttribute("successMessage", "Role deleted successfully!");
        } else {
            request.setAttribute("errorMessage", "Failed to delete role.");
        }
        
        response.sendRedirect("role?action=list");
    }
    
    private void assignPermission(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_ROLES")) {
            request.setAttribute("errorMessage", "You don't have permission to assign permissions.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        int roleId = Integer.parseInt(request.getParameter("roleId"));
        int permissionId = Integer.parseInt(request.getParameter("permissionId"));
        
        if (roleDAO.assignPermissionToRole(roleId, permissionId)) {
            request.setAttribute("successMessage", "Permission assigned successfully!");
        } else {
            request.setAttribute("errorMessage", "Failed to assign permission.");
        }
        
        response.sendRedirect("role?action=permissions&id=" + roleId);
    }
    
    private void removePermission(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_ROLES")) {
            request.setAttribute("errorMessage", "You don't have permission to remove permissions.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        int roleId = Integer.parseInt(request.getParameter("roleId"));
        int permissionId = Integer.parseInt(request.getParameter("permissionId"));
        
        if (roleDAO.removePermissionFromRole(roleId, permissionId)) {
            request.setAttribute("successMessage", "Permission removed successfully!");
        } else {
            request.setAttribute("errorMessage", "Failed to remove permission.");
        }
        
        response.sendRedirect("role?action=permissions&id=" + roleId);
    }
    
    private boolean checkPermission(HttpServletRequest request, String permission) {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            return false;
        }
        
        return permissionDAO.hasPermission(user.getId(), permission);
    }
}