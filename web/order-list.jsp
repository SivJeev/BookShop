<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Order" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Management - Bookshop System</title>
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
        .card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        .table-responsive {
            border-radius: 10px;
            overflow: hidden;
        }
        .table thead th {
            background-color: #6B73FF;
            color: white;
        }
        .badge-placed {
            background-color: #17a2b8;
        }
        .badge-processing {
            background-color: #ffc107;
            color: #212529;
        }
        .badge-shipped {
            background-color: #fd7e14;
        }
        .badge-delivered {
            background-color: #28a745;
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
                <a class="nav-link" href="order?action=new">
                    <i class="fas fa-plus-circle me-1"></i>New Order
                </a>
            </div>
        </div>
    </nav>

    <!-- Page Header -->
    <div class="page-header">
        <div class="container">
            <h1 class="mb-0">
                <i class="fas fa-clipboard-list me-3"></i>Order Management
            </h1>
            <p class="mb-0 mt-2 opacity-75">View and manage all customer orders</p>
        </div>
    </div>

    <div class="container">
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

        <div class="card">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>Order ID</th>
                                <th>Date</th>
                                <th>Customer</th>
                                <th>Items</th>
                                <th>Total</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                            for (Order order : (List<Order>) request.getAttribute("orders")) { 
                                String badgeClass = "";
                                switch(order.getOrderStatus()) {
                                    case "ORDER_PLACED":
                                        badgeClass = "badge-placed";
                                        break;
                                    case "PROCESSING":
                                        badgeClass = "badge-processing";
                                        break;
                                    case "SHIPPED":
                                        badgeClass = "badge-shipped";
                                        break;
                                    case "DELIVERED":
                                        badgeClass = "badge-delivered";
                                        break;
                                }
                            %>
                                <tr>
                                    <td><%= order.getId() %></td>
                                    <td><%= dateFormat.format(order.getOrderDate()) %></td>
                                    <td><%= order.getCustomerName() %></td>
                                    <td><%= order.getItems() != null ? order.getItems().size() : 0 %></td>
                                    <td>$<%= String.format("%.2f", order.getTotal()) %></td>
                                    <td>
                                        <span class="badge <%= badgeClass %>">
                                            <%= order.getOrderStatus().replace("_", " ") %>
                                        </span>
                                    </td>
                                    <td>
                                        <a href="order?action=view&id=<%= order.getId() %>" class="btn btn-sm btn-outline-primary">
                                            <i class="fas fa-eye"></i> View
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