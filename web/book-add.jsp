<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Book - Bookshop System</title>
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
        .img-thumbnail {
            max-height: 200px;
            display: none;
        }
        #imagePreviewContainer {
            text-align: center;
            margin-bottom: 15px;
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
                <i class="fas fa-book-medical me-3"></i>Add New Book
            </h1>
            <p class="mb-0 mt-2 opacity-75">Add a new book to the inventory</p>
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
                        <h4 class="card-title mb-4">Book Information</h4>
                        
                        <form action="book" method="post" id="bookForm" enctype="multipart/form-data">
                            <input type="hidden" name="action" value="create">
                            
                            <div class="mb-3">
                                <label for="title" class="form-label">
                                    <i class="fas fa-heading me-2"></i>Title*
                                </label>
                                <input type="text" class="form-control" id="title" name="title" 
                                       placeholder="Enter book title" required maxlength="255">
                            </div>

                            <div class="mb-3">
                                <label for="author" class="form-label">
                                    <i class="fas fa-user-edit me-2"></i>Author*
                                </label>
                                <input type="text" class="form-control" id="author" name="author" 
                                       placeholder="Enter author name" required maxlength="255">
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="yearPublished" class="form-label">
                                        <i class="fas fa-calendar-alt me-2"></i>Year Published*
                                    </label>
                                    <input type="number" class="form-control" id="yearPublished" name="yearPublished" 
                                           placeholder="e.g. 2023" required min="1000" max="<%= java.time.Year.now().getValue() %>">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="isbn" class="form-label">
                                        <i class="fas fa-barcode me-2"></i>ISBN*
                                    </label>
                                    <input type="text" class="form-control" id="isbn" name="isbn" 
                                           placeholder="Enter ISBN" required maxlength="20">
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
                                               name="purchasePrice" placeholder="0.00" required min="0">
                                    </div>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="sellingPrice" class="form-label">
                                        <i class="fas fa-tag me-2"></i>Selling Price*
                                    </label>
                                    <div class="input-group">
                                        <span class="input-group-text">Rs </span>
                                        <input type="number" step="0.01" class="form-control" id="sellingPrice" 
                                               name="sellingPrice" placeholder="0.00" required min="0">
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="initialQty" class="form-label">
                                        <i class="fas fa-boxes me-2"></i>Initial Quantity*
                                    </label>
                                    <input type="number" class="form-control" id="initialQty" name="initialQty" 
                                           placeholder="Number of copies" required min="0">
                                </div>
                                <div class="col-md-6 mb-4">
                                    <label for="alertQty" class="form-label">
                                        <i class="fas fa-exclamation-triangle me-2"></i>Alert Quantity*
                                    </label>
                                    <input type="number" class="form-control" id="alertQty" name="alertQty" 
                                           placeholder="Low stock threshold" required min="0">
                                    <small class="text-muted">When stock reaches this level</small>
                                </div>
                            </div>

                            <div class="mb-4">
                                <label for="image" class="form-label">
                                    <i class="fas fa-image me-2"></i>Book Cover Image
                                </label>
                                <div id="imagePreviewContainer">
                                    <img id="imagePreview" class="img-thumbnail" alt="Preview" />
                                </div>
                                <input type="file" class="form-control" id="image" name="image" 
                                       accept="image/*" onchange="previewImage(this)">
                                <small class="text-muted">JPEG, PNG or GIF (Max 10MB)</small>
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <button type="submit" class="btn btn-primary btn-lg w-100">
                                        <i class="fas fa-save me-2"></i>Add Book
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
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Form validation
        document.getElementById('bookForm').addEventListener('submit', function(e) {
            var purchasePrice = parseFloat(document.getElementById('purchasePrice').value);
            var sellingPrice = parseFloat(document.getElementById('sellingPrice').value);
            
            if (purchasePrice <= 0 || sellingPrice <= 0) {
                e.preventDefault();
                alert('Prices must be greater than zero!');
                return false;
            }
            
            if (sellingPrice < purchasePrice) {
                if (!confirm('Selling price is lower than purchase price. Continue anyway?')) {
                    e.preventDefault();
                    return false;
                }
            }
            
            var initialQty = parseInt(document.getElementById('initialQty').value);
            var alertQty = parseInt(document.getElementById('alertQty').value);
            
            if (initialQty < 0 || alertQty < 0) {
                e.preventDefault();
                alert('Quantities cannot be negative!');
                return false;
            }
        });

        // Image preview function
        function previewImage(input) {
            var preview = document.getElementById('imagePreview');
            var previewContainer = document.getElementById('imagePreviewContainer');
            
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