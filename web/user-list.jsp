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
    
    List<User> users = (List<User>) request.getAttribute("users");
    
    // Calculate statistics using traditional loops instead of lambda expressions
    int totalUsers = 0;
    int activeUsers = 0;
    int inactiveUsers = 0;
    int totalRoleAssignments = 0;
    
    if (users != null) {
        totalUsers = users.size();
        for (User user : users) {
            if (user.isActive()) {
                activeUsers++;
            } else {
                inactiveUsers++;
            }
            if (user.getRoles() != null) {
                totalRoleAssignments += user.getRoles().size();
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Users Management - Bookshop Management System</title>
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
        .table-responsive {
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        .table th {
            background-color: #f8f9fa;
            border-top: none;
            font-weight: 600;
        }
        .badge-role {
            font-size: 0.75em;
            margin: 2px;
        }
        .btn-action {
            padding: 0.25rem 0.5rem;
            margin: 0 2px;
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
                <a class="nav-link" href="dashboard.jsp">
                    <i class="fas fa-home me-1"></i>Dashboard
                </a>
            </div>
        </div>
    </nav>

    <!-- Page Header -->
    <div class="page-header">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-8">
                    <h1 class="mb-0">
                        <i class="fas fa-users me-3"></i>Users Management
                    </h1>
                    <p class="mb-0 mt-2 opacity-75">Manage user accounts and permissions</p>
                </div>
                <div class="col-lg-4 text-lg-end">
                    <a href="user?action=add" class="btn btn-light btn-lg">
                        <i class="fas fa-plus me-2"></i>Add New User
                    </a>
                </div>
            </div>
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

        <!-- Users Table -->
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Username</th>
                                <th>Full Name</th>
                                <th>Email</th>
                                <th>Roles</th>
                                <th>Status</th>
                                <th>Created</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (users != null && !users.isEmpty()) {
                                for (User user : users) { %>
                                <tr>
                                    <td><%= user.getId() %></td>
                                    <td>
                                        <strong><%= user.getUsername() %></strong>
                                    </td>
                                    <td><%= user.getFullName() %></td>
                                    <td>
                                        <i class="fas fa-envelope text-muted me-1"></i>
                                        <%= user.getEmail() %>
                                    </td>
                                    <td>
                                        <% if (user.getRoles() != null && !user.getRoles().isEmpty()) {
                                            for (Role role : user.getRoles()) { %>
                                                <span class="badge bg-primary badge-role">
                                                    <%= role.getName() %>
                                                </span>
                                        <% }
                                        } else { %>
                                            <span class="text-muted">No roles</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (user.isActive()) { %>
                                            <span class="badge bg-success">
                                                <i class="fas fa-check-circle"></i> Active
                                            </span>
                                        <% } else { %>
                                            <span class="badge bg-danger">
                                                <i class="fas fa-times-circle"></i> Inactive
                                            </span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <small class="text-muted">
                                            <%= user.getCreatedAt() != null ? 
                                                java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy")
                                                .format(user.getCreatedAt().toLocalDateTime()) : "N/A" %>
                                        </small>
                                    </td>
                                    <td>
                                        <div class="btn-group" role="group">
                                            <a href="user?action=edit&id=<%= user.getId() %>" 
                                               class="btn btn-outline-primary btn-action" 
                                               title="Edit User">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                            <a href="user?action=delete&id=<%= user.getId() %>" 
                                               class="btn btn-outline-danger btn-action" 
                                               title="Delete User"
                                               onclick="return confirm('Are you sure you want to delete this user?')">
                                                <i class="fas fa-trash"></i>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            <% }
                            } else { %>
                                <tr>
                                    <td colspan="8" class="text-center py-5">
                                        <i class="fas fa-users fa-3x text-muted mb-3"></i>
                                        <p class="text-muted mb-0">No users found</p>
                                        <a href="user?action=add" class="btn btn-primary mt-3">
                                            <i class="fas fa-plus me-2"></i>Add First User
                                        </a>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Summary Card -->
        <% if (users != null && !users.isEmpty()) { %>
        <div class="row mt-4">
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-primary"><%= totalUsers %></h3>
                        <p class="text-muted mb-0">Total Users</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-success"><%= activeUsers %></h3>
                        <p class="text-muted mb-0">Active Users</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-warning"><%= inactiveUsers %></h3>
                        <p class="text-muted mb-0">Inactive Users</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-info"><%= totalRoleAssignments %></h3>
                        <p class="text-muted mb-0">Total Role Assignments</p>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>