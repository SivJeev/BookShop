<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Book" %>
<%@ page import="java.util.List" %>
<%
    List<Book> books = (List<Book>) request.getAttribute("books");
    
    // Calculate statistics
    int totalBooks = 0;
    int lowStockBooks = 0;
    double totalInventoryValue = 0;
    
    if (books != null) {
        totalBooks = books.size();
        for (Book book : books) {
            if (book.getQuantity() <= book.getAlertQuantity()) {
                lowStockBooks++;
            }
            totalInventoryValue += book.getQuantity() * book.getPurchasePrice();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Books Management - Bookshop System</title>
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
                        <i class="fas fa-book me-3"></i>Books Management
                    </h1>
                    <p class="mb-0 mt-2 opacity-75">Manage book inventory and stock</p>
                </div>
                <div class="col-lg-4 text-lg-end">
                    <a href="book?action=add" class="btn btn-light btn-lg">
                        <i class="fas fa-plus me-2"></i>Add New Book
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

        <!-- Books Table -->
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Title</th>
                                <th>Author</th>
                                <th>Year</th>
                                <th>ISBN</th>
                                <th>Price</th>
                                <th>Stock</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (books != null && !books.isEmpty()) {
                                for (Book book : books) { %>
                                <tr>
                                    <td><%= book.getId() %></td>
                                    <td>
                                        <strong><%= book.getTitle() %></strong>
                                    </td>
                                    <td><%= book.getAuthor() %></td>
                                    <td><%= book.getYearPublished() %></td>
                                    <td><%= book.getIsbn() %></td>
                                    <td>
                                        <span class="text-success">Rs <%= String.format("%.2f", book.getSellingPrice()) %></span>
                                        <br>
                                        <small class="text-muted">Cost: Rs <%= String.format("%.2f", book.getPurchasePrice()) %></small>
                                    </td>
                                    <td class="<%= book.getQuantity() <= book.getAlertQuantity() ? "stock-low" : "stock-ok" %>">
                                        <%= book.getQuantity() %>
                                        <% if (book.getQuantity() <= book.getAlertQuantity()) { %>
                                            <br><small>(Alert: <%= book.getAlertQuantity() %>)</small>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (book.getQuantity() <= book.getAlertQuantity()) { %>
                                            <span class="badge bg-warning text-dark">
                                                <i class="fas fa-exclamation-triangle"></i> Low Stock
                                            </span>
                                        <% } else if (book.getQuantity() == 0) { %>
                                            <span class="badge bg-danger">
                                                <i class="fas fa-times-circle"></i> Out of Stock
                                            </span>
                                        <% } else { %>
                                            <span class="badge bg-success">
                                                <i class="fas fa-check-circle"></i> In Stock
                                            </span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <div class="btn-group" role="group">
                                            <a href="book?action=edit&id=<%= book.getId() %>" 
                                               class="btn btn-outline-primary btn-action" 
                                               title="Edit Book">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                            <a href="book?action=view&id=<%= book.getId() %>" 
                                               class="btn btn-outline-info btn-action" 
                                               title="View Details">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <a href="book?action=delete&id=<%= book.getId() %>" 
                                               class="btn btn-outline-danger btn-action" 
                                               title="Delete Book"
                                               onclick="return confirm('Are you sure you want to delete this book?')">
                                                <i class="fas fa-trash"></i>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            <% }
                            } else { %>
                                <tr>
                                    <td colspan="9" class="text-center py-5">
                                        <i class="fas fa-book fa-3x text-muted mb-3"></i>
                                        <p class="text-muted mb-0">No books found in inventory</p>
                                        <a href="book?action=add" class="btn btn-primary mt-3">
                                            <i class="fas fa-plus me-2"></i>Add First Book
                                        </a>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Summary Card -->
        <% if (books != null && !books.isEmpty()) { %>
        <div class="row mt-4">
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-primary"><%= totalBooks %></h3>
                        <p class="text-muted mb-0">Total Books</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-warning"><%= lowStockBooks %></h3>
                        <p class="text-muted mb-0">Low Stock</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-danger">
                            <% 
                                int outOfStock = 0;
                                for (Book book : books) {
                                    if (book.getQuantity() == 0) outOfStock++;
                                }
                            %>
                            <%= outOfStock %>
                        </h3>
                        <p class="text-muted mb-0">Out of Stock</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-success">Rs <%= String.format("%.2f", totalInventoryValue) %></h3>
                        <p class="text-muted mb-0">Inventory Value</p>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>