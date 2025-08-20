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

    List<Role> roles = (List<Role>) request.getAttribute("roles");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Roles Management - Bookshop Management System</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <style>
            body {
                background-color: #f8f9fa;
            }
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
            .badge-permission {
                font-size: 0.7em;
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
                            <i class="fas fa-user-shield me-3"></i>Roles Management
                        </h1>
                        <p class="mb-0 mt-2 opacity-75">Manage system roles and permissions</p>
                    </div>
                    <div class="col-lg-4 text-lg-end">
                        <a href="role?action=add" class="btn btn-light btn-lg">
                            <i class="fas fa-plus me-2"></i>Add New Role
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <div class="container">
            <!-- Display Messages -->
            <% if (request.getAttribute("errorMessage") != null) {%>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>
                <%= request.getAttribute("errorMessage")%>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>

            <% if (request.getAttribute("successMessage") != null) {%>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>
                <%= request.getAttribute("successMessage")%>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>

            <!-- Roles Table -->
            <div class="card">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Role Name</th>
                                    <th>Description</th>
                                    <th>Permissions</th>
                                    <th>Created</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (roles != null && !roles.isEmpty()) {
                                        for (Role role : roles) {%>
                                <tr>
                                    <td><%= role.getId()%></td>
                                    <td>
                                        <strong><%= role.getName()%></strong>
                                    </td>
                                    <td>
                                        <%= role.getDescription() != null ? role.getDescription() : "No description"%>
                                    </td>
                                    <td>
                                        <% if (role.getPermissions() != null && !role.getPermissions().isEmpty()) {
                                                int count = 0;
                                                for (Permission permission : role.getPermissions()) {
                                                    if (count >= 3) {%>
                                        <span class="badge bg-secondary badge-permission">
                                            +<%= role.getPermissions().size() - 3%> more
                                        </span>
                                        <% break;
                                            }%>
                                        <span class="badge bg-info badge-permission">
                                            <%= permission.getName()%>
                                        </span>
                                        <% count++;
                                            }
                                        } else { %>
                                        <span class="text-muted">No permissions</span>
                                        <% }%>
                                    </td>
                                    <td>
                                        <small class="text-muted">
                                            <%= role.getCreatedAt() != null
                                                    ? java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy")
                                                            .format(role.getCreatedAt().toLocalDateTime()) : "N/A"%>
                                        </small>
                                    </td>
                                    <td>
                                        <div class="btn-group" role="group">
                                            <a href="role?action=permissions&id=<%= role.getId()%>" 
                                               class="btn btn-outline-info btn-action" 
                                               title="Manage Permissions">
                                                <i class="fas fa-key"></i>
                                            </a>
                                            <a href="role?action=edit&id=<%= role.getId()%>" 
                                               class="btn btn-outline-primary btn-action" 
                                               title="Edit Role">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                            <a href="role?action=delete&id=<%= role.getId()%>" 
                                               class="btn btn-outline-danger btn-action" 
                                               title="Delete Role"
                                               onclick="return confirm('Are you sure you want to delete this role?')">
                                                <i class="fas fa-trash"></i>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                                <% }
                                } else { %>
                                <tr>
                                    <td colspan="6" class="text-center py-5">
                                        <i class="fas fa-user-shield fa-3x text-muted mb-3"></i>
                                        <p class="text-muted mb-0">No roles found</p>
                                        <a href="role?action=add" class="btn btn-primary mt-3">
                                            <i class="fas fa-plus me-2"></i>Add First Role
                                        </a>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Summary Cards -->
            <% if (roles != null && !roles.isEmpty()) {
                // Calculate total permission assignments using traditional loop
                int totalPermissions = 0;
                for (Role role : roles) {
                    if (role.getPermissions() != null) {
                        totalPermissions += role.getPermissions().size();
                    }
                }
            %>
            <div class="row mt-4">
                <div class="col-md-4">
                    <div class="card text-center">
                        <div class="card-body">
                            <h3 class="text-primary"><%= roles.size()%></h3>
                            <p class="text-muted mb-0">Total Roles</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card text-center">
                        <div class="card-body">
                            <h3 class="text-success"><%= totalPermissions%></h3>
                            <p class="text-muted mb-0">Total Permission Assignments</p>
                        </div>
                    </div>
                </div>
            </div>
            <% }%>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>