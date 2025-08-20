<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Book" %>
<%
    Book book = (Book) request.getAttribute("book");
    if (book == null) {
        response.sendRedirect("book?action=list");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Book - Bookshop System</title>
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
        .info-card {
            border-left: 4px solid #6B73FF;
        }
        .img-thumbnail {
            max-height: 200px;
        }
        #newImagePreview {
            display: none;
            max-height: 200px;
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
                <i class="fas fa-book-edit me-3"></i>Edit Book
            </h1>
            <p class="mb-0 mt-2 opacity-75">Update book information</p>
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

                <div class="card form-card">
                    <div class="card-body p-4">
                        <h4 class="card-title mb-4">Book Information</h4>
                        
                        <form action="book" method="post" enctype="multipart/form-data">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="id" value="<%= book.getId() %>">
                            
                            <div class="mb-3">
                                <label for="title" class="form-label">
                                    <i class="fas fa-heading me-2"></i>Title*
                                </label>
                                <input type="text" class="form-control" id="title" name="title" 
                                       value="<%= book.getTitle() %>" required maxlength="255">
                            </div>

                            <div class="mb-3">
                                <label for="author" class="form-label">
                                    <i class="fas fa-user-edit me-2"></i>Author*
                                </label>
                                <input type="text" class="form-control" id="author" name="author" 
                                       value="<%= book.getAuthor() %>" required maxlength="255">
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="yearPublished" class="form-label">
                                        <i class="fas fa-calendar-alt me-2"></i>Year Published*
                                    </label>
                                    <input type="number" class="form-control" id="yearPublished" name="yearPublished" 
                                           value="<%= book.getYearPublished() %>" required min="1000" max="<%= java.time.Year.now().getValue() %>">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="isbn" class="form-label">
                                        <i class="fas fa-barcode me-2"></i>ISBN*
                                    </label>
                                    <input type="text" class="form-control" id="isbn" name="isbn" 
                                           value="<%= book.getIsbn() %>" required maxlength="20">
                                    <small class="text-muted">International Standard Book Number</small>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="purchasePrice" class="form-label">
                                        <i class="fas fa-money-bill-wave me-2"></i>Purchase Price*
                                    </label>
                                    <div class="input-group">
                                        <span class="input-group-text">Rs </span>
                                        <input type="number" step="0.01" class="form-control" id="purchasePrice" 
                                               name="purchasePrice" value="<%= String.format("%.2f", book.getPurchasePrice()) %>" required min="0">
                                    </div>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="sellingPrice" class="form-label">
                                        <i class="fas fa-tag me-2"></i>Selling Price*
                                    </label>
                                    <div class="input-group">
                                        <span class="input-group-text">Rs </span>
                                        <input type="number" step="0.01" class="form-control" id="sellingPrice" 
                                               name="sellingPrice" value="<%= String.format("%.2f", book.getSellingPrice()) %>" required min="0">
                                    </div>
                                </div>
                            </div>

                            <div class="mb-4">
                                <label for="alertQty" class="form-label">
                                    <i class="fas fa-exclamation-triangle me-2"></i>Alert Quantity*
                                </label>
                                <input type="number" class="form-control" id="alertQty" name="alertQty" 
                                       value="<%= book.getAlertQuantity() %>" required min="0">
                                <small class="text-muted">When stock reaches this level</small>
                            </div>

                            <div class="mb-4">
                                <label for="image" class="form-label">
                                    <i class="fas fa-image me-2"></i>Book Cover Image
                                </label>
                                
                                <% if (book.getImagePath() != null && !book.getImagePath().isEmpty()) { %>
                                    <div class="mb-3">
                                        <p>Current Image:</p>
                                        <img src="<%= request.getContextPath() + "/" + book.getImagePath() %>" 
                                             alt="Current book cover" class="img-thumbnail">
                                        <div class="form-check mt-2">
                                            <input class="form-check-input" type="checkbox" id="removeImage" name="removeImage">
                                            <label class="form-check-label" for="removeImage">Remove current image</label>
                                        </div>
                                    </div>
                                <% } %>
                                
                                <div class="mb-3">
                                    <p>New Image:</p>
                                    <img id="newImagePreview" class="img-thumbnail" alt="New image preview">
                                </div>
                                
                                <input type="file" class="form-control" id="image" name="image" 
                                       accept="image/*" onchange="previewNewImage(this)">
                                <small class="text-muted">JPEG, PNG or GIF (Max 10MB). Leave empty to keep current image.</small>
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <button type="submit" class="btn btn-primary btn-lg w-100">
                                        <i class="fas fa-save me-2"></i>Update Book
                                    </button>
                                </div>
                                <div class="col-md-6">
                                    <a href="book?action=list" class="btn btn-secondary btn-lg w-100">
                                        <i class="fas fa-times me-2"></i>Cancel
                                    </a>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <div class="col-lg-4">
                <!-- Book Details -->
                <div class="card info-card mb-3">
                    <div class="card-body">
                        <h5 class="card-title">
                            <i class="fas fa-info-circle me-2"></i>Book Details
                        </h5>
                        
                        <p><strong>Book ID:</strong> <%= book.getId() %></p>
                        <p><strong>Current Stock:</strong> 
                            <span class="<%= book.getQuantity() <= book.getAlertQuantity() ? "text-danger fw-bold" : "text-success" %>">
                                <%= book.getQuantity() %>
                            </span>
                        </p>
                        <p><strong>Alert Level:</strong> <%= book.getAlertQuantity() %></p>
                        <p><strong>Created:</strong> 
                            <% if (book.getCreatedAt() != null) { %>
                                <%= java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm")
                                    .format(book.getCreatedAt().toLocalDateTime()) %>
                            <% } else { %>
                                N/A
                            <% } %>
                        </p>
                        <p><strong>Last Updated:</strong> 
                            <% if (book.getUpdatedAt() != null) { %>
                                <%= java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm")
                                    .format(book.getUpdatedAt().toLocalDateTime()) %>
                            <% } else { %>
                                N/A
                            <% } %>
                        </p>
                    </div>
                </div>

                <!-- Stock Management -->
                <div class="card info-card">
                    <div class="card-body">
                        <h5 class="card-title">
                            <i class="fas fa-boxes me-2"></i>Stock Management
                        </h5>
                        
                        <form action="book" method="post" class="mb-3">
                            <input type="hidden" name="action" value="updateStock">
                            <input type="hidden" name="id" value="<%= book.getId() %>">
                            
                            <div class="mb-3">
                                <label class="form-label">Adjust Stock Level</label>
                                <div class="input-group">
                                    <select class="form-select" name="stockOperation" required>
                                        <option value="add">Add Stock</option>
                                        <option value="remove">Remove Stock</option>
                                        <option value="set">Set Exact Value</option>
                                    </select>
                                    <input type="number" class="form-control" name="quantity" 
                                           placeholder="Quantity" required min="1">
                                </div>
                            </div>
                            
                            <button type="submit" class="btn btn-success w-100">
                                <i class="fas fa-sync-alt me-2"></i>Update Stock
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Preview new image when selected
        function previewNewImage(input) {
            var preview = document.getElementById('newImagePreview');
            
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                
                reader.onload = function(e) {
                    preview.src = e.target.result;
                    preview.style.display = 'block';
                }
                
                reader.readAsDataURL(input.files[0]);
            } else {
                preview.src = '';
                preview.style.display = 'none';
            }
        }
    </script>
</body>
</html>