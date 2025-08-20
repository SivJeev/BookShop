<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Bookshop Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            padding: 20px 0;
        }
        .register-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
            backdrop-filter: blur(10px);
        }
        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }
        .btn-register {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            padding: 12px 30px;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        .btn-register:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
        }
        .brand-title {
            color: #333;
            font-weight: 700;
            margin-bottom: 30px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-6 col-md-8">
                <div class="register-card p-5">
                    <div class="text-center">
                        <h2 class="brand-title">
                            <i class="fas fa-book text-primary me-2"></i>
                            Create Account
                        </h2>
                        <p class="text-muted mb-4">Join our bookshop management system</p>
                    </div>

                    <!-- Display Messages -->
                    <% if (request.getAttribute("errorMessage") != null) { %>
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-circle me-2"></i>
                            <%= request.getAttribute("errorMessage") %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    <% } %>

                    <form action="auth" method="post" onsubmit="return validateForm()">
                        <input type="hidden" name="action" value="register">
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="username" class="form-label">
                                    <i class="fas fa-user me-2"></i>Username*
                                </label>
                                <input type="text" class="form-control" id="username" name="username" 
                                       placeholder="Choose a username" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="fullName" class="form-label">
                                    <i class="fas fa-id-card me-2"></i>Full Name*
                                </label>
                                <input type="text" class="form-control" id="fullName" name="fullName" 
                                       placeholder="Enter your full name" required>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label for="email" class="form-label">
                                <i class="fas fa-envelope me-2"></i>Email Address*
                            </label>
                            <input type="email" class="form-control" id="email" name="email" 
                                   placeholder="Enter your email" required>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="password" class="form-label">
                                    <i class="fas fa-lock me-2"></i>Password*
                                </label>
                                <input type="password" class="form-control" id="password" name="password" 
                                       placeholder="Enter password" required minlength="6">
                                <small class="text-muted">Minimum 6 characters</small>
                            </div>
                            <div class="col-md-6 mb-4">
                                <label for="confirmPassword" class="form-label">
                                    <i class="fas fa-lock me-2"></i>Confirm Password*
                                </label>
                                <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" 
                                       placeholder="Confirm password" required minlength="6">
                            </div>
                        </div>

                        <div class="d-grid mb-3">
                            <button type="submit" class="btn btn-primary btn-register">
                                <i class="fas fa-user-plus me-2"></i> Create Account
                            </button>
                        </div>
                    </form>

                    <div class="text-center">
                        <p class="mb-0">Already have an account? 
                            <a href="login.jsp" class="text-decoration-none">Sign in here</a>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        function validateForm() {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            if (password !== confirmPassword) {
                alert('Passwords do not match!');
                return false;
            }
            
            if (password.length < 6) {
                alert('Password must be at least 6 characters long!');
                return false;
            }
            
            return true;
        }
    </script>
</body>
</html>