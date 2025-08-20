package dao;

import model.Book;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookDAO {

    private final DBConnection dbConnection;

    public BookDAO() throws SQLException {
        this.dbConnection = DBConnection.getInstance();
    }

    public boolean createBook(Book book) {
        String sql = "INSERT INTO books (title, author, year_published, isbn, purchase_price, "
                + "selling_price, quantity, alert_quantity, image_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, book.getTitle());
            stmt.setString(2, book.getAuthor());
            stmt.setInt(3, book.getYearPublished());
            stmt.setString(4, book.getIsbn());
            stmt.setDouble(5, book.getPurchasePrice());
            stmt.setDouble(6, book.getSellingPrice());
            stmt.setInt(7, book.getQuantity());
            stmt.setInt(8, book.getAlertQuantity());
            stmt.setString(9, book.getImagePath());

            int affectedRows = stmt.executeUpdate();

            if (affectedRows == 0) {
                return false;
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    book.setId(generatedKeys.getInt(1));
                }
            }
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Book getBookById(int id) {
        String sql = "SELECT * FROM books WHERE id = ?";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToBook(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public int getTotalBooksCount() {
        String sql = "SELECT COUNT(*) AS total FROM books";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            if (rs.next()) {
                return rs.getInt("total");  // or rs.getInt(1) for the first column
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;  // Return 0 if there's an error or no books
    }

    public Book getBookByISBN(String isbn) {
        String sql = "SELECT * FROM books WHERE isbn = ?";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, isbn);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToBook(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Book> getAllBooks() {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT * FROM books ORDER BY title";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                books.add(mapResultSetToBook(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return books;
    }

    public boolean updateBook(Book book) {
        String sql = "UPDATE books SET title = ?, author = ?, year_published = ?, isbn = ?, "
                + "purchase_price = ?, selling_price = ?, alert_quantity = ?, image_path = ? WHERE id = ?";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, book.getTitle());
            stmt.setString(2, book.getAuthor());
            stmt.setInt(3, book.getYearPublished());
            stmt.setString(4, book.getIsbn());
            stmt.setDouble(5, book.getPurchasePrice());
            stmt.setDouble(6, book.getSellingPrice());
            stmt.setInt(7, book.getAlertQuantity());
            stmt.setString(8, book.getImagePath());
            stmt.setInt(9, book.getId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteBook(int id) {
        String sql = "DELETE FROM books WHERE id = ?";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateBookQuantity(int bookId, int quantityChange) {
        String sql = "UPDATE books SET quantity = quantity + ? WHERE id = ?";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, quantityChange);
            stmt.setInt(2, bookId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Book> getLowStockBooks() {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT * FROM books WHERE quantity <= alert_quantity ORDER BY quantity";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                books.add(mapResultSetToBook(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return books;
    }

    private Book mapResultSetToBook(ResultSet rs) throws SQLException {
        Book book = new Book();
        book.setId(rs.getInt("id"));
        book.setTitle(rs.getString("title"));
        book.setAuthor(rs.getString("author"));
        book.setYearPublished(rs.getInt("year_published"));
        book.setIsbn(rs.getString("isbn"));
        book.setPurchasePrice(rs.getDouble("purchase_price"));
        book.setSellingPrice(rs.getDouble("selling_price"));
        book.setQuantity(rs.getInt("quantity"));
        book.setAlertQuantity(rs.getInt("alert_quantity"));
        book.setCreatedAt(rs.getTimestamp("created_at"));
        book.setUpdatedAt(rs.getTimestamp("updated_at"));
        book.setImagePath(rs.getString("image_path"));
        return book;
    }
}
