package servlet;

import dao.UserDAO;
import dao.RoleDAO;
import dao.PermissionDAO;
import model.User;
import model.Role;

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

@WebServlet("/user")
public class UserServlet extends HttpServlet {
    private UserDAO userDAO;
    private RoleDAO roleDAO;
    private PermissionDAO permissionDAO;
    
    @Override
    public void init() throws ServletException {
        try {
            userDAO = new UserDAO();
        } catch (SQLException ex) {
            Logger.getLogger(UserServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
        try {
            roleDAO = new RoleDAO();
        } catch (SQLException ex) {
            Logger.getLogger(UserServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
        try {
            permissionDAO = new PermissionDAO();
        } catch (SQLException ex) {
            Logger.getLogger(UserServlet.class.getName()).log(Level.SEVERE, null, ex);
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
                listUsers(request, response);
                break;
            case "add":
                showAddForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteUser(request, response);
                break;
            default:
                listUsers(request, response);
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if (action == null) {
            response.sendRedirect("user?action=list");
            return;
        }
        
        switch (action) {
            case "create":
                createUser(request, response);
                break;
            case "update":
                updateUser(request, response);
                break;
            case "assignRole":
                assignRole(request, response);
                break;
            case "removeRole":
                removeRole(request, response);
                break;
            default:
                response.sendRedirect("user?action=list");
                break;
        }
    }
    
    private void listUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check permission
        if (!checkPermission(request, "MANAGE_USERS")) {
            request.setAttribute("errorMessage", "You don't have permission to view users.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        List<User> users = userDAO.getAllUsers();
        request.setAttribute("users", users);
        request.getRequestDispatcher("user-list.jsp").forward(request, response);
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_USERS")) {
            request.setAttribute("errorMessage", "You don't have permission to add users.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        List<Role> roles = roleDAO.getAllRoles();
        request.setAttribute("roles", roles);
        request.getRequestDispatcher("user-add.jsp").forward(request, response);
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_USERS")) {
            request.setAttribute("errorMessage", "You don't have permission to edit users.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        int userId = Integer.parseInt(request.getParameter("id"));
        User user = userDAO.getUserById(userId);
        List<Role> allRoles = roleDAO.getAllRoles();
        
        if (user != null) {
            user.setRoles(userDAO.getUserById(userId).getRoles());
            request.setAttribute("user", user);
            request.setAttribute("allRoles", allRoles);
            request.getRequestDispatcher("user-edit.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "User not found.");
            response.sendRedirect("user?action=list");
        }
    }
    
    private void createUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_USERS")) {
            request.setAttribute("errorMessage", "You don't have permission to create users.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String[] roleIds = request.getParameterValues("roleIds");
        
        // Validation
        if (username == null || email == null || password == null || fullName == null ||
            username.trim().isEmpty() || email.trim().isEmpty() || 
            password.trim().isEmpty() || fullName.trim().isEmpty()) {
            
            request.setAttribute("errorMessage", "All fields are required.");
            showAddForm(request, response);
            return;
        }
        
        // Check if username already exists
        if (userDAO.getUserByUsername(username.trim()) != null) {
            request.setAttribute("errorMessage", "Username already exists.");
            showAddForm(request, response);
            return;
        }
        
        User newUser = new User(username.trim(), email.trim(), password, fullName.trim());
        
        if (userDAO.createUser(newUser)) {
            // Assign roles if selected
            if (roleIds != null) {
                User createdUser = userDAO.getUserByUsername(username.trim());
                for (String roleId : roleIds) {
                    userDAO.assignRoleToUser(createdUser.getId(), Integer.parseInt(roleId));
                }
            }
            
            request.setAttribute("successMessage", "User created successfully!");
            response.sendRedirect("user?action=list");
        } else {
            request.setAttribute("errorMessage", "Failed to create user.");
            showAddForm(request, response);
        }
    }
    
    private void updateUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_USERS")) {
            request.setAttribute("errorMessage", "You don't have permission to update users.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        int userId = Integer.parseInt(request.getParameter("id"));
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String fullName = request.getParameter("fullName");
        boolean isActive = "on".equals(request.getParameter("isActive"));
        
        User user = userDAO.getUserById(userId);
        if (user != null) {
            user.setUsername(username.trim());
            user.setEmail(email.trim());
            user.setFullName(fullName.trim());
            user.setActive(isActive);
            
            if (userDAO.updateUser(user)) {
                request.setAttribute("successMessage", "User updated successfully!");
                response.sendRedirect("user?action=list");
            } else {
                request.setAttribute("errorMessage", "Failed to update user.");
                showEditForm(request, response);
            }
        } else {
            request.setAttribute("errorMessage", "User not found.");
            response.sendRedirect("user?action=list");
        }
    }
    
    private void deleteUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_USERS")) {
            request.setAttribute("errorMessage", "You don't have permission to delete users.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        int userId = Integer.parseInt(request.getParameter("id"));
        
        if (userDAO.deleteUser(userId)) {
            request.setAttribute("successMessage", "User deleted successfully!");
        } else {
            request.setAttribute("errorMessage", "Failed to delete user.");
        }
        
        response.sendRedirect("user?action=list");
    }
    
    private void assignRole(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_USERS")) {
            request.setAttribute("errorMessage", "You don't have permission to assign roles.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        int userId = Integer.parseInt(request.getParameter("userId"));
        int roleId = Integer.parseInt(request.getParameter("roleId"));
        
        if (userDAO.assignRoleToUser(userId, roleId)) {
            request.setAttribute("successMessage", "Role assigned successfully!");
        } else {
            request.setAttribute("errorMessage", "Failed to assign role.");
        }
        
        response.sendRedirect("user?action=edit&id=" + userId);
    }
    
    private void removeRole(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_USERS")) {
            request.setAttribute("errorMessage", "You don't have permission to remove roles.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        int userId = Integer.parseInt(request.getParameter("userId"));
        int roleId = Integer.parseInt(request.getParameter("roleId"));
        
        if (userDAO.removeRoleFromUser(userId, roleId)) {
            request.setAttribute("successMessage", "Role removed successfully!");
        } else {
            request.setAttribute("errorMessage", "Failed to remove role.");
        }
        
        response.sendRedirect("user?action=edit&id=" + userId);
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