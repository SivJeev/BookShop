<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Supplier" %>
<%@ page import="java.util.List" %>
<%
    List<Supplier> suppliers = (List<Supplier>) request.getAttribute("suppliers");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Suppliers Management - Bookshop System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .page-header {
            background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
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
                        <i class="fas fa-truck me-3"></i>Suppliers Management
                    </h1>
                    <p class="mb-0 mt-2 opacity-75">Manage your book suppliers and vendors</p>
                </div>
                <div class="col-lg-4 text-lg-end">
                    <a href="supplier?action=add" class="btn btn-light btn-lg">
                        <i class="fas fa-plus me-2"></i>Add New Supplier
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

        <!-- Suppliers Table -->
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Contact Person</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (suppliers != null && !suppliers.isEmpty()) {
                                for (Supplier supplier : suppliers) { %>
                                <tr>
                                    <td><%= supplier.getId() %></td>
                                    <td>
                                        <strong><%= supplier.getName() %></strong>
                                    </td>
                                    <td><%= supplier.getContactPerson() %></td>
                                    <td>
                                        <i class="fas fa-envelope text-muted me-1"></i>
                                        <%= supplier.getEmail() %>
                                    </td>
                                    <td>
                                        <i class="fas fa-phone text-muted me-1"></i>
                                        <%= supplier.getPhone() %>
                                    </td>
                                    <td>
                                        <div class="btn-group" role="group">
                                            <a href="supplier?action=edit&id=<%= supplier.getId() %>" 
                                               class="btn btn-outline-primary btn-action" 
                                               title="Edit Supplier">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                            <a href="supplier?action=view&id=<%= supplier.getId() %>" 
                                               class="btn btn-outline-info btn-action" 
                                               title="View Details">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <a href="supplier?action=delete&id=<%= supplier.getId() %>" 
                                               class="btn btn-outline-danger btn-action" 
                                               title="Delete Supplier"
                                               onclick="return confirm('Are you sure you want to delete this supplier?')">
                                                <i class="fas fa-trash"></i>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            <% }
                            } else { %>
                                <tr>
                                    <td colspan="6" class="text-center py-5">
                                        <i class="fas fa-truck fa-3x text-muted mb-3"></i>
                                        <p class="text-muted mb-0">No suppliers found</p>
                                        <a href="supplier?action=add" class="btn btn-primary mt-3">
                                            <i class="fas fa-plus me-2"></i>Add First Supplier
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
        <% if (suppliers != null && !suppliers.isEmpty()) { %>
        <div class="row mt-4">
            <div class="col-md-4">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-primary"><%= suppliers.size() %></h3>
                        <p class="text-muted mb-0">Total Suppliers</p>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-success">
                            <% 
                                int withWebsite = 0;
                                for (Supplier s : suppliers) {
                                    if (s.getWebsite() != null && !s.getWebsite().isEmpty()) withWebsite++;
                                }
                            %>
                            <%= withWebsite %>
                        </h3>
                        <p class="text-muted mb-0">With Website</p>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-info">
                            <% 
                                int international = 0;
                                for (Supplier s : suppliers) {
                                    if (s.getCountry() != null && !s.getCountry().equals("US")) international++;
                                }
                            %>
                            <%= international %>
                        </h3>
                        <p class="text-muted mb-0">International</p>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>