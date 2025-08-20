<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Role" %>
<%@ page import="dao.PermissionDAO" %>
<%@ page import="java.sql.SQLException" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Debug user information using application.log instead of System.out
    application.log("Dashboard loaded for user: " + user.getUsername());
    application.log("User ID: " + user.getId());
    application.log("User roles: " + (user.getRoles() != null ? user.getRoles().size() : "null"));

    PermissionDAO permissionDAO = null;
    boolean permissionDAOAvailable = false;

    try {
        permissionDAO = new PermissionDAO();
        // Test with a simple permission check
        boolean canViewDashboard = permissionDAO.hasPermission(user.getId(), "VIEW_DASHBOARD");
        application.log("Can view dashboard: " + canViewDashboard);
        permissionDAOAvailable = true;
        application.log("PermissionDAO initialized successfully for user: " + user.getUsername());
    } catch (SQLException e) {
        application.log("Failed to initialize PermissionDAO: " + e.getMessage(), e);
        application.log("PermissionDAO initialization failed: " + e.getMessage());
        e.printStackTrace();
        permissionDAOAvailable = false;
    }

    // Debug permission checks if DAO is available
    if (permissionDAOAvailable && permissionDAO != null) {
        try {
            application.log("=== PERMISSION DEBUG ===");
            application.log("MANAGE_USERS: " + permissionDAO.hasPermission(user.getId(), "MANAGE_USERS"));
            application.log("MANAGE_ROLES: " + permissionDAO.hasPermission(user.getId(), "MANAGE_ROLES"));
            application.log("MANAGE_BOOKS: " + permissionDAO.hasPermission(user.getId(), "MANAGE_BOOKS"));
        } catch (Exception e) {
            application.log("Error during permission debug: " + e.getMessage(), e);
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Dashboard - Bookshop Management System</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <style>
            body {
                background-color: #f8f9fa;
            }
            .navbar-brand {
                font-weight: 700;
            }
            .card {
                transition: transform 0.2s ease-in-out;
                border: none;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            .card:hover {
                transform: translateY(-5px);
            }
            .feature-card {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border-radius: 15px;
            }
            .feature-card h5 {
                font-weight: 600;
            }
            .welcome-section {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border-radius: 15px;
                padding: 30px;
                margin-bottom: 30px;
            }
            .stat-card {
                background: white;
                border-radius: 10px;
                padding: 20px;
                text-align: center;
            }
            .stat-number {
                font-size: 2rem;
                font-weight: 700;
                color: #667eea;
            }
            .error-card {
                background: linear-gradient(135deg, #ff6b6b 0%, #ee5a52 100%);
                color: white;
                border-radius: 15px;
            }
        </style>
    </head>
    <body>
        <!-- Navigation -->
        <nav class="navbar navbar-expand-lg navbar-dark bg-primary shadow">
            <div class="container">
                <a class="navbar-brand" href="dashboard.jsp">
                    <i class="fas fa-book me-2"></i>
                    Bookshop Manager
                </a>

                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span class="navbar-toggler-icon"></span>
                </button>

                <div class="collapse navbar-collapse" id="navbarNav">
                    <ul class="navbar-nav me-auto">
                        <li class="nav-item">
                            <a class="nav-link active" href="dashboard.jsp">
                                <i class="fas fa-home me-1"></i>Dashboard
                            </a>
                        </li>

                        <li class="nav-item">
                            <a class="nav-link" href="user?action=list">
                                <i class="fas fa-users me-1"></i>Users
                            </a>
                        </li>

                        <li class="nav-item">
                            <a class="nav-link" href="role?action=list">
                                <i class="fas fa-user-shield me-1"></i>Roles
                            </a>
                        </li>
                        
                        <li class="nav-item">
                            <a class="nav-link" href="book?action=list">
                                <i class="fas fa-book me-1"></i>Books
                            </a>
                        </li>
                        
                        <li class="nav-item">
                            <a class="nav-link" href="supplier?action=list">
                                <i class="fas fa-book me-1"></i>Supplier
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="pos">
                                <i class="fas fa-book me-1"></i>POS
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="reservation">
                                <i class="fas fa-book me-1"></i>Reservation
                            </a>
                        </li>
                    </ul>

                    <ul class="navbar-nav">
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-bs-toggle="dropdown">
                                <i class="fas fa-user-circle me-1"></i>
                                <%= user.getFullName()%>
                            </a>
                            <ul class="dropdown-menu">
                                <li><a class="dropdown-item" href="#" onclick="alert('Profile management coming soon!')">
                                        <i class="fas fa-user me-2"></i>Profile
                                    </a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li>
                                    <form action="auth" method="post" class="d-inline">
                                        <input type="hidden" name="action" value="logout">
                                        <button type="submit" class="dropdown-item">
                                            <i class="fas fa-sign-out-alt me-2"></i>Logout
                                        </button>
                                    </form>
                                </li>
                            </ul>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>

        <div class="container mt-4">
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

            <!-- Permission DAO Error Warning -->
            <% if (!permissionDAOAvailable) { %>
            <div class="alert alert-warning alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-triangle me-2"></i>
                <strong>Warning:</strong> Permission system is not available. Some features may be hidden. 
                Please check your database configuration and ensure permission tables exist.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% }%>

            <!-- Welcome Section -->
            <div class="welcome-section">
                <div class="row align-items-center">
                    <div class="col-lg-8">
                        <h1 class="mb-3">Welcome back, <%= user.getFullName()%>!</h1>
                        <p class="mb-0 lead">Here's what's happening in your bookshop today.</p>
                    </div>
                    <div class="col-lg-4 text-lg-end">
                        <i class="fas fa-chart-line fa-3x opacity-50"></i>
                    </div>
                </div>
            </div>

            <!-- User Roles -->
            <div class="row mb-4">
                <div class="col-12">
                    <div class="card">
                        <div class="card-body">
                            <h6 class="card-title">Your Roles & Permissions</h6>
                            <div class="d-flex flex-wrap gap-2">
                                <% if (user.getRoles() != null && !user.getRoles().isEmpty()) {
                                    for (Role role : user.getRoles()) {%>
                                <span class="badge bg-primary px-3 py-2">
                                    <i class="fas fa-shield-alt me-1"></i>
                                    <%= role.getName()%>
                                </span>
                                <% }
                            } else { %>
                                <span class="text-muted">No roles assigned</span>
                                <% } %>
                            </div>

                            <% if (!permissionDAOAvailable) { %>
                            <div class="mt-2">
                                <small class="text-warning">
                                    <i class="fas fa-exclamation-triangle me-1"></i>
                                    Permission checking is currently unavailable
                                </small>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="row">
                <div class="col-12">
                    <h4 class="mb-3">Quick Actions</h4>
                </div>

                <% if (!permissionDAOAvailable) { %>
                <!-- Show all options when permission system is unavailable -->
                <div class="col-lg-4 col-md-6 mb-4">
                    <div class="card error-card h-100">
                        <div class="card-body text-center">
                            <i class="fas fa-exclamation-triangle fa-3x mb-3"></i>
                            <h5 class="card-title">Permission System Error</h5>
                            <p class="card-text">The permission system is not available. Please contact your administrator.</p>
                            <small>All features are temporarily hidden for security.</small>
                        </div>
                    </div>
                </div>

                <!-- Fallback options when permissions aren't working -->
                <div class="col-lg-4 col-md-6 mb-4">
                    <div class="card h-100">
                        <div class="card-body text-center">
                            <i class="fas fa-users fa-3x text-primary mb-3"></i>
                            <h5 class="card-title">Users</h5>
                            <p class="card-text">Manage user accounts (permission check disabled).</p>
                            <a href="user?action=list" class="btn btn-primary">
                                <i class="fas fa-arrow-right me-2"></i>View Users
                            </a>
                        </div>
                    </div>
                </div>

                <div class="col-lg-4 col-md-6 mb-4">
                    <div class="card h-100">
                        <div class="card-body text-center">
                            <i class="fas fa-user-shield fa-3x text-primary mb-3"></i>
                            <h5 class="card-title">Roles</h5>
                            <p class="card-text">Manage roles and permissions (permission check disabled).</p>
                            <a href="role?action=list" class="btn btn-primary">
                                <i class="fas fa-arrow-right me-2"></i>View Roles
                            </a>
                        </div>
                    </div>
                </div>

                <% } else { %>
                <!-- Normal permission-based display -->

                <div class="col-lg-4 col-md-6 mb-4">
                    <div class="card feature-card h-100">
                        <div class="card-body text-center">
                            <i class="fas fa-users fa-3x mb-3"></i>
                            <h5 class="card-title">Manage Users</h5>
                            <p class="card-text">Create, edit, and manage user accounts and permissions.</p>
                            <a href="user?action=list" class="btn btn-light">
                                <i class="fas fa-arrow-right me-2"></i>View Users
                            </a>
                        </div>
                    </div>
                </div>

                <div class="col-lg-4 col-md-6 mb-4">
                    <div class="card feature-card h-100">
                        <div class="card-body text-center">
                            <i class="fas fa-user-shield fa-3x mb-3"></i>
                            <h5 class="card-title">Manage Roles</h5>
                            <p class="card-text">Configure roles and assign permissions to control access.</p>
                            <a href="role?action=list" class="btn btn-light">
                                <i class="fas fa-arrow-right me-2"></i>View Roles
                            </a>
                        </div>
                    </div>
                </div>

                <div class="col-lg-4 col-md-6 mb-4">
                    <div class="card feature-card h-100">
                        <div class="card-body text-center">
                            <i class="fas fa-book fa-3x mb-3"></i>
                            <h5 class="card-title">Manage Books</h5>
                            <p class="card-text">Add, update, and organize your book inventory.</p>
                            <a href="#" onclick="alert('Books management coming soon!')" class="btn btn-light">
                                <i class="fas fa-arrow-right me-2"></i>View Books
                            </a>
                        </div>
                    </div>
                </div>

                <div class="col-lg-4 col-md-6 mb-4">
                    <div class="card feature-card h-100">
                        <div class="card-body text-center">
                            <i class="fas fa-chart-bar fa-3x mb-3"></i>
                            <h5 class="card-title">View Reports</h5>
                            <p class="card-text">Access sales reports and analytics.</p>
                            <a href="#" onclick="alert('Reports coming soon!')" class="btn btn-light">
                                <i class="fas fa-arrow-right me-2"></i>View Reports
                            </a>
                        </div>
                    </div>
                </div>

                <div class="col-lg-4 col-md-6 mb-4">
                    <div class="card feature-card h-100">
                        <div class="card-body text-center">
                            <i class="fas fa-boxes fa-3x mb-3"></i>
                            <h5 class="card-title">Inventory</h5>
                            <p class="card-text">Manage book inventory and stock levels.</p>
                            <a href="#" onclick="alert('Inventory management coming soon!')" class="btn btn-light">
                                <i class="fas fa-arrow-right me-2"></i>View Inventory
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Default card if user has limited permissions -->
                <div class="col-lg-6 col-md-6 mb-4">
                    <div class="card h-100">
                        <div class="card-body text-center">
                            <i class="fas fa-info-circle fa-3x text-info mb-3"></i>
                            <h5 class="card-title">Limited Access</h5>
                            <p class="card-text text-muted">You have limited permissions. Contact your administrator for more access.</p>
                            <small class="text-muted">User ID: <%= user.getId()%></small>
                        </div>
                    </div>
                </div>

                <% } %>
            </div>

            <!-- System Info -->
            <div class="row mt-5">
                <div class="col-12">
                    <div class="card">
                        <div class="card-body">
                            <h6 class="card-title">System Information</h6>
                            <div class="row text-center">
                                <div class="col-md-3">
                                    <div class="stat-card">
                                        <div class="stat-number">1</div>
                                        <small class="text-muted">Active Users</small>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="stat-card">
                                        <div class="stat-number">4</div>
                                        <small class="text-muted">System Roles</small>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="stat-card">
                                        <div class="stat-number">6</div>
                                        <small class="text-muted">Permissions</small>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="stat-card">
                                        <div class="stat-number">v1.0</div>
                                        <small class="text-muted">System Version</small>
                                    </div>
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