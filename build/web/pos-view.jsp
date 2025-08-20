<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Sale" %>
<%@ page import="model.SaleProduct" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.NumberFormat" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sale Details - Bookshop System</title>
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
                    <a class="nav-link" href="pos?action=list">
                        <i class="fas fa-list me-1"></i>Sales History
                    </a>
                </div>
            </div>
        </nav>

        <!-- Page Header -->
        <div class="page-header">
            <div class="container">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h1 class="mb-0">
                            <i class="fas fa-receipt me-3"></i>Sale Details
                        </h1>
                        <p class="mb-0 mt-2 opacity-75">Transaction #<%= ((Sale) request.getAttribute("sale")).getId()%></p>
                    </div>
                    <div>
                        <button class="btn btn-light" onclick="window.print()">
                            <i class="fas fa-print me-1"></i> Print Receipt
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <div class="container">
            <% Sale sale = (Sale) request.getAttribute("sale");
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                NumberFormat currencyFormat = NumberFormat.getCurrencyInstance();
            %>

            <div class="row">
                <div class="col-md-8">
                    <div class="card mb-4">
                        <div class="card-body">
                            <h5 class="card-title"><i class="fas fa-list me-2"></i>Items Sold</h5>

                            <div class="table-responsive">
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>Book</th>
                                            <th>ISBN</th>
                                            <th>Qty</th>
                                            <th>Price</th>
                                            <th>Total</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (SaleProduct item : sale.getProducts()) {%>
                                        <tr>
                                            <td><%= item.getBook().getTitle()%></td>
                                            <td><%= item.getBook().getIsbn()%></td>
                                            <td><%= item.getQuantity()%></td>
                                            <td><%= currencyFormat.format(item.getUnitPrice())%></td>
                                            <td><%= currencyFormat.format(item.getTotalPrice())%></td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <% if (sale.getNotes() != null && !sale.getNotes().isEmpty()) {%>
                    <div class="card mb-4">
                        <div class="card-body">
                            <h5 class="card-title"><i class="fas fa-sticky-note me-2"></i>Notes</h5>
                            <p><%= sale.getNotes()%></p>
                        </div>
                    </div>
                    <% }%>
                </div>

                <div class="col-md-4">
                    <div class="card mb-4">
                        <div class="card-body">
                            <h5 class="card-title"><i class="fas fa-info-circle me-2"></i>Transaction Details</h5>

                            <div class="mb-3">
                                <p class="mb-1"><strong>Date:</strong> <%= dateFormat.format(sale.getSaleDate())%></p>
                                <p class="mb-1"><strong>Transaction ID:</strong> <%= sale.getId()%></p>
                                <p class="mb-1"><strong>Cashier:</strong> <%= sale.getUser().getFullName()%></p>
                            </div>

                            <% if (sale.getCustomerName() != null && !sale.getCustomerName().isEmpty()) {%>
                            <div class="mb-3">
                                <h6 class="card-subtitle mb-2">Customer Information</h6>
                                <p class="mb-1"><strong>Name:</strong> <%= sale.getCustomerName()%></p>
                                <% if (sale.getCustomerEmail() != null && !sale.getCustomerEmail().isEmpty()) {%>
                                <p class="mb-1"><strong>Email:</strong> <%= sale.getCustomerEmail()%></p>
                                <% } %>
                            </div>
                            <% } %>

                            <div class="mb-3">
                                <h6 class="card-subtitle mb-2">Payment Information</h6>
                                <%
                                    String badgeClass = "";
                                    if ("CASH".equals(sale.getPaymentMethod())) {
                                        badgeClass = "bg-success";
                                    } else if ("CARD".equals(sale.getPaymentMethod())) {
                                        badgeClass = "bg-info";
                                    } else {
                                        badgeClass = "bg-primary";
                                    }
                                %>
                                <p class="mb-1">
                                    <strong>Method:</strong> 
                                    <span class="badge <%= badgeClass%> payment-badge">
                                        <%= sale.getPaymentMethod()%>
                                    </span>
                                </p>

                                <% if ("CASH".equals(sale.getPaymentMethod()) || "MIXED".equals(sale.getPaymentMethod())) {%>
                                <p class="mb-1"><strong>Cash Amount:</strong> <%= currencyFormat.format(sale.getCashAmount())%></p>
                                <% } %>

                                <% if ("CARD".equals(sale.getPaymentMethod()) || "MIXED".equals(sale.getPaymentMethod())) {%>
                                <p class="mb-1"><strong>Card Amount:</strong> <%= currencyFormat.format(sale.getCardAmount())%></p>
                                <% }%>
                            </div>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-body">
                            <h5 class="card-title"><i class="fas fa-file-invoice-dollar me-2"></i>Summary</h5>

                            <div class="receipt">
                                <div class="receipt-header">
                                    <h4>Bookshop</h4>
                                    <p class="mb-1">123 Book Street, City</p>
                                    <p class="mb-1">Tel: (123) 456-7890</p>
                                    <p class="mb-1">Transaction #<%= sale.getId()%></p>
                                    <p><%= dateFormat.format(sale.getSaleDate())%></p>
                                </div>

                                <div class="mb-3">
                                    <% for (SaleProduct item : sale.getProducts()) {%>
                                    <div class="receipt-item">
                                        <span><%= item.getQuantity()%> x <%= item.getBook().getTitle()%></span>
                                        <span><%= currencyFormat.format(item.getTotalPrice())%></span>
                                    </div>
                                    <% }%>
                                </div>

                                <div class="receipt-item">
                                    <span>Subtotal:</span>
                                    <span><%= currencyFormat.format(sale.getSubtotal())%></span>
                                </div>
                                <div class="receipt-item">
                                    <span>Tax (10%):</span>
                                    <span><%= currencyFormat.format(sale.getTax())%></span>
                                </div>
                                <div class="receipt-item">
                                    <span>Discount:</span>
                                    <span><%= currencyFormat.format(sale.getDiscount())%></span>
                                </div>
                                <div class="receipt-item receipt-total">
                                    <span>Total:</span>
                                    <span><%= currencyFormat.format(sale.getTotal())%></span>
                                </div>

                                <div class="mt-3 text-center">
                                    <p class="mb-1">Thank you for your purchase!</p>
                                    <p>Please come again</p>
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