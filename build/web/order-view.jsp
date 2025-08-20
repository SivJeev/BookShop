<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Order" %>
<%@ page import="model.OrderStatusHistory" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Details - Bookshop System</title>
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
            margin-bottom: 30px;
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
        .timeline {
            position: relative;
            padding-left: 50px;
        }
        .timeline:before {
            content: '';
            position: absolute;
            left: 15px;
            top: 0;
            bottom: 0;
            width: 2px;
            background: #dee2e6;
        }
        .timeline-item {
            position: relative;
            margin-bottom: 20px;
        }
        .timeline-item:before {
            content: '';
            position: absolute;
            left: -38px;
            top: 5px;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background: #6B73FF;
            border: 2px solid white;
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
                <a class="nav-link" href="order?action=list">
                    <i class="fas fa-arrow-left me-1"></i>Back to Orders
                </a>
            </div>
        </div>
    </nav>

    <!-- Page Header -->
    <div class="page-header">
        <div class="container">
            <h1 class="mb-0">
                <i class="fas fa-file-invoice me-3"></i>Order Details
            </h1>
            <p class="mb-0 mt-2 opacity-75">View and manage order #${order.id}</p>
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

        <% 
        Order order = (Order) request.getAttribute("order");
        if (order != null) { 
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
        <div class="row">
            <div class="col-md-8">
                <!-- Order Summary Card -->
                <div class="card mb-4">
                    <div class="card-header bg-white">
                        <h5 class="card-title mb-0">
                            <i class="fas fa-shopping-cart me-2"></i>Order Items
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Item</th>
                                        <th>Price</th>
                                        <th>Qty</th>
                                        <th>Total</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (OrderItem item : order.getItems()) { %>
                                    <tr>
                                        <td>
                                            <strong><%= item.getBook().getTitle() %></strong><br>
                                            <small class="text-muted">ISBN: <%= item.getBook().getIsbn() %></small>
                                        </td>
                                        <td>$<%= String.format("%.2f", item.getUnitPrice()) %></td>
                                        <td><%= item.getQuantity() %></td>
                                        <td>$<%= String.format("%.2f", item.getTotalPrice()) %></td>
                                    </tr>
                                    <% } %>
                                </tbody>
                                <tfoot>
                                    <tr>
                                        <td colspan="3" class="text-end"><strong>Subtotal:</strong></td>
                                        <td>$<%= String.format("%.2f", order.getSubtotal()) %></td>
                                    </tr>
                                    <tr>
                                        <td colspan="3" class="text-end"><strong>Shipping:</strong></td>
                                        <td>$<%= String.format("%.2f", order.getShippingCost()) %></td>
                                    </tr>
                                    <tr>
                                        <td colspan="3" class="text-end"><strong>Tax:</strong></td>
                                        <td>$<%= String.format("%.2f", order.getTax()) %></td>
                                    </tr>
                                    <tr>
                                        <td colspan="3" class="text-end"><strong>Total:</strong></td>
                                        <td><strong>$<%= String.format("%.2f", order.getTotal()) %></strong></td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Status History Card -->
                <div class="card">
                    <div class="card-header bg-white">
                        <h5 class="card-title mb-0">
                            <i class="fas fa-history me-2"></i>Status History
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="timeline">
                            <% 
                            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                            for (OrderStatusHistory history : order.getStatusHistory()) { 
                                String statusBadgeClass = "";
                                switch(history.getStatus()) {
                                    case "ORDER_PLACED":
                                        statusBadgeClass = "badge-placed";
                                        break;
                                    case "PROCESSING":
                                        statusBadgeClass = "badge-processing";
                                        break;
                                    case "SHIPPED":
                                        statusBadgeClass = "badge-shipped";
                                        break;
                                    case "DELIVERED":
                                        statusBadgeClass = "badge-delivered";
                                        break;
                                }
                            %>
                            <div class="timeline-item">
                                <div class="d-flex justify-content-between">
                                    <span class="badge <%= statusBadgeClass %>">
                                        <%= history.getStatus().replace("_", " ") %>
                                    </span>
                                    <small class="text-muted"><%= dateFormat.format(history.getChangedAt()) %></small>
                                </div>
                                <% if (history.getNotes() != null && !history.getNotes().isEmpty()) { %>
                                    <p class="mt-2 mb-0"><%= history.getNotes() %></p>
                                <% } %>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <!-- Order Info Card -->
                <div class="card mb-4">
                    <div class="card-header bg-white">
                        <h5 class="card-title mb-0">
                            <i class="fas fa-info-circle me-2"></i>Order Information
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <h6 class="text-muted">Order Status</h6>
                            <span class="badge <%= badgeClass %> fs-6">
                                <%= order.getOrderStatus().replace("_", " ") %>
                            </span>
                        </div>
                        <div class="mb-3">
                            <h6 class="text-muted">Order Date</h6>
                            <p><%= dateFormat.format(order.getOrderDate()) %></p>
                        </div>
                        <div class="mb-3">
                            <h6 class="text-muted">Payment Method</h6>
                            <p><%= order.getPaymentMethod() %></p>
                        </div>
                        <div class="mb-3">
                            <h6 class="text-muted">Payment Status</h6>
                            <p><%= order.getPaymentStatus() %></p>
                        </div>
                        <% if (order.getTrackingNumber() != null && !order.getTrackingNumber().isEmpty()) { %>
                        <div class="mb-3">
                            <h6 class="text-muted">Tracking Number</h6>
                            <p><%= order.getTrackingNumber() %></p>
                        </div>
                        <% } %>
                        <% if (order.getNotes() != null && !order.getNotes().isEmpty()) { %>
                        <div class="mb-3">
                            <h6 class="text-muted">Notes</h6>
                            <p><%= order.getNotes() %></p>
                        </div>
                        <% } %>
                    </div>
                </div>

                <!-- Customer Info Card -->
                <div class="card mb-4">
                    <div class="card-header bg-white">
                        <h5 class="card-title mb-0">
                            <i class="fas fa-user me-2"></i>Customer Information
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <h6 class="text-muted">Name</h6>
                            <p><%= order.getCustomerName() %></p>
                        </div>
                        <div class="mb-3">
                            <h6 class="text-muted">Email</h6>
                            <p><%= order.getCustomerEmail() %></p>
                        </div>
                        <div class="mb-3">
                            <h6 class="text-muted">Phone</h6>
                            <p><%= order.getCustomerPhone() %></p>
                        </div>
                    </div>
                </div>

                <!-- Shipping Info Card -->
                <div class="card mb-4">
                    <div class="card-header bg-white">
                        <h5 class="card-title mb-0">
                            <i class="fas fa-truck me-2"></i>Shipping Information
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <h6 class="text-muted">Shipping Address</h6>
                            <p><%= order.getShippingAddress().replace("\n", "<br>") %></p>
                        </div>
                        <div class="mb-3">
                            <h6 class="text-muted">Billing Address</h6>
                            <p><%= order.getBillingAddress().replace("\n", "<br>") %></p>
                        </div>
                    </div>
                </div>

                <!-- Status Update Form -->
                <div class="card">
                    <div class="card-header bg-white">
                        <h5 class="card-title mb-0">
                            <i class="fas fa-sync-alt me-2"></i>Update Status
                        </h5>
                    </div>
                    <div class="card-body">
                        <form action="order?action=updateStatus" method="post">
                            <input type="hidden" name="orderId" value="<%= order.getId() %>">
                            <div class="mb-3">
                                <label for="newStatus" class="form-label">New Status</label>
                                <select class="form-select" id="newStatus" name="newStatus" required>
                                    <option value="PROCESSING">Processing</option>
                                    <option value="SHIPPED">Shipped</option>
                                    <option value="DELIVERED">Delivered</option>
                                </select>
                            </div>
                            <div class="mb-3" id="trackingNumberGroup" style="display: none;">
                                <label for="trackingNumber" class="form-label">Tracking Number</label>
                                <input type="text" class="form-control" id="trackingNumber" name="trackingNumber">
                            </div>
                            <div class="mb-3">
                                <label for="notes" class="form-label">Notes</label>
                                <textarea class="form-control" id="notes" name="notes" rows="2"></textarea>
                            </div>
                            <button type="submit" class="btn btn-primary w-100">
                                <i class="fas fa-save me-2"></i>Update Status
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
        <% } else { %>
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle me-2"></i>Order not found.
            </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Show/hide tracking number field based on status selection
        document.getElementById('newStatus').addEventListener('change', function() {
            const trackingGroup = document.getElementById('trackingNumberGroup');
            trackingGroup.style.display = this.value === 'SHIPPED' ? 'block' : 'none';
        });
    </script>
</body>
</html>