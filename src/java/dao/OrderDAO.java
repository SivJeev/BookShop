package dao;

import model.*;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {
    private final DBConnection dbConnection;

    public OrderDAO() throws SQLException {
        this.dbConnection = DBConnection.getInstance();
    }

    public int createOrder(Order order) throws SQLException {
        String sql = "INSERT INTO orders (customer_id, customer_name, customer_email, customer_phone, " +
                     "shipping_address, billing_address, subtotal, shipping_cost, tax, discount, total, " +
                     "payment_method, payment_status, order_status, tracking_number, notes) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setObject(1, order.getCustomerId());
            stmt.setString(2, order.getCustomerName());
            stmt.setString(3, order.getCustomerEmail());
            stmt.setString(4, order.getCustomerPhone());
            stmt.setString(5, order.getShippingAddress());
            stmt.setString(6, order.getBillingAddress());
            stmt.setDouble(7, order.getSubtotal());
            stmt.setDouble(8, order.getShippingCost());
            stmt.setDouble(9, order.getTax());
            stmt.setDouble(10, order.getDiscount());
            stmt.setDouble(11, order.getTotal());
            stmt.setString(12, order.getPaymentMethod());
            stmt.setString(13, order.getPaymentStatus());
            stmt.setString(14, order.getOrderStatus());
            stmt.setString(15, order.getTrackingNumber());
            stmt.setString(16, order.getNotes());
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows == 0) {
                throw new SQLException("Creating order failed, no rows affected.");
            }
            
            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                } else {
                    throw new SQLException("Creating order failed, no ID obtained.");
                }
            }
        }
    }

    public void createOrderItems(int orderId, List<OrderItem> items) throws SQLException {
        String sql = "INSERT INTO order_items (order_id, book_id, quantity, unit_price, total_price) " +
                     "VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            for (OrderItem item : items) {
                stmt.setInt(1, orderId);
                stmt.setInt(2, item.getBookId());
                stmt.setInt(3, item.getQuantity());
                stmt.setDouble(4, item.getUnitPrice());
                stmt.setDouble(5, item.getTotalPrice());
                stmt.addBatch();
            }
            
            stmt.executeBatch();
        }
    }

    public void addOrderStatusHistory(OrderStatusHistory history) throws SQLException {
        String sql = "INSERT INTO order_status_history (order_id, status, changed_by, notes) " +
                     "VALUES (?, ?, ?, ?)";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, history.getOrderId());
            stmt.setString(2, history.getStatus());
            stmt.setObject(3, history.getChangedBy());
            stmt.setString(4, history.getNotes());
            
            stmt.executeUpdate();
        }
    }

    public List<Order> getAllOrders() throws SQLException {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT o.*, u.username, u.full_name FROM orders o " +
                     "LEFT JOIN users u ON o.customer_id = u.id ORDER BY o.order_date DESC";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Order order = mapResultSetToOrder(rs);
                orders.add(order);
            }
        }
        return orders;
    }

    public Order getOrderById(int id) throws SQLException {
        String sql = "SELECT o.*, u.username, u.full_name FROM orders o " +
                     "LEFT JOIN users u ON o.customer_id = u.id WHERE o.id = ?";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Order order = mapResultSetToOrder(rs);
                    
                    // Load order items
                    order.setItems(getOrderItemsByOrderId(id));
                    
                    // Load status history
                    order.setStatusHistory(getOrderStatusHistoryByOrderId(id));
                    
                    return order;
                }
            }
        }
        return null;
    }

    public boolean updateOrderStatus(int orderId, String status, int changedBy, String notes) throws SQLException {
        Connection conn = null;
        try {
            conn = dbConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Update order status
            String updateSql = "UPDATE orders SET order_status = ? WHERE id = ?";
            try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                updateStmt.setString(1, status);
                updateStmt.setInt(2, orderId);
                updateStmt.executeUpdate();
            }
            
            // Add status history
            OrderStatusHistory history = new OrderStatusHistory();
            history.setOrderId(orderId);
            history.setStatus(status);
            history.setChangedBy(changedBy);
            history.setNotes(notes);
            
            addOrderStatusHistory(history);
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
            }
        }
    }

    private List<OrderItem> getOrderItemsByOrderId(int orderId) throws SQLException {
        List<OrderItem> items = new ArrayList<>();
        String sql = "SELECT oi.*, b.title, b.isbn FROM order_items oi " +
                     "JOIN books b ON oi.book_id = b.id WHERE oi.order_id = ?";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, orderId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    item.setId(rs.getInt("id"));
                    item.setOrderId(rs.getInt("order_id"));
                    item.setBookId(rs.getInt("book_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setUnitPrice(rs.getDouble("unit_price"));
                    item.setTotalPrice(rs.getDouble("total_price"));
                    
                    Book book = new Book();
                    book.setId(rs.getInt("book_id"));
                    book.setTitle(rs.getString("title"));
                    book.setIsbn(rs.getString("isbn"));
                    item.setBook(book);
                    
                    items.add(item);
                }
            }
        }
        return items;
    }

    private List<OrderStatusHistory> getOrderStatusHistoryByOrderId(int orderId) throws SQLException {
        List<OrderStatusHistory> history = new ArrayList<>();
        String sql = "SELECT osh.*, u.username, u.full_name FROM order_status_history osh " +
                     "LEFT JOIN users u ON osh.changed_by = u.id WHERE osh.order_id = ? " +
                     "ORDER BY osh.created_at DESC";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, orderId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    OrderStatusHistory entry = new OrderStatusHistory();
                    entry.setId(rs.getInt("id"));
                    entry.setOrderId(rs.getInt("order_id"));
                    entry.setStatus(rs.getString("status"));
                    entry.setChangedBy(rs.getInt("changed_by"));
                    entry.setNotes(rs.getString("notes"));
                    entry.setCreatedAt(rs.getTimestamp("created_at"));
                    
                    if (rs.getInt("changed_by") > 0) {
                        User user = new User();
                        user.setId(rs.getInt("changed_by"));
                        user.setUsername(rs.getString("username"));
                        user.setFullName(rs.getString("full_name"));
                        entry.setChangedByUser(user);
                    }
                    
                    history.add(entry);
                }
            }
        }
        return history;
    }

    private Order mapResultSetToOrder(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setId(rs.getInt("id"));
        order.setOrderDate(rs.getTimestamp("order_date"));
        order.setCustomerId(rs.getInt("customer_id"));
        order.setCustomerName(rs.getString("customer_name"));
        order.setCustomerEmail(rs.getString("customer_email"));
        order.setCustomerPhone(rs.getString("customer_phone"));
        order.setShippingAddress(rs.getString("shipping_address"));
        order.setBillingAddress(rs.getString("billing_address"));
        order.setSubtotal(rs.getDouble("subtotal"));
        order.setShippingCost(rs.getDouble("shipping_cost"));
        order.setTax(rs.getDouble("tax"));
        order.setDiscount(rs.getDouble("discount"));
        order.setTotal(rs.getDouble("total"));
        order.setPaymentMethod(rs.getString("payment_method"));
        order.setPaymentStatus(rs.getString("payment_status"));
        order.setOrderStatus(rs.getString("order_status"));
        order.setTrackingNumber(rs.getString("tracking_number"));
        order.setNotes(rs.getString("notes"));
        order.setCreatedAt(rs.getTimestamp("created_at"));
        order.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        if (rs.getInt("customer_id") > 0) {
            User customer = new User();
            customer.setId(rs.getInt("customer_id"));
            customer.setUsername(rs.getString("username"));
            customer.setFullName(rs.getString("full_name"));
            order.setCustomer(customer);
        }
        
        return order;
    }
}