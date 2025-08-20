<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reservation Management - Pahana Edu System</title>
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
        }
        .table-responsive {
            border-radius: 10px;
            overflow: hidden;
        }
        .table thead th {
            background-color: #6B73FF;
            color: white;
        }
        .badge-pending {
            background-color: #ffc107;
            color: #212529;
        }
        .badge-confirmed {
            background-color: #17a2b8;
        }
        .badge-completed {
            background-color: #28a745;
        }
        .badge-cancelled {
            background-color: #dc3545;
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
                <a class="nav-link" href="book">
                    <i class="fas fa-book me-1"></i>Books
                </a>
            </div>
        </div>
    </nav>

    <!-- Page Header -->
    <div class="page-header">
        <div class="container">
            <h1 class="mb-0">
                <i class="fas fa-calendar-check me-3"></i>Reservation Management
            </h1>
            <p class="mb-0 mt-2 opacity-75">View and finalize customer reservations</p>
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

        <% if (request.getAttribute("successMessage") != null) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>
                <%= request.getAttribute("successMessage") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <div class="card">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>Reservation ID</th>
                                <th>Date</th>
                                <th>Customer</th>
                                <th>Book</th>
                                <th>Quantity</th>
                                <th>Total</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                            List<Map<String, Object>> reservations = (List<Map<String, Object>>) request.getAttribute("reservations");
                            if (reservations != null) {
                                for (Map<String, Object> reservation : reservations) { 
                                    String badgeClass = "";
                                    String status = (String) reservation.get("status");
                                    switch(status) {
                                        case "PENDING":
                                            badgeClass = "badge-pending";
                                            break;
                                        case "CONFIRMED":
                                            badgeClass = "badge-confirmed";
                                            break;
                                        case "COMPLETED":
                                            badgeClass = "badge-completed";
                                            break;
                                        case "CANCELLED":
                                            badgeClass = "badge-cancelled";
                                            break;
                                    }
                            %>
                                <tr>
                                    <td><%= reservation.get("id") %></td>
                                    <td><%= dateFormat.format(reservation.get("reservationDate")) %></td>
                                    <td>
                                        <strong><%= reservation.get("customerName") %></strong><br>
                                        <small class="text-muted"><%= reservation.get("customerEmail") %></small>
                                    </td>
                                    <td>
                                        <strong><%= reservation.get("bookTitle") %></strong><br>
                                        <small class="text-muted">by <%= reservation.get("bookAuthor") %></small>
                                    </td>
                                    <td><%= reservation.get("quantity") %></td>
                                    <td>$<%= String.format("%.2f", (Double) reservation.get("total")) %></td>
                                    <td>
                                        <span class="badge <%= badgeClass %>">
                                            <%= status %>
                                        </span>
                                    </td>
                                    <td>
                                        <% if ("PENDING".equals(status) || "CONFIRMED".equals(status)) { %>
                                            <button class="btn btn-sm btn-success me-1" 
                                                    onclick="finalizeReservation('<%= reservation.get("id") %>', 
                                                                               '<%= reservation.get("customerName") %>', 
                                                                               '<%= reservation.get("bookTitle") %>', 
                                                                               '<%= reservation.get("quantity") %>', 
                                                                               '<%= String.format("%.2f", (Double) reservation.get("total")) %>')">
                                                <i class="fas fa-check"></i> Finalize
                                            </button>
                                        <% } %>
                                        <a href="reservation?action=view&id=<%= reservation.get("id") %>" 
                                           class="btn btn-sm btn-outline-primary">
                                            <i class="fas fa-eye"></i> View
                                        </a>
                                    </td>
                                </tr>
                            <% } 
                            } else { %>
                                <tr>
                                    <td colspan="8" class="text-center">No reservations found</td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Finalize Reservation Modal -->
    <div class="modal fade" id="finalizeModal" tabindex="-1" aria-labelledby="finalizeModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="finalizeModalLabel">Finalize Reservation</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="reservation" method="post">
                    <div class="modal-body">
                        <input type="hidden" name="action" value="finalize">
                        <input type="hidden" name="reservationId" id="reservationId">
                        
                        <div class="mb-3">
                            <label class="form-label"><strong>Customer:</strong></label>
                            <div id="customerInfo"></div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label"><strong>Book:</strong></label>
                            <div id="bookInfo"></div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label"><strong>Quantity:</strong></label>
                            <div id="quantityInfo"></div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label"><strong>Total Amount:</strong></label>
                            <div id="totalInfo" class="h5 text-success"></div>
                        </div>
                        
                        <div class="mb-3">
                            <label for="paymentMethod" class="form-label"><strong>Payment Method:</strong></label>
                            <select class="form-select" name="paymentMethod" id="paymentMethod" required>
                                <option value="">Select Payment Method</option>
                                <option value="CASH">Cash</option>
                                <option value="CARD">Card</option>
                                <option value="MIXED">Mixed (Cash + Card)</option>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label for="salesNotes" class="form-label">Notes (Optional):</label>
                            <textarea class="form-control" name="salesNotes" id="salesNotes" rows="3" 
                                      placeholder="Enter any additional notes for this sale..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-success">
                            <i class="fas fa-check-circle"></i> Complete Sale
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function finalizeReservation(id, customerName, bookTitle, quantity, total) {
            document.getElementById('reservationId').value = id;
            document.getElementById('customerInfo').innerHTML = customerName;
            document.getElementById('bookInfo').innerHTML = bookTitle;
            document.getElementById('quantityInfo').innerHTML = quantity;
            document.getElementById('totalInfo').innerHTML = '$' + total;
            
            var modal = new bootstrap.Modal(document.getElementById('finalizeModal'));
            modal.show();
        }
    </script>
</body>
</html>