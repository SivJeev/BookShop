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
    
    List<Role> roles = (List<Role>) request.getAttribute("roles");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add User - Bookshop Management System</title>
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
        .role-checkbox {
            background-color: #f8f9fa;
            border-radius: 8px;
            padding: 10px;
            margin-bottom: 10px;
            border: 1px solid #e9ecef;
        }
        .role-checkbox:hover {
            background-color: #e9ecef;
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
                <i class="fas fa-user-plus me-3"></i>Add New User
            </h1>
            <p class="mb-0 mt-2 opacity-75">Create a new user account</p>
        </div>
    </div>

    <div class="container">
        <div class="row justify-content-center">
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
                    <div class="card-body p-5">
                        <h4 class="card-title mb-4">User Information</h4>
                        
                        <form action="user" method="post" id="userForm">
                            <input type="hidden" name="action" value="create">
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="username" class="form-label">
                                        <i class="fas fa-user me-2"></i>Username*
                                    </label>
                                    <input type="text" class="form-control" id="username" name="username" 
                                           placeholder="Enter username" required maxlength="50">
                                    <small class="text-muted">Username must be unique</small>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="fullName" class="form-label">
                                        <i class="fas fa-id-card me-2"></i>Full Name*
                                    </label>
                                    <input type="text" class="form-control" id="fullName" name="fullName" 
                                           placeholder="Enter full name" required maxlength="255">
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="email" class="form-label">
                                    <i class="fas fa-envelope me-2"></i>Email Address*
                                </label>
                                <input type="email" class="form-control" id="email" name="email" 
                                       placeholder="Enter email address" required maxlength="255">
                                <small class="text-muted">Email must be unique</small>
                            </div>

                            <div class="mb-4">
                                <label for="password" class="form-label">
                                    <i class="fas fa-lock me-2"></i>Password*
                                </label>
                                <input type="password" class="form-control" id="password" name="password" 
                                       placeholder="Enter password" required minlength="6" maxlength="255">
                                <small class="text-muted">Minimum 6 characters</small>
                            </div>

                            <div class="mb-3">
                                <label for="confirmPassword" class="form-label">
                                    <i class="fas fa-lock me-2"></i>Confirm Password*
                                </label>
                                <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" 
                                       placeholder="Confirm password" required minlength="6">
                                <small class="text-muted">Re-enter the password to confirm</small>
                            </div>

                            <div class="mb-4">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" id="isActive" name="isActive" checked>
                                    <label class="form-check-label" for="isActive">
                                        <i class="fas fa-toggle-on me-2"></i>Active User
                                    </label>
                                    <small class="form-text text-muted d-block">
                                        Active users can log in to the system
                                    </small>
                                </div>
                            </div>

                            <div class="mb-4">
                                <label class="form-label">
                                    <i class="fas fa-user-shield me-2"></i>Assign Roles
                                </label>
                                <div class="row">
                                    <% if (roles != null && !roles.isEmpty()) {
                                        for (Role role : roles) { %>
                                        <div class="col-md-6 mb-2">
                                            <div class="role-checkbox">
                                                <div class="form-check">
                                                    <input class="form-check-input" type="checkbox" 
                                                           name="roleIds" value="<%= role.getId() %>" 
                                                           id="role<%= role.getId() %>">
                                                    <label class="form-check-label" for="role<%= role.getId() %>">
                                                        <strong><%= role.getName() != null ? role.getName() : "Unknown Role" %></strong>
                                                        <br><small class="text-muted"><%= role.getDescription() != null ? role.getDescription() : "No description available" %></small>
                                                    </label>
                                                </div>
                                            </div>
                                        </div>
                                    <% }
                                    } else { %>
                                        <div class="col-12">
                                            <div class="alert alert-warning">
                                                <i class="fas fa-exclamation-triangle me-2"></i>
                                                No roles available. Contact administrator to create roles first.
                                            </div>
                                        </div>
                                    <% } %>
                                </div>
                                <small class="text-muted">Select one or more roles for this user</small>
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <button type="submit" class="btn btn-primary btn-lg w-100">
                                        <i class="fas fa-save me-2"></i>Create User
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
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Form validation
        document.getElementById('userForm').addEventListener('submit', function(e) {
            var password = document.getElementById('password').value;
            var confirmPassword = document.getElementById('confirmPassword').value;
            
            if (password !== confirmPassword) {
                e.preventDefault();
                alert('Passwords do not match!');
                document.getElementById('confirmPassword').focus();
                return false;
            }
            
            if (password.length < 6) {
                e.preventDefault();
                alert('Password must be at least 6 characters long!');
                document.getElementById('password').focus();
                return false;
            }
        });
    </script>
</body>
</html>