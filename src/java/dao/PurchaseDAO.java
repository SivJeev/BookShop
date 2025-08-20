package dao;

import model.Purchase;
import model.PurchaseItem;
import model.PurchasePayment;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PurchaseDAO {

    private final DBConnection dbConnection;

    public PurchaseDAO() throws SQLException {
        this.dbConnection = DBConnection.getInstance();
    }

    public boolean createPurchase(Purchase purchase) {
        String sql = "INSERT INTO purchases (supplier_id, purchase_date, expected_delivery_date, "
                + "shipping_cost, tax, discount, total_amount, paid_amount, payment_method, "
                + "payment_status, status, notes, created_by) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, purchase.getSupplierId());
            stmt.setDate(2, purchase.getPurchaseDate());
            stmt.setDate(3, purchase.getExpectedDeliveryDate());
            stmt.setDouble(4, purchase.getShippingCost());
            stmt.setDouble(5, purchase.getTax());
            stmt.setDouble(6, purchase.getDiscount());
            stmt.setDouble(7, purchase.getTotalAmount());
            stmt.setDouble(8, purchase.getPaidAmount());
            stmt.setString(9, purchase.getPaymentMethod());
            stmt.setString(10, purchase.getPaymentStatus());
            stmt.setString(11, purchase.getStatus());
            stmt.setString(12, purchase.getNotes());
            stmt.setInt(13, purchase.getCreatedBy());

            int affectedRows = stmt.executeUpdate();

            if (affectedRows == 0) {
                return false;
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    purchase.setId(generatedKeys.getInt(1));
                }
            }
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Purchase getPurchaseById(int id) {
        String sql = "SELECT p.*, s.name as supplier_name, u.full_name as created_by_name "
                + "FROM purchases p "
                + "LEFT JOIN suppliers s ON p.supplier_id = s.id "
                + "LEFT JOIN users u ON p.created_by = u.id "
                + "WHERE p.id = ?";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToPurchase(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Purchase> getAllPurchases() {
        List<Purchase> purchases = new ArrayList<>();
        String sql = "SELECT p.*, s.name as supplier_name, u.full_name as created_by_name "
                + "FROM purchases p "
                + "LEFT JOIN suppliers s ON p.supplier_id = s.id "
                + "LEFT JOIN users u ON p.created_by = u.id "
                + "ORDER BY p.purchase_date DESC";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                purchases.add(mapResultSetToPurchase(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return purchases;
    }

    public boolean updatePurchase(Purchase purchase) {
        String sql = "UPDATE purchases SET supplier_id = ?, purchase_date = ?, expected_delivery_date = ?, "
                + "shipping_cost = ?, tax = ?, discount = ?, total_amount = ?, paid_amount = ?, "
                + "payment_method = ?, payment_status = ?, status = ?, notes = ? "
                + "WHERE id = ?";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, purchase.getSupplierId());
            stmt.setDate(2, purchase.getPurchaseDate());
            stmt.setDate(3, purchase.getExpectedDeliveryDate());
            stmt.setDouble(4, purchase.getShippingCost());
            stmt.setDouble(5, purchase.getTax());
            stmt.setDouble(6, purchase.getDiscount());
            stmt.setDouble(7, purchase.getTotalAmount());
            stmt.setDouble(8, purchase.getPaidAmount());
            stmt.setString(9, purchase.getPaymentMethod());
            stmt.setString(10, purchase.getPaymentStatus());
            stmt.setString(11, purchase.getStatus());
            stmt.setString(12, purchase.getNotes());
            stmt.setInt(13, purchase.getId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deletePurchase(int id) {
        String sql = "DELETE FROM purchases WHERE id = ?";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean addPurchaseItem(PurchaseItem item) {
        String sql = "INSERT INTO purchase_items (purchase_id, book_id, quantity, received_quantity, unit_price, total_price) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, item.getPurchaseId());
            stmt.setInt(2, item.getBookId());
            stmt.setInt(3, item.getQuantity());
            stmt.setInt(4, item.getReceivedQuantity());
            stmt.setDouble(5, item.getUnitPrice());
            stmt.setDouble(6, item.getTotalPrice());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<PurchaseItem> getPurchaseItems(int purchaseId) {
        List<PurchaseItem> items = new ArrayList<>();
        String sql = "SELECT pi.*, b.title as book_title, b.author as book_author, b.isbn as book_isbn "
                + "FROM purchase_items pi "
                + "JOIN books b ON pi.book_id = b.id "
                + "WHERE pi.purchase_id = ?";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, purchaseId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    items.add(mapResultSetToPurchaseItem(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }

    public boolean updatePurchaseItem(PurchaseItem item) {
        String sql = "UPDATE purchase_items SET quantity = ?, received_quantity = ?, unit_price = ?, total_price = ? "
                + "WHERE id = ?";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, item.getQuantity());
            stmt.setInt(2, item.getReceivedQuantity());
            stmt.setDouble(3, item.getUnitPrice());
            stmt.setDouble(4, item.getTotalPrice());
            stmt.setInt(5, item.getId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deletePurchaseItem(int id) {
        String sql = "DELETE FROM purchase_items WHERE id = ?";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean addPurchasePayment(PurchasePayment payment) {
        String sql = "INSERT INTO purchase_payments (purchase_id, amount, payment_method, payment_date, notes, created_by) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, payment.getPurchaseId());
            stmt.setDouble(2, payment.getAmount());
            stmt.setString(3, payment.getPaymentMethod());
            stmt.setDate(4, payment.getPaymentDate());
            stmt.setString(5, payment.getNotes());
            stmt.setInt(6, payment.getCreatedBy());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<PurchasePayment> getPurchasePayments(int purchaseId) {
        List<PurchasePayment> payments = new ArrayList<>();
        String sql = "SELECT pp.*, u.full_name as created_by_name "
                + "FROM purchase_payments pp "
                + "LEFT JOIN users u ON pp.created_by = u.id "
                + "WHERE pp.purchase_id = ? "
                + "ORDER BY pp.payment_date DESC";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, purchaseId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    payments.add(mapResultSetToPurchasePayment(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return payments;
    }

    public double getTotalPaidAmount(int purchaseId) {
        String sql = "SELECT COALESCE(SUM(amount), 0) as total_paid FROM purchase_payments WHERE purchase_id = ?";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, purchaseId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("total_paid");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean updatePurchaseStatus(int purchaseId, String status) {
        String sql = "UPDATE purchases SET status = ? WHERE id = ?";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setInt(2, purchaseId);

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updatePurchasePaymentStatus(int purchaseId, String paymentStatus) {
        String sql = "UPDATE purchases SET payment_status = ? WHERE id = ?";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, paymentStatus);
            stmt.setInt(2, purchaseId);

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Purchase mapResultSetToPurchase(ResultSet rs) throws SQLException {
        Purchase purchase = new Purchase();
        purchase.setId(rs.getInt("id"));
        purchase.setSupplierId(rs.getInt("supplier_id"));
        purchase.setPurchaseDate(rs.getDate("purchase_date"));
        purchase.setExpectedDeliveryDate(rs.getDate("expected_delivery_date"));
        purchase.setShippingCost(rs.getDouble("shipping_cost"));
        purchase.setTax(rs.getDouble("tax"));
        purchase.setDiscount(rs.getDouble("discount"));
        purchase.setTotalAmount(rs.getDouble("total_amount"));
        purchase.setPaidAmount(rs.getDouble("paid_amount"));
        purchase.setPaymentMethod(rs.getString("payment_method"));
        purchase.setPaymentStatus(rs.getString("payment_status"));
        purchase.setStatus(rs.getString("status"));
        purchase.setNotes(rs.getString("notes"));
        purchase.setCreatedBy(rs.getInt("created_by"));
        purchase.setCreatedAt(rs.getTimestamp("created_at"));
        purchase.setUpdatedAt(rs.getTimestamp("updated_at"));
        purchase.setSupplierName(rs.getString("supplier_name"));
        purchase.setCreatedByName(rs.getString("created_by_name"));
        return purchase;
    }

    private PurchaseItem mapResultSetToPurchaseItem(ResultSet rs) throws SQLException {
        PurchaseItem item = new PurchaseItem();
        item.setId(rs.getInt("id"));
        item.setPurchaseId(rs.getInt("purchase_id"));
        item.setBookId(rs.getInt("book_id"));
        item.setQuantity(rs.getInt("quantity"));
        item.setReceivedQuantity(rs.getInt("received_quantity"));
        item.setUnitPrice(rs.getDouble("unit_price"));
        item.setTotalPrice(rs.getDouble("total_price"));
        item.setBookTitle(rs.getString("book_title"));
        item.setBookAuthor(rs.getString("book_author"));
        item.setBookIsbn(rs.getString("book_isbn"));
        return item;
    }

    private PurchasePayment mapResultSetToPurchasePayment(ResultSet rs) throws SQLException {
        PurchasePayment payment = new PurchasePayment();
        payment.setId(rs.getInt("id"));
        payment.setPurchaseId(rs.getInt("purchase_id"));
        payment.setAmount(rs.getDouble("amount"));
        payment.setPaymentMethod(rs.getString("payment_method"));
        payment.setPaymentDate(rs.getDate("payment_date"));
        payment.setNotes(rs.getString("notes"));
        payment.setCreatedBy(rs.getInt("created_by"));
        payment.setCreatedAt(rs.getTimestamp("created_at"));
        payment.setCreatedByName(rs.getString("created_by_name"));
        return payment;
    }

    public boolean updateBookQuantities(int purchaseId) throws SQLException {
        // Get all items for this purchase
        List<PurchaseItem> items = getPurchaseItems(purchaseId);

        Connection conn = null;
        try {
            conn = dbConnection.getConnection();
            conn.setAutoCommit(false);

            // Update each book's quantity
            for (PurchaseItem item : items) {
                String sql = "UPDATE books SET quantity = quantity + ? WHERE id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setInt(1, item.getReceivedQuantity());
                    stmt.setInt(2, item.getBookId());
                    stmt.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // Reset auto-commit
                    conn.close();
                } catch (SQLException e) {
                    // Log or handle
                }
            }
        }
    }
}
