<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Pahana Edu - Point of Sale</title>

        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <!-- Bootstrap Icons -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">

        <style>
            :root {
                --primary-color: #2c3e50;
                --secondary-color: #3498db;
                --accent-color: #e74c3c;
                --success-color: #27ae60;
                --warning-color: #f39c12;
                --light-bg: #f8f9fa;
            }

            body {
                background-color: var(--light-bg);
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }

            .navbar {
                background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }

            .main-container {
                min-height: calc(100vh - 76px);
                padding-top: 20px;
            }

            .product-grid {
                max-height: calc(100vh - 150px);
                overflow-y: auto;
            }

            .product-card {
                transition: all 0.3s ease;
                cursor: pointer;
                border: none;
                border-radius: 15px;
                overflow: hidden;
                box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            }

            .product-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 25px rgba(0,0,0,0.15);
            }

            .product-image {
                height: 120px;
                object-fit: cover;
                background: linear-gradient(45deg, #f0f0f0, #e0e0e0);
            }

            .product-price {
                font-weight: bold;
                color: var(--success-color);
                font-size: 1.1em;
            }

            .product-title {
                font-size: 0.9em;
                font-weight: 600;
                color: var(--primary-color);
            }

            .product-author {
                font-size: 0.8em;
                color: #666;
            }

            .cart-section {
                background: white;
                border-radius: 15px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.1);
                height: calc(100vh - 150px);
                display: flex;
                flex-direction: column;
            }

            .cart-header {
                background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
                color: white;
                padding: 15px 20px;
                border-radius: 15px 15px 0 0;
                font-weight: bold;
            }

            .cart-items {
                flex: 1;
                overflow-y: auto;
                padding: 15px;
            }

            .cart-item {
                background: #f8f9fa;
                border-radius: 10px;
                padding: 10px;
                margin-bottom: 10px;
                border-left: 4px solid var(--secondary-color);
            }

            .cart-item-name {
                font-weight: 600;
                color: var(--primary-color);
                font-size: 0.9em;
            }

            .quantity-controls {
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .quantity-btn {
                width: 30px;
                height: 30px;
                border-radius: 50%;
                border: none;
                background: var(--secondary-color);
                color: white;
                display: flex;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                transition: all 0.2s ease;
            }

            .quantity-btn:hover {
                background: var(--primary-color);
                transform: scale(1.1);
            }

            .cart-summary {
                background: #f8f9fa;
                padding: 20px;
                border-radius: 0 0 15px 15px;
                border-top: 2px solid #e9ecef;
            }

            .summary-row {
                display: flex;
                justify-content: space-between;
                margin-bottom: 8px;
            }

            .summary-total {
                font-size: 1.3em;
                font-weight: bold;
                color: var(--primary-color);
                border-top: 2px solid var(--secondary-color);
                padding-top: 10px;
            }

            .complete-btn {
                background: linear-gradient(135deg, var(--success-color), #2ecc71);
                border: none;
                padding: 12px 30px;
                font-weight: bold;
                font-size: 1.1em;
                border-radius: 10px;
                transition: all 0.3s ease;
            }

            .complete-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(39, 174, 96, 0.3);
            }

            .discount-input {
                max-width: 100px;
                text-align: center;
                border-radius: 8px;
                border: 2px solid #e9ecef;
                transition: border-color 0.3s ease;
            }

            .discount-input:focus {
                border-color: var(--secondary-color);
                box-shadow: none;
            }

            .modal-header {
                background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
                color: white;
                border-radius: 15px 15px 0 0;
            }

            .payment-option {
                padding: 15px;
                border: 2px solid #e9ecef;
                border-radius: 10px;
                cursor: pointer;
                transition: all 0.3s ease;
                text-align: center;
            }

            .payment-option:hover {
                border-color: var(--secondary-color);
                background: #f0f8ff;
            }

            .payment-option.active {
                border-color: var(--success-color);
                background: #e8f5e8;
            }

            .empty-cart {
                text-align: center;
                color: #666;
                padding: 40px 20px;
            }

            .empty-cart i {
                font-size: 3em;
                color: #ccc;
                margin-bottom: 15px;
            }

            .search-box {
                position: sticky;
                top: 0;
                background: white;
                z-index: 10;
                padding: 15px;
                border-radius: 15px 15px 0 0;
                border-bottom: 2px solid #e9ecef;
            }

            @media (max-width: 768px) {
                .cart-section {
                    height: auto;
                    margin-top: 20px;
                }

                .product-card {
                    margin-bottom: 15px;
                }
            }
        </style>
    </head>
    <body>
        <!-- Navigation -->
        <nav class="navbar navbar-expand-lg navbar-dark">
            <div class="container-fluid">
                <a class="navbar-brand fw-bold" href="#">
                    <i class="bi bi-shop"></i> Pahana Edu POS
                </a>
                <div class="navbar-nav ms-auto">
                    <span class="navbar-text">
                        <i class="bi bi-person-circle"></i> Welcome, Admin
                    </span>
                </div>
            </div>
        </nav>

        <div class="container-fluid main-container">
            <div class="row">
                <!-- Products Section -->
                <div class="col-lg-8">
                    <div class="card border-0 shadow-sm" style="border-radius: 15px;">
                        <div class="search-box">
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-search"></i></span>
                                <input type="text" class="form-control" id="searchInput" placeholder="Search books...">
                            </div>
                        </div>
                        <div class="product-grid p-3">
                            <div class="row" id="productGrid">
                                <!-- Products will be loaded here -->
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Cart Section -->
                <div class="col-lg-4">
                    <div class="cart-section">
                        <div class="cart-header">
                            <i class="bi bi-cart3"></i> Shopping Cart
                            <span class="badge bg-light text-dark ms-2" id="cartCount">0</span>
                        </div>

                        <div class="cart-items" id="cartItems">
                            <div class="empty-cart">
                                <i class="bi bi-cart-x"></i>
                                <p>Your cart is empty<br><small>Add items to get started</small></p>
                            </div>
                        </div>

                        <div class="cart-summary">
                            <div class="summary-row">
                                <span>Subtotal:</span>
                                <span id="subtotal">LKR 0.00</span>
                            </div>
                            <div class="summary-row">
                                <span>Tax (0%):</span>
                                <span id="tax">LKR 0.00</span>
                            </div>
                            <div class="summary-row">
                                <span>Discount:</span>
                                <div>
                                    LKR <input type="number" class="discount-input" id="discountInput" value="0" min="0" step="0.01">
                                </div>
                            </div>
                            <div class="summary-row summary-total">
                                <span>Total:</span>
                                <span id="total">LKR 0.00</span>
                            </div>
                            <button class="btn btn-success complete-btn w-100 mt-3" id="completeBtn" disabled>
                                <i class="bi bi-check-circle"></i> Complete Sale
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Sale Completion Modal -->
        <div class="modal fade" id="saleModal" tabindex="-1" data-bs-backdrop="static">
            <div class="modal-dialog modal-lg">
                <div class="modal-content" style="border-radius: 15px; border: none;">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <i class="bi bi-credit-card"></i> Complete Sale
                        </h5>
                    </div>
                    <div class="modal-body">
                        <form id="saleForm">
                            <div class="row">
                                <!-- Customer Information -->
                                <div class="col-md-6">
                                    <h6 class="mb-3"><i class="bi bi-person"></i> Customer Information</h6>
                                    <div class="mb-3">
                                        <label class="form-label">Customer Name</label>
                                        <input type="text" class="form-control" id="customerName" placeholder="Optional">
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Customer Email</label>
                                        <input type="email" class="form-control" id="customerEmail" placeholder="Optional">
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Notes</label>
                                        <textarea class="form-control" id="notes" rows="3" placeholder="Additional notes..."></textarea>
                                    </div>
                                </div>

                                <!-- Payment Information -->
                                <div class="col-md-6">
                                    <h6 class="mb-3"><i class="bi bi-wallet2"></i> Payment Method</h6>
                                    <div class="row g-2 mb-3">
                                        <div class="col-4">
                                            <div class="payment-option" data-payment="CASH">
                                                <i class="bi bi-cash-coin d-block mb-2" style="font-size: 1.5em;"></i>
                                                <small>Cash</small>
                                            </div>
                                        </div>
                                        <div class="col-4">
                                            <div class="payment-option" data-payment="CARD">
                                                <i class="bi bi-credit-card d-block mb-2" style="font-size: 1.5em;"></i>
                                                <small>Card</small>
                                            </div>
                                        </div>
                                        <div class="col-4">
                                            <div class="payment-option" data-payment="MIXED">
                                                <i class="bi bi-wallet2 d-block mb-2" style="font-size: 1.5em;"></i>
                                                <small>Mixed</small>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Mixed Payment Details -->
                                    <div id="mixedPaymentDetails" style="display: none;">
                                        <div class="mb-3">
                                            <label class="form-label">Cash Amount</label>
                                            <input type="number" class="form-control" id="cashAmount" step="0.01" min="0">
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label">Card Amount</label>
                                            <input type="number" class="form-control" id="cardAmount" step="0.01" min="0" readonly>
                                        </div>
                                    </div>

                                    <!-- Sale Summary -->
                                    <div class="mt-4 p-3" style="background: #f8f9fa; border-radius: 10px;">
                                        <h6 class="mb-3">Sale Summary</h6>
                                        <div class="d-flex justify-content-between mb-2">
                                            <span>Subtotal:</span>
                                            <span id="modalSubtotal">LKR 0.00</span>
                                        </div>
                                        <div class="d-flex justify-content-between mb-2">
                                            <span>Tax:</span>
                                            <span id="modalTax">LKR 0.00</span>
                                        </div>
                                        <div class="d-flex justify-content-between mb-2">
                                            <span>Discount:</span>
                                            <span id="modalDiscount">LKR 0.00</span>
                                        </div>
                                        <hr>
                                        <div class="d-flex justify-content-between fw-bold" style="font-size: 1.2em;">
                                            <span>Total:</span>
                                            <span id="modalTotal">LKR 0.00</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="bi bi-x-circle"></i> Cancel
                        </button>
                        <button type="button" class="btn btn-success" id="processSaleBtn">
                            <i class="bi bi-check-circle"></i> Process Sale
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Success Modal -->
        <div class="modal fade" id="successModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content" style="border-radius: 15px; border: none;">
                    <div class="modal-body text-center p-5">
                        <i class="bi bi-check-circle-fill text-success" style="font-size: 4em;"></i>
                        <h4 class="mt-3 mb-3">Sale Completed Successfully!</h4>
                        <p class="text-muted">Sale ID: <span id="saleIdSpan" class="fw-bold"></span></p>
                        <button type="button" class="btn btn-primary" data-bs-dismiss="modal">
                            <i class="bi bi-arrow-left"></i> New Sale
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

        <script>
            // Global variables
            let books = [];
            let cart = [];
            let selectedPaymentMethod = '';

            // Initialize POS system
            document.addEventListener('DOMContentLoaded', function () {
                loadBooks();
                initializeEventListeners();
            });

            // Load books from server
            function loadBooks() {
                fetch('pos?action=getBooks')
                        .then(response => response.json())
                        .then(data => {
                            books = data;
                            displayBooks(books);
                        })
                        .catch(error => {
                            console.error('Error loading books:', error);
                            alert('Failed to load books. Please refresh the page.');
                        });
            }

            // Display books in grid
            function displayBooks(booksToShow) {
                const productGrid = document.getElementById('productGrid');

                if (booksToShow.length === 0) {
                    productGrid.innerHTML =
                            '<div class="col-12 text-center py-5">' +
                            '<i class="bi bi-book" style="font-size: 3em; color: #ccc;"></i>' +
                            '<p class="mt-3 text-muted">No books found</p>' +
                            '</div>';
                    return;
                }

                let booksHTML = '';
                booksToShow.forEach(function (book) {
                    const imageHtml = book.image_path ?
                            '<img src="' + book.image_path + '" class="w-100 h-100 product-image" alt="' + escapeHtml(book.title) + '">' :
                            '<i class="bi bi-book" style="font-size: 2em; color: #ccc;"></i>';

                    booksHTML +=
                            '<div class="col-lg-4 col-md-6 col-sm-6 mb-3">' +
                            '<div class="card product-card h-100" onclick="addToCart(' + book.id + ')">' +
                            '<div class="product-image w-100 d-flex align-items-center justify-content-center bg-light">' +
                            imageHtml +
                            '</div>' +
                            '<div class="card-body p-3">' +
                            '<div class="product-title mb-1">' + escapeHtml(book.title) + '</div>' +
                            '<div class="product-author mb-2">' + escapeHtml(book.author) + '</div>' +
                            '<div class="d-flex justify-content-between align-items-center">' +
                            '<div class="product-price">LKR ' + book.selling_price.toFixed(2) + '</div>' +
                            '<small class="text-muted">Stock: ' + book.quantity + '</small>' +
                            '</div>' +
                            '</div>' +
                            '</div>' +
                            '</div>';
                });

                productGrid.innerHTML = booksHTML;
            }

            // Add product to cart
            function addToCart(bookId) {
                console.log('Adding book to cart:', bookId);

                const book = books.find(b => b.id === bookId);
                if (!book) {
                    console.error('Book not found:', bookId);
                    return;
                }

                console.log('Found book:', book);

                if (book.quantity <= 0) {
                    alert('This book is out of stock!');
                    return;
                }

                const existingItem = cart.find(item => item.id === bookId);

                if (existingItem) {
                    if (existingItem.quantity >= book.quantity) {
                        alert('Cannot add more items. Stock limit reached!');
                        return;
                    }
                    existingItem.quantity += 1;
                    existingItem.total = existingItem.quantity * existingItem.selling_price;
                    console.log('Updated existing item:', existingItem);
                } else {
                    const newItem = {
                        id: book.id,
                        title: book.title,
                        author: book.author,
                        selling_price: book.selling_price,
                        quantity: 1,
                        total: book.selling_price,
                        max_stock: book.quantity
                    };
                    cart.push(newItem);
                    console.log('Added new item:', newItem);
                }

                console.log('Current cart:', cart);
                updateCartDisplay();
                updateCartSummary();
            }


            // Update cart display
            // Fixed updateCartDisplay function
            function updateCartDisplay() {
                const cartItems = document.getElementById('cartItems');
                const cartCount = document.getElementById('cartCount');

                cartCount.textContent = cart.reduce((sum, item) => sum + item.quantity, 0);

                if (cart.length === 0) {
                    cartItems.innerHTML =
                            '<div class="empty-cart">' +
                            '<i class="bi bi-cart-x"></i>' +
                            '<p>Your cart is empty<br><small>Add items to get started</small></p>' +
                            '</div>';
                    document.getElementById('completeBtn').disabled = true;
                    return;
                }

                let cartHTML = '';
                cart.forEach(function (item) {
                    cartHTML +=
                            '<div class="cart-item">' +
                            '<div class="d-flex justify-content-between align-items-start mb-2">' +
                            '<div class="flex-grow-1">' +
                            '<div class="cart-item-name">' + escapeHtml(item.title) + '</div>' +
                            '<small class="text-muted">' + escapeHtml(item.author) + '</small>' +
                            '</div>' +
                            '<button class="btn btn-sm btn-outline-danger" onclick="removeFromCart(' + item.id + ')">' +
                            '<i class="bi bi-trash"></i>' +
                            '</button>' +
                            '</div>' +
                            '<div class="d-flex justify-content-between align-items-center">' +
                            '<div class="quantity-controls">' +
                            '<button class="quantity-btn" onclick="updateQuantity(' + item.id + ', -1)">' +
                            '<i class="bi bi-dash"></i>' +
                            '</button>' +
                            '<span class="mx-2 fw-bold">' + item.quantity + '</span>' +
                            '<button class="quantity-btn" onclick="updateQuantity(' + item.id + ', 1)">' +
                            '<i class="bi bi-plus"></i>' +
                            '</button>' +
                            '</div>' +
                            '<div class="fw-bold text-success">LKR ' + item.total.toFixed(2) + '</div>' +
                            '</div>' +
                            '</div>';
                });

                cartItems.innerHTML = cartHTML;
                document.getElementById('completeBtn').disabled = false;
            }

            function escapeHtml(text) {
                if (!text)
                    return '';
                var map = {
                    '&': '&amp;',
                    '<': '&lt;',
                    '>': '&gt;',
                    '"': '&quot;',
                    "'": '&#039;'
                };
                return text.replace(/[&<>"']/g, function (m) {
                    return map[m];
                });
            }

            // Update item quantity
            function updateQuantity(itemId, change) {
                const item = cart.find(item => item.id === itemId);
                if (!item)
                    return;

                const newQuantity = item.quantity + change;

                if (newQuantity <= 0) {
                    removeFromCart(itemId);
                    return;
                }

                if (newQuantity > item.max_stock) {
                    alert('Cannot exceed available stock!');
                    return;
                }

                item.quantity = newQuantity;
                item.total = item.quantity * item.selling_price;

                updateCartDisplay();
                updateCartSummary();
            }

            // Remove item from cart
            function removeFromCart(itemId) {
                cart = cart.filter(item => item.id !== itemId);
                updateCartDisplay();
                updateCartSummary();
            }

            // Update cart summary
            function updateCartSummary() {
                console.log('Updating cart summary, cart:', cart);

                const subtotal = cart.reduce((sum, item) => sum + item.total, 0);
                const discountInput = document.getElementById('discountInput');
                const discount = parseFloat(discountInput.value) || 0;
                const taxableAmount = subtotal - discount;
                const tax = taxableAmount * 0; // 10% tax
                const total = taxableAmount + tax;

                console.log('Cart totals:', {subtotal, discount, tax, total});

                // Update cart summary
                document.getElementById('subtotal').textContent = 'LKR ' + subtotal.toFixed(2);
                document.getElementById('tax').textContent = 'LKR ' + tax.toFixed(2);
                document.getElementById('total').textContent = 'LKR ' + total.toFixed(2);

                // Update modal summary
                const modalSubtotal = document.getElementById('modalSubtotal');
                const modalTax = document.getElementById('modalTax');
                const modalDiscount = document.getElementById('modalDiscount');
                const modalTotal = document.getElementById('modalTotal');

                if (modalSubtotal)
                    modalSubtotal.textContent = 'LKR ' + subtotal.toFixed(2);
                if (modalTax)
                    modalTax.textContent = 'LKR ' + tax.toFixed(2);
                if (modalDiscount)
                    modalDiscount.textContent = 'LKR ' + discount.toFixed(2);
                if (modalTotal)
                    modalTotal.textContent = 'LKR ' + total.toFixed(2);
            }

            // Initialize event listeners
            function initializeEventListeners() {
                // Search functionality
                document.getElementById('searchInput').addEventListener('input', function (e) {
                    const searchTerm = e.target.value.toLowerCase();
                    const filteredBooks = books.filter(book =>
                        book.title.toLowerCase().includes(searchTerm) ||
                                book.author.toLowerCase().includes(searchTerm)
                    );
                    displayBooks(filteredBooks);
                });

                // Discount input
                document.getElementById('discountInput').addEventListener('input', updateCartSummary);

                // Complete sale button
                document.getElementById('completeBtn').addEventListener('click', function () {
                    updateCartSummary();
                    new bootstrap.Modal(document.getElementById('saleModal')).show();
                });

                // Payment method selection
                document.querySelectorAll('.payment-option').forEach(option => {
                    option.addEventListener('click', function () {
                        document.querySelectorAll('.payment-option').forEach(opt => opt.classList.remove('active'));
                        this.classList.add('active');
                        selectedPaymentMethod = this.dataset.payment;

                        const mixedDetails = document.getElementById('mixedPaymentDetails');
                        if (selectedPaymentMethod === 'MIXED') {
                            mixedDetails.style.display = 'block';
                            updateMixedPayment();
                        } else {
                            mixedDetails.style.display = 'none';
                        }
                    });
                });

                // Cash amount input for mixed payment
                document.getElementById('cashAmount').addEventListener('input', updateMixedPayment);

                // Process sale button
                document.getElementById('processSaleBtn').addEventListener('click', processSale);

                // Success modal close event
                document.getElementById('successModal').addEventListener('hidden.bs.modal', function () {
                    // Reset cart and form
                    cart = [];
                    updateCartDisplay();
                    updateCartSummary();
                    document.getElementById('saleForm').reset();
                    selectedPaymentMethod = '';
                    document.querySelectorAll('.payment-option').forEach(opt => opt.classList.remove('active'));
                    bootstrap.Modal.getInstance(document.getElementById('saleModal')).hide();
                });
            }

            // Update mixed payment calculation
            function updateMixedPayment() {
                const total = parseFloat(document.getElementById('modalTotal').textContent.replace('LKR ', ''));
                const cashAmount = parseFloat(document.getElementById('cashAmount').value) || 0;
                const cardAmount = Math.max(0, total - cashAmount);
                document.getElementById('cardAmount').value = cardAmount.toFixed(2);
            }

            // Process sale
            // Fixed processSale function
            function processSale() {
                console.log('=== Process Sale Started ===');

                if (!selectedPaymentMethod) {
                    alert('Please select a payment method');
                    return;
                }

                if (selectedPaymentMethod === 'MIXED') {
                    const total = parseFloat(document.getElementById('modalTotal').textContent.replace('LKR ', ''));
                    const cashAmount = parseFloat(document.getElementById('cashAmount').value) || 0;
                    const cardAmount = parseFloat(document.getElementById('cardAmount').value) || 0;

                    if (Math.abs((cashAmount + cardAmount) - total) > 0.01) {
                        alert('Cash and card amounts must equal the total');
                        return;
                    }
                }

                const processSaleBtn = document.getElementById('processSaleBtn');
                processSaleBtn.disabled = true;
                processSaleBtn.innerHTML = '<i class="bi bi-hourglass-split"></i> Processing...';

                // Prepare sale data
                const subtotal = cart.reduce((sum, item) => sum + item.total, 0);
                const discount = parseFloat(document.getElementById('discountInput').value) || 0;
                const taxableAmount = subtotal - discount;
                const tax = taxableAmount * 0;
                const total = taxableAmount + tax;

                console.log('Sale calculations:', {
                    subtotal: subtotal,
                    tax: tax,
                    discount: discount,
                    total: total,
                    cart: cart,
                    paymentMethod: selectedPaymentMethod
                });

                // Method 1: Try with URL parameters (most reliable)
                const params = new URLSearchParams();
                params.append('action', 'completeSale');
                params.append('customerName', document.getElementById('customerName').value || '');
                params.append('customerEmail', document.getElementById('customerEmail').value || '');
                params.append('subtotal', subtotal.toFixed(2));
                params.append('tax', tax.toFixed(2));
                params.append('discount', discount.toFixed(2));
                params.append('total', total.toFixed(2));
                params.append('paymentMethod', selectedPaymentMethod);
                params.append('notes', document.getElementById('notes').value || '');
                params.append('cartItems', JSON.stringify(cart));

                if (selectedPaymentMethod === 'MIXED') {
                    params.append('cashAmount', document.getElementById('cashAmount').value || '0');
                    params.append('cardAmount', document.getElementById('cardAmount').value || '0');
                }

                // Debug: Log all parameters
                console.log('=== Parameters Being Sent ===');
                for (let pair of params.entries()) {
                    console.log(pair[0] + ': ' + pair[1]);
                }

                // Submit sale with URLSearchParams (application/x-www-form-urlencoded)
                console.log('Sending POST request to: pos');

                fetch('pos', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: params.toString()
                })
                        .then(response => {
                            console.log('Response received:');
                            console.log('- Status:', response.status);
                            console.log('- Status Text:', response.statusText);
                            console.log('- URL:', response.url);

                            // Check if response is ok
                            if (!response.ok) {
                                throw new Error('HTTP error! status: ' + response.status + ' - ' + response.statusText);
                            }

                            // Check content type
                            const contentType = response.headers.get('content-type');
                            console.log('Content-Type:', contentType);

                            if (!contentType || !contentType.includes('application/json')) {
                                // If not JSON, get text to see what was returned
                                return response.text().then(text => {
                                    console.log('Non-JSON response received:', text);
                                    throw new Error('Server returned non-JSON response. First 200 chars: ' + text.substring(0, 200));
                                });
                            }

                            return response.text(); // Get as text first for debugging
                        })
                        .then(text => {
                            console.log('Raw response text:', text);

                            // Try to parse JSON
                            if (!text || text.trim() === '') {
                                throw new Error('Empty response from server');
                            }

                            let data;
                            try {
                                data = JSON.parse(text);
                            } catch (e) {
                                console.error('JSON parse error:', e);
                                console.error('Response text that failed to parse:', text);
                                throw new Error('Invalid JSON response. First 200 chars: ' + text.substring(0, 200));
                            }

                            console.log('Parsed response data:', data);

                            processSaleBtn.disabled = false;
                            processSaleBtn.innerHTML = '<i class="bi bi-check-circle"></i> Process Sale';

                            if (data.success) {
                                console.log('Sale completed successfully with ID:', data.saleId);
                                document.getElementById('saleIdSpan').textContent = data.saleId || 'Unknown';
                                new bootstrap.Modal(document.getElementById('successModal')).show();
                                loadBooks(); // Refresh book quantities
                            } else {
                                console.error('Sale failed:', data.error);
                                alert('Error: ' + (data.error || data.message || 'Failed to process sale'));
                            }
                        })
                        .catch(error => {
                            processSaleBtn.disabled = false;
                            processSaleBtn.innerHTML = '<i class="bi bi-check-circle"></i> Process Sale';

                            console.error('=== Sale Processing Error ===');
                            console.error('Error:', error);
                            console.error('Error message:', error.message);

                            alert('Failed to process sale: ' + error.message);
                        });
            }
        </script>
    </body>
</html>