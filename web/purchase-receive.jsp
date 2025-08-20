<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Purchase" %>
<%@ page import="model.PurchaseItem" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%
    Purchase purchase = (Purchase) request.getAttribute("purchase");
    List<PurchaseItem> items = purchase.getItems();
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Receive Items - Purchase #<%= purchase.getId() %></title>
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
                <i class="fas fa-check-circle me-3"></i>Receive Items
            </h1>
            <p class="mb-0 mt-2 opacity-75">Record received items for Purchase #<%= purchase.getId() %></p>
        </div>
    </div>

    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-10">
                <!-- Display Messages -->
                <% if (request.getAttribute("errorMessage") != null) { %>
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i>
                        <%= request.getAttribute("errorMessage") %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>

                <div class="card form-card">
                    <div class="card-body p-4">
                        <h4 class="card-title mb-4">Received Items</h4>
                        
                        <form action="purchase" method="post">
                            <input type="hidden" name="action" value="receive">
                            <input type="hidden" name="id" value="<%= purchase.getId() %>">
                            
                            <div class="table-responsive mb-4">
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>Book</th>
                                            <th>Ordered</th>
                                            <th>Already Received</th>
                                            <th>Receive Now</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (PurchaseItem item : items) { %>
                                            <tr>
                                                <td>
                                                    <strong><%= item.getBookTitle() %></strong>
                                                    <p class="mb-0 text-muted"><%= item.getBookAuthor() %></p>
                                                    <small class="text-muted"><%= item.getBookIsbn() %></small>
                                                    <input type="hidden" name="itemId" value="<%= item.getId() %>">
                                                </td>
                                                <td><%= item.getQuantity() %></td>
                                                <td>
                                                    <% if (item.getReceivedQuantity() > 0) { %>
                                                        <span class="received-qty"><%= item.getReceivedQuantity() %></span>
                                                    <% } else { %>
                                                        0
                                                    <% } %>
                                                </td>
                                                <td width="150">
                                                    <input type="number" class="form-control" name="receivedQuantity" 
                                                           value="0" min="0" max="<%= item.getQuantity() - item.getReceivedQuantity() %>">
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6">
                                    <button type="submit" class="btn btn-primary btn-lg w-100">
                                        <i class="fas fa-save me-2"></i>Record Receipt
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
</body>
</html>