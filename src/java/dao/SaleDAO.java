package dao;

import model.Sale;
import model.SaleProduct;
import util.DBConnection;
import java.sql.*;
import java.util.List;

public class SaleDAO {
    
    private final DBConnection dbConnection;

    public SaleDAO() throws SQLException {
        this.dbConnection = DBConnection.getInstance();
    }

    public boolean createSale(Sale sale, List<SaleProduct> saleProducts) {
        Connection conn = null;
        try {
            conn = dbConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction

            // Insert sale
            String saleSql = "INSERT INTO sales (customer_name, customer_email, subtotal, tax, discount, total, "
                    + "payment_method, cash_amount, card_amount, user_id, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            PreparedStatement saleStmt = conn.prepareStatement(saleSql, Statement.RETURN_GENERATED_KEYS);
            saleStmt.setString(1, sale.getCustomerName());
            saleStmt.setString(2, sale.getCustomerEmail());
            saleStmt.setDouble(3, sale.getSubtotal());
            saleStmt.setDouble(4, sale.getTax());
            saleStmt.setDouble(5, sale.getDiscount());
            saleStmt.setDouble(6, sale.getTotal());
            saleStmt.setString(7, sale.getPaymentMethod());
            saleStmt.setDouble(8, sale.getCashAmount());
            saleStmt.setDouble(9, sale.getCardAmount());
            saleStmt.setInt(10, sale.getUserId());
            saleStmt.setString(11, sale.getNotes());

            int affectedRows = saleStmt.executeUpdate();
            if (affectedRows == 0) {
                conn.rollback();
                return false;
            }

            // Get generated sale ID
            ResultSet generatedKeys = saleStmt.getGeneratedKeys();
            int saleId = 0;
            if (generatedKeys.next()) {
                saleId = generatedKeys.getInt(1);
                sale.setId(saleId);
            }

            // Insert sale products and update book quantities
            String productSql = "INSERT INTO sale_products (sale_id, book_id, quantity, unit_price, total_price) VALUES (?, ?, ?, ?, ?)";
            String updateQuantitySql = "UPDATE books SET quantity = quantity - ? WHERE id = ?";
            
            PreparedStatement productStmt = conn.prepareStatement(productSql);
            PreparedStatement updateStmt = conn.prepareStatement(updateQuantitySql);

            for (SaleProduct product : saleProducts) {
                // Insert sale product
                productStmt.setInt(1, saleId);
                productStmt.setInt(2, product.getBookId());
                productStmt.setInt(3, product.getQuantity());
                productStmt.setDouble(4, product.getUnitPrice());
                productStmt.setDouble(5, product.getTotalPrice());
                productStmt.addBatch();

                // Update book quantity
                updateStmt.setInt(1, product.getQuantity());
                updateStmt.setInt(2, product.getBookId());
                updateStmt.addBatch();
            }

            productStmt.executeBatch();
            updateStmt.executeBatch();

            conn.commit(); // Commit transaction
            return true;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
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
    }

    public Sale getSaleById(int id) {
        String sql = "SELECT * FROM sales WHERE id = ?";
        
        try (Connection conn = dbConnection.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToSale(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private Sale mapResultSetToSale(ResultSet rs) throws SQLException {
        Sale sale = new Sale();
        sale.setId(rs.getInt("id"));
        sale.setSaleDate(rs.getTimestamp("sale_date"));
        sale.setCustomerName(rs.getString("customer_name"));
        sale.setCustomerEmail(rs.getString("customer_email"));
        sale.setSubtotal(rs.getDouble("subtotal"));
        sale.setTax(rs.getDouble("tax"));
        sale.setDiscount(rs.getDouble("discount"));
        sale.setTotal(rs.getDouble("total"));
        sale.setPaymentMethod(rs.getString("payment_method"));
        sale.setCashAmount(rs.getDouble("cash_amount"));
        sale.setCardAmount(rs.getDouble("card_amount"));
        sale.setUserId(rs.getInt("user_id"));
        sale.setNotes(rs.getString("notes"));
        sale.setCreatedAt(rs.getTimestamp("created_at"));
        return sale;
    }
}