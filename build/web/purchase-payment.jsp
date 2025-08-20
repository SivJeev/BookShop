<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Purchase" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.NumberFormat" %>
<%
    Purchase purchase = (Purchase) request.getAttribute("purchase");
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Payment - Purchase #<%= purchase.getId() %></title>
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
        .form-card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        .form-control:focus {
            border-color: #6B73FF;
            box-shadow: 0 0 0 0.2rem rgba(107, 115, 255, 0.25);
        }
        .btn-primary {
            background: linear-gradient(135deg, #6B73FF 0%, #000DFF 100%);
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
                <a class="nav-link" href="purchase?action=view&id=<%= purchase.getId() %>">
                    <i class="fas fa-arrow-left me-1"></i>Back to Purchase
                </a>
            </div>
        </div>
    </nav>

    <!-- Page Header -->
    <div class="page-header">
        <div class="container">
            <h1 class="mb-0">
                <i class="fas fa-money-bill-wave me-3"></i>Add Payment
            </h1>
            <p class="mb-0 mt-2 opacity-75">Record payment for Purchase #<%= purchase.getId() %></p>
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

                <div class="card form-card">
                    <div class="card-body p-5">
                        <h4 class="card-title mb-4">Payment Information</h4>
                        
                        <div class="mb-4">
                            <p><strong>Purchase Total:</strong> <%= currencyFormat.format(purchase.getTotalAmount()) %></p>
                            <p><strong>Amount Paid:</strong> <%= currencyFormat.format(purchase.getPaidAmount()) %></p>
                            <p><strong>Amount Due:</strong> <%= currencyFormat.format(purchase.getTotalAmount() - purchase.getPaidAmount()) %></p>
                        </div>
                        
                        <form action="purchase" method="post">
                            <input type="hidden" name="action" value="addPayment">
                            <input type="hidden" name="id" value="<%= purchase.getId() %>">
                            
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="amount" class="form-label">
                                            <i class="fas fa-dollar-sign me-2"></i>Amount*
                                        </label>
                                        <div class="input-group">
                                            <span class="input-group-text">$</span>
                                            <input type="number" step="0.01" class="form-control" id="amount" 
                                                   name="amount" required min="0.01" 
                                                   max="<%= purchase.getTotalAmount() - purchase.getPaidAmount() %>">
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="paymentDate" class="form-label">
                                            <i class="fas fa-calendar-alt me-2"></i>Payment Date*
                                        </label>
                                        <input type="date" class="form-control" id="paymentDate" name="paymentDate" 
                                               value="<%= dateFormat.format(new java.util.Date()) %>" required>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="paymentMethod" class="form-label">
                                    <i class="fas fa-credit-card me-2"></i>Payment Method*
                                </label>
                                <select class="form-select" id="paymentMethod" name="paymentMethod" required>
                                    <option value="CASH">Cash</option>
                                    <option value="CARD">Card</option>
                                    <option value="BANK_TRANSFER">Bank Transfer</option>
                                </select>
                            </div>
                            
                            <div class="mb-4">
                                <label for="notes" class="form-label">
                                    <i class="fas fa-sticky-note me-2"></i>Notes
                                </label>
                                <textarea class="form-control" id="notes" name="notes" rows="2"></textarea>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6">
                                    <button type="submit" class="btn btn-primary btn-lg w-100">
                                        <i class="fas fa-save me-2"></i>Record Payment
                                    </button>
                                </div>
                                <div class="col-md-6">
                                    <a href="purchase?action=view&id=<%= purchase.getId() %>" class="btn btn-secondary btn-lg w-100">
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
        // Set max amount to due amount
        document.getElementById('amount').max = <%= purchase.getTotalAmount() - purchase.getPaidAmount() %>;
    </script>
</body>
</html>