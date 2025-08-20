<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>

<%
    // Database connection parameters
    String dbURL = "jdbc:mysql://localhost:3306/bookshop";
    String dbUser = "root";
    String dbPassword = "";
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    // Get filter parameters
    String reportType = request.getParameter("reportType");
    String dateFrom = request.getParameter("dateFrom");
    String dateTo = request.getParameter("dateTo");
    String status = request.getParameter("status");
    String exportExcel = request.getParameter("exportExcel");
    
    // Set default values
    if (reportType == null) reportType = "sales";
    if (dateFrom == null || dateFrom.isEmpty()) {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.MONTH, -1);
        dateFrom = new SimpleDateFormat("yyyy-MM-dd").format(cal.getTime());
    }
    if (dateTo == null || dateTo.isEmpty()) {
        dateTo = new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
    }
    
    // Handle CSV Export with proper debugging
    if ("true".equals(exportExcel)) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
            
            String sql = "";
            String[] headers = {};
            String filename = "";
            
            if ("sales".equals(reportType)) {
                sql = "SELECT s.id, DATE_FORMAT(s.sale_date, '%Y-%m-%d %H:%i') as sale_date, " +
                      "COALESCE(s.customer_name, 'Walk-in') as customer_name, " +
                      "COALESCE(s.customer_email, '-') as customer_email, " +
                      "s.subtotal, s.tax, s.discount, s.total, s.payment_method, " +
                      "COALESCE(u.full_name, '-') as cashier " +
                      "FROM sales s " +
                      "LEFT JOIN users u ON s.user_id = u.id " +
                      "WHERE DATE(s.sale_date) BETWEEN ? AND ? " +
                      "ORDER BY s.sale_date DESC";
                headers = new String[]{"ID", "Date", "Customer", "Email", "Subtotal", "Tax", "Discount", "Total", "Payment", "Cashier"};
                filename = "sales_report_" + dateFrom + "_to_" + dateTo + ".csv";
            } else if ("purchases".equals(reportType)) {
                sql = "SELECT p.id, DATE_FORMAT(p.purchase_date, '%Y-%m-%d') as purchase_date, " +
                      "COALESCE(s.name, '-') as supplier, p.total_amount, " +
                      "p.paid_amount, p.payment_status, p.status, " +
                      "COALESCE(u.full_name, '-') as created_by " +
                      "FROM purchases p " +
                      "LEFT JOIN suppliers s ON p.supplier_id = s.id " +
                      "LEFT JOIN users u ON p.created_by = u.id " +
                      "WHERE DATE(p.purchase_date) BETWEEN ? AND ? ";
                if (status != null && !status.isEmpty()) {
                    sql += "AND p.status = ? ";
                }
                sql += "ORDER BY p.purchase_date DESC";
                headers = new String[]{"ID", "Date", "Supplier", "Total Amount", "Paid Amount", "Payment Status", "Status", "Created By"};
                filename = "purchases_report_" + dateFrom + "_to_" + dateTo + ".csv";
            } else if ("reservations".equals(reportType)) {
                sql = "SELECT r.id, DATE_FORMAT(r.reservation_date, '%Y-%m-%d %H:%i') as reservation_date, " +
                      "COALESCE(c.name, '-') as customer, COALESCE(c.email, '-') as email, " +
                      "COALESCE(b.title, '-') as book, r.quantity, r.status, " +
                      "COALESCE(r.transaction_id, '-') as transaction_id " +
                      "FROM reservations r " +
                      "LEFT JOIN customers c ON r.customer_id = c.id " +
                      "LEFT JOIN books b ON r.book_id = b.id " +
                      "WHERE DATE(r.reservation_date) BETWEEN ? AND ? ";
                if (status != null && !status.isEmpty()) {
                    sql += "AND r.status = ? ";
                }
                sql += "ORDER BY r.reservation_date DESC";
                headers = new String[]{"ID", "Date", "Customer", "Email", "Book", "Quantity", "Status", "Transaction ID"};
                filename = "reservations_report_" + dateFrom + "_to_" + dateTo + ".csv";
            }
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dateFrom);
            pstmt.setString(2, dateTo);
            if (status != null && !status.isEmpty() && !reportType.equals("sales")) {
                pstmt.setString(3, status);
            }
            
            rs = pstmt.executeQuery();
            
            // Set response headers for CSV download
            response.setContentType("text/csv; charset=UTF-8");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");
            response.setHeader("Cache-Control", "no-cache");
            response.setHeader("Pragma", "no-cache");
            
            PrintWriter csvWriter = response.getWriter();
            
            // Add BOM for proper UTF-8 encoding in Excel
            csvWriter.print('\ufeff');
            
            // Write headers
            for (int i = 0; i < headers.length; i++) {
                csvWriter.print("\"" + headers[i] + "\"");
                if (i < headers.length - 1) csvWriter.print(",");
            }
            csvWriter.println();
            
            // Write data rows
            int rowCount = 0;
            while (rs.next()) {
                rowCount++;
                for (int i = 0; i < headers.length; i++) {
                    Object value = rs.getObject(i + 1);
                    String cellValue = "";
                    if (value != null) {
                        cellValue = value.toString().replace("\"", "\"\""); // Escape quotes
                    }
                    csvWriter.print("\"" + cellValue + "\"");
                    if (i < headers.length - 1) csvWriter.print(",");
                }
                csvWriter.println();
            }
            
            csvWriter.flush();
            csvWriter.close();
            
            
            return;
        } catch (Exception e) {
            e.printStackTrace();
            // Log the error and continue to show the page with error message
            request.setAttribute("exportError", "Error during CSV export: " + e.getMessage());
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports Dashboard - BookHub</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f6fa;
            min-height: 100vh;
            padding: 20px;
            margin: 0;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            overflow: hidden;
        }

        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 25px;
            text-align: center;
        }

        .header h1 {
            font-size: 2rem;
            margin-bottom: 8px;
            font-weight: 600;
        }

        .header p {
            font-size: 1rem;
            opacity: 0.9;
            margin: 0;
        }

        .filters-section {
            background: #f8f9fa;
            padding: 25px;
            border-bottom: 1px solid #e9ecef;
        }

        .filters-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-group label {
            font-weight: 500;
            margin-bottom: 6px;
            color: #495057;
            font-size: 0.9rem;
            display: block;
        }

        .form-control {
            padding: 10px 12px;
            border: 1px solid #ced4da;
            border-radius: 6px;
            font-size: 0.95rem;
            transition: border-color 0.2s ease;
            background: white;
            width: 100%;
        }

        .form-control:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.1);
        }

        .btn-group {
            display: flex;
            gap: 12px;
            justify-content: center;
            margin-top: 20px;
            flex-wrap: wrap;
        }

        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            font-size: 0.95rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-primary {
            background: #667eea;
            color: white;
        }

        .btn-primary:hover {
            background: #5a6fd8;
            transform: translateY(-1px);
        }

        .btn-success {
            background: #28a745;
            color: white;
        }

        .btn-success:hover {
            background: #218838;
            transform: translateY(-1px);
        }

        .btn-info {
            background: #17a2b8;
            color: white;
        }

        .btn-info:hover {
            background: #138496;
            transform: translateY(-1px);
        }

        .content {
            padding: 25px;
        }

        .table-container {
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            margin-top: 20px;
        }

        .table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.9rem;
        }

        .table th {
            background: #f8f9fa;
            color: #495057;
            padding: 15px 12px;
            text-align: left;
            font-weight: 600;
            border-bottom: 2px solid #dee2e6;
        }

        .table td {
            padding: 12px;
            border-bottom: 1px solid #dee2e6;
            vertical-align: middle;
        }

        .table tbody tr:hover {
            background-color: #f8f9fa;
        }

        .status-badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 500;
            text-transform: uppercase;
        }

        .status-pending { background: #fff3cd; color: #856404; }
        .status-confirmed { background: #d4edda; color: #155724; }
        .status-completed { background: #d1ecf1; color: #0c5460; }
        .status-cancelled { background: #f8d7da; color: #721c24; }
        .status-paid { background: #d4edda; color: #155724; }
        .status-partial { background: #fff3cd; color: #856404; }
        .status-received { background: #d1ecf1; color: #0c5460; }
        .status-ordered { background: #e2e3e5; color: #383d41; }

        .summary-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 25px;
        }

        .summary-card {
            background: white;
            border: 1px solid #dee2e6;
            border-left: 4px solid #667eea;
            padding: 20px;
            border-radius: 6px;
        }

        .summary-card h3 {
            font-size: 1.8rem;
            margin-bottom: 8px;
            color: #495057;
            font-weight: 600;
        }

        .summary-card p {
            color: #6c757d;
            font-size: 0.9rem;
            margin: 0;
        }

        .no-data {
            text-align: center;
            padding: 40px 20px;
            color: #6c757d;
        }

        .no-data i {
            font-size: 3rem;
            margin-bottom: 15px;
            opacity: 0.5;
        }

        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border: 1px solid transparent;
            border-radius: 6px;
        }

        .alert-danger {
            color: #721c24;
            background-color: #f8d7da;
            border-color: #f5c6cb;
        }

        @media (max-width: 768px) {
            .filters-grid {
                grid-template-columns: 1fr;
            }
            
            .btn-group {
                flex-direction: column;
            }
            
            .header h1 {
                font-size: 1.5rem;
            }
            
            .table-container {
                overflow-x: auto;
            }
            
            .summary-cards {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1><i class="fas fa-chart-bar"></i> Reports Dashboard</h1>
            <p>Comprehensive business analytics and reporting</p>
        </div>

        <div class="filters-section">
            <form method="GET" action="">
                <div class="filters-grid">
                    <div class="form-group">
                        <label for="reportType"><i class="fas fa-filter"></i> Report Type</label>
                        <select name="reportType" id="reportType" class="form-control">
                            <option value="sales" <%= "sales".equals(reportType) ? "selected" : "" %>>Sales Report</option>
                            <option value="purchases" <%= "purchases".equals(reportType) ? "selected" : "" %>>Purchase Report</option>
                            <option value="reservations" <%= "reservations".equals(reportType) ? "selected" : "" %>>Reservation Report</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="dateFrom"><i class="fas fa-calendar-alt"></i> From Date</label>
                        <input type="date" name="dateFrom" id="dateFrom" class="form-control" value="<%= dateFrom %>">
                    </div>

                    <div class="form-group">
                        <label for="dateTo"><i class="fas fa-calendar-alt"></i> To Date</label>
                        <input type="date" name="dateTo" id="dateTo" class="form-control" value="<%= dateTo %>">
                    </div>

                    <div class="form-group" id="statusFilter" style="<%= "sales".equals(reportType) ? "display:none;" : "" %>">
                        <label for="status"><i class="fas fa-info-circle"></i> Status</label>
                        <select name="status" id="status" class="form-control">
                            <option value="">All Status</option>
                            <% if ("purchases".equals(reportType)) { %>
                                <option value="ORDERED" <%= "ORDERED".equals(status) ? "selected" : "" %>>Ordered</option>
                                <option value="RECEIVED" <%= "RECEIVED".equals(status) ? "selected" : "" %>>Received</option>
                                <option value="CANCELLED" <%= "CANCELLED".equals(status) ? "selected" : "" %>>Cancelled</option>
                                <option value="PARTIAL_RECEIVED" <%= "PARTIAL_RECEIVED".equals(status) ? "selected" : "" %>>Partial Received</option>
                            <% } else { %>
                                <option value="PENDING" <%= "PENDING".equals(status) ? "selected" : "" %>>Pending</option>
                                <option value="CONFIRMED" <%= "CONFIRMED".equals(status) ? "selected" : "" %>>Confirmed</option>
                                <option value="COMPLETED" <%= "COMPLETED".equals(status) ? "selected" : "" %>>Completed</option>
                                <option value="CANCELLED" <%= "CANCELLED".equals(status) ? "selected" : "" %>>Cancelled</option>
                            <% } %>
                        </select>
                    </div>
                </div>

                <div class="btn-group">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-search"></i> Generate Report
                    </button>
                    <button type="submit" name="exportExcel" value="true" class="btn btn-success">
                        <i class="fas fa-file-csv"></i> Export to CSV
                    </button>
                </div>
            </form>
        </div>

        <div class="content">
            <%
            // Check for export error
            String exportError = (String) request.getAttribute("exportError");
            if (exportError != null) {
            %>
            <div class="alert alert-danger">
                <h4>Export Error:</h4>
                <p><%= exportError %></p>
            </div>
            <%
            }
            
            if (request.getMethod().equals("GET") && request.getParameter("reportType") != null) {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
                    
                    // Summary calculations
                    String summarySQL = "";
                    if ("sales".equals(reportType)) {
                        summarySQL = "SELECT COUNT(*) as total_count, SUM(total) as total_amount, AVG(total) as avg_amount " +
                                   "FROM sales WHERE DATE(sale_date) BETWEEN ? AND ?";
                    } else if ("purchases".equals(reportType)) {
                        summarySQL = "SELECT COUNT(*) as total_count, SUM(total_amount) as total_amount, AVG(total_amount) as avg_amount " +
                                   "FROM purchases WHERE DATE(purchase_date) BETWEEN ? AND ?";
                        if (status != null && !status.isEmpty()) {
                            summarySQL += " AND status = ?";
                        }
                    } else if ("reservations".equals(reportType)) {
                        summarySQL = "SELECT COUNT(*) as total_count, SUM(quantity) as total_quantity " +
                                   "FROM reservations WHERE DATE(reservation_date) BETWEEN ? AND ?";
                        if (status != null && !status.isEmpty()) {
                            summarySQL += " AND status = ?";
                        }
                    }
                    
                    pstmt = conn.prepareStatement(summarySQL);
                    pstmt.setString(1, dateFrom);
                    pstmt.setString(2, dateTo);
                    if (status != null && !status.isEmpty() && !reportType.equals("sales")) {
                        pstmt.setString(3, status);
                    }
                    
                    rs = pstmt.executeQuery();
                    
                    int totalCount = 0;
                    double totalAmount = 0;
                    double avgAmount = 0;
                    int totalQuantity = 0;
                    
                    if (rs.next()) {
                        totalCount = rs.getInt("total_count");
                        if (!"reservations".equals(reportType)) {
                            totalAmount = rs.getDouble("total_amount");
                            avgAmount = rs.getDouble("avg_amount");
                        } else {
                            totalQuantity = rs.getInt("total_quantity");
                        }
                    }
                    rs.close();
                    pstmt.close();
            %>

            <div class="summary-cards">
                <div class="summary-card">
                    <h3><%= totalCount %></h3>
                    <p><i class="fas fa-list"></i> Total Records</p>
                </div>
                
                <% if (!"reservations".equals(reportType)) { %>
                <div class="summary-card">
                    <h3>LKR <%= String.format("%,.2f", totalAmount) %></h3>
                    <p><i class="fas fa-money-bill-wave"></i> Total Amount</p>
                </div>
                
                <div class="summary-card">
                    <h3>LKR <%= String.format("%,.2f", avgAmount) %></h3>
                    <p><i class="fas fa-chart-line"></i> Average Amount</p>
                </div>
                <% } else { %>
                <div class="summary-card">
                    <h3><%= totalQuantity %></h3>
                    <p><i class="fas fa-books"></i> Total Books Reserved</p>
                </div>
                <% } %>
            </div>

            <div class="table-container">
                <%
                // Main report query
                String mainSQL = "";
                if ("sales".equals(reportType)) {
                    mainSQL = "SELECT s.id, DATE_FORMAT(s.sale_date, '%Y-%m-%d %H:%i') as sale_date, " +
                             "s.customer_name, s.customer_email, s.subtotal, s.tax, s.discount, s.total, " +
                             "s.payment_method, u.full_name as cashier " +
                             "FROM sales s " +
                             "LEFT JOIN users u ON s.user_id = u.id " +
                             "WHERE DATE(s.sale_date) BETWEEN ? AND ? " +
                             "ORDER BY s.sale_date DESC";
                } else if ("purchases".equals(reportType)) {
                    mainSQL = "SELECT p.id, DATE_FORMAT(p.purchase_date, '%Y-%m-%d') as purchase_date, " +
                             "s.name as supplier, p.total_amount, p.paid_amount, p.payment_status, p.status, " +
                             "u.full_name as created_by " +
                             "FROM purchases p " +
                             "LEFT JOIN suppliers s ON p.supplier_id = s.id " +
                             "LEFT JOIN users u ON p.created_by = u.id " +
                             "WHERE DATE(p.purchase_date) BETWEEN ? AND ? ";
                    if (status != null && !status.isEmpty()) {
                        mainSQL += "AND p.status = ? ";
                    }
                    mainSQL += "ORDER BY p.purchase_date DESC";
                } else if ("reservations".equals(reportType)) {
                    mainSQL = "SELECT r.id, DATE_FORMAT(r.reservation_date, '%Y-%m-%d %H:%i') as reservation_date, " +
                             "c.name as customer, c.email, b.title as book, r.quantity, r.status, r.transaction_id " +
                             "FROM reservations r " +
                             "LEFT JOIN customers c ON r.customer_id = c.id " +
                             "LEFT JOIN books b ON r.book_id = b.id " +
                             "WHERE DATE(r.reservation_date) BETWEEN ? AND ? ";
                    if (status != null && !status.isEmpty()) {
                        mainSQL += "AND r.status = ? ";
                    }
                    mainSQL += "ORDER BY r.reservation_date DESC";
                }
                
                pstmt = conn.prepareStatement(mainSQL);
                pstmt.setString(1, dateFrom);
                pstmt.setString(2, dateTo);
                if (status != null && !status.isEmpty() && !reportType.equals("sales")) {
                    pstmt.setString(3, status);
                }
                
                rs = pstmt.executeQuery();
                %>

                <table class="table">
                    <thead>
                        <tr>
                            <% if ("sales".equals(reportType)) { %>
                                <th>ID</th>
                                <th>Date</th>
                                <th>Customer</th>
                                <th>Email</th>
                                <th>Subtotal</th>
                                <th>Tax</th>
                                <th>Discount</th>
                                <th>Total</th>
                                <th>Payment</th>
                                <th>Cashier</th>
                            <% } else if ("purchases".equals(reportType)) { %>
                                <th>ID</th>
                                <th>Date</th>
                                <th>Supplier</th>
                                <th>Total Amount</th>
                                <th>Paid Amount</th>
                                <th>Payment Status</th>
                                <th>Status</th>
                                <th>Created By</th>
                            <% } else if ("reservations".equals(reportType)) { %>
                                <th>ID</th>
                                <th>Date</th>
                                <th>Customer</th>
                                <th>Email</th>
                                <th>Book</th>
                                <th>Quantity</th>
                                <th>Status</th>
                                <th>Transaction ID</th>
                            <% } %>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        boolean hasData = false;
                        while (rs.next()) {
                            hasData = true;
                        %>
                        <tr>
                            <% if ("sales".equals(reportType)) { %>
                                <td><%= rs.getInt("id") %></td>
                                <td><%= rs.getString("sale_date") %></td>
                                <td><%= rs.getString("customer_name") != null ? rs.getString("customer_name") : "Walk-in" %></td>
                                <td><%= rs.getString("customer_email") != null ? rs.getString("customer_email") : "-" %></td>
                                <td>LKR <%= String.format("%,.2f", rs.getDouble("subtotal")) %></td>
                                <td>LKR <%= String.format("%,.2f", rs.getDouble("tax")) %></td>
                                <td>LKR <%= String.format("%,.2f", rs.getDouble("discount")) %></td>
                                <td><strong>LKR <%= String.format("%,.2f", rs.getDouble("total")) %></strong></td>
                                <td><%= rs.getString("payment_method") %></td>
                                <td><%= rs.getString("cashier") %></td>
                            <% } else if ("purchases".equals(reportType)) { %>
                                <td><%= rs.getInt("id") %></td>
                                <td><%= rs.getString("purchase_date") %></td>
                                <td><%= rs.getString("supplier") %></td>
                                <td>LKR <%= String.format("%,.2f", rs.getDouble("total_amount")) %></td>
                                <td>LKR <%= String.format("%,.2f", rs.getDouble("paid_amount")) %></td>
                                <td><span class="status-badge status-<%= rs.getString("payment_status").toLowerCase() %>"><%= rs.getString("payment_status") %></span></td>
                                <td><span class="status-badge status-<%= rs.getString("status").toLowerCase() %>"><%= rs.getString("status") %></span></td>
                                <td><%= rs.getString("created_by") %></td>
                            <% } else if ("reservations".equals(reportType)) { %>
                                <td><%= rs.getInt("id") %></td>
                                <td><%= rs.getString("reservation_date") %></td>
                                <td><%= rs.getString("customer") %></td>
                                <td><%= rs.getString("email") %></td>
                                <td><%= rs.getString("book") %></td>
                                <td><%= rs.getInt("quantity") %></td>
                                <td><span class="status-badge status-<%= rs.getString("status").toLowerCase() %>"><%= rs.getString("status") %></span></td>
                                <td><%= rs.getString("transaction_id") %></td>
                            <% } %>
                        </tr>
                        <% } %>
                        
                        <% if (!hasData) { %>
                        <tr>
                            <td colspan="10" class="no-data">
                                <i class="fas fa-inbox"></i>
                                <h3>No Data Found</h3>
                                <p>No records found for the selected criteria. Try adjusting your filters.</p>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <%
                } catch (Exception e) {
                    out.println("<div class='alert alert-danger'>");
                    out.println("<h4>Error occurred while generating report:</h4>");
                    out.println("<p>" + e.getMessage() + "</p>");
                    out.println("</div>");
                    e.printStackTrace();
                } finally {
                    if (rs != null) try { rs.close(); } catch (Exception e) {}
                    if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
                    if (conn != null) try { conn.close(); } catch (Exception e) {}
                }
            } else {
            %>
            <div class="no-data">
                <i class="fas fa-chart-bar"></i>
                <h3>Welcome to Reports Dashboard</h3>
                <p>Select your report type and date range above, then click "Generate Report" to view your data.</p>
            </div>
            <% } %>
        </div>
    </div>

    <script>
        // Handle report type change to show/hide status filter
        document.getElementById('reportType').addEventListener('change', function() {
            const statusFilter = document.getElementById('statusFilter');
            const statusSelect = document.getElementById('status');
            
            if (this.value === 'sales') {
                statusFilter.style.display = 'none';
                statusSelect.value = '';
            } else {
                statusFilter.style.display = 'block';
                // Clear and populate status options based on report type
                statusSelect.innerHTML = '<option value="">All Status</option>';
                
                if (this.value === 'purchases') {
                    statusSelect.innerHTML += `
                        <option value="ORDERED">Ordered</option>
                        <option value="RECEIVED">Received</option>
                        <option value="CANCELLED">Cancelled</option>
                        <option value="PARTIAL_RECEIVED">Partial Received</option>
                    `;
                } else if (this.value === 'reservations') {
                    statusSelect.innerHTML += `
                        <option value="PENDING">Pending</option>
                        <option value="CONFIRMED">Confirmed</option>
                        <option value="COMPLETED">Completed</option>
                        <option value="CANCELLED">Cancelled</option>
                    `;
                }
            }
        });

        // Add smooth scrolling to table when data loads
        document.addEventListener('DOMContentLoaded', function() {
            const tableContainer = document.querySelector('.table-container');
            if (tableContainer && document.querySelector('.table tbody tr:not(.no-data)')) {
                tableContainer.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        });

        // Add loading animation for form submission
        document.querySelector('form').addEventListener('submit', function(e) {
            const buttons = document.querySelectorAll('.btn');
            buttons.forEach(btn => {
                if (btn.type === 'submit') {
                    btn.disabled = true;
                    const originalText = btn.innerHTML;
                    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Loading...';
                    
                    setTimeout(() => {
                        btn.disabled = false;
                        btn.innerHTML = originalText;
                    }, 3000);
                }
            });
        });

        // Enhanced table interactions (simplified)
        document.addEventListener('DOMContentLoaded', function() {
            const rows = document.querySelectorAll('.table tbody tr:not(.no-data)');
            
            rows.forEach(row => {
                row.addEventListener('mouseenter', function() {
                    this.style.backgroundColor = '#f8f9fa';
                });
                
                row.addEventListener('mouseleave', function() {
                    this.style.backgroundColor = '';
                });
            });
        });

        // Auto-refresh feature (optional)
        let autoRefresh = false;
        function toggleAutoRefresh() {
            autoRefresh = !autoRefresh;
            if (autoRefresh) {
                setInterval(() => {
                    if (autoRefresh) {
                        document.querySelector('form').submit();
                    }
                }, 30000); // Refresh every 30 seconds
            }
        }

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            // Ctrl + E for CSV export
            if (e.ctrlKey && e.key === 'e') {
                e.preventDefault();
                const exportBtn = document.querySelector('button[name="exportExcel"]');
                if (exportBtn) {
                    exportBtn.click();
                }
            }
            
            // Ctrl + R for refresh/generate report
            if (e.ctrlKey && e.key === 'r') {
                e.preventDefault();
                document.querySelector('form').submit();
            }
        });

        // Print functionality
        function printReport() {
            const printWindow = window.open('', '_blank');
            const tableHtml = document.querySelector('.table-container').outerHTML;
            const summaryHtml = document.querySelector('.summary-cards').outerHTML;
            
            printWindow.document.write(`
                <html>
                <head>
                    <title>Report - ${document.getElementById('reportType').value.toUpperCase()}</title>
                    <style>
                        body { font-family: Arial, sans-serif; margin: 20px; }
                        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
                        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
                        th { background-color: #f2f2f2; }
                        .summary-cards { display: flex; gap: 20px; margin-bottom: 20px; }
                        .summary-card { border: 1px solid #ddd; padding: 15px; border-radius: 5px; }
                        @media print { body { margin: 0; } }
                    </style>
                </head>
                <body>
                    <h1>BookHub - ${document.getElementById('reportType').value.toUpperCase()} Report</h1>
                    
                    <p>Period: ${document.getElementById('dateFrom').value} to ${document.getElementById('dateTo').value}</p>
                    ${summaryHtml}
                    ${tableHtml}
                </body>
                </html>
            `);
            
            printWindow.document.close();
            printWindow.print();
        }

        // Add print button dynamically if data exists
        document.addEventListener('DOMContentLoaded', function() {
            if (document.querySelector('.table tbody tr:not(.no-data)')) {
                const btnGroup = document.querySelector('.btn-group');
                const printBtn = document.createElement('button');
                printBtn.type = 'button';
                printBtn.className = 'btn btn-info';
                printBtn.innerHTML = '<i class="fas fa-print"></i> Print Report';
                printBtn.onclick = printReport;
                btnGroup.appendChild(printBtn);
            }
        });1)';
                    this.style.zIndex = '5';
                });
                
                row.addEventListener('mouseleave', function() {
                    this.style.transform = 'scale(1)';
                    this.style.boxShadow = 'none';
                    this.style.zIndex = '1';
                });
            });
        });

        // Auto-refresh feature (optional)
        let autoRefresh = false;
        function toggleAutoRefresh() {
            autoRefresh = !autoRefresh;
            if (autoRefresh) {
                setInterval(() => {
                    if (autoRefresh) {
                        document.querySelector('form').submit();
                    }
                }, 30000); // Refresh every 30 seconds
            }
        }

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            // Ctrl + E for CSV export
            if (e.ctrlKey && e.key === 'e') {
                e.preventDefault();
                const exportBtn = document.querySelector('button[name="exportExcel"]');
                if (exportBtn) {
                    exportBtn.click();
                }
            }
            
            // Ctrl + R for refresh/generate report
            if (e.ctrlKey && e.key === 'r') {
                e.preventDefault();
                document.querySelector('form').submit();
            }
        });

        // Print functionality
        function printReport() {
            const printWindow = window.open('', '_blank');
            const tableHtml = document.querySelector('.table-container').outerHTML;
            const summaryHtml = document.querySelector('.summary-cards').outerHTML;
            
            printWindow.document.write(`
                <html>
                <head>
                    <title>Report - ${document.getElementById('reportType').value.toUpperCase()}</title>
                    <style>
                        body { font-family: Arial, sans-serif; margin: 20px; }
                        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
                        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
                        th { background-color: #f2f2f2; }
                        .summary-cards { display: flex; gap: 20px; margin-bottom: 20px; }
                        .summary-card { border: 1px solid #ddd; padding: 15px; border-radius: 5px; }
                        @media print { body { margin: 0; } }
                    </style>
                </head>
                <body>
                    <h1>BookHub - ${document.getElementById('reportType').value.toUpperCase()} Report</h1>
                    
                    <p>Period: ${document.getElementById('dateFrom').value} to ${document.getElementById('dateTo').value}</p>
                    ${summaryHtml}
                    ${tableHtml}
                </body>
                </html>
            `);
            
            printWindow.document.close();
            printWindow.print();
        }

        // Add print button dynamically
        if (document.querySelector('.table tbody tr:not(.no-data)')) {
            const btnGroup = document.querySelector('.btn-group');
            const printBtn = document.createElement('button');
            printBtn.type = 'button';
            printBtn.className = 'btn btn-info';
            printBtn.innerHTML = '<i class="fas fa-print"></i> Print Report';
            printBtn.onclick = printReport;
            btnGroup.appendChild(printBtn);
        }
    </script>
</body>
</html>