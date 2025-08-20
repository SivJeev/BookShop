<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Supplier" %>
<%@ page import="model.Book" %>
<%@ page import="java.util.List" %>
<%
    List<Supplier> suppliers = (List<Supplier>) request.getAttribute("suppliers");
    List<Book> books = (List<Book>) request.getAttribute("books");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Add Purchase - Bookshop System</title>
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
            .items-table th {
                background-color: #f8f9fa;
            }
            .item-row:last-child td {
                border-bottom: none;
            }
            .book-info {
                line-height: 1.2;
            }
            .book-title {
                font-weight: 600;
            }
            .book-author {
                font-size: 0.9rem;
                color: #6c757d;
            }
            .book-isbn {
                font-size: 0.8rem;
                color: #6c757d;
            }
            #bookModal .modal-body {
                max-height: 60vh;
                overflow-y: auto;
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
                    <a class="nav-link" href="purchase?action=list">
                        <i class="fas fa-arrow-left me-1"></i>Back to Purchases
                    </a>
                </div>
            </div>
        </nav>

        <!-- Page Header -->
        <div class="page-header">
            <div class="container">
                <h1 class="mb-0">
                    <i class="fas fa-cart-plus me-3"></i>New Purchase
                </h1>
                <p class="mb-0 mt-2 opacity-75">Create a new purchase order</p>
            </div>
        </div>

        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-12">
                    <!-- Display Messages -->
                    <% if (request.getAttribute("errorMessage") != null) {%>
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i>
                        <%= request.getAttribute("errorMessage")%>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <% } %>

                    <div class="card form-card">
                        <div class="card-body p-5">
                            <h4 class="card-title mb-4">Purchase Information</h4>

                            <form action="purchase" method="post" id="purchaseForm">
                                <input type="hidden" name="action" value="create">

                                <div class="row mb-4">
                                    <div class="col-md-4">
                                        <div class="mb-3">
                                            <label for="supplier" class="form-label">
                                                <i class="fas fa-truck me-2"></i>Supplier*
                                            </label>
                                            <select class="form-select" id="supplier" name="supplier" required>
                                                <option value="">Select Supplier</option>
                                                <% if (suppliers != null) { %>
                                                <% for (Supplier supplier : suppliers) {%>
                                                <option value="<%= supplier.getId()%>"><%= supplier.getName()%></option>
                                                <% } %>
                                                <% } %>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="mb-3">
                                            <label for="purchaseDate" class="form-label">
                                                <i class="fas fa-calendar-alt me-2"></i>Purchase Date*
                                            </label>
                                            <input type="date" class="form-control" id="purchaseDate" name="purchaseDate" required>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="mb-3">
                                            <label for="expectedDeliveryDate" class="form-label">
                                                <i class="fas fa-calendar-check me-2"></i>Expected Delivery Date
                                            </label>
                                            <input type="date" class="form-control" id="expectedDeliveryDate" name="expectedDeliveryDate">
                                        </div>
                                    </div>
                                </div>

                                <div class="row mb-4">
                                    <div class="col-md-4">
                                        <div class="mb-3">
                                            <label for="paymentMethod" class="form-label">
                                                <i class="fas fa-credit-card me-2"></i>Payment Method*
                                            </label>
                                            <select class="form-select" id="paymentMethod" name="paymentMethod" required>
                                                <option value="">Select Payment Method</option>
                                                <option value="CASH">Cash</option>
                                                <option value="CARD">Card</option>
                                                <option value="BANK_TRANSFER">Bank Transfer</option>
                                                <option value="CREDIT">Credit</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="mb-3">
                                            <label for="shippingCost" class="form-label">
                                                <i class="fas fa-shipping-fast me-2"></i>Shipping Cost*
                                            </label>
                                            <div class="input-group">
                                                <span class="input-group-text">$</span>
                                                <input type="number" step="0.01" class="form-control" id="shippingCost" 
                                                       name="shippingCost" value="0.00" required min="0">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="mb-3">
                                            <label for="tax" class="form-label">
                                                <i class="fas fa-percentage me-2"></i>Tax*
                                            </label>
                                            <div class="input-group">
                                                <span class="input-group-text">$</span>
                                                <input type="number" step="0.01" class="form-control" id="tax" 
                                                       name="tax" value="0.00" required min="0">
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="mb-4">
                                    <label for="notes" class="form-label">
                                        <i class="fas fa-sticky-note me-2"></i>Notes
                                    </label>
                                    <textarea class="form-control" id="notes" name="notes" rows="2" placeholder="Optional notes about the purchase..."></textarea>
                                </div>

                                <h5 class="mb-3">
                                    <i class="fas fa-book me-2"></i>Purchase Items
                                </h5>

                                <div class="table-responsive mb-4">
                                    <table class="table items-table" id="itemsTable">
                                        <thead>
                                            <tr>
                                                <th>Book</th>
                                                <th width="120">Quantity</th>
                                                <th width="150">Unit Price</th>
                                                <th width="150">Total</th>
                                                <th width="50"></th>
                                            </tr>
                                        </thead>
                                        <tbody id="itemsBody">
                                            <!-- Items will be added here dynamically -->
                                        </tbody>
                                        <tfoot>
                                            <tr>
                                                <td colspan="5">
                                                    <button type="button" class="btn btn-sm btn-outline-primary" 
                                                            data-bs-toggle="modal" data-bs-target="#bookModal">
                                                        <i class="fas fa-plus me-1"></i>Add Item
                                                    </button>
                                                </td>
                                            </tr>
                                        </tfoot>
                                    </table>
                                </div>

                                <div class="row mb-4">
                                    <div class="col-md-4 offset-md-8">
                                        <table class="table table-borderless">
                                            <tr>
                                                <th>Subtotal:</th>
                                                <td class="text-end" id="subtotal">$0.00</td>
                                            </tr>
                                            <tr>
                                                <th>Shipping:</th>
                                                <td class="text-end" id="shippingDisplay">$0.00</td>
                                            </tr>
                                            <tr>
                                                <th>Tax:</th>
                                                <td class="text-end" id="taxDisplay">$0.00</td>
                                            </tr>
                                            <tr>
                                                <th>Discount:</th>
                                                <td class="text-end">
                                                    <div class="input-group input-group-sm">
                                                        <span class="input-group-text">$</span>
                                                        <input type="number" step="0.01" class="form-control" id="discount" 
                                                               name="discount" value="0.00" min="0">
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr class="border-top">
                                                <th>Total:</th>
                                                <td class="text-end fw-bold" id="total">$0.00</td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <button type="submit" class="btn btn-primary btn-lg w-100">
                                            <i class="fas fa-save me-2"></i>Save Purchase
                                        </button>
                                    </div>
                                    <div class="col-md-6">
                                        <a href="purchase?action=list" class="btn btn-secondary btn-lg w-100">
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

        <!-- Book Selection Modal -->
        <div class="modal fade" id="bookModal" tabindex="-1" aria-labelledby="bookModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="bookModalLabel">Select Book</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <input type="text" class="form-control" id="bookSearch" placeholder="Search books by title, author, or ISBN...">
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover" id="bookTable">
                                <thead>
                                    <tr>
                                        <th>Title</th>
                                        <th>Author</th>
                                        <th>ISBN</th>
                                        <th>Price</th>
                                        <th></th>
                                    </tr>
                                </thead>
                                <tbody id="bookTableBody">
                                    <% if (books != null && books.size() > 0) { %>
                                    <% for (Book book : books) {%>
                                    <tr class="book-row">
                                        <td><%= book.getTitle()%></td>
                                        <td><%= book.getAuthor()%></td>
                                        <td><%= book.getIsbn()%></td>
                                        <td>$<%= String.format("%.2f", book.getPurchasePrice())%></td>
                                        <td class="text-end">
                                            <button type="button" class="btn btn-sm btn-primary select-book" 
                                                    data-id="<%= book.getId()%>" 
                                                    data-title="<%= book.getTitle().replace("\"", "&quot;").replace("'", "&#39;")%>"
                                                    data-author="<%= book.getAuthor().replace("\"", "&quot;").replace("'", "&#39;")%>"
                                                    data-isbn="<%= book.getIsbn()%>"
                                                    data-price="<%= book.getPurchasePrice()%>">
                                                Select
                                            </button>
                                        </td>
                                    </tr>
                                    <% } %>
                                    <% } else { %>
                                    <tr>
                                        <td colspan="5" class="text-center text-muted">No books available</td>
                                    </tr>
                                    <% }%>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
        
        <!-- JavaScript -->
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                // Initialize modal
                var bookModalElement = document.getElementById('bookModal');
                var bookModal = new bootstrap.Modal(bookModalElement);

                // Set today's date
                var today = new Date();
                document.getElementById('purchaseDate').value = today.toISOString().substr(0, 10);

                // Book search functionality
                document.getElementById('bookSearch').addEventListener('input', function () {
                    var searchTerm = this.value.toLowerCase();
                    var bookRows = document.querySelectorAll('.book-row');
                    
                    for (var i = 0; i < bookRows.length; i++) {
                        var row = bookRows[i];
                        var title = row.cells[0].textContent.toLowerCase();
                        var author = row.cells[1].textContent.toLowerCase();
                        var isbn = row.cells[2].textContent.toLowerCase();
                        
                        if (title.includes(searchTerm) || author.includes(searchTerm) || isbn.includes(searchTerm)) {
                            row.style.display = '';
                        } else {
                            row.style.display = 'none';
                        }
                    }
                });

                // Clear search when modal opens
                bookModalElement.addEventListener('show.bs.modal', function () {
                    document.getElementById('bookSearch').value = '';
                    var bookRows = document.querySelectorAll('.book-row');
                    for (var i = 0; i < bookRows.length; i++) {
                        bookRows[i].style.display = '';
                    }
                });

                // Book selection handler - using event delegation
                document.getElementById('bookTableBody').addEventListener('click', function (e) {
                    if (e.target.classList.contains('select-book')) {
                        var button = e.target;
                        var bookData = {
                            id: button.dataset.id,
                            title: button.dataset.title,
                            author: button.dataset.author,
                            isbn: button.dataset.isbn,
                            price: parseFloat(button.dataset.price)
                        };

                        // Check if book already exists
                        var existingIds = [];
                        var bookIdInputs = document.querySelectorAll('input[name="bookId"]');
                        for (var i = 0; i < bookIdInputs.length; i++) {
                            existingIds.push(bookIdInputs[i].value);
                        }

                        if (existingIds.indexOf(bookData.id) !== -1) {
                            alert('This book is already added to the purchase.');
                            return;
                        }

                        // Add new row
                        addBookRow(bookData);

                        // Close modal
                        bookModal.hide();
                        calculateTotals();
                    }
                });

                // Remove item handler
                document.getElementById('itemsBody').addEventListener('click', function (e) {
                    if (e.target.closest('.remove-item')) {
                        e.target.closest('tr').remove();
                        calculateTotals();
                    }
                });

                // Escape HTML function to prevent XSS
                function escapeHtml(text) {
                    var div = document.createElement('div');
                    div.textContent = text;
                    return div.innerHTML;
                }

                // Add book row function
                function addBookRow(book) {
                    var row = document.createElement('tr');
                    row.className = 'item-row';
                    
                    // Create the row HTML using string concatenation to avoid JSP EL conflicts
                    row.innerHTML = 
                        '<td>' +
                            '<div class="book-info">' +
                                '<div class="book-title">' + escapeHtml(book.title) + '</div>' +
                                '<div class="book-author">' + escapeHtml(book.author) + '</div>' +
                                '<div class="book-isbn">' + escapeHtml(book.isbn) + '</div>' +
                            '</div>' +
                        '</td>' +
                        '<td>' +
                            '<input type="hidden" name="bookId" value="' + book.id + '">' +
                            '<input type="number" class="form-control form-control-sm quantity" ' +
                                   'name="quantity" value="1" min="1" required>' +
                        '</td>' +
                        '<td>' +
                            '<div class="input-group input-group-sm">' +
                                '<span class="input-group-text">$</span>' +
                                '<input type="number" step="0.01" class="form-control unit-price" ' +
                                       'name="unitPrice" value="' + book.price.toFixed(2) + '" min="0" required>' +
                            '</div>' +
                        '</td>' +
                        '<td class="text-end row-total">$' + book.price.toFixed(2) + '</td>' +
                        '<td class="text-end">' +
                            '<button type="button" class="btn btn-sm btn-outline-danger remove-item">' +
                                '<i class="fas fa-trash"></i>' +
                            '</button>' +
                        '</td>';

                    // Add event listeners for the new row
                    var quantityInput = row.querySelector('.quantity');
                    var unitPriceInput = row.querySelector('.unit-price');
                    
                    quantityInput.addEventListener('input', function() {
                        updateRowTotal(row);
                    });
                    
                    unitPriceInput.addEventListener('input', function() {
                        updateRowTotal(row);
                    });

                    document.getElementById('itemsBody').appendChild(row);
                }

                // Update row total
                function updateRowTotal(row) {
                    var quantity = parseFloat(row.querySelector('.quantity').value) || 0;
                    var unitPrice = parseFloat(row.querySelector('.unit-price').value) || 0;
                    row.querySelector('.row-total').textContent = '$' + (quantity * unitPrice).toFixed(2);
                    calculateTotals();
                }

                // Calculate totals
                function calculateTotals() {
                    var subtotal = 0;
                    var itemRows = document.querySelectorAll('.item-row');
                    
                    for (var i = 0; i < itemRows.length; i++) {
                        var rowTotalText = itemRows[i].querySelector('.row-total').textContent.replace('$', '');
                        subtotal += parseFloat(rowTotalText) || 0;
                    }

                    var shipping = parseFloat(document.getElementById('shippingCost').value) || 0;
                    var tax = parseFloat(document.getElementById('tax').value) || 0;
                    var discount = parseFloat(document.getElementById('discount').value) || 0;

                    document.getElementById('subtotal').textContent = '$' + subtotal.toFixed(2);
                    document.getElementById('shippingDisplay').textContent = '$' + shipping.toFixed(2);
                    document.getElementById('taxDisplay').textContent = '$' + tax.toFixed(2);

                    var total = Math.max(0, subtotal + shipping + tax - discount);
                    document.getElementById('total').textContent = '$' + total.toFixed(2);
                }

                // Form validation
                document.getElementById('purchaseForm').addEventListener('submit', function (e) {
                    var itemRows = document.querySelectorAll('.item-row');
                    if (itemRows.length === 0) {
                        e.preventDefault();
                        alert('Please add at least one item to the purchase.');
                        return;
                    }

                    // Validate all fields
                    var errors = [];

                    // Validate items
                    for (var i = 0; i < itemRows.length; i++) {
                        var row = itemRows[i];
                        var quantity = parseFloat(row.querySelector('.quantity').value);
                        var price = parseFloat(row.querySelector('.unit-price').value);

                        if (isNaN(quantity)) {
                            errors.push('Item ' + (i + 1) + ': Invalid quantity');
                        }
                        if (quantity <= 0) {
                            errors.push('Item ' + (i + 1) + ': Quantity must be positive');
                        }
                        if (isNaN(price)) {
                            errors.push('Item ' + (i + 1) + ': Invalid price');
                        }
                        if (price < 0) {
                            errors.push('Item ' + (i + 1) + ': Price cannot be negative');
                        }
                    }

                    // Validate other fields
                    if (!document.getElementById('supplier').value) {
                        errors.push('Supplier is required');
                    }
                    if (!document.getElementById('purchaseDate').value) {
                        errors.push('Purchase date is required');
                    }
                    if (!document.getElementById('paymentMethod').value) {
                        errors.push('Payment method is required');
                    }

                    var shipping = parseFloat(document.getElementById('shippingCost').value);
                    var tax = parseFloat(document.getElementById('tax').value);
                    if (shipping < 0) {
                        errors.push('Shipping cost cannot be negative');
                    }
                    if (tax < 0) {
                        errors.push('Tax cannot be negative');
                    }

                    if (errors.length > 0) {
                        e.preventDefault();
                        alert('Please fix the following errors:\n\n' + errors.join('\n'));
                    }
                });

                // Initialize totals
                calculateTotals();

                // Add input listeners for shipping, tax, discount
                var costInputs = ['shippingCost', 'tax', 'discount'];
                for (var i = 0; i < costInputs.length; i++) {
                    document.getElementById(costInputs[i]).addEventListener('input', calculateTotals);
                }
            });
        </script>
    </body>
</html>