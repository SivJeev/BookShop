<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Purchase" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    List<Purchase> purchases = (List<Purchase>) request.getAttribute("purchases");
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Purchases - Bookshop System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .page-header {
            background: linear-gradient(135deg, #6B73FF 0%, #000DFF 100%);
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
        .status-ordered { background-color: #fff3cd; color: #856404; }
        .status-received { background-color: #d4edda; color: #155724; }
        .status-cancelled { background-color: #f8d7da; color: #721c24; }
        .status-partial { background-color: #e2e3e5; color: #383d41; }
        .payment-pending { color: #dc3545; }
        .payment-partial { color: #ffc107; }
        .payment-paid { color: #28a745; }
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
                        <i class="fas fa-shopping-cart me-3"></i>Purchases Management
                    </h1>
                    <p class="mb-0 mt-2 opacity-75">Manage book purchases from suppliers</p>
                </div>
                <div class="col-lg-4 text-lg-end">
                    <a href="purchase?action=add" class="btn btn-light btn-lg">
                        <i class="fas fa-plus me-2"></i>New Purchase
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

        <!-- Purchases Table -->
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Date</th>
                                <th>Supplier</th>
                                <th>Total</th>
                                <th>Paid</th>
                                <th>Due</th>
                                <th>Status</th>
                                <th>Payment</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (purchases != null && !purchases.isEmpty()) {
                                for (Purchase purchase : purchases) { %>
                                <tr>
                                    <td><%= purchase.getId() %></td>
                                    <td><%= dateFormat.format(purchase.getPurchaseDate()) %></td>
                                    <td><%= purchase.getSupplierName() %></td>
                                    <td>$<%= String.format("%.2f", purchase.getTotalAmount()) %></td>
                                    <td>$<%= String.format("%.2f", purchase.getPaidAmount()) %></td>
                                    <td>$<%= String.format("%.2f", purchase.getTotalAmount() - purchase.getPaidAmount()) %></td>
                                    <td>
                                        <span class="badge status-<%= purchase.getStatus().toLowerCase().replace("_", "-") %>">
                                            <%= purchase.getStatus().replace("_", " ") %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="fw-bold payment-<%= purchase.getPaymentStatus().toLowerCase() %>">
                                            <%= purchase.getPaymentStatus() %>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="btn-group" role="group">
                                            <a href="purchase?action=view&id=<%= purchase.getId() %>" 
                                               class="btn btn-outline-info btn-action" 
                                               title="View Details">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <a href="purchase?action=edit&id=<%= purchase.getId() %>" 
                                               class="btn btn-outline-primary btn-action" 
                                               title="Edit Purchase">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                            <a href="purchase?action=delete&id=<%= purchase.getId() %>" 
                                               class="btn btn-outline-danger btn-action" 
                                               title="Delete Purchase"
                                               onclick="return confirm('Are you sure you want to delete this purchase?')">
                                                <i class="fas fa-trash"></i>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            <% }
                            } else { %>
                                <tr>
                                    <td colspan="9" class="text-center py-5">
                                        <i class="fas fa-shopping-cart fa-3x text-muted mb-3"></i>
                                        <p class="text-muted mb-0">No purchases found</p>
                                        <a href="purchase?action=add" class="btn btn-primary mt-3">
                                            <i class="fas fa-plus me-2"></i>Create First Purchase
                                        </a>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>