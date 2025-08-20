<%@page import="model.OrderItem"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Order" %>
<%@ page import="model.OrderStatusHistory" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Status - Bookshop</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary: #6B73FF;
            --primary-dark: #000DFF;
            --secondary: #f8f9fa;
        }
        body { background-color: #f8f9fa; }
        .order-header {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: white;
            padding: 2rem 0;
            margin-bottom: 2rem;
            border-radius: 0 0 1rem 1rem;
        }
        .status-card {
            border: none;
            border-radius: 1rem;
            box-shadow: 0 0.5rem 1rem rgba(0,0,0,0.1);
            transition: transform 0.3s;
        }
        .status-card:hover {
            transform: translateY(-5px);
        }
        .status-badge {
            padding: 0.5rem 1rem;
            border-radius: 2rem;
            font-weight: 600;
        }
        .status-placed {
            background-color: #17a2b8;
            color: white;
        }
        .status-processing {
            background-color: #ffc107;
            color: #212529;
        }
        .status-shipped {
            background-color: #fd7e14;
            color: white;
        }
        .status-delivered {
            background-color: #28a745;
            color: white;
        }
        .timeline {
            position: relative;
            padding-left: 2.5rem;
        }
        .timeline::before {
            content: '';
            position: absolute;
            left: 0.75rem;
            top: 0;
            bottom: 0;
            width: 3px;
            background: #e9ecef;
        }
        .timeline-item {
            position: relative;
            margin-bottom: 1.5rem;
        }
        .timeline-item::before {
            content: '';
            position: absolute;
            left: -2.25rem;
            top: 0.25rem;
            width: 1rem;
            height: 1rem;
            border-radius: 50%;
            background: var(--primary);
            border: 3px solid white;
            z-index: 1;
        }
        .tracking-input {
            max-width: 400px;
            margin: 0 auto;
        }
        .order-item {
            border-bottom: 1px solid #eee;
            padding: 1rem 0;
        }
        .order-item:last-child {
            border-bottom: none;
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark" style="background-color: var(--primary-dark);">
        <div class="container">
            <a class="navbar-brand fw-bold" href="index.jsp">
                <i class="fas fa-book me-2"></i>Bookshop
            </a>
            <div class="d-flex">
                <a href="index.jsp" class="btn btn-outline-light">
                    <i class="fas fa-home me-1"></i> Home
                </a>
            </div>
        </div>
    </nav>

    <!-- Page Header -->
    <header class="order-header">
        <div class="container text-center">
            <h1 class="display-5 fw-bold mb-3">
                <i class="fas fa-clipboard-list me-2"></i>Your Order Status
            </h1>
            <p class="lead mb-0">Track your book order details</p>
        </div>
    </header>

    <main class="container mb-5">
        <% 
        Order order = (Order) request.getAttribute("order");
        if (order != null) { 
            String statusClass = "";
            String statusText = "";
            switch(order.getOrderStatus()) {
                case "ORDER_PLACED":
                    statusClass = "status-placed";
                    statusText = "Order Placed";
                    break;
                case "PROCESSING":
                    statusClass = "status-processing";
                    statusText = "Processing";
                    break;
                case "SHIPPED":
                    statusClass = "status-shipped";
                    statusText = "Shipped";
                    break;
                case "DELIVERED":
                    statusClass = "status-delivered";
                    statusText = "Delivered";
                    break;
            }
        %>
        <div class="row justify-content-center">
            <div class="col-lg-10">
                <!-- Order Summary Card -->
                <div class="card status-card mb-4">
                    <div class="card-body">
                        <div class="row align-items-center">
                            <div class="col-md-6 mb-3 mb-md-0">
                                <h3 class="card-title mb-3">Order #<%= order.getId() %></h3>
                                <div class="d-flex flex-wrap gap-2">
                                    <span class="status-badge <%= statusClass %>">
                                        <i class="fas fa-circle me-1 small"></i> <%= statusText %>
                                    </span>
                                    <% if (order.getTrackingNumber() != null && !order.getTrackingNumber().isEmpty()) { %>
                                    <span class="status-badge bg-dark text-white">
                                        <i class="fas fa-truck me-1"></i> <%= order.getTrackingNumber() %>
                                    </span>
                                    <% } %>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="row">
                                    <div class="col-6">
                                        <p class="mb-1 text-muted small">Order Date</p>
                                        <p class="fw-bold"><%= new SimpleDateFormat("MMM d, yyyy").format(order.getOrderDate()) %></p>
                                    </div>
                                    <div class="col-6">
                                        <p class="mb-1 text-muted small">Total Amount</p>
                                        <p class="fw-bold">$<%= String.format("%.2f", order.getTotal()) %></p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Delivery Progress -->
                <div class="card status-card mb-4">
                    <div class="card-header bg-white">
                        <h5 class="mb-0"><i class="fas fa-truck-fast me-2"></i>Delivery Progress</h5>
                    </div>
                    <div class="card-body">
                        <div class="timeline">
                            <% 
                            SimpleDateFormat dateFormat = new SimpleDateFormat("MMM d, h:mm a");
                            for (OrderStatusHistory history : order.getStatusHistory()) { 
                                String itemStatusClass = "";
                                switch(history.getStatus()) {
                                    case "ORDER_PLACED":
                                        itemStatusClass = "status-placed";
                                        break;
                                    case "PROCESSING":
                                        itemStatusClass = "status-processing";
                                        break;
                                    case "SHIPPED":
                                        itemStatusClass = "status-shipped";
                                        break;
                                    case "DELIVERED":
                                        itemStatusClass = "status-delivered";
                                        break;
                                }
                            %>
                            <div class="timeline-item">
                                <div class="d-flex justify-content-between">
                                    <span class="status-badge <%= itemStatusClass %> small">
                                        <%= history.getStatus().replace("_", " ") %>
                                    </span>
                                   <small class="text-muted"><%= dateFormat.format(history.getTimestamp()) %></small>
                                </div>
                                <% if (history.getNotes() != null && !history.getNotes().isEmpty()) { %>
                                    <p class="mt-2 mb-0 small"><%= history.getNotes() %></p>
                                <% } %>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>

                <!-- Order Items -->
                <div class="card status-card mb-4">
                    <div class="card-header bg-white">
                        <h5 class="mb-0"><i class="fas fa-boxes me-2"></i>Order Items</h5>
                    </div>
                    <div class="card-body">
                        <% for (OrderItem item : order.getItems()) { %>
                        <div class="order-item">
                            <div class="row align-items-center">
                                <div class="col-md-6 mb-2 mb-md-0">
                                    <h6 class="mb-1"><%= item.getBook().getTitle() %></h6>
                                    <small class="text-muted">ISBN: <%= item.getBook().getIsbn() %></small>
                                </div>
                                <div class="col-md-6">
                                    <div class="row text-end">
                                        <div class="col-4">
                                            <p class="mb-0">$<%= String.format("%.2f", item.getUnitPrice()) %></p>
                                        </div>
                                        <div class="col-4">
                                            <p class="mb-0">x<%= item.getQuantity() %></p>
                                        </div>
                                        <div class="col-4">
                                            <p class="mb-0 fw-bold">$<%= String.format("%.2f", item.getTotalPrice()) %></p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <% } %>
                        
                        <div class="mt-3 pt-3 border-top">
                            <div class="row justify-content-end">
                                <div class="col-md-6">
                                    <div class="d-flex justify-content-between mb-2">
                                        <span>Subtotal:</span>
                                        <span>$<%= String.format("%.2f", order.getSubtotal()) %></span>
                                    </div>
                                    <div class="d-flex justify-content-between mb-2">
                                        <span>Shipping:</span>
                                        <span>$<%= String.format("%.2f", order.getShippingCost()) %></span>
                                    </div>
                                    <div class="d-flex justify-content-between mb-2">
                                        <span>Tax:</span>
                                        <span>$<%= String.format("%.2f", order.getTax()) %></span>
                                    </div>
                                    <div class="d-flex justify-content-between fw-bold fs-5 mt-2">
                                        <span>Total:</span>
                                        <span>$<%= String.format("%.2f", order.getTotal()) %></span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Customer Information -->
                <div class="row">
                    <div class="col-md-6 mb-4 mb-md-0">
                        <div class="card status-card h-100">
                            <div class="card-header bg-white">
                                <h5 class="mb-0"><i class="fas fa-user me-2"></i>Customer Information</h5>
                            </div>
                            <div class="card-body">
                                <p class="mb-2"><strong><%= order.getCustomerName() %></strong></p>
                                <p class="mb-2"><%= order.getCustomerEmail() %></p>
                                <p class="mb-0"><%= order.getCustomerPhone() %></p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card status-card h-100">
                            <div class="card-header bg-white">
                                <h5 class="mb-0"><i class="fas fa-truck me-2"></i>Shipping Information</h5>
                            </div>
                            <div class="card-body">
                                <p class="mb-2"><strong>Shipping Address:</strong></p>
                                <p class="mb-3"><%= order.getShippingAddress().replace("\n", "<br>") %></p>
                                <% if (!order.getShippingAddress().equals(order.getBillingAddress())) { %>
                                <p class="mb-2"><strong>Billing Address:</strong></p>
                                <p class="mb-0"><%= order.getBillingAddress().replace("\n", "<br>") %></p>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <% } else { %>
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card status-card">
                    <div class="card-body text-center py-5">
                        <i class="fas fa-exclamation-circle fa-3x text-danger mb-4"></i>
                        <h3 class="mb-3">Order Not Found</h3>
                        <p class="text-muted mb-4">We couldn't find an order with that ID. Please check your order number and try again.</p>
                        <a href="index.jsp" class="btn btn-primary">
                            <i class="fas fa-home me-2"></i>Return to Home
                        </a>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
    </main>

    <footer class="bg-light py-4 mt-5">
        <div class="container text-center">
            <p class="text-muted mb-0">&copy; 2023 Bookshop. All rights reserved.</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Track order form functionality
        document.addEventListener('DOMContentLoaded', function() {
            const trackForm = document.getElementById('trackForm');
            if (trackForm) {
                trackForm.addEventListener('submit', function(e) {
                    const orderId = document.getElementById('orderId').value.trim();
                    const email = document.getElementById('email').value.trim();
                    
                    if (!orderId || !email) {
                        e.preventDefault();
                        alert('Please enter both order ID and email address');
                    }
                });
            }
        });
    </script>
</body>
</html>