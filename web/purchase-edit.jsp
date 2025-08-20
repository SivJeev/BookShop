<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Purchase" %>
<%@ page import="model.Supplier" %>
<%@ page import="model.Book" %>
<%@ page import="model.PurchaseItem" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Purchase purchase = (Purchase) request.getAttribute("purchase");
    List<Supplier> suppliers = (List<Supplier>) request.getAttribute("suppliers");
    List<Book> books = (List<Book>) request.getAttribute("books");
    List<PurchaseItem> items = purchase.getItems();
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Purchase - Bookshop System</title>
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
        .items-table th {
            background-color: #f8f9fa;
        }
        .item-row:last-child td {
            border-bottom: none;
        }
        .received-qty {
            color: #28a745;
            font-weight: bold;
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
                <i class="fas fa-edit me-3"></i>Edit Purchase #<%= purchase.getId() %>
            </h1>
            <p class="mb-0 mt-2 opacity-75">Update purchase information</p>
        </div>
    </div>

    <div class="container">
        <div class="row">
            <div class="col-lg-12">
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
                        <h4 class="card-title mb-4">Purchase Information</h4>
                        
                        <form action="purchase" method="post" id="purchaseForm">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="id" value="<%= purchase.getId() %>">
                            
                            <div class="row mb-4">
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label for="supplier" class="form-label">
                                            <i class="fas fa-truck me-2"></i>Supplier*
                                        </label>
                                        <select class="form-select" id="supplier" name="supplier" required>
                                            <option value="">Select Supplier</option>
                                            <% for (Supplier supplier : suppliers) { %>
                                                <option value="<%= supplier.getId() %>" 
                                                    <%= supplier.getId() == purchase.getSupplierId() ? "selected" : "" %>>
                                                    <%= supplier.getName() %>
                                                </option>
                                            <% } %>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label for="purchaseDate" class="form-label">
                                            <i class="fas fa-calendar-alt me-2"></i>Purchase Date*
                                        </label>
                                        <input type="date" class="form-control" id="purchaseDate" name="purchaseDate" 
                                               value="<%= dateFormat.format(purchase.getPurchaseDate()) %>" required>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label for="expectedDeliveryDate" class="form-label">
                                            <i class="fas fa-calendar-check me-2"></i>Expected Delivery Date
                                        </label>
                                        <input type="date" class="form-control" id="expectedDeliveryDate" name="expectedDeliveryDate"
                                               value="<%= purchase.getExpectedDeliveryDate() != null ? dateFormat.format(purchase.getExpectedDeliveryDate()) : "" %>">
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
                                            <option value="CASH" <%= purchase.getPaymentMethod().equals("CASH") ? "selected" : "" %>>Cash</option>
                                            <option value="CARD" <%= purchase.getPaymentMethod().equals("CARD") ? "selected" : "" %>>Card</option>
                                            <option value="BANK_TRANSFER" <%= purchase.getPaymentMethod().equals("BANK_TRANSFER") ? "selected" : "" %>>Bank Transfer</option>
                                            <option value="CREDIT" <%= purchase.getPaymentMethod().equals("CREDIT") ? "selected" : "" %>>Credit</option>
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
                                                   name="shippingCost" value="<%= String.format("%.2f", purchase.getShippingCost()) %>" required min="0">
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
                                                   name="tax" value="<%= String.format("%.2f", purchase.getTax()) %>" required min="0">
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="mb-4">
                                <label for="notes" class="form-label">
                                    <i class="fas fa-sticky-note me-2"></i>Notes
                                </label>
                                <textarea class="form-control" id="notes" name="notes" rows="2"><%= purchase.getNotes() != null ? purchase.getNotes() : "" %></textarea>
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
                                        <% for (PurchaseItem item : items) { %>
                                            <tr class="item-row">
                                                <td><%= item.getBookTitle() %></td>
                                                <td>
                                                    <input type="hidden" name="itemId" value="<%= item.getId() %>">
                                                    <input type="hidden" name="bookId" value="<%= item.getBookId() %>">
                                                    <input type="number" class="form-control form-control-sm quantity" 
                                                           name="quantity" value="<%= item.getQuantity() %>" min="1" required>
                                                    <% if (item.getReceivedQuantity() > 0) { %>
                                                        <small class="received-qty">Received: <%= item.getReceivedQuantity() %></small>
                                                    <% } %>
                                                </td>
                                                <td>
                                                    <div class="input-group input-group-sm">
                                                        <span class="input-group-text">$</span>
                                                        <input type="number" step="0.01" class="form-control unit-price" 
                                                               name="unitPrice" value="<%= String.format("%.2f", item.getUnitPrice()) %>" min="0" required>
                                                    </div>
                                                </td>
                                                <td class="text-end row-total">$<%= String.format("%.2f", item.getTotalPrice()) %></td>
                                                <td class="text-end">
                                                    <% if (item.getReceivedQuantity() == 0) { %>
                                                        <button type="button" class="btn btn-sm btn-outline-danger remove-item">
                                                            <i class="fas fa-trash"></i>
                                                        </button>
                                                    <% } %>
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                    <tfoot>
                                        <tr>
                                            <td colspan="5">
                                                <button type="button" class="btn btn-sm btn-outline-primary" id="addItemBtn">
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
                                            <td class="text-end" id="subtotal">$<%= String.format("%.2f", purchase.getTotalAmount() - purchase.getShippingCost() - purchase.getTax() + purchase.getDiscount()) %></td>
                                        </tr>
                                        <tr>
                                            <th>Shipping:</th>
                                            <td class="text-end" id="shippingDisplay">$<%= String.format("%.2f", purchase.getShippingCost()) %></td>
                                        </tr>
                                        <tr>
                                            <th>Tax:</th>
                                            <td class="text-end" id="taxDisplay">$<%= String.format("%.2f", purchase.getTax()) %></td>
                                        </tr>
                                        <tr>
                                            <th>Discount:</th>
                                            <td class="text-end">
                                                <div class="input-group input-group-sm">
                                                    <span class="input-group-text">$</span>
                                                    <input type="number" step="0.01" class="form-control" id="discount" 
                                                           name="discount" value="<%= String.format("%.2f", purchase.getDiscount()) %>" min="0">
                                                </div>
                                            </td>
                                        </tr>
                                        <tr class="border-top">
                                            <th>Total:</th>
                                            <td class="text-end fw-bold" id="total">$<%= String.format("%.2f", purchase.getTotalAmount()) %></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <button type="submit" class="btn btn-primary btn-lg w-100">
                                        <i class="fas fa-save me-2"></i>Update Purchase
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
    <div class="modal fade" id="bookModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Select Book</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Author</th>
                                <th>ISBN</th>
                                <th>Price</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Book book : books) { %>
                                <tr>
                                    <td><%= book.getTitle() %></td>
                                    <td><%= book.getAuthor() %></td>
                                    <td><%= book.getIsbn() %></td>
                                    <td>$<%= String.format("%.2f", book.getPurchasePrice()) %></td>
                                    <td class="text-end">
                                        <button type="button" class="btn btn-sm btn-primary select-book" 
                                                data-id="<%= book.getId() %>" 
                                                data-title="<%= book.getTitle() %>"
                                                data-price="<%= book.getPurchasePrice() %>">
                                            Select
                                        </button>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Book selection modal
        const bookModal = new bootstrap.Modal(document.getElementById('bookModal'));
        let currentRow = null;
        
        document.getElementById('addItemBtn').addEventListener('click', function() {
            currentRow = null;
            bookModal.show();
        });
        
        // Set up event listeners for existing rows
        document.querySelectorAll('.item-row').forEach(row => {
            row.querySelector('.quantity').addEventListener('change', function() {
                updateRowTotal(row);
            });
            
            row.querySelector('.unit-price').addEventListener('change', function() {
                updateRowTotal(row);
            });
            
            const removeBtn = row.querySelector('.remove-item');
            if (removeBtn) {
                removeBtn.addEventListener('click', function() {
                    row.remove();
                    calculateTotals();
                });
            }
        });
        
        document.querySelectorAll('.select-book').forEach(button => {
            button.addEventListener('click', function() {
                const bookId = this.getAttribute('data-id');
                const bookTitle = this.getAttribute('data-title');
                const bookPrice = this.getAttribute('data-price');
                
                if (currentRow) {
                    // Update existing row
                    currentRow.cells[0].textContent = bookTitle;
                    currentRow.querySelector('input[name="bookId"]').value = bookId;
                    currentRow.querySelector('input[name="unitPrice"]').value = bookPrice;
                    updateRowTotal(currentRow);
                } else {
                    // Add new row
                    const tbody = document.getElementById('itemsBody');
                    const newRow = document.createElement('tr');
                    newRow.className = 'item-row';
                    newRow.innerHTML = `
                        <td>${bookTitle}</td>
                        <td>
                            <input type="hidden" name="itemId" value="">
                            <input type="hidden" name="bookId" value="${bookId}">
                            <input type="number" class="form-control form-control-sm quantity" 
                                   name="quantity" value="1" min="1" required>
                        </td>
                        <td>
                            <div class="input-group input-group-sm">
                                <span class="input-group-text">$</span>
                                <input type="number" step="0.01" class="form-control unit-price" 
                                       name="unitPrice" value="${bookPrice}" min="0" required>
                            </div>
                        </td>
                        <td class="text-end row-total">$${bookPrice}</td>
                        <td class="text-end">
                            <button type="button" class="btn btn-sm btn-outline-danger remove-item">
                                <i class="fas fa-trash"></i>
                            </button>
                        </td>
                    `;
                    tbody.appendChild(newRow);
                    
                    // Add event listeners to new row
                    newRow.querySelector('.quantity').addEventListener('change', function() {
                        updateRowTotal(newRow);
                    });
                    
                    newRow.querySelector('.unit-price').addEventListener('change', function() {
                        updateRowTotal(newRow);
                    });
                    
                    newRow.querySelector('.remove-item').addEventListener('click', function() {
                        newRow.remove();
                        calculateTotals();
                    });
                }
                
                bookModal.hide();
                calculateTotals();
            });
        });
        
        function updateRowTotal(row) {
            const quantity = parseFloat(row.querySelector('.quantity').value) || 0;
            const unitPrice = parseFloat(row.querySelector('.unit-price').value) || 0;
            const total = quantity * unitPrice;
            row.querySelector('.row-total').textContent = '$' + total.toFixed(2);
            calculateTotals();
        }
        
        function calculateTotals() {
            let subtotal = 0;
            document.querySelectorAll('.item-row').forEach(row => {
                const rowTotal = parseFloat(row.querySelector('.row-total').textContent.replace('$', '')) || 0;
                subtotal += rowTotal;
            });
            
            const shipping = parseFloat(document.getElementById('shippingCost').value) || 0;
            const tax = parseFloat(document.getElementById('tax').value) || 0;
            const discount = parseFloat(document.getElementById('discount').value) || 0;
            
            document.getElementById('subtotal').textContent = '$' + subtotal.toFixed(2);
            document.getElementById('shippingDisplay').textContent = '$' + shipping.toFixed(2);
            document.getElementById('taxDisplay').textContent = '$' + tax.toFixed(2);
            
            const total = subtotal + shipping + tax - discount;
            document.getElementById('total').textContent = '$' + total.toFixed(2);
        }
        
        // Add event listeners for shipping, tax, discount
        document.getElementById('shippingCost').addEventListener('change', calculateTotals);
        document.getElementById('tax').addEventListener('change', calculateTotals);
        document.getElementById('discount').addEventListener('change', calculateTotals);
        
        // Form validation
        document.getElementById('purchaseForm').addEventListener('submit', function(e) {
            const itemRows = document.querySelectorAll('.item-row');
            if (itemRows.length === 0) {
                e.preventDefault();
                alert('Please add at least one item to the purchase.');
                return false;
            }
            
            const shipping = parseFloat(document.getElementById('shippingCost').value) || 0;
            const tax = parseFloat(document.getElementById('tax').value) || 0;
            const discount = parseFloat(document.getElementById('discount').value) || 0;
            
            if (shipping < 0 || tax < 0 || discount < 0) {
                e.preventDefault();
                alert('Shipping, tax and discount cannot be negative.');
                return false;
            }
            
            return true;
        });
    </script>
</body>
</html>