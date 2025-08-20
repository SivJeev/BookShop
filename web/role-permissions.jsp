<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Role" %>
<%@ page import="model.Permission" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    Role role = (Role) request.getAttribute("role");
    List<Permission> allPermissions = (List<Permission>) request.getAttribute("allPermissions");
    
    if (role == null) {
        response.sendRedirect("role?action=list");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Role Permissions - Bookshop Management System</title>
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
        .permission-item {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 10px;
            border-left: 4px solid #667eea;
        }
        .permission-item.assigned {
            background: #e8f5e8;
            border-left-color: #28a745;
        }
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
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
                <a class="nav-link" href="role?action=list">
                    <i class="fas fa-user-shield me-1"></i>Back to Roles
                </a>
            </div>
        </div>
    </nav>

    <!-- Page Header -->
    <div class="page-header">
        <div class="container">
            <h1 class="mb-0">
                <i class="fas fa-key me-3"></i>Role Permissions
            </h1>
            <p class="mb-0 mt-2 opacity-75">
                Manage permissions for role: <strong><%= role.getName() %></strong>
            </p>
        </div>
    </div>

    <div class="container">
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

        <div class="row">
            <!-- Current Permissions -->
            <div class="col-lg-6">
                <div class="card form-card">
                    <div class="card-body">
                        <h5 class="card-title">
                            <i class="fas fa-shield-check me-2 text-success"></i>
                            Current Permissions
                            <span class="badge bg-success ms-2">
                                <%= role.getPermissions() != null ? role.getPermissions().size() : 0 %>
                            </span>
                        </h5>
                        
                        <% if (role.getPermissions() != null && !role.getPermissions().isEmpty()) {
                            for (Permission permission : role.getPermissions()) { %>
                            <div class="permission-item assigned">
                                <div class="d-flex justify-content-between align-items-start">
                                    <div>
                                        <h6 class="mb-1">
                                            <i class="fas fa-check-circle text-success me-2"></i>
                                            <%= permission.getName() %>
                                        </h6>
                                        <p class="text-muted mb-0">
                                            <%= permission.getDescription() %>
                                        </p>
                                    </div>
                                    <form action="role" method="post" class="d-inline">
                                        <input type="hidden" name="action" value="removePermission">
                                        <input type="hidden" name="roleId" value="<%= role.getId() %>">
                                        <input type="hidden" name="permissionId" value="<%= permission.getId() %>">
                                        <button type="submit" class="btn btn-outline-danger btn-sm" 
                                                onclick="return confirm('Remove this permission from role?')"
                                                title="Remove Permission">
                                            <i class="fas fa-times"></i>
                                        </button>
                                    </form>
                                </div>
                            </div>
                        <% }
                        } else { %>
                            <div class="text-center py-4">
                                <i class="fas fa-shield-alt fa-3x text-muted mb-3"></i>
                                <p class="text-muted">No permissions assigned to this role</p>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- Available Permissions -->
            <div class="col-lg-6">
                <div class="card form-card">
                    <div class="card-body">
                        <h5 class="card-title">
                            <i class="fas fa-plus-circle me-2 text-primary"></i>
                            Available Permissions
                        </h5>
                        
                        <% if (allPermissions != null && !allPermissions.isEmpty()) {
                            for (Permission permission : allPermissions) {
                                // Check if this permission is already assigned
                                boolean isAssigned = false;
                                if (role.getPermissions() != null) {
                                    for (Permission rolePermission : role.getPermissions()) {
                                        if (rolePermission.getId() == permission.getId()) {
                                            isAssigned = true;
                                            break;
                                        }
                                    }
                                }
                                
                                if (!isAssigned) { %>
                                <div class="permission-item">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <h6 class="mb-1">
                                                <i class="fas fa-shield-alt text-primary me-2"></i>
                                                <%= permission.getName() %>
                                            </h6>
                                            <p class="text-muted mb-0">
                                                <%= permission.getDescription() %>
                                            </p>
                                        </div>
                                        <form action="role" method="post" class="d-inline">
                                            <input type="hidden" name="action" value="assignPermission">
                                            <input type="hidden" name="roleId" value="<%= role.getId() %>">
                                            <input type="hidden" name="permissionId" value="<%= permission.getId() %>">
                                            <button type="submit" class="btn btn-primary btn-sm" 
                                                    title="Assign Permission">
                                                <i class="fas fa-plus"></i>
                                            </button>
                                        </form>
                                    </div>
                                </div>
                        <%      }
                            }
                        } else { %>
                            <div class="text-center py-4">
                                <i class="fas fa-exclamation-triangle fa-3x text-warning mb-3"></i>
                                <p class="text-muted">No permissions available in the system</p>
                            </div>
                        <% } %>
                        
                        <!-- Check if all permissions are assigned -->
                        <% 
                        boolean allAssigned = true;
                        if (allPermissions != null && role.getPermissions() != null) {
                            if (role.getPermissions().size() < allPermissions.size()) {
                                allAssigned = false;
                            }
                        }
                        
                        if (allAssigned && allPermissions != null && !allPermissions.isEmpty()) { %>
                            <div class="text-center py-4">
                                <i class="fas fa-check-circle fa-3x text-success mb-3"></i>
                                <p class="text-success mb-0">All permissions have been assigned to this role!</p>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <!-- Role Summary -->
        <div class="row mt-4">
            <div class="col-12">
                <div class="card form-card">
                    <div class="card-body">
                        <h5 class="card-title">
                            <i class="fas fa-info-circle me-2"></i>Role Summary
                        </h5>
                        
                        <div class="row">
                            <div class="col-md-3">
                                <div class="text-center">
                                    <h3 class="text-primary">
                                        <%= role.getPermissions() != null ? role.getPermissions().size() : 0 %>
                                    </h3>
                                    <p class="text-muted mb-0">Assigned Permissions</p>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="text-center">
                                    <h3 class="text-warning">
                                        <%= allPermissions != null ? 
                                            (allPermissions.size() - (role.getPermissions() != null ? role.getPermissions().size() : 0)) : 0 %>
                                    </h3>
                                    <p class="text-muted mb-0">Available Permissions</p>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="text-center">
                                    <h3 class="text-info">
                                        <%= allPermissions != null ? allPermissions.size() : 0 %>
                                    </h3>
                                    <p class="text-muted mb-0">Total Permissions</p>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="text-center">
                                    <h3 class="text-success">
                                        <%= role.getPermissions() != null && allPermissions != null ? 
                                            Math.round((double) role.getPermissions().size() / allPermissions.size() * 100) : 0 %>%
                                    </h3>
                                    <p class="text-muted mb-0">Coverage</p>
                                </div>
                            </div>
                        </div>
                        
                        <hr>
                        
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <strong>Role:</strong> <%= role.getName() %><br>
                                <strong>Description:</strong> <%= role.getDescription() != null ? role.getDescription() : "No description" %>
                            </div>
                            <div class="text-end">
                                <a href="role?action=edit&id=<%= role.getId() %>" class="btn btn-outline-primary me-2">
                                    <i class="fas fa-edit me-1"></i>Edit Role
                                </a>
                                <a href="role?action=list" class="btn btn-secondary">
                                    <i class="fas fa-arrow-left me-1"></i>Back to Roles
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>