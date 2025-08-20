<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Supplier - Bookshop System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .page-header {
            background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
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
            border-color: #17a2b8;
            box-shadow: 0 0 0 0.2rem rgba(23, 162, 184, 0.25);
        }
        .btn-primary {
            background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
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
                <a class="nav-link" href="supplier?action=list">
                    <i class="fas fa-arrow-left me-1"></i>Back to Suppliers
                </a>
            </div>
        </div>
    </nav>

    <!-- Page Header -->
    <div class="page-header">
        <div class="container">
            <h1 class="mb-0">
                <i class="fas fa-truck-loading me-3"></i>Add New Supplier
            </h1>
            <p class="mb-0 mt-2 opacity-75">Add a new book supplier to your system</p>
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
                    <div class="card-body p-5">
                        <h4 class="card-title mb-4">Supplier Information</h4>
                        
                        <form action="supplier" method="post" id="supplierForm">
                            <input type="hidden" name="action" value="create">
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="name" class="form-label">
                                        <i class="fas fa-building me-2"></i>Supplier Name*
                                    </label>
                                    <input type="text" class="form-control" id="name" name="name" 
                                           placeholder="Enter supplier name" required maxlength="255">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="contactPerson" class="form-label">
                                        <i class="fas fa-user-tie me-2"></i>Contact Person*
                                    </label>
                                    <input type="text" class="form-control" id="contactPerson" name="contactPerson" 
                                           placeholder="Enter contact person" required maxlength="255">
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="email" class="form-label">
                                        <i class="fas fa-envelope me-2"></i>Email Address*
                                    </label>
                                    <input type="email" class="form-control" id="email" name="email" 
                                           placeholder="Enter email address" required maxlength="255">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="phone" class="form-label">
                                        <i class="fas fa-phone me-2"></i>Phone Number*
                                    </label>
                                    <input type="tel" class="form-control" id="phone" name="phone" 
                                           placeholder="Enter phone number" required maxlength="20">
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="address" class="form-label">
                                    <i class="fas fa-map-marker-alt me-2"></i>Address
                                </label>
                                <input type="text" class="form-control" id="address" name="address" 
                                       placeholder="Enter street address" maxlength="255">
                            </div>

                            <div class="row">
                                <div class="col-md-4 mb-3">
                                    <label for="city" class="form-label">
                                        <i class="fas fa-city me-2"></i>City
                                    </label>
                                    <input type="text" class="form-control" id="city" name="city" 
                                           placeholder="Enter city" maxlength="100">
                                </div>
                                <div class="col-md-4 mb-3">
                                    <label for="state" class="form-label">
                                        <i class="fas fa-flag me-2"></i>State/Province
                                    </label>
                                    <input type="text" class="form-control" id="state" name="state" 
                                           placeholder="Enter state or province" maxlength="100">
                                </div>
                                <div class="col-md-4 mb-3">
                                    <label for="country" class="form-label">
                                        <i class="fas fa-globe me-2"></i>Country
                                    </label>
                                    <input type="text" class="form-control" id="country" name="country" 
                                           placeholder="Enter country" maxlength="100">
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="postalCode" class="form-label">
                                        <i class="fas fa-mail-bulk me-2"></i>Postal Code
                                    </label>
                                    <input type="text" class="form-control" id="postalCode" name="postalCode" 
                                           placeholder="Enter postal code" maxlength="20">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="website" class="form-label">
                                        <i class="fas fa-globe me-2"></i>Website
                                    </label>
                                    <input type="url" class="form-control" id="website" name="website" 
                                           placeholder="Enter website URL" maxlength="255">
                                </div>
                            </div>

                            <div class="mb-4">
                                <label for="notes" class="form-label">
                                    <i class="fas fa-sticky-note me-2"></i>Notes
                                </label>
                                <textarea class="form-control" id="notes" name="notes" 
                                          rows="3" placeholder="Enter any additional notes"></textarea>
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <button type="submit" class="btn btn-primary btn-lg w-100">
                                        <i class="fas fa-save me-2"></i>Add Supplier
                                    </button>
                                </div>
                                <div class="col-md-6">
                                    <a href="supplier?action=list" class="btn btn-secondary btn-lg w-100">
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
        document.getElementById('supplierForm').addEventListener('submit', function(e) {
            var name = document.getElementById('name').value.trim();
            var contactPerson = document.getElementById('contactPerson').value.trim();
            var email = document.getElementById('email').value.trim();
            var phone = document.getElementById('phone').value.trim();
            
            if (name === '' || contactPerson === '' || email === '' || phone === '') {
                e.preventDefault();
                alert('Name, Contact Person, Email, and Phone are required fields!');
                return false;
            }
        });
    </script>
</body>
</html>