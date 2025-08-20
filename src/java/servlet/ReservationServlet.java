package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/reservation")
public class ReservationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Database configuration
    private static final String DB_URL = "jdbc:mysql://localhost:3306/bookshop";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";
    
    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL Driver not found", e);
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "list";
        }
        
        switch (action) {
            case "list":
                listReservations(request, response);
                break;
            case "view":
                viewReservation(request, response);
                break;
            default:
                listReservations(request, response);
                break;
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("finalize".equals(action)) {
            finalizeReservation(request, response);
        } else {
            doGet(request, response);
        }
    }
    
    private void listReservations(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<Map<String, Object>> reservations = new ArrayList<>();
        
        String sql = "SELECT r.id, r.customer_id, r.book_id, r.quantity, r.status, " +
                    "r.reservation_date, r.notes, r.transaction_id, " +
                    "c.name as customer_name, c.email as customer_email, c.phone as customer_phone, " +
                    "b.title as book_title, b.author as book_author, b.selling_price " +
                    "FROM reservations r " +
                    "JOIN customers c ON r.customer_id = c.id " +
                    "JOIN books b ON r.book_id = b.id " +
                    "WHERE r.status IN ('PENDING', 'CONFIRMED') " +
                    "ORDER BY r.reservation_date DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> reservation = new HashMap<>();
                reservation.put("id", rs.getInt("id"));
                reservation.put("customerId", rs.getInt("customer_id"));
                reservation.put("bookId", rs.getInt("book_id"));
                reservation.put("quantity", rs.getInt("quantity"));
                reservation.put("status", rs.getString("status"));
                reservation.put("reservationDate", rs.getTimestamp("reservation_date"));
                reservation.put("notes", rs.getString("notes"));
                reservation.put("transactionId", rs.getString("transaction_id"));
                reservation.put("customerName", rs.getString("customer_name"));
                reservation.put("customerEmail", rs.getString("customer_email"));
                reservation.put("customerPhone", rs.getString("customer_phone"));
                reservation.put("bookTitle", rs.getString("book_title"));
                reservation.put("bookAuthor", rs.getString("book_author"));
                reservation.put("sellingPrice", rs.getDouble("selling_price"));
                reservation.put("total", rs.getDouble("selling_price") * rs.getInt("quantity"));
                
                reservations.add(reservation);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading reservations: " + e.getMessage());
        }
        
        request.setAttribute("reservations", reservations);
        request.getRequestDispatcher("reservations.jsp").forward(request, response);
    }
    
    private void viewReservation(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String reservationId = request.getParameter("id");
        Map<String, Object> reservation = null;
        
        if (reservationId != null) {
            String sql = "SELECT r.id, r.customer_id, r.book_id, r.quantity, r.status, " +
                        "r.reservation_date, r.notes, r.transaction_id, " +
                        "c.name as customer_name, c.email as customer_email, c.phone as customer_phone, " +
                        "b.title as book_title, b.author as book_author, b.selling_price " +
                        "FROM reservations r " +
                        "JOIN customers c ON r.customer_id = c.id " +
                        "JOIN books b ON r.book_id = b.id " +
                        "WHERE r.id = ?";
            
            try (Connection conn = getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                
                stmt.setInt(1, Integer.parseInt(reservationId));
                ResultSet rs = stmt.executeQuery();
                
                if (rs.next()) {
                    reservation = new HashMap<>();
                    reservation.put("id", rs.getInt("id"));
                    reservation.put("customerId", rs.getInt("customer_id"));
                    reservation.put("bookId", rs.getInt("book_id"));
                    reservation.put("quantity", rs.getInt("quantity"));
                    reservation.put("status", rs.getString("status"));
                    reservation.put("reservationDate", rs.getTimestamp("reservation_date"));
                    reservation.put("notes", rs.getString("notes"));
                    reservation.put("transactionId", rs.getString("transaction_id"));
                    reservation.put("customerName", rs.getString("customer_name"));
                    reservation.put("customerEmail", rs.getString("customer_email"));
                    reservation.put("customerPhone", rs.getString("customer_phone"));
                    reservation.put("bookTitle", rs.getString("book_title"));
                    reservation.put("bookAuthor", rs.getString("book_author"));
                    reservation.put("sellingPrice", rs.getDouble("selling_price"));
                    reservation.put("total", rs.getDouble("selling_price") * rs.getInt("quantity"));
                }
                
            } catch (SQLException e) {
                e.printStackTrace();
                request.setAttribute("errorMessage", "Error loading reservation details: " + e.getMessage());
            }
        }
        
        request.setAttribute("reservation", reservation);
        request.getRequestDispatcher("reservation-details.jsp").forward(request, response);
    }
    
    private void finalizeReservation(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String reservationId = request.getParameter("reservationId");
        String paymentMethod = request.getParameter("paymentMethod");
        String salesNotes = request.getParameter("salesNotes");
        
        if (reservationId == null || paymentMethod == null) {
            request.setAttribute("errorMessage", "Missing required parameters");
            listReservations(request, response);
            return;
        }
        
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); // Start transaction
            
            // Get reservation details
            String getReservationSql = "SELECT r.customer_id, r.book_id, r.quantity, " +
                                     "c.name as customer_name, c.email as customer_email, " +
                                     "b.selling_price, b.quantity as book_stock " +
                                     "FROM reservations r " +
                                     "JOIN customers c ON r.customer_id = c.id " +
                                     "JOIN books b ON r.book_id = b.id " +
                                     "WHERE r.id = ? AND r.status IN ('PENDING', 'CONFIRMED')";
            
            Map<String, Object> reservationData = new HashMap<>();
            try (PreparedStatement stmt = conn.prepareStatement(getReservationSql)) {
                stmt.setInt(1, Integer.parseInt(reservationId));
                ResultSet rs = stmt.executeQuery();
                
                if (!rs.next()) {
                    throw new SQLException("Reservation not found or already processed");
                }
                
                reservationData.put("customerId", rs.getInt("customer_id"));
                reservationData.put("bookId", rs.getInt("book_id"));
                reservationData.put("quantity", rs.getInt("quantity"));
                reservationData.put("customerName", rs.getString("customer_name"));
                reservationData.put("customerEmail", rs.getString("customer_email"));
                reservationData.put("sellingPrice", rs.getDouble("selling_price"));
                reservationData.put("bookStock", rs.getInt("book_stock"));
            }
            
            int quantity = (Integer) reservationData.get("quantity");
            double unitPrice = (Double) reservationData.get("sellingPrice");
            double subtotal = quantity * unitPrice;
            double tax = subtotal * 0.10; // 10% tax
            double total = subtotal + tax;
            
            // Check if enough stock is available
            int bookStock = (Integer) reservationData.get("bookStock");
            if (bookStock < quantity) {
                throw new SQLException("Insufficient stock. Available: " + bookStock + ", Required: " + quantity);
            }
            
            // Get current user ID from session
            HttpSession session = request.getSession();
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId == null) {
                userId = 1; // Default to admin user if session not found
            }
            
            // Create sale record
            String insertSaleSql = "INSERT INTO sales (customer_name, customer_email, subtotal, tax, " +
                                 "total, payment_method, cash_amount, card_amount, user_id, notes) " +
                                 "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            int saleId;
            try (PreparedStatement stmt = conn.prepareStatement(insertSaleSql, PreparedStatement.RETURN_GENERATED_KEYS)) {
                stmt.setString(1, (String) reservationData.get("customerName"));
                stmt.setString(2, (String) reservationData.get("customerEmail"));
                stmt.setDouble(3, subtotal);
                stmt.setDouble(4, tax);
                stmt.setDouble(5, total);
                stmt.setString(6, paymentMethod);
                
                if ("CASH".equals(paymentMethod)) {
                    stmt.setDouble(7, total);
                    stmt.setNull(8, java.sql.Types.DECIMAL);
                } else if ("CARD".equals(paymentMethod)) {
                    stmt.setNull(7, java.sql.Types.DECIMAL);
                    stmt.setDouble(8, total);
                } else {
                    stmt.setDouble(7, total / 2);
                    stmt.setDouble(8, total / 2);
                }
                
                stmt.setInt(9, userId);
                stmt.setString(10, salesNotes);
                
                stmt.executeUpdate();
                
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (!generatedKeys.next()) {
                    throw new SQLException("Failed to get sale ID");
                }
                saleId = generatedKeys.getInt(1);
            }
            
            // Create sale product record
            String insertSaleProductSql = "INSERT INTO sale_products (sale_id, book_id, quantity, unit_price, total_price) " +
                                        "VALUES (?, ?, ?, ?, ?)";
            
            try (PreparedStatement stmt = conn.prepareStatement(insertSaleProductSql)) {
                stmt.setInt(1, saleId);
                stmt.setInt(2, (Integer) reservationData.get("bookId"));
                stmt.setInt(3, quantity);
                stmt.setDouble(4, unitPrice);
                stmt.setDouble(5, quantity * unitPrice);
                stmt.executeUpdate();
            }
            
            // Update book stock (reduce quantity and reserved quantity)
            String updateBookSql = "UPDATE books SET quantity = quantity - ?, reserved_quantity = reserved_quantity - ? WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateBookSql)) {
                stmt.setInt(1, quantity);
                stmt.setInt(2, quantity);
                stmt.setInt(3, (Integer) reservationData.get("bookId"));
                stmt.executeUpdate();
            }
            
            // Update reservation status to COMPLETED
            String updateReservationSql = "UPDATE reservations SET status = 'COMPLETED' WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateReservationSql)) {
                stmt.setInt(1, Integer.parseInt(reservationId));
                stmt.executeUpdate();
            }
            
            conn.commit(); // Commit transaction
            
            request.setAttribute("successMessage", 
                "Reservation finalized successfully! Sale ID: " + saleId + ", Total: $" + String.format("%.2f", total));
            
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error finalizing reservation: " + e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        
        listReservations(request, response);
    }
}