<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Book" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    Book book = (Book) request.getAttribute("book");
    if (book == null) {
        response.sendRedirect("book?action=list");
        return;
    }
    
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= book.getTitle() %> - Bookshop System</title>
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
        .book-card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        .book-cover {
            background-color: #f1f3ff;
            border-radius: 10px;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 5rem;
            color: #6B73FF;
        }
        .info-item {
            margin-bottom: 1rem;
        }
        .info-label {
            font-weight: 600;
            color: #6c757d;
        }
        .stock-low {
            color: #dc3545;
            font-weight: bold;
        }
        .stock-ok {
            color: #28a745;
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
                <a class="nav-link" href="book?action=list">
                    <i class="fas fa-arrow-left me-1"></i>Back to Books
                </a>
            </div>
        </div>
    </nav>

    <!-- Page Header -->
    <div class="page-header">
        <div class="container">
            <h1 class="mb-0">
                <i class="fas fa-book-open me-3"></i><%= book.getTitle() %>
            </h1>
            <p class="mb-0 mt-2 opacity-75">Book Details</p>
        </div>
    </div>

    <div class="container">
        <div class="row">
            <div class="col-lg-4">
                <div class="card book-card mb-4">
                    <div class="card-body p-4">
                        <div class="book-cover">
                            <i class="fas fa-book"></i>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-lg-8">
                <div class="card book-card">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-start mb-4">
                            <div>
                                <h2 class="mb-1"><%= book.getTitle() %></h2>
                                <h4 class="text-muted"><%= book.getAuthor() %></h4>
                            </div>
                            <div>
                                <span class="badge bg-<%= book.getQuantity() == 0 ? "danger" : 
                                    book.getQuantity() <= book.getAlertQuantity() ? "warning text-dark" : "success" %>">
                                    <%= book.getQuantity() == 0 ? "Out of Stock" : 
                                        book.getQuantity() <= book.getAlertQuantity() ? "Low Stock" : "In Stock" %>
                                </span>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="info-item">
                                    <div class="info-label">ISBN</div>
                                    <div><%= book.getIsbn() %></div>
                                </div>
                                
                                <div class="info-item">
                                    <div class="info-label">Year Published</div>
                                    <div><%= book.getYearPublished() %></div>
                                </div>
                                
                                <div class="info-item">
                                    <div class="info-label">Purchase Price</div>
                                    <div>Rs <%= String.format("%.2f", book.getPurchasePrice()) %></div>
                                </div>
                            </div>
                            
                            <div class="col-md-6">
                                <div class="info-item">
                                    <div class="info-label">Selling Price</div>
                                    <div class="text-success">Rs <%= String.format("%.2f", book.getSellingPrice()) %></div>
                                </div>
                                
                                <div class="info-item">
                                    <div class="info-label">Current Stock</div>
                                    <div class="<%= book.getQuantity() <= book.getAlertQuantity() ? "stock-low" : "stock-ok" %>">
                                        <%= book.getQuantity() %>
                                        <% if (book.getQuantity() <= book.getAlertQuantity()) { %>
                                            <small>(Alert: <%= book.getAlertQuantity() %>)</small>
                                        <% } %>
                                    </div>
                                </div>
                                
                                <div class="info-item">
                                    <div class="info-label">Profit Margin</div>
                                    <div>
                                        <% 
                                            double profit = book.getSellingPrice() - book.getPurchasePrice();
                                            double margin = (profit / book.getPurchasePrice()) * 100;
                                        %>
                                        Rs <%= String.format("%.2f", profit) %> 
                                        (<%= String.format("%.1f", margin) %>%)
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <hr>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="info-item">
                                    <div class="info-label">Created</div>
                                    <div>
                                        <% if (book.getCreatedAt() != null) { %>
                                            <%= dateFormatter.format(book.getCreatedAt().toLocalDateTime()) %>
                                        <% } else { %>
                                            N/A
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="info-item">
                                    <div class="info-label">Last Updated</div>
                                    <div>
                                        <% if (book.getUpdatedAt() != null) { %>
                                            <%= dateFormatter.format(book.getUpdatedAt().toLocalDateTime()) %>
                                        <% } else { %>
                                            N/A
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="d-flex justify-content-end mt-4">
                            <a href="book?action=edit&id=<%= book.getId() %>" class="btn btn-primary me-2">
                                <i class="fas fa-edit me-2"></i>Edit Book
                            </a>
                            <a href="book?action=list" class="btn btn-outline-secondary">
                                <i class="fas fa-arrow-left me-2"></i>Back to List
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>