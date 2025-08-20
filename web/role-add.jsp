<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Role - Bookshop Management System</title>
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
                <i class="fas fa-plus-circle me-3"></i>Add New Role
            </h1>
            <p class="mb-0 mt-2 opacity-75">Create a new system role</p>
        </div>
    </div>

    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-6">
                <!-- Display Messages -->
                <% if (request.getAttribute("errorMessage") != null) { %>
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i>
                        <%= request.getAttribute("errorMessage") %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>

                <div class="card form-card">
                    <div class="card-body p-5">
                        <h4 class="card-title mb-4">Role Information</h4>
                        
                        <form action="role" method="post">
                            <input type="hidden" name="action" value="create">
                            
                            <div class="mb-3">
                                <label for="name" class="form-label">
                                    <i class="fas fa-shield-alt me-2"></i>Role Name*
                                </label>
                                <input type="text" class="form-control" id="name" name="name" 
                                       placeholder="Enter role name (e.g., STAFF, MANAGER)" required>
                                <small class="text-muted">Role names are typically in UPPERCASE</small>
                            </div>

                            <div class="mb-4">
                                <label for="description" class="form-label">
                                    <i class="fas fa-file-alt me-2"></i>Description
                                </label>
                                <textarea class="form-control" id="description" name="description" 
                                          rows="3" placeholder="Enter role description"></textarea>
                                <small class="text-muted">Optional: Describe what this role is for</small>
                            </div>

                            <div class="alert alert-info">
                                <i class="fas fa-info-circle me-2"></i>
                                <strong>Note:</strong> After creating the role, you can assign permissions 
                                from the roles list page.
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <button type="submit" class="btn btn-primary btn-lg w-100">
                                        <i class="fas fa-save me-2"></i>Create Role
                                    </button>
                                </div>
                                <div class="col-md-6">
                                    <a href="role?action=list" class="btn btn-secondary btn-lg w-100">
                                        <i class="fas fa-times me-2"></i>Cancel
                                    </a>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Role Examples -->
                <div class="card form-card mt-4">
                    <div class="card-body">
                        <h5 class="card-title">
                            <i class="fas fa-lightbulb me-2"></i>Common Role Examples
                        </h5>
                        <div class="row">
                            <div class="col-md-6">
                                <ul class="list-unstyled">
                                    <li class="mb-2">
                                        <strong>ADMIN</strong><br>
                                        <small class="text-muted">Full system access</small>
                                    </li>
                                    <li class="mb-2">
                                        <strong>MANAGER</strong><br>
                                        <small class="text-muted">Store management</small>
                                    </li>
                                </ul>
                            </div>
                            <div class="col-md-6">
                                <ul class="list-unstyled">
                                    <li class="mb-2">
                                        <strong>EMPLOYEE</strong><br>
                                        <small class="text-muted">Basic operations</small>
                                    </li>
                                    <li class="mb-2">
                                        <strong>CUSTOMER</strong><br>
                                        <small class="text-muted">Customer access</small>
                                    </li>
                                </ul>
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