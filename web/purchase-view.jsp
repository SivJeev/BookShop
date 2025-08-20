<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Purchase" %>
<%@ page import="model.PurchaseItem" %>
<%@ page import="model.PurchasePayment" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.NumberFormat" %>
<%
    Purchase purchase = (Purchase) request.getAttribute("purchase");
    List<PurchaseItem> items = purchase.getItems();
    List<PurchasePayment> payments = purchase.getPayments();
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    SimpleDateFormat datetimeFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Purchase #<%= purchase.getId() %> - Bookshop System</title>
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
        .info-card {
            border-left: 4px solid #6B73FF;
        }
        .status-ordered { background-color: #fff3cd; color: #856404; }
        .status-received { background-color: #d4edda; color: #155724; }
        .status-cancelled { background-color: #f8d7da; color: #721c24; }
        .status-partial { background-color: #e2e3e5; color: #383d41; }
        .payment-pending { color: #dc3545; }
        .payment-partial { color: #ffc107; }
        .payment-paid { color: #28a745; }
        .received-qty {
            color: #28a745;
            font-weight: bold;
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
                <a class="nav-link" href="purchase?action=list">
                    <i class="fas fa-arrow-left me-1"></i>Back to Purchases
                </a>
            </div>
        </div>
    </nav>

    <!-- Page Header -->
    <div class="page-header">
        <div class="container">
            <h1 class="mb-0">
                <i class="fas fa-shopping-cart me-3"></i>Purchase #<%= purchase.getId() %>
            </h1>
            <p class="mb-0 mt-2 opacity-75">Purchase details</p>
        </div>
    </div>

    <div class="container">
        <div class="row">
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

                <!-- Purchase Details -->
                <div class="card mb-4">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-start mb-4">
                            <div>
                                <h3 class="mb-1">Supplier: <%= purchase.getSupplierName() %></h3>
                                <p class="text-muted mb-0">Purchase Date: <%= dateFormat.format(purchase.getPurchaseDate()) %></p>
                                <% if (purchase.getExpectedDeliveryDate() != null) { %>
                                    <p class="text-muted">Expected Delivery: <%= dateFormat.format(purchase.getExpectedDeliveryDate()) %></p>
                                <% } %>
                            </div>
                            <div class="text-end">
                                <span class="badge status-<%= purchase.getStatus().toLowerCase().replace("_", "-") %>">
                                    <%= purchase.getStatus().replace("_", " ") %>
                                </span>
                                <p class="mt-2 mb-0">
                                    <span class="fw-bold payment-<%= purchase.getPaymentStatus().toLowerCase() %>">
                                        <%= purchase.getPaymentStatus() %>
                                    </span>
                                </p>
                            </div>
                        </div>
                        
                        <div class="table-responsive mb-4">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Book</th>
                                        <th>Quantity</th>
                                        <th>Unit Price</th>
                                        <th>Total</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (PurchaseItem item : items) { %>
                                        <tr>
                                            <td>
                                                <strong><%= item.getBookTitle() %></strong>
                                                <p class="mb-0 text-muted"><%= item.getBookAuthor() %></p>
                                                <small class="text-muted"><%= item.getBookIsbn() %></small>
                                            </td>
                                            <td>
                                                <%= item.getQuantity() %>
                                                <% if (item.getReceivedQuantity() > 0) { %>
                                                    <br><small class="received-qty">Received: <%= item.getReceivedQuantity() %></small>
                                                <% } %>
                                            </td>
                                            <td><%= currencyFormat.format(item.getUnitPrice()) %></td>
                                            <td><%= currencyFormat.format(item.getTotalPrice()) %></td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6 offset-md-6">
                                <table class="table table-borderless">
                                    <tr>
                                        <th>Subtotal:</th>
                                        <td class="text-end"><%= currencyFormat.format(purchase.getTotalAmount() - purchase.getShippingCost() - purchase.getTax() + purchase.getDiscount()) %></td>
                                    </tr>
                                    <tr>
                                        <th>Shipping:</th>
                                        <td class="text-end"><%= currencyFormat.format(purchase.getShippingCost()) %></td>
                                    </tr>
                                    <tr>
                                        <th>Tax:</th>
                                        <td class="text-end"><%= currencyFormat.format(purchase.getTax()) %></td>
                                    </tr>
                                    <tr>
                                        <th>Discount:</th>
                                        <td class="text-end"><%= currencyFormat.format(purchase.getDiscount()) %></td>
                                    </tr>
                                    <tr class="border-top">
                                        <th>Total:</th>
                                        <td class="text-end fw-bold"><%= currencyFormat.format(purchase.getTotalAmount()) %></td>
                                    </tr>
                                    <tr>
                                        <th>Paid:</th>
                                        <td class="text-end"><%= currencyFormat.format(purchase.getPaidAmount()) %></td>
                                    </tr>
                                    <tr class="border-top">
                                        <th>Due:</th>
                                        <td class="text-end fw-bold"><%= currencyFormat.format(purchase.getTotalAmount() - purchase.getPaidAmount()) %></td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                        
                        <% if (purchase.getNotes() != null && !purchase.getNotes().isEmpty()) { %>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Notes:</label>
                                <p><%= purchase.getNotes() %></p>
                            </div>
                        <% } %>
                        
                        <div class="d-flex justify-content-end mt-4">
                            <% if (!purchase.getStatus().equals("RECEIVED") && !purchase.getStatus().equals("CANCELLED")) { %>
                                <a href="purchase?action=receive&id=<%= purchase.getId() %>" class="btn btn-success me-2">
                                    <i class="fas fa-check-circle me-2"></i>Receive Items
                                </a>
                            <% } %>
                            
                            <% if (purchase.getTotalAmount() > purchase.getPaidAmount()) { %>
                                <a href="purchase?action=addPayment&id=<%= purchase.getId() %>" class="btn btn-primary me-2">
                                    <i class="fas fa-money-bill-wave me-2"></i>Add Payment
                                </a>
                            <% } %>
                            
                            <a href="purchase?action=edit&id=<%= purchase.getId() %>" class="btn btn-outline-primary me-2">
                                <i class="fas fa-edit me-2"></i>Edit
                            </a>
                            <a href="purchase?action=list" class="btn btn-outline-secondary">
                                <i class="fas fa-arrow-left me-2"></i>Back to List
                            </a>
                        </div>
                    </div>
                </div>
                
                <!-- Payments -->
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title mb-4">
                            <i class="fas fa-money-bill-wave me-2"></i>Payments
                        </h5>
                        
                        <% if (payments != null && !payments.isEmpty()) { %>
                            <div class="table-responsive">
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>Date</th>
                                            <th>Amount</th>
                                            <th>Method</th>
                                            <th>Recorded By</th>
                                            <th>Notes</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (PurchasePayment payment : payments) { %>
                                            <tr>
                                                <td><%= dateFormat.format(payment.getPaymentDate()) %></td>
                                                <td><%= currencyFormat.format(payment.getAmount()) %></td>
                                                <td><%= payment.getPaymentMethod() %></td>
                                                <td><%= payment.getCreatedByName() %></td>
                                                <td><%= payment.getNotes() != null ? payment.getNotes() : "" %></td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        <% } else { %>
                            <p class="text-muted">No payments recorded for this purchase.</p>
                        <% } %>
                    </div>
                </div>
            </div>
            
            <div class="col-lg-4">
                <!-- Purchase Summary -->
                <div class="card info-card mb-4">
                    <div class="card-body">
                        <h5 class="card-title">
                            <i class="fas fa-info-circle me-2"></i>Purchase Summary
                        </h5>
                        
                        <p><strong>Purchase ID:</strong> <%= purchase.getId() %></p>
                        <p><strong>Supplier:</strong> <%= purchase.getSupplierName() %></p>
                        <p><strong>Created By:</strong> <%= purchase.getCreatedByName() %></p>
                        <p><strong>Created At:</strong> <%= datetimeFormat.format(purchase.getCreatedAt()) %></p>
                        <p><strong>Last Updated:</strong> <%= datetimeFormat.format(purchase.getUpdatedAt()) %></p>
                        <p><strong>Payment Method:</strong> <%= purchase.getPaymentMethod() %></p>
                    </div>
                </div>
                
                <!-- Status Actions -->
                <div class="card info-card">
                    <div class="card-body">
                        <h5 class="card-title">
                            <i class="fas fa-tasks me-2"></i>Status Actions
                        </h5>
                        
                        <% if (!purchase.getStatus().equals("CANCELLED")) { %>
                            <form action="purchase" method="post" class="mb-3">
                                <input type="hidden" name="action" value="updateStatus">
                                <input type="hidden" name="id" value="<%= purchase.getId() %>">
                                
                                <div class="mb-3">
                                    <label class="form-label">Change Status</label>
                                    <select class="form-select" name="status">
                                        <option value="ORDERED" <%= purchase.getStatus().equals("ORDERED") ? "selected" : "" %>>Ordered</option>
                                        <option value="RECEIVED" <%= purchase.getStatus().equals("RECEIVED") ? "selected" : "" %>>Received</option>
                                        <option value="CANCELLED">Cancelled</option>
                                    </select>
                                </div>
                                
                                <button type="submit" class="btn btn-warning w-100">
                                    <i class="fas fa-sync-alt me-2"></i>Update Status
                                </button>
                            </form>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>