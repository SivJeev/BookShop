package servlet;

import dao.BookDAO;
import model.Book;
import util.FileUploadUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.annotation.WebServlet;
import model.User;

@WebServlet("/book")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,  // 1 MB
    maxFileSize = 1024 * 1024 * 10,       // 10 MB
    maxRequestSize = 1024 * 1024 * 100    // 100 MB
)
public class BookServlet extends HttpServlet {
    private BookDAO bookDAO;
    private static final Logger logger = Logger.getLogger(BookServlet.class.getName());
    
    @Override
    public void init() throws ServletException {
        try {
            bookDAO = new BookDAO();
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error initializing BookDAO", ex);
            throw new ServletException("Error initializing BookDAO", ex);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "list";
        }
        
        try {
            switch (action) {
                case "list":
                    listBooks(request, response);
                    break;
                case "add":
                    showAddForm(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "delete":
                    deleteBook(request, response);
                    break;
                case "view":
                    viewBook(request, response);
                    break;
                default:
                    listBooks(request, response);
                    break;
            }
        } catch (Exception ex) {
            logger.log(Level.SEVERE, "Error processing request", ex);
            throw new ServletException("Error processing request", ex);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if (action == null) {
            response.sendRedirect("book?action=list");
            return;
        }
        
        try {
            switch (action) {
                case "create":
                    createBook(request, response);
                    break;
                case "update":
                    updateBook(request, response);
                    break;
                case "updateStock":
                    updateStock(request, response);
                    break;
                default:
                    response.sendRedirect("book?action=list");
                    break;
            }
        } catch (Exception ex) {
            logger.log(Level.SEVERE, "Error processing request", ex);
            request.setAttribute("errorMessage", "An error occurred: " + ex.getMessage());
            if (action.equals("create")) {
                showAddForm(request, response);
            } else if (action.equals("update")) {
                showEditForm(request, response);
            } else {
                response.sendRedirect("book?action=list");
            }
        }
    }
    
    private void listBooks(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_BOOKS")) {
            request.setAttribute("errorMessage", "You don't have permission to view books.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        List<Book> books = bookDAO.getAllBooks();
        request.setAttribute("books", books);
        request.getRequestDispatcher("book-list.jsp").forward(request, response);
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_BOOKS")) {
            request.setAttribute("errorMessage", "You don't have permission to add books.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        request.getRequestDispatcher("book-add.jsp").forward(request, response);
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_BOOKS")) {
            request.setAttribute("errorMessage", "You don't have permission to edit books.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        int bookId = Integer.parseInt(request.getParameter("id"));
        Book book = bookDAO.getBookById(bookId);
        
        if (book != null) {
            request.setAttribute("book", book);
            request.getRequestDispatcher("book-edit.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Book not found.");
            response.sendRedirect("book?action=list");
        }
    }
    
    private void viewBook(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int bookId = Integer.parseInt(request.getParameter("id"));
        Book book = bookDAO.getBookById(bookId);
        
        if (book != null) {
            request.setAttribute("book", book);
            request.getRequestDispatcher("book-view.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Book not found.");
            response.sendRedirect("book?action=list");
        }
    }
    
    private void createBook(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_BOOKS")) {
            request.setAttribute("errorMessage", "You don't have permission to create books.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        String title = request.getParameter("title");
        String author = request.getParameter("author");
        int yearPublished = Integer.parseInt(request.getParameter("yearPublished"));
        String isbn = request.getParameter("isbn");
        double purchasePrice = Double.parseDouble(request.getParameter("purchasePrice"));
        double sellingPrice = Double.parseDouble(request.getParameter("sellingPrice"));
        int initialQty = Integer.parseInt(request.getParameter("initialQty"));
        int alertQty = Integer.parseInt(request.getParameter("alertQty"));
        Part filePart = request.getPart("image");
        
        // Validation
        if (title == null || author == null || isbn == null ||
            title.trim().isEmpty() || author.trim().isEmpty() || isbn.trim().isEmpty()) {
            
            request.setAttribute("errorMessage", "Title, author, and ISBN are required.");
            showAddForm(request, response);
            return;
        }
        
        if (purchasePrice <= 0 || sellingPrice <= 0 || initialQty < 0 || alertQty < 0) {
            request.setAttribute("errorMessage", "Prices must be positive and quantities can't be negative.");
            showAddForm(request, response);
            return;
        }
        
        // Check if ISBN already exists
        if (bookDAO.getBookByISBN(isbn.trim()) != null) {
            request.setAttribute("errorMessage", "A book with this ISBN already exists.");
            showAddForm(request, response);
            return;
        }
        
        // Process image upload
        String imagePath = null;
        try {
            imagePath = FileUploadUtil.saveImage(filePart, request.getServletContext().getRealPath(""));
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error uploading image: " + e.getMessage());
            showAddForm(request, response);
            return;
        }
        
        Book newBook = new Book();
        newBook.setTitle(title.trim());
        newBook.setAuthor(author.trim());
        newBook.setYearPublished(yearPublished);
        newBook.setIsbn(isbn.trim());
        newBook.setPurchasePrice(purchasePrice);
        newBook.setSellingPrice(sellingPrice);
        newBook.setQuantity(initialQty);
        newBook.setAlertQuantity(alertQty);
        newBook.setImagePath(imagePath);
        
        if (bookDAO.createBook(newBook)) {
            request.setAttribute("successMessage", "Book created successfully!");
            response.sendRedirect("book?action=list");
        } else {
            // Delete the uploaded image if book creation failed
            if (imagePath != null) {
                FileUploadUtil.deleteImage(imagePath, request.getServletContext().getRealPath(""));
            }
            request.setAttribute("errorMessage", "Failed to create book.");
            showAddForm(request, response);
        }
    }
    
    private void updateBook(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_BOOKS")) {
            request.setAttribute("errorMessage", "You don't have permission to update books.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        int bookId = Integer.parseInt(request.getParameter("id"));
        Book book = bookDAO.getBookById(bookId);
        
        if (book == null) {
            request.setAttribute("errorMessage", "Book not found.");
            response.sendRedirect("book?action=list");
            return;
        }
        
        String title = request.getParameter("title");
        String author = request.getParameter("author");
        int yearPublished = Integer.parseInt(request.getParameter("yearPublished"));
        String isbn = request.getParameter("isbn");
        double purchasePrice = Double.parseDouble(request.getParameter("purchasePrice"));
        double sellingPrice = Double.parseDouble(request.getParameter("sellingPrice"));
        int alertQty = Integer.parseInt(request.getParameter("alertQty"));
        Part filePart = request.getPart("image");
        boolean removeImage = "on".equals(request.getParameter("removeImage"));
        
        // Validation
        if (title == null || author == null || isbn == null ||
            title.trim().isEmpty() || author.trim().isEmpty() || isbn.trim().isEmpty()) {
            
            request.setAttribute("errorMessage", "Title, author, and ISBN are required.");
            request.setAttribute("book", book);
            request.getRequestDispatcher("book-edit.jsp").forward(request, response);
            return;
        }
        
        if (purchasePrice <= 0 || sellingPrice <= 0 || alertQty < 0) {
            request.setAttribute("errorMessage", "Prices must be positive and alert quantity can't be negative.");
            request.setAttribute("book", book);
            request.getRequestDispatcher("book-edit.jsp").forward(request, response);
            return;
        }
        
        // Check if ISBN is being changed to one that already exists
        Book existingBook = bookDAO.getBookByISBN(isbn.trim());
        if (existingBook != null && existingBook.getId() != bookId) {
            request.setAttribute("errorMessage", "A book with this ISBN already exists.");
            request.setAttribute("book", book);
            request.getRequestDispatcher("book-edit.jsp").forward(request, response);
            return;
        }
        
        // Handle image removal
        if (removeImage && book.getImagePath() != null) {
            FileUploadUtil.deleteImage(book.getImagePath(), request.getServletContext().getRealPath(""));
            book.setImagePath(null);
        }
        
        // Handle new image upload
        if (filePart != null && filePart.getSize() > 0) {
            // Delete old image if exists
            if (book.getImagePath() != null) {
                FileUploadUtil.deleteImage(book.getImagePath(), request.getServletContext().getRealPath(""));
            }
            
            // Save new image
            String imagePath = FileUploadUtil.saveImage(filePart, request.getServletContext().getRealPath(""));
            book.setImagePath(imagePath);
        }
        
        // Update book properties
        book.setTitle(title.trim());
        book.setAuthor(author.trim());
        book.setYearPublished(yearPublished);
        book.setIsbn(isbn.trim());
        book.setPurchasePrice(purchasePrice);
        book.setSellingPrice(sellingPrice);
        book.setAlertQuantity(alertQty);
        
        if (bookDAO.updateBook(book)) {
            request.setAttribute("successMessage", "Book updated successfully!");
            response.sendRedirect("book?action=list");
        } else {
            request.setAttribute("errorMessage", "Failed to update book.");
            request.setAttribute("book", book);
            request.getRequestDispatcher("book-edit.jsp").forward(request, response);
        }
    }
    
    private void updateStock(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_BOOKS")) {
            request.setAttribute("errorMessage", "You don't have permission to update stock.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        int bookId = Integer.parseInt(request.getParameter("id"));
        String operation = request.getParameter("stockOperation");
        int quantity = Integer.parseInt(request.getParameter("quantity"));
        
        Book book = bookDAO.getBookById(bookId);
        if (book == null) {
            request.setAttribute("errorMessage", "Book not found.");
            response.sendRedirect("book?action=list");
            return;
        }
        
        int quantityChange = 0;
        switch (operation) {
            case "add":
                quantityChange = quantity;
                break;
            case "remove":
                quantityChange = -quantity;
                break;
            case "set":
                quantityChange = quantity - book.getQuantity();
                break;
        }
        
        if (book.getQuantity() + quantityChange < 0) {
            request.setAttribute("errorMessage", "Cannot have negative stock.");
            request.setAttribute("book", book);
            request.getRequestDispatcher("book-edit.jsp").forward(request, response);
            return;
        }
        
        if (bookDAO.updateBookQuantity(bookId, quantityChange)) {
            request.setAttribute("successMessage", "Stock updated successfully!");
        } else {
            request.setAttribute("errorMessage", "Failed to update stock.");
        }
        
        response.sendRedirect("book?action=edit&id=" + bookId);
    }
    
    private void deleteBook(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_BOOKS")) {
            request.setAttribute("errorMessage", "You don't have permission to delete books.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        int bookId = Integer.parseInt(request.getParameter("id"));
        Book book = bookDAO.getBookById(bookId);
        
        if (book != null && book.getImagePath() != null) {
            FileUploadUtil.deleteImage(book.getImagePath(), request.getServletContext().getRealPath(""));
        }
        
        if (bookDAO.deleteBook(bookId)) {
            request.setAttribute("successMessage", "Book deleted successfully!");
        } else {
            request.setAttribute("errorMessage", "Failed to delete book.");
        }
        
        response.sendRedirect("book?action=list");
    }
    
    private boolean checkPermission(HttpServletRequest request, String permission) {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            return false;
        }
        
        // In a real application, implement proper permission checking
        return true;
    }
}