<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Sale" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sales History - Bookshop System</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <style>
            body {
                background-color: #f8f9fa;
            }
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
            .badge-cash {
                background-color: #28a745;
            }
            .badge-card {
                background-color: #17a2b8;
            }
            .badge-mixed {
                background-color: #6f42c1;
            }
            /* POS specific styles */
            .pos-container {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
                height: calc(100vh - 150px);
            }

            .products-section {
                background: white;
                border-radius: 10px;
                padding: 20px;
                box-shadow: 0 0 10px rgba(0,0,0,0.1);
                overflow-y: auto;
            }

            .cart-section {
                background: white;
                border-radius: 10px;
                padding: 20px;
                box-shadow: 0 0 10px rgba(0,0,0,0.1);
                display: flex;
                flex-direction: column;
            }

            .cart-items {
                flex-grow: 1;
                overflow-y: auto;
            }

            .cart-summary {
                border-top: 1px solid #eee;
                padding-top: 15px;
            }

            .product-card {
                border: 1px solid #eee;
                border-radius: 8px;
                padding: 15px;
                margin-bottom: 15px;
                transition: all 0.3s ease;
            }

            .product-card:hover {
                transform: translateY(-3px);
                box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            }

            .cart-item {
                border-bottom: 1px solid #eee;
                padding: 10px 0;
            }

            /* Payment method badges */
            .badge-cash {
                background-color: #28a745;
            }

            .badge-card {
                background-color: #17a2b8;
            }

            .badge-mixed {
                background-color: #6f42c1;
            }

            /* POS specific buttons */
            .btn-pos-primary {
                background: linear-gradient(135deg, #6B73FF 0%, #000DFF 100%);
                color: white;
                border: none;
            }

            .btn-pos-danger {
                background: linear-gradient(135deg, #FF6B6B 0%, #FF0000 100%);
                color: white;
                border: none;
            }

            .btn-pos-success {
                background: linear-gradient(135deg, #4CAF50 0%, #2E7D32 100%);
                color: white;
                border: none;
            }

            /* Receipt styling */
            .receipt {
                max-width: 500px;
                margin: 0 auto;
                border: 1px dashed #ccc;
                padding: 20px;
            }

            .receipt-header {
                text-align: center;
                border-bottom: 1px dashed #ccc;
                padding-bottom: 10px;
                margin-bottom: 15px;
            }

            .receipt-item {
                display: flex;
                justify-content: space-between;
                margin-bottom: 5px;
            }

            .receipt-total {
                border-top: 1px dashed #ccc;
                padding-top: 10px;
                margin-top: 10px;
                font-weight: bold;
            }

            .payment-badge {
                font-size: 1rem;
                padding: 0.5rem;
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
                    <a class="nav-link" href="pos?action=new">
                        <i class="fas fa-cash-register me-1"></i>New Sale
                    </a>
                </div>
            </div>
        </nav>

        <!-- Page Header -->
        <div class="page-header">
            <div class="container">
                <h1 class="mb-0">
                    <i class="fas fa-history me-3"></i>Sales History
                </h1>
                <p class="mb-0 mt-2 opacity-75">View all completed sales transactions</p>
            </div>
        </div>

        <div class="container">
            <div class="card">
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>Sale ID</th>
                                    <th>Date</th>
                                    <th>Customer</th>
                                    <th>Items</th>
                                    <th>Total</th>
                                    <th>Payment</th>
                                    <th>Cashier</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                                    for (Sale sale : (List<Sale>) request.getAttribute("sales")) {
                                %>
                                <tr>
                                    <td><%= sale.getId()%></td>
                                    <td><%= dateFormat.format(sale.getSaleDate())%></td>
                                    <td>
                                        <% if (sale.getCustomerName() != null && !sale.getCustomerName().isEmpty()) {%>
                                        <%= sale.getCustomerName()%>
                                        <% } else { %>
                                        <span class="text-muted">Walk-in</span>
                                        <% }%>
                                    </td>
                                    <td><%= sale.getProducts().size()%></td>
                                    <td>$<%= String.format("%.2f", sale.getTotal())%></td>
                                    <td>
                                        <%
                                            String badgeClass = "";
                                            if ("CASH".equals(sale.getPaymentMethod())) {
                                                badgeClass = "badge-cash";
                                            } else if ("CARD".equals(sale.getPaymentMethod())) {
                                                badgeClass = "badge-card";
                                            } else {
                                                badgeClass = "badge-mixed";
                                            }
                                        %>
                                        <span class="badge <%= badgeClass%>">
                                            <%= sale.getPaymentMethod()%>
                                        </span>
                                    </td>
                                    <td><%= sale.getUser().getFullName()%></td>
                                    <td>
                                        <a href="pos?action=view&id=<%= sale.getId()%>" class="btn btn-sm btn-outline-primary">
                                            <i class="fas fa-eye"></i> View
                                        </a>
                                    </td>
                                </tr>
                                <% }%>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>