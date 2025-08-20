<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Book" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Order - Bookshop System</title>
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
        .card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        .cart-item {
            border-bottom: 1px solid #eee;
            padding: 15px 0;
        }
        .cart-item:last-child {
            border-bottom: none;
        }
        .book-card {
            transition: all 0.3s;
            cursor: pointer;
        }
        .book-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.1);
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
                <a class="nav-link" href="order?action=list">
                    <i class="fas fa-arrow-left me-1"></i>Back to Orders
                </a>
            </div>
        </div>
    </nav>

    <!-- Page Header -->
    <div class="page-header">
        <div class="container">
            <h1 class="mb-0">
                <i class="fas fa-cart-plus me-3"></i>Create New Order
            </h1>
            <p class="mb-0 mt-2 opacity-75">Add items and customer details for a new order</p>
        </div>
    </div>

    <div class="container">
        <% if (request.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>
                <%= request.getAttribute("errorMessage") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <div class="row">
            <div class="col-md-8">
                <!-- Book Selection -->
                <div class="card mb-4">
                    <div class="card-header bg-white">
                        <h5 class="card-title mb-0">
                            <i class="fas fa-book me-2"></i>Available Books
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <% for (Book book : (List<Book>) request.getAttribute("books")) { %>
                            <div class="col-md-4 mb-4">
                                <div class="card book-card h-100" onclick="addToCart(<%= book.getId() %>, '<%= book.getTitle().replace("'", "\\'") %>', <%= book.getSellingPrice() %>, <%= book.getQuantity() %>)">
                                    <div class="card-body text-center">
                                        <h6 class="card-title"><%= book.getTitle() %></h6>
                                        <p class="text-muted small mb-2">ISBN: <%= book.getIsbn() %></p>
                                        <p class="text-success fw-bold">$<%= String.format("%.2f", book.getSellingPrice()) %></p>
                                        <p class="text-muted small">Stock: <%= book.getQuantity() %></p>
                                    </div>
                                </div>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <!-- Shopping Cart -->
                <div class="card mb-4">
                    <div class="card-header bg-white">
                        <h5 class="card-title mb-0">
                            <i class="fas fa-shopping-cart me-2"></i>Shopping Cart
                            <span id="cartCount" class="badge bg-primary ms-2">0</span>
                        </h5>
                    </div>
                    <div class="card-body" id="cartItems">
                        <div class="text-center text-muted py-4" id="emptyCartMessage">
                            <i class="fas fa-cart-arrow-down fa-2x mb-3"></i>
                            <p>Your cart is empty</p>
                            <p class="small">Click on books to add them to your cart</p>
                        </div>
                    </div>
                    <div class="card-footer bg-white">
                        <div class="d-flex justify-content-between fw-bold">
                            <span>Subtotal:</span>
                            <span id="subtotal">$0.00</span>
                        </div>
                        <div class="d-flex justify-content-between small text-muted">
                            <span>Shipping:</span>
                            <span id="shipping">$0.00</span>
                        </div>
                        <div class="d-flex justify-content-between small text-muted">
                            <span>Tax (10%):</span>
                            <span id="tax">$0.00</span>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between fw-bold fs-5">
                            <span>Total:</span>
                            <span id="total">$0.00</span>
                        </div>
                    </div>
                </div>

                <!-- Customer Details Form -->
                <div class="card">
                    <div class="card-header bg-white">
                        <h5 class="card-title mb-0">
                            <i class="fas fa-user me-2"></i>Customer Details
                        </h5>
                    </div>
                    <div class="card-body">
                        <form id="orderForm" action="order?action=create" method="post">
                            <div class="mb-3">
                                <label for="customerName" class="form-label">Full Name</label>
                                <input type="text" class="form-control" id="customerName" name="customerName" required>
                            </div>
                            <div class="mb-3">
                                <label for="customerEmail" class="form-label">Email</label>
                                <input type="email" class="form-control" id="customerEmail" name="customerEmail" required>
                            </div>
                            <div class="mb-3">
                                <label for="customerPhone" class="form-label">Phone</label>
                                <input type="tel" class="form-control" id="customerPhone" name="customerPhone" required>
                            </div>
                            <div class="mb-3">
                                <label for="shippingAddress" class="form-label">Shipping Address</label>
                                <textarea class="form-control" id="shippingAddress" name="shippingAddress" rows="3" required></textarea>
                            </div>
                            <div class="mb-3">
                                <label for="billingAddress" class="form-label">Billing Address</label>
                                <textarea class="form-control" id="billingAddress" name="billingAddress" rows="3"></textarea>
                                <div class="form-check mt-2">
                                    <input class="form-check-input" type="checkbox" id="sameAsShipping">
                                    <label class="form-check-label" for="sameAsShipping">
                                        Same as shipping address
                                    </label>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label for="paymentMethod" class="form-label">Payment Method</label>
                                <select class="form-select" id="paymentMethod" name="paymentMethod" required>
                                    <option value="CREDIT_CARD">Credit Card</option>
                                    <option value="PAYPAL">PayPal</option>
                                    <option value="BANK_TRANSFER">Bank Transfer</option>
                                    <option value="CASH">Cash on Delivery</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label for="notes" class="form-label">Order Notes</label>
                                <textarea class="form-control" id="notes" name="notes" rows="2"></textarea>
                            </div>
                            <button type="submit" class="btn btn-primary w-100" id="placeOrderBtn" disabled>
                                <i class="fas fa-check-circle me-2"></i>Place Order
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let cart = [];
        
        // Add to cart function
        function addToCart(bookId, title, price, stock) {
            const existingItem = cart.find(item => item.bookId === bookId);
            
            if (existingItem) {
                if (existingItem.quantity < stock) {
                    existingItem.quantity++;
                    existingItem.totalPrice = existingItem.quantity * price;
                } else {
                    alert('Cannot add more than available stock');
                    return;
                }
            } else {
                cart.push({
                    bookId: bookId,
                    title: title,
                    unitPrice: price,
                    quantity: 1,
                    totalPrice: price
                });
            }
            
            updateCartDisplay();
        }
        
        // Update cart quantity
        function updateQuantity(bookId, change) {
            const item = cart.find(item => item.bookId === bookId);
            if (!item) return;
            
            const newQuantity = item.quantity + change;
            if (newQuantity < 1) {
                removeFromCart(bookId);
                return;
            }
            
            // Check stock (in a real app, you'd verify with server)
            item.quantity = newQuantity;
            item.totalPrice = item.quantity * item.unitPrice;
            
            updateCartDisplay();
        }
        
        // Remove from cart
        function removeFromCart(bookId) {
            cart = cart.filter(item => item.bookId !== bookId);
            updateCartDisplay();
        }
        
        // Update cart display
        function updateCartDisplay() {
            const cartItemsEl = document.getElementById('cartItems');
            const emptyCartMessage = document.getElementById('emptyCartMessage');
            const cartCountEl = document.getElementById('cartCount');
            const subtotalEl = document.getElementById('subtotal');
            const shippingEl = document.getElementById('shipping');
            const taxEl = document.getElementById('tax');
            const totalEl = document.getElementById('total');
            const placeOrderBtn = document.getElementById('placeOrderBtn');
            
            if (cart.length === 0) {
                cartItemsEl.innerHTML = `
                    <div class="text-center text-muted py-4" id="emptyCartMessage">
                        <i class="fas fa-cart-arrow-down fa-2x mb-3"></i>
                        <p>Your cart is empty</p>
                        <p class="small">Click on books to add them to your cart</p>
                    </div>
                `;
                cartCountEl.textContent = '0';
                subtotalEl.textContent = '$0.00';
                shippingEl.textContent = '$0.00';
                taxEl.textContent = '$0.00';
                totalEl.textContent = '$0.00';
                placeOrderBtn.disabled = true;
                return;
            }
            
            // Calculate totals
            const subtotal = cart.reduce((sum, item) => sum + item.totalPrice, 0);
            const shipping = 5 + (cart.reduce((sum, item) => sum + item.quantity, 0) * 0.5);
            const tax = subtotal * 0.1;
            const total = subtotal + shipping + tax;
            
            // Update cart items display
            let cartHTML = '';
            cart.forEach(item => {
                cartHTML += `
                    <div class="cart-item">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h6 class="mb-1">${item.title}</h6>
                                <small class="text-muted">$${item.unitPrice.toFixed(2)} each</small>
                            </div>
                            <div class="text-end">
                                <span class="d-block">$${item.totalPrice.toFixed(2)}</span>
                                <div class="btn-group btn-group-sm mt-1">
                                    <button class="btn btn-outline-secondary" onclick="updateQuantity(${item.bookId}, -1)">-</button>
                                    <button class="btn btn-outline-secondary" disabled>${item.quantity}</button>
                                    <button class="btn btn-outline-secondary" onclick="updateQuantity(${item.bookId}, 1)">+</button>
                                </div>
                            </div>
                        </div>
                        <button class="btn btn-sm btn-link text-danger p-0 mt-1" onclick="removeFromCart(${item.bookId})">
                            <i class="fas fa-trash-alt me-1"></i>Remove
                        </button>
                    </div>
                `;
            });
            
            cartItemsEl.innerHTML = cartHTML;
            cartCountEl.textContent = cart.reduce((sum, item) => sum + item.quantity, 0);
            subtotalEl.textContent = `$${subtotal.toFixed(2)}`;
            shippingEl.textContent = `$${shipping.toFixed(2)}`;
            taxEl.textContent = `$${tax.toFixed(2)}`;
            totalEl.textContent = `$${total.toFixed(2)}`;
            placeOrderBtn.disabled = false;
            
            // Add hidden inputs for cart items
            const form = document.getElementById('orderForm');
            // Remove any existing cart inputs
            document.querySelectorAll('[name^="cart_"]').forEach(el => el.remove());
            
            cart.forEach((item, index) => {
                const bookIdInput = document.createElement('input');
                bookIdInput.type = 'hidden';
                bookIdInput.name = `cart_${index}_bookId`;
                bookIdInput.value = item.bookId;
                form.appendChild(bookIdInput);
                
                const quantityInput = document.createElement('input');
                quantityInput.type = 'hidden';
                quantityInput.name = `cart_${index}_quantity`;
                quantityInput.value = item.quantity;
                form.appendChild(quantityInput);
                
                const priceInput = document.createElement('input');
                priceInput.type = 'hidden';
                priceInput.name = `cart_${index}_price`;
                priceInput.value = item.unitPrice;
                form.appendChild(priceInput);
            });
        }
        
        // Same as shipping address checkbox
        document.getElementById('sameAsShipping').addEventListener('change', function() {
            const billingAddress = document.getElementById('billingAddress');
            if (this.checked) {
                billingAddress.value = document.getElementById('shippingAddress').value;
                billingAddress.readOnly = true;
            } else {
                billingAddress.readOnly = false;
            }
        });
    </script>
</body>
</html>