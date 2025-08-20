<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Role" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    User user = (User) request.getAttribute("user");
    List<Role> allRoles = (List<Role>) request.getAttribute("allRoles");
    
    if (user == null) {
        response.sendRedirect("user?action=list");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit User - Bookshop Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .page-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px 0;
            margin-bottom: 30px;
        }
        .form-card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
        }
        .role-item {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 10px;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand fw-bold" href="dashboard.jsp">
                <i class="fas fa-book me-2"></i>Bookshop Manager
            </a>
            <div class="navbar-nav ms-auto">
                <a class="nav-link" href="user?action=list">
                    <i class="fas fa-users me-1"></i>Back to Users
                </a>
            </div>
        </div>
    </nav>

    <!-- Page Header -->
    <div class="page-header">
        <div class="container">
            <h1 class="mb-0">
                <i class="fas fa-user-edit me-3"></i>Edit User
            </h1>
            <p class="mb-0 mt-2 opacity-75">Update user information and roles</p>
        </div>
    </div>

    <div class="container">
        <div class="row">
            <div class="col-lg-8">
                <!-- Display Messages -->
                <% if (request.getAttribute("errorMessage") != null) { %>
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i>
                        <%= request.getAttribute("errorMessage") %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>

                <% if (request.getAttribute("successMessage") != null) { %>
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fas fa-check-circle me-2"></i>
                        <%= request.getAttribute("successMessage") %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>

                <div class="card form-card">
                    <div class="card-body p-4">
                        <h4 class="card-title mb-4">User Information</h4>
                        
                        <form action="user" method="post">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="id" value="<%= user.getId() %>">
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="username" class="form-label">
                                        <i class="fas fa-user me-2"></i>Username*
                                    </label>
                                    <input type="text" class="form-control" id="username" name="username" 
                                           value="<%= user.getUsername() != null ? user.getUsername() : "" %>" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="fullName" class="form-label">
                                        <i class="fas fa-id-card me-2"></i>Full Name*
                                    </label>
                                    <input type="text" class="form-control" id="fullName" name="fullName" 
                                           value="<%= user.getFullName() != null ? user.getFullName() : "" %>" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="email" class="form-label">
                                    <i class="fas fa-envelope me-2"></i>Email Address*
                                </label>
                                <input type="email" class="form-control" id="email" name="email" 
                                       value="<%= user.getEmail() != null ? user.getEmail() : "" %>" required>
                            </div>

                            <div class="mb-4">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" id="isActive" name="isActive" 
                                           <%= user.isActive() ? "checked" : "" %>>
                                    <label class="form-check-label" for="isActive">
                                        <i class="fas fa-toggle-on me-2"></i>Active User
                                    </label>
                                    <small class="form-text text-muted d-block">
                                        Inactive users cannot log in to the system
                                    </small>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <button type="submit" class="btn btn-primary btn-lg w-100">
                                        <i class="fas fa-save me-2"></i>Update User
                                    </button>
                                </div>
                                <div class="col-md-6">
                                    <a href="user?action=list" class="btn btn-secondary btn-lg w-100">
                                        <i class="fas fa-times me-2"></i>Cancel
                                    </a>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <div class="col-lg-4">
                <!-- Current Roles -->
                <div class="card form-card">
                    <div class="card-body">
                        <h5 class="card-title">
                            <i class="fas fa-user-shield me-2"></i>Current Roles
                        </h5>
                        
                        <% if (user.getRoles() != null && !user.getRoles().isEmpty()) {
                            for (Role role : user.getRoles()) { %>
                            <div class="role-item d-flex justify-content-between align-items-center">
                                <div>
                                    <strong><%= role.getName() != null ? role.getName() : "Unknown Role" %></strong>
                                    <br><small class="text-muted"><%= role.getDescription() != null ? role.getDescription() : "No description" %></small>
                                </div>
                                <form action="user" method="post" class="d-inline">
                                    <input type="hidden" name="action" value="removeRole">
                                    <input type="hidden" name="userId" value="<%= user.getId() %>">
                                    <input type="hidden" name="roleId" value="<%= role.getId() %>">
                                    <button type="submit" class="btn btn-outline-danger btn-sm" 
                                            onclick="return confirm('Remove this role from user?')">
                                        <i class="fas fa-times"></i>
                                    </button>
                                </form>
                            </div>
                        <% }
                        } else { %>
                            <p class="text-muted">No roles assigned</p>
                        <% } %>
                    </div>
                </div>

                <!-- Assign New Role -->
                <div class="card form-card mt-3">
                    <div class="card-body">
                        <h5 class="card-title">
                            <i class="fas fa-plus-circle me-2"></i>Assign Role
                        </h5>
                        
                        <form action="user" method="post">
                            <input type="hidden" name="action" value="assignRole">
                            <input type="hidden" name="userId" value="<%= user.getId() %>">
                            
                            <div class="mb-3">
                                <select class="form-select" name="roleId" required>
                                    <option value="">Select a role...</option>
                                    <% if (allRoles != null) {
                                        for (Role role : allRoles) {
                                            // Check if user already has this role
                                            boolean hasRole = false;
                                            if (user.getRoles() != null) {
                                                for (Role userRole : user.getRoles()) {
                                                    if (userRole.getId() == role.getId()) {
                                                        hasRole = true;
                                                        break;
                                                    }
                                                }
                                            }
                                            if (!hasRole) { %>
                                                <option value="<%= role.getId() %>">
                                                    <%= role.getName() != null ? role.getName() : "Unknown Role" %> - <%= role.getDescription() != null ? role.getDescription() : "No description" %>
                                                </option>
                                    <%      }
                                        }
                                    } %>
                                </select>
                            </div>
                            
                            <button type="submit" class="btn btn-success w-100">
                                <i class="fas fa-plus me-2"></i>Assign Role
                            </button>
                        </form>
                    </div>
                </div>

                <!-- User Info -->
                <div class="card form-card mt-3">
                    <div class="card-body">
                        <h5 class="card-title">
                            <i class="fas fa-info-circle me-2"></i>User Details
                        </h5>
                        
                        <p><strong>User ID:</strong> <%= user.getId() %></p>
                        <p><strong>Created:</strong> 
                            <% if (user.getCreatedAt() != null) { %>
                                <%= java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm")
                                    .format(user.getCreatedAt().toLocalDateTime()) %>
                            <% } else { %>
                                N/A
                            <% } %>
                        </p>
                        <p><strong>Last Updated:</strong> 
                            <% if (user.getUpdatedAt() != null) { %>
                                <%= java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm")
                                    .format(user.getUpdatedAt().toLocalDateTime()) %>
                            <% } else { %>
                                N/A
                            <% } %>
                        </p>
                        <p><strong>Status:</strong> 
                            <span class="badge <%= user.isActive() ? "bg-success" : "bg-danger" %>">
                                <%= user.isActive() ? "Active" : "Inactive" %>
                            </span>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>