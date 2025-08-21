<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.lang.*" %>
<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.*" %>

<%!
    // Database connection
    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection("jdbc:mysql://localhost:3306/bookshop", "root", "");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL Driver not found", e);
        }
    }

    // Simple data structures (avoid session serialization issues)
    public class BookData {

        public int id;
        public String title;
        public String author;
        public double price;
        public int totalStock;
        public int reservedStock;
        public int availableStock;
        public String image;
        public double rating;

        public BookData(int id, String title, String author, double price, int totalStock, int reservedStock, String image) {
            this.id = id;
            this.title = title;
            this.author = author;
            this.price = price;
            this.totalStock = totalStock;
            this.reservedStock = reservedStock;
            this.availableStock = totalStock - reservedStock;
            this.rating = 4.0 + (Math.random() * 1.0);

            // Handle image path - use fallback if empty or invalid
            if (image != null && !image.trim().isEmpty() && (image.startsWith("http") || image.startsWith("/"))) {
                this.image = image;
            } else {
                // Use category-specific placeholder images
                String[] bookImages = {
                    "https://images.unsplash.com/photo-1544947950-fa07a98d237f?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80",
                    "https://images.unsplash.com/photo-1481627834876-b7833e8f5570?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80",
                    "https://images.unsplash.com/photo-1589998059171-988d887df646?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80",
                    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80",
                    "https://images.unsplash.com/photo-1516979187457-637abb4f9353?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80",
                    "https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80"
                };
                this.image = bookImages[id % bookImages.length];
            }
        }
    }

    public class ReservationData {

        public int id;
        public String bookTitle;
        public String bookAuthor;
        public double bookPrice;
        public int quantity;
        public String status;
        public String reservationDate;
        public String notes;
        public String transactionId;

        public ReservationData(int id, String bookTitle, String bookAuthor, double bookPrice, int quantity, String status, String reservationDate, String notes, String transactionId) {
            this.id = id;
            this.bookTitle = bookTitle;
            this.bookAuthor = bookAuthor;
            this.bookPrice = bookPrice;
            this.quantity = quantity;
            this.status = status;
            this.reservationDate = reservationDate;
            this.notes = notes;
            this.transactionId = transactionId;
        }
    }

    // Generate transaction ID
    private String generateTransactionId() {
        java.util.Date now = new java.util.Date();
        return "TXN" + now.getTime() + String.format("%04d", (int) (Math.random() * 10000));
    }
%>
<%!
// Email sending utility
    private void sendEmailNotification(String toEmail, String customerName, String subject, String message) {
        // SMTP Configuration - Update these with your Gmail credentials
        final String fromEmail = "hajeepanasivanesan10@gmail.com"; // Your Gmail address
        final String password = "vmra zjln xmpz fhwr";     // Your Gmail App Password
        final String smtpHost = "smtp.gmail.com";
        final String smtpPort = "587";

        java.util.Properties props = new java.util.Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", smtpHost);
        props.put("mail.smtp.port", smtpPort);
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");

        javax.mail.Session session = javax.mail.Session.getInstance(props, new javax.mail.Authenticator() {
            protected javax.mail.PasswordAuthentication getPasswordAuthentication() {
                return new javax.mail.PasswordAuthentication(fromEmail, password);
            }
        });

        try {
            javax.mail.Message emailMessage = new javax.mail.internet.MimeMessage(session);
            emailMessage.setFrom(new javax.mail.internet.InternetAddress(fromEmail, "Pahana Edu"));
            emailMessage.setRecipients(javax.mail.Message.RecipientType.TO,
                    javax.mail.internet.InternetAddress.parse(toEmail));
            emailMessage.setSubject(subject);

            // Create HTML email content
            String htmlContent
                    = "<html><body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>"
                    + "<div style='max-width: 600px; margin: 0 auto; padding: 20px;'>"
                    + "<div style='background: #2563eb; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;'>"
                    + "<h1 style='margin: 0;'>📚 Pahana Edu</h1>"
                    + "</div>"
                    + "<div style='background: #f8fafc; padding: 30px; border-radius: 0 0 8px 8px; border: 1px solid #e2e8f0;'>"
                    + "<h2 style='color: #2563eb; margin-top: 0;'>Hello " + customerName + "!</h2>"
                    + "<div style='background: white; padding: 20px; border-radius: 8px; border-left: 4px solid #2563eb;'>"
                    + "<p style='margin: 0; font-size: 16px;'>" + message + "</p>"
                    + "</div>"
                    + "<hr style='margin: 30px 0; border: none; border-top: 1px solid #e2e8f0;'>"
                    + "<p style='color: #64748b; font-size: 14px; text-align: center; margin-bottom: 0;'>"
                    + "Thank you for choosing Pahana Edu!<br>"
                    + "Visit our website to manage your reservations."
                    + "</p>"
                    + "</div>"
                    + "</div>"
                    + "</body></html>";

            emailMessage.setContent(htmlContent, "text/html; charset=utf-8");
            emailMessage.setSentDate(new java.util.Date());

            javax.mail.Transport.send(emailMessage);

        } catch (Exception e) {
//            System.err.println("Failed to send email to " + toEmail + ": " + e.getMessage());
            e.printStackTrace();
        }
    }
%>
<%    String message = "";
    String messageType = "";

    // Use simple session variables instead of objects to avoid ClassCastException
    Integer customerId = (Integer) session.getAttribute("customerId");
    String customerName = (String) session.getAttribute("customerName");
    String customerEmail = (String) session.getAttribute("customerEmail");
    String customerPhone = (String) session.getAttribute("customerPhone");
    String customerAddress = (String) session.getAttribute("customerAddress");
    String customerAccountNo = (String) session.getAttribute("customerAccountNo");

    String action = request.getParameter("action");

    // Handle customer login
    if ("login".equals(action)) {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try (Connection conn = getConnection()) {
            String sql = "SELECT * FROM customers WHERE email = ? AND password = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            pstmt.setString(2, password);

            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                // Store simple values in session instead of objects
                session.setAttribute("customerId", rs.getInt("id"));
                session.setAttribute("customerName", rs.getString("name"));
                session.setAttribute("customerEmail", rs.getString("email"));
                session.setAttribute("customerPhone", rs.getString("phone"));
                session.setAttribute("customerAddress", rs.getString("address"));
                session.setAttribute("customerAccountNo", rs.getString("account_no"));

                customerId = rs.getInt("id");
                customerName = rs.getString("name");
                customerEmail = rs.getString("email");
                customerPhone = rs.getString("phone");
                customerAddress = rs.getString("address");
                customerAccountNo = rs.getString("account_no");

                message = "Welcome back, " + customerName + "!";
                messageType = "success";
            } else {
                message = "Invalid email or password.";
                messageType = "error";
            }
        } catch (Exception e) {
            message = "Login error: " + e.getMessage();
            messageType = "error";
        }
    }

    // Handle customer registration
    if ("register".equals(action)) {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String accountNo = request.getParameter("accountNo");
        String password = request.getParameter("password");

        try (Connection conn = getConnection()) {
            String checkSql = "SELECT COUNT(*) FROM customers WHERE email = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, email);
            ResultSet checkRs = checkStmt.executeQuery();

            if (checkRs.next() && checkRs.getInt(1) > 0) {
                message = "Email already exists. Please use a different email.";
                messageType = "error";
            } else {
                String sql = "INSERT INTO customers (name, email, phone, address, account_no, password) VALUES (?, ?, ?, ?, ?, ?)";
                PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
                pstmt.setString(1, name);
                pstmt.setString(2, email);
                pstmt.setString(3, phone);
                pstmt.setString(4, address);
                pstmt.setString(5, accountNo);
                pstmt.setString(6, password);

                int result = pstmt.executeUpdate();
                if (result > 0) {
                    ResultSet keys = pstmt.getGeneratedKeys();
                    if (keys.next()) {
                        int newCustomerId = keys.getInt(1);

                        // Store simple values in session
                        session.setAttribute("customerId", newCustomerId);
                        session.setAttribute("customerName", name);
                        session.setAttribute("customerEmail", email);
                        session.setAttribute("customerPhone", phone);
                        session.setAttribute("customerAddress", address);
                        session.setAttribute("customerAccountNo", accountNo);

                        customerId = newCustomerId;
                        customerName = name;
                        customerEmail = email;
                        customerPhone = phone;
                        customerAddress = address;
                        customerAccountNo = accountNo;

                        // Send welcome notification
                        String notifSql = "INSERT INTO customer_notifications (customer_id, type, title, message) VALUES (?, 'WELCOME', ?, ?)";
                        PreparedStatement notifStmt = conn.prepareStatement(notifSql);
                        notifStmt.setInt(1, newCustomerId);
                        notifStmt.setString(2, "Welcome to Pahana Edu!");
                        notifStmt.setString(3, "Hello " + name + "! Welcome to Pahana Edu. You can now browse and reserve books from our collection. Happy reading!");
                        notifStmt.executeUpdate();

                        message = "Registration successful! Welcome, " + name + "! Check your notifications for a welcome message.";
                        messageType = "success";
                    }
                }
            }
        } catch (Exception e) {
            message = "Registration failed: " + e.getMessage();
            messageType = "error";
        }
    }

    // Handle profile update
    if ("updateProfile".equals(action) && customerId != null) {
        String name = request.getParameter("name");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String accountNo = request.getParameter("accountNo");

        try (Connection conn = getConnection()) {
            String sql = "UPDATE customers SET name = ?, phone = ?, address = ?, account_no = ? WHERE id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, name);
            pstmt.setString(2, phone);
            pstmt.setString(3, address);
            pstmt.setString(4, accountNo);
            pstmt.setInt(5, customerId);

            int result = pstmt.executeUpdate();
            if (result > 0) {
                // Update session variables
                session.setAttribute("customerName", name);
                session.setAttribute("customerPhone", phone);
                session.setAttribute("customerAddress", address);
                session.setAttribute("customerAccountNo", accountNo);

                customerName = name;
                customerPhone = phone;
                customerAddress = address;
                customerAccountNo = accountNo;

                message = "Profile updated successfully!";
                messageType = "success";
            } else {
                message = "Failed to update profile.";
                messageType = "error";
            }
        } catch (Exception e) {
            message = "Profile update failed: " + e.getMessage();
            messageType = "error";
        }
    }

    // Handle logout
    if ("logout".equals(action)) {
        session.invalidate();
        customerId = null;
        customerName = null;
        customerEmail = null;
        customerPhone = null;
        customerAddress = null;
        customerAccountNo = null;
        message = "Logged out successfully.";
        messageType = "info";
    }

    // Handle book reservation
    if ("reserve".equals(action) && customerId != null) {
        int bookId = Integer.parseInt(request.getParameter("bookId"));
        int quantity = Integer.parseInt(request.getParameter("quantity"));
        String notes = request.getParameter("notes");
        String transactionId = generateTransactionId();

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);

            try {
                // Check availability with row locking
                String checkSql = "SELECT title, quantity, reserved_quantity, (quantity - reserved_quantity) as available FROM books WHERE id = ? FOR UPDATE";
                PreparedStatement checkStmt = conn.prepareStatement(checkSql);
                checkStmt.setInt(1, bookId);
                ResultSet checkRs = checkStmt.executeQuery();

                if (checkRs.next()) {
                    int available = checkRs.getInt("available");
                    String bookTitle = checkRs.getString("title");

                    if (available >= quantity) {
                        // Check for duplicate reservations
                        String duplicateCheckSql = "SELECT COUNT(*) FROM reservations WHERE customer_id = ? AND book_id = ? AND status IN ('PENDING', 'CONFIRMED')";
                        PreparedStatement dupCheckStmt = conn.prepareStatement(duplicateCheckSql);
                        dupCheckStmt.setInt(1, customerId);
                        dupCheckStmt.setInt(2, bookId);
                        ResultSet dupCheckRs = dupCheckStmt.executeQuery();

                        if (dupCheckRs.next() && dupCheckRs.getInt(1) > 0) {
                            message = "You already have an active reservation for this book.";
                            messageType = "error";
                        } else {
                            // Create reservation
                            String sql = "INSERT INTO reservations (customer_id, book_id, quantity, notes, transaction_id) VALUES (?, ?, ?, ?, ?)";
                            PreparedStatement pstmt = conn.prepareStatement(sql);
                            pstmt.setInt(1, customerId);
                            pstmt.setInt(2, bookId);
                            pstmt.setInt(3, quantity);
                            pstmt.setString(4, notes);
                            pstmt.setString(5, transactionId);

                            int insertResult = pstmt.executeUpdate();
                            if (insertResult > 0) {
                                // Update reserved quantity
                                String updateSql = "UPDATE books SET reserved_quantity = reserved_quantity + ? WHERE id = ?";
                                PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                                updateStmt.setInt(1, quantity);
                                updateStmt.setInt(2, bookId);
                                int updateResult = updateStmt.executeUpdate();

                                if (updateResult > 0) {
                                    // Send reservation notification
                                    String notifSql = "INSERT INTO customer_notifications (customer_id, type, title, message) VALUES (?, 'RESERVATION_CREATED', ?, ?)";
                                    PreparedStatement notifStmt = conn.prepareStatement(notifSql);
                                    notifStmt.setInt(1, customerId);
                                    notifStmt.setString(2, "Book Reserved Successfully!");
                                    notifStmt.setString(3, "Your reservation for '" + bookTitle + "' (Quantity: " + quantity + ") has been created successfully with Transaction ID: " + transactionId + ". You will be notified when it's ready for pickup. Thank you for choosing Pahana Edu!");
                                    notifStmt.executeUpdate();
                                    String reservationMessage = "Your reservation for '" + bookTitle + "' (Quantity: " + quantity + ") has been created successfully with Transaction ID: " + transactionId + ". You will be notified when it's ready for pickup. Thank you for choosing Pahana Edu!";

                                    try {
                                        sendEmailNotification(customerEmail, customerName, "Book Reservation Confirmation - " + transactionId, reservationMessage);
                                    } catch (Exception emailError) {
//                                        
                                    }

                                    conn.commit();
                                    message = "Book '" + bookTitle + "' reserved successfully! Transaction ID: " + transactionId + ". Check your notifications for details.";
                                    messageType = "success";
                                } else {
                                    conn.rollback();
                                    message = "Failed to update stock. Please try again.";
                                    messageType = "error";
                                }
                            } else {
                                conn.rollback();
                                message = "Failed to create reservation. Please try again.";
                                messageType = "error";
                            }
                        }
                    } else {
                        message = "Sorry, only " + available + " copies available.";
                        messageType = "error";
                    }
                } else {
                    message = "Book not found.";
                    messageType = "error";
                }
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            message = "Reservation failed: " + e.getMessage();
            messageType = "error";
        }
    }

    // Handle cancel reservation
    if ("cancel".equals(action) && customerId != null) {
        int reservationId = Integer.parseInt(request.getParameter("reservationId"));

        try (Connection conn = getConnection()) {
            String getSql = "SELECT book_id, quantity FROM reservations WHERE id = ? AND customer_id = ? AND status IN ('PENDING', 'CONFIRMED')";
            PreparedStatement getStmt = conn.prepareStatement(getSql);
            getStmt.setInt(1, reservationId);
            getStmt.setInt(2, customerId);
            ResultSet getRs = getStmt.executeQuery();

            if (getRs.next()) {
                int bookId = getRs.getInt("book_id");
                int quantity = getRs.getInt("quantity");

                String cancelSql = "UPDATE reservations SET status = 'CANCELLED' WHERE id = ?";
                PreparedStatement cancelStmt = conn.prepareStatement(cancelSql);
                cancelStmt.setInt(1, reservationId);

                if (cancelStmt.executeUpdate() > 0) {
                    String updateSql = "UPDATE books SET reserved_quantity = reserved_quantity - ? WHERE id = ?";
                    PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                    updateStmt.setInt(1, quantity);
                    updateStmt.setInt(2, bookId);
                    updateStmt.executeUpdate();

                    message = "Reservation cancelled successfully.";
                    messageType = "success";
                }
            }
        } catch (Exception e) {
            message = "Cancel failed: " + e.getMessage();
            messageType = "error";
        }
    }

    // Handle bill search (public access)
    Map<String, Object> billData = null;
    String searchTransactionId = request.getParameter("searchTransactionId");
    if (searchTransactionId != null && !searchTransactionId.trim().isEmpty()) {
        try (Connection conn = getConnection()) {
            String sql = "SELECT r.id, r.transaction_id, r.quantity, r.status, r.reservation_date, r.notes, "
                    + "b.title, b.author, b.selling_price, "
                    + "c.name, c.email, c.phone, c.address, c.account_no "
                    + "FROM reservations r "
                    + "JOIN books b ON r.book_id = b.id "
                    + "JOIN customers c ON r.customer_id = c.id "
                    + "WHERE r.transaction_id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, searchTransactionId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                billData = new HashMap<>();
                billData.put("transactionId", rs.getString("transaction_id"));
                billData.put("reservationId", rs.getInt("id"));
                billData.put("bookTitle", rs.getString("title"));
                billData.put("bookAuthor", rs.getString("author"));
                billData.put("bookPrice", rs.getDouble("selling_price"));
                billData.put("quantity", rs.getInt("quantity"));
                billData.put("status", rs.getString("status"));
                billData.put("reservationDate", rs.getString("reservation_date"));
                billData.put("notes", rs.getString("notes"));
                billData.put("customerName", rs.getString("name"));
                billData.put("customerEmail", rs.getString("email"));
                billData.put("customerPhone", rs.getString("phone"));
                billData.put("customerAddress", rs.getString("address"));
                billData.put("customerAccountNo", rs.getString("account_no"));
                billData.put("totalAmount", rs.getDouble("selling_price") * rs.getInt("quantity"));
            } else {
                message = "No reservation found with this Transaction ID.";
                messageType = "error";
            }
        } catch (Exception e) {
            message = "Error searching transaction: " + e.getMessage();
            messageType = "error";
        }
    }

    // Load books from database
    List<BookData> books = new ArrayList<>();
    try (Connection conn = getConnection()) {
        String sql = "SELECT id, title, author, selling_price, quantity, reserved_quantity, image_path FROM books ORDER BY title";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        ResultSet rs = pstmt.executeQuery();

        while (rs.next()) {
            books.add(new BookData(
                    rs.getInt("id"),
                    rs.getString("title"),
                    rs.getString("author"),
                    rs.getDouble("selling_price"),
                    rs.getInt("quantity"),
                    rs.getInt("reserved_quantity"),
                    rs.getString("image_path")
            ));
        }
    } catch (Exception e) {
        message = "Error loading books: " + e.getMessage();
        messageType = "error";
    }

    // Load customer reservations and notifications
    List<ReservationData> myReservations = new ArrayList<>();
    List<Map<String, Object>> myNotifications = new ArrayList<>();
    if (customerId != null) {
        try (Connection conn = getConnection()) {
            // Load reservations
            String sql = "SELECT r.id, b.title, b.author, b.selling_price, r.quantity, r.status, "
                    + "DATE_FORMAT(r.reservation_date, '%M %d, %Y') as formatted_date, r.notes, r.transaction_id "
                    + "FROM reservations r JOIN books b ON r.book_id = b.id "
                    + "WHERE r.customer_id = ? ORDER BY r.reservation_date DESC";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, customerId);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                myReservations.add(new ReservationData(
                        rs.getInt("id"),
                        rs.getString("title"),
                        rs.getString("author"),
                        rs.getDouble("selling_price"),
                        rs.getInt("quantity"),
                        rs.getString("status"),
                        rs.getString("formatted_date"),
                        rs.getString("notes"),
                        rs.getString("transaction_id")
                ));
            }

            // Load notifications
            String notifSql = "SELECT id, type, title, message, is_read, DATE_FORMAT(created_at, '%M %d at %h:%i %p') as formatted_date "
                    + "FROM customer_notifications WHERE customer_id = ? ORDER BY created_at DESC LIMIT 5";
            PreparedStatement notifStmt = conn.prepareStatement(notifSql);
            notifStmt.setInt(1, customerId);
            ResultSet notifRs = notifStmt.executeQuery();

            while (notifRs.next()) {
                Map<String, Object> notification = new HashMap<>();
                notification.put("id", notifRs.getInt("id"));
                notification.put("type", notifRs.getString("type"));
                notification.put("title", notifRs.getString("title"));
                notification.put("message", notifRs.getString("message"));
                notification.put("isRead", notifRs.getBoolean("is_read"));
                notification.put("date", notifRs.getString("formatted_date"));
                myNotifications.add(notification);
            }
        } catch (Exception e) {
            // Handle silently
        }
    }

    // Calculate stats for logged-in users
    int totalReservations = myReservations.size();
    int pendingReservations = 0;
    int confirmedReservations = 0;
    double totalValue = 0;

    for (ReservationData r : myReservations) {
        if ("PENDING".equals(r.status)) {
            pendingReservations++;
        }
        if ("CONFIRMED".equals(r.status)) {
            confirmedReservations++;
        }
        if ("PENDING".equals(r.status) || "CONFIRMED".equals(r.status)) {
            totalValue += r.bookPrice * r.quantity;
        }
    }
%>
<%
    // Handle password reset
    if ("resetPassword".equals(action)) {
        int resetCustomerId = Integer.parseInt(request.getParameter("resetCustomerId"));
        String newPassword = request.getParameter("newPassword");

        try (Connection conn = getConnection()) {
            String sql = "UPDATE customers SET password = ? WHERE id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, newPassword);
            pstmt.setInt(2, resetCustomerId);

            int result = pstmt.executeUpdate();
            if (result > 0) {
                // Get customer details for email
                String getCustomerSql = "SELECT name, email FROM customers WHERE id = ?";
                PreparedStatement getCustomerStmt = conn.prepareStatement(getCustomerSql);
                getCustomerStmt.setInt(1, resetCustomerId);
                ResultSet customerRs = getCustomerStmt.executeQuery();

                if (customerRs.next()) {
                    String fcustomerName = customerRs.getString("name");
                    String fcustomerEmail = customerRs.getString("email");

                    // Send password reset notification
                    String notifSql = "INSERT INTO customer_notifications (customer_id, type, title, message) VALUES (?, 'PASSWORD_RESET', ?, ?)";
                    PreparedStatement notifStmt = conn.prepareStatement(notifSql);
                    notifStmt.setInt(1, resetCustomerId);
                    notifStmt.setString(2, "Password Reset Successful");
                    String resetMessage = "Your password has been successfully reset. If you did not request this change, please contact us immediately for security purposes.";
                    notifStmt.setString(3, resetMessage);
                    notifStmt.executeUpdate();

                    // Send reset confirmation email
                    try {
                        sendEmailNotification(fcustomerEmail, fcustomerName, "Password Reset Confirmation - Pahana Edu", resetMessage);
                    } catch (Exception emailError) {
                        // Handle email error silently
                    }
                }

                message = "Password reset successfully! You can now login with your new password.";
                messageType = "success";
            } else {
                message = "Failed to reset password. Please try again.";
                messageType = "error";
            }
        } catch (Exception e) {
            message = "Password reset failed: " + e.getMessage();
            messageType = "error";
        }
    }
%>

<%
    // Handle account verification for password reset
    if ("verifyAccount".equals(action)) {
        String verifyName = request.getParameter("verifyName");
        String verifyEmail = request.getParameter("verifyEmail");

        try (Connection conn = getConnection()) {
            String sql = "SELECT id FROM customers WHERE LOWER(name) = LOWER(?) AND LOWER(email) = LOWER(?)";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, verifyName.trim());
            pstmt.setString(2, verifyEmail.trim());

            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                int foundCustomerId = rs.getInt("id");
                // Return success with customer ID
                out.clear();
                out.print("VERIFY_SUCCESS:" + foundCustomerId + "|");
                return;
            } else {
                out.clear();
                out.print("VERIFY_FAILED");
                return;
            }
        } catch (Exception e) {
            out.clear();
            out.print("VERIFY_ERROR");
            return;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Pahana Edu - Professional Book Reservation System</title>
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root {
                --primary: #2563eb;
                --primary-dark: #1d4ed8;
                --secondary: #64748b;
                --success: #059669;
                --danger: #dc2626;
                --warning: #d97706;
                --info: #0891b2;
                --light: #f8fafc;
                --white: #ffffff;
                --dark: #0f172a;
                --border: #e2e8f0;
                --text: #334155;
                --text-light: #64748b;
                --shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
                --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
                --radius: 8px;
            }

            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Poppins', -apple-system, BlinkMacSystemFont, sans-serif;
                background-color: var(--light);
                color: var(--text);
                line-height: 1.6;
            }

            .header {
                background: var(--white);
                border-bottom: 1px solid var(--border);
                position: sticky;
                top: 0;
                z-index: 100;
                box-shadow: var(--shadow);
            }

            .header-content {
                max-width: 1200px;
                margin: 0 auto;
                padding: 1rem 2rem;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .logo {
                display: flex;
                align-items: center;
                gap: 0.75rem;
                font-size: 1.5rem;
                font-weight: 700;
                color: var(--primary);
                text-decoration: none;
            }

            .logo i {
                font-size: 1.75rem;
            }

            .user-section {
                display: flex;
                align-items: center;
                gap: 1rem;
            }

            .user-info {
                display: flex;
                align-items: center;
                gap: 0.75rem;
                padding: 0.5rem 1rem;
                background: var(--light);
                border-radius: var(--radius);
                border: 1px solid var(--border);
            }

            .user-avatar {
                width: 36px;
                height: 36px;
                border-radius: 50%;
                background: var(--primary);
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-weight: 600;
                font-size: 0.875rem;
            }

            .user-details h4 {
                font-size: 0.875rem;
                font-weight: 600;
                color: var(--text);
            }

            .user-details p {
                font-size: 0.75rem;
                color: var(--text-light);
            }

            .btn {
                display: inline-flex;
                align-items: center;
                gap: 0.5rem;
                padding: 0.625rem 1.25rem;
                border: 1px solid transparent;
                border-radius: var(--radius);
                font-family: inherit;
                font-size: 0.875rem;
                font-weight: 500;
                line-height: 1;
                text-decoration: none;
                cursor: pointer;
                transition: all 0.2s ease;
                white-space: nowrap;
            }

            .btn-primary {
                background: var(--primary);
                color: var(--white);
                border-color: var(--primary);
            }

            .btn-primary:hover {
                background: var(--primary-dark);
                border-color: var(--primary-dark);
            }

            .btn-secondary {
                background: var(--white);
                color: var(--text);
                border-color: var(--border);
            }

            .btn-secondary:hover {
                background: var(--light);
            }

            .btn-success {
                background: var(--success);
                color: var(--white);
                border-color: var(--success);
            }

            .btn-success:hover {
                background: #047857;
                border-color: #047857;
            }

            .btn-danger {
                background: var(--danger);
                color: var(--white);
                border-color: var(--danger);
            }

            .btn-danger:hover {
                background: #b91c1c;
                border-color: #b91c1c;
            }

            .btn-warning {
                background: var(--warning);
                color: var(--white);
                border-color: var(--warning);
            }

            .btn-warning:hover {
                background: #c2410c;
                border-color: #c2410c;
            }

            .btn-sm {
                padding: 0.375rem 0.875rem;
                font-size: 0.8125rem;
            }

            .btn-full {
                width: 100%;
                justify-content: center;
            }

            .btn:disabled {
                opacity: 0.6;
                cursor: not-allowed;
            }

            .container {
                max-width: 1200px;
                margin: 0 auto;
                padding: 2rem;
            }

            .alert {
                padding: 1rem 1.25rem;
                border-radius: var(--radius);
                margin-bottom: 1.5rem;
                border: 1px solid;
                display: flex;
                align-items: center;
                gap: 0.75rem;
                font-weight: 500;
            }

            .alert-success {
                background: #f0fdf4;
                border-color: #bbf7d0;
                color: #166534;
            }

            .alert-error {
                background: #fef2f2;
                border-color: #fecaca;
                color: #991b1b;
            }

            .alert-info {
                background: #f0f9ff;
                border-color: #bae6fd;
                color: #0c4a6e;
            }

            .hero {
                background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
                color: var(--white);
                text-align: center;
                padding: 4rem 2rem;
                margin-bottom: 2rem;
                border-radius: var(--radius);
            }

            .hero h1 {
                font-size: 2.5rem;
                font-weight: 700;
                margin-bottom: 1rem;
                line-height: 1.2;
            }

            .hero p {
                font-size: 1.125rem;
                margin-bottom: 2rem;
                opacity: 0.9;
                max-width: 600px;
                margin-left: auto;
                margin-right: auto;
            }

            .bill-search {
                background: var(--white);
                border: 1px solid var(--border);
                border-radius: var(--radius);
                padding: 2rem;
                margin-bottom: 2rem;
                box-shadow: var(--shadow);
            }

            .search-form {
                display: flex;
                gap: 1rem;
                align-items: end;
            }

            .search-input {
                flex: 1;
            }

            .stats-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 1.5rem;
                margin-bottom: 2rem;
            }

            .stat-card {
                background: var(--white);
                border: 1px solid var(--border);
                border-radius: var(--radius);
                padding: 1.5rem;
                text-align: center;
                transition: all 0.2s ease;
            }

            .stat-card:hover {
                box-shadow: var(--shadow-lg);
                transform: translateY(-2px);
            }

            .stat-number {
                font-size: 2rem;
                font-weight: 700;
                color: var(--primary);
                margin-bottom: 0.5rem;
            }

            .stat-label {
                color: var(--text-light);
                font-size: 0.875rem;
                font-weight: 500;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }

            .section {
                background: var(--white);
                border: 1px solid var(--border);
                border-radius: var(--radius);
                padding: 2rem;
                margin-bottom: 2rem;
                box-shadow: var(--shadow);
            }

            .section-title {
                font-size: 1.75rem;
                font-weight: 600;
                color: var(--text);
                margin-bottom: 0.5rem;
                display: flex;
                align-items: center;
                gap: 0.75rem;
            }

            .section-title i {
                color: var(--primary);
            }

            .section-subtitle {
                color: var(--text-light);
                margin-bottom: 2rem;
            }

            .books-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
                gap: 1.5rem;
            }

            .book-card {
                background: var(--white);
                border: 1px solid var(--border);
                border-radius: var(--radius);
                overflow: hidden;
                transition: all 0.2s ease;
            }

            .book-card:hover {
                box-shadow: var(--shadow-lg);
                transform: translateY(-2px);
            }

            .book-image {
                height: 200px;
                background-size: cover;
                background-position: center;
                position: relative;
                background-color: var(--light);
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .book-image-placeholder {
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                color: var(--text-light);
                font-size: 2rem;
                z-index: 2;
                display: none;
            }

            .book-image.error .book-image-placeholder {
                display: block;
            }

            .book-badge {
                position: absolute;
                top: 0.75rem;
                right: 0.75rem;
                background: var(--success);
                color: var(--white);
                padding: 0.375rem 0.75rem;
                border-radius: var(--radius);
                font-size: 0.75rem;
                font-weight: 600;
                text-transform: uppercase;
            }

            .book-info {
                padding: 1.25rem;
            }

            .book-title {
                font-size: 1.125rem;
                font-weight: 600;
                margin-bottom: 0.5rem;
                color: var(--text);
                line-height: 1.4;
            }

            .book-author {
                color: var(--text-light);
                margin-bottom: 1rem;
                font-size: 0.875rem;
            }

            .book-meta {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 1rem;
            }

            .book-price {
                font-size: 1.25rem;
                font-weight: 700;
                color: var(--primary);
            }

            .book-rating {
                display: flex;
                align-items: center;
                gap: 0.25rem;
            }

            .book-rating i {
                color: #fbbf24;
                font-size: 0.875rem;
            }

            .book-rating span {
                color: var(--text-light);
                font-size: 0.875rem;
                margin-left: 0.25rem;
            }

            .book-stock {
                display: flex;
                justify-content: space-between;
                margin-bottom: 1rem;
                padding: 0.75rem;
                background: var(--light);
                border-radius: var(--radius);
                font-size: 0.875rem;
            }

            .stock-item {
                text-align: center;
            }

            .stock-number {
                font-weight: 600;
                margin-bottom: 0.25rem;
            }

            .stock-label {
                color: var(--text-light);
                font-size: 0.75rem;
            }

            .total {
                color: var(--info);
            }
            .reserved {
                color: var(--warning);
            }
            .available {
                color: var(--success);
            }
            .unavailable {
                color: var(--danger);
            }

            .reservations-list {
                display: grid;
                gap: 1rem;
            }

            .reservation-card {
                background: var(--white);
                border: 1px solid var(--border);
                border-radius: var(--radius);
                padding: 1.25rem;
                transition: all 0.2s ease;
            }

            .reservation-card:hover {
                box-shadow: var(--shadow);
            }

            .reservation-header {
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                margin-bottom: 1rem;
            }

            .reservation-info h4 {
                font-weight: 600;
                margin-bottom: 0.25rem;
            }

            .reservation-info p {
                color: var(--text-light);
                font-size: 0.875rem;
                margin-bottom: 0.25rem;
            }

            .status-badge {
                padding: 0.375rem 0.75rem;
                border-radius: var(--radius);
                font-size: 0.75rem;
                font-weight: 600;
                text-transform: uppercase;
                display: inline-flex;
                align-items: center;
                gap: 0.25rem;
            }

            .status-pending {
                background: #fef3c7;
                color: #92400e;
            }

            .status-confirmed {
                background: #d1fae5;
                color: #065f46;
            }

            .status-completed {
                background: #dbeafe;
                color: #1e40af;
            }

            .status-cancelled {
                background: #fee2e2;
                color: #991b1b;
            }

            .reservation-meta {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 1rem;
                margin-top: 1rem;
                padding-top: 1rem;
                border-top: 1px solid var(--border);
                font-size: 0.875rem;
            }

            .meta-item {
                text-align: center;
            }

            .meta-value {
                font-weight: 600;
                color: var(--text);
            }

            .meta-label {
                color: var(--text-light);
                font-size: 0.75rem;
            }

            .bill-container {
                background: var(--white);
                border: 2px solid var(--border);
                border-radius: var(--radius);
                padding: 2rem;
                max-width: 600px;
                margin: 2rem auto;
                box-shadow: var(--shadow-lg);
            }

            .bill-header {
                text-align: center;
                margin-bottom: 2rem;
                padding-bottom: 1rem;
                border-bottom: 2px solid var(--border);
            }

            .bill-title {
                font-size: 1.75rem;
                font-weight: 700;
                color: var(--primary);
                margin-bottom: 0.5rem;
            }

            .bill-subtitle {
                color: var(--text-light);
                font-size: 0.875rem;
            }

            .bill-details {
                display: grid;
                gap: 1.5rem;
                margin-bottom: 2rem;
            }

            .bill-section {
                background: var(--light);
                padding: 1rem;
                border-radius: var(--radius);
            }

            .bill-section h4 {
                color: var(--primary);
                font-weight: 600;
                margin-bottom: 0.75rem;
                font-size: 1rem;
            }

            .bill-row {
                display: flex;
                justify-content: space-between;
                margin-bottom: 0.5rem;
                font-size: 0.875rem;
            }

            .bill-row:last-child {
                margin-bottom: 0;
            }

            .bill-label {
                color: var(--text-light);
            }

            .bill-value {
                font-weight: 500;
                color: var(--text);
            }

            .bill-total {
                background: var(--primary);
                color: var(--white);
                padding: 1rem;
                border-radius: var(--radius);
                text-align: center;
                margin-bottom: 1.5rem;
            }

            .bill-total-label {
                font-size: 0.875rem;
                opacity: 0.9;
                margin-bottom: 0.25rem;
            }

            .bill-total-amount {
                font-size: 1.5rem;
                font-weight: 700;
            }

            .bill-actions {
                display: flex;
                gap: 1rem;
                justify-content: center;
            }

            .reset-step {
                transition: all 0.3s ease;
            }

            .reset-step.active {
                display: block;
            }

            #passwordError {
                font-size: 0.875rem;
            }

            .btn[style*="background: none"] {
                transition: color 0.2s ease;
            }

            .btn[style*="background: none"]:hover {
                color: var(--primary-dark) !important;
            }

            @media print {
                body * {
                    visibility: hidden;
                }
                .bill-container, .bill-container * {
                    visibility: visible;
                }
                .bill-container {
                    position: absolute;
                    left: 0;
                    top: 0;
                    width: 100%;
                    margin: 0;
                    box-shadow: none;
                    border: none;
                }
                .bill-actions {
                    display: none !important;
                }
                .header, .container > *:not(.bill-container) {
                    display: none !important;
                }
            }

            .modal {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.5);
                z-index: 1000;
                backdrop-filter: blur(4px);
            }

            .modal.active {
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .modal-content {
                background: var(--white);
                border-radius: var(--radius);
                max-width: 500px;
                width: 90%;
                max-height: 90vh;
                overflow-y: auto;
                box-shadow: var(--shadow-lg);
            }

            .modal-header {
                padding: 1.5rem 1.5rem 0;
                display: flex;
                justify-content: space-between;
                align-items: center;
                border-bottom: 1px solid var(--border);
                margin-bottom: 1.5rem;
            }

            .modal-title {
                font-size: 1.25rem;
                font-weight: 600;
                color: var(--text);
            }

            .modal-close {
                background: none;
                border: none;
                font-size: 1.25rem;
                color: var(--text-light);
                cursor: pointer;
                padding: 0.25rem;
                border-radius: var(--radius);
                transition: all 0.2s ease;
            }

            .modal-close:hover {
                background: var(--light);
                color: var(--text);
            }

            .modal-body {
                padding: 0 1.5rem 1.5rem;
            }

            .auth-tabs {
                display: flex;
                margin-bottom: 1.5rem;
                background: var(--light);
                border-radius: var(--radius);
                padding: 0.25rem;
            }

            .auth-tab {
                flex: 1;
                padding: 0.75rem;
                border: none;
                background: none;
                border-radius: calc(var(--radius) - 2px);
                font-weight: 500;
                cursor: pointer;
                transition: all 0.2s ease;
                color: var(--text-light);
            }

            .auth-tab.active {
                background: var(--white);
                color: var(--text);
                box-shadow: var(--shadow);
            }

            .auth-content {
                display: none;
            }
            .auth-content.active {
                display: block;
            }

            .form-group {
                margin-bottom: 1.25rem;
            }

            .form-label {
                display: block;
                margin-bottom: 0.5rem;
                font-weight: 500;
                color: var(--text);
                font-size: 0.875rem;
            }

            .form-input {
                width: 100%;
                padding: 0.75rem 1rem;
                border: 1px solid var(--border);
                border-radius: var(--radius);
                font-family: inherit;
                font-size: 0.875rem;
                transition: all 0.2s ease;
                background: var(--white);
            }

            .form-input:focus {
                outline: none;
                border-color: var(--primary);
                box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
            }

            .form-textarea {
                resize: vertical;
                min-height: 80px;
            }

            .form-select {
                appearance: none;
                background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%236b7280' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='m6 8 4 4 4-4'/%3e%3c/svg%3e");
                background-position: right 0.75rem center;
                background-repeat: no-repeat;
                background-size: 1.25em 1.25em;
                padding-right: 2.5rem;
            }

            .form-row {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 1rem;
            }

            .empty-state {
                text-align: center;
                padding: 3rem 2rem;
                color: var(--text-light);
            }

            .empty-state i {
                font-size: 3rem;
                margin-bottom: 1rem;
                color: var(--border);
            }

            .empty-state h3 {
                font-size: 1.25rem;
                font-weight: 600;
                color: var(--text);
                margin-bottom: 0.5rem;
            }

            .empty-state p {
                margin-bottom: 1.5rem;
            }

            @media (max-width: 768px) {
                .container {
                    padding: 1rem;
                }
                .header-content {
                    padding: 1rem;
                    flex-direction: column;
                    gap: 1rem;
                }
                .hero {
                    padding: 3rem 1rem;
                }
                .hero h1 {
                    font-size: 2rem;
                }
                .books-grid {
                    grid-template-columns: 1fr;
                }
                .stats-grid {
                    grid-template-columns: repeat(2, 1fr);
                }
                .book-meta {
                    flex-direction: column;
                    gap: 0.75rem;
                    align-items: flex-start;
                }
                .reservation-header {
                    flex-direction: column;
                    gap: 1rem;
                    align-items: flex-start;
                }
                .reservation-meta {
                    grid-template-columns: 1fr;
                    text-align: left;
                }
                .modal-content {
                    width: 95%;
                    margin: 1rem;
                }
                .search-form {
                    flex-direction: column;
                }
                .form-row {
                    grid-template-columns: 1fr;
                }
                .bill-actions {
                    flex-direction: column;
                }
            }

            @media (max-width: 480px) {
                .stats-grid {
                    grid-template-columns: 1fr;
                }
                .book-stock {
                    flex-direction: column;
                    gap: 0.5rem;
                }
            }

            .loading {
                display: inline-block;
                width: 16px;
                height: 16px;
                border: 2px solid rgba(255, 255, 255, 0.3);
                border-radius: 50%;
                border-top-color: white;
                animation: spin 1s ease-in-out infinite;
            }

            @keyframes spin {
                to {
                    transform: rotate(360deg);
                }
            }

            .fade-in {
                animation: fadeIn 0.3s ease-out;
            }

            @keyframes fadeIn {
                from {
                    opacity: 0;
                }
                to {
                    opacity: 1;
                }
            }
        </style>
    </head>
    <body>
        <!-- Header -->
        <header class="header">
            <div class="header-content">
                <a href="#" class="logo">
                    <i class="fas fa-book"></i>
                    Pahana Edu
                </a>
                <div class="user-section">
                    <% if (customerId != null) {%>
                    <div class="user-info">
                        <div class="user-avatar">
                            <%= customerName != null ? customerName.substring(0, 1).toUpperCase() : "U"%>
                        </div>
                        <div class="user-details">
                            <h4><%= customerName != null ? customerName : "User"%></h4>
                            <p><%= customerEmail != null ? customerEmail : ""%></p>
                        </div>
                    </div>
                    <a href="help.jsp" class="btn btn-secondary">
                        <i class="fas fa-question-circle"></i>
                        Help
                    </a>
                    <button class="btn btn-secondary" onclick="openModal('profileModal')">
                        <i class="fas fa-user-edit"></i>
                        Profile
                    </button>
                    <form method="POST" style="display: inline;">
                        <input type="hidden" name="action" value="logout">
                        <button type="submit" class="btn btn-secondary">
                            <i class="fas fa-sign-out-alt"></i>
                            Logout
                        </button>
                    </form>
                    <% } else { %>
                    <a href="help.jsp" class="btn btn-secondary">
                        <i class="fas fa-question-circle"></i>
                        Help
                    </a>
                    <button class="btn btn-primary" onclick="openModal('authModal')">
                        <i class="fas fa-user"></i>
                        Login / Register
                    </button>
                    <% } %>
                </div>
            </div>
        </header>

        <div class="container">
            <!-- Message Alert -->
            <% if (!message.isEmpty()) {%>
            <div class="alert alert-<%= messageType%> fade-in">
                <i class="fas fa-<%= messageType.equals("success") ? "check-circle" : messageType.equals("error") ? "exclamation-circle" : "info-circle"%>"></i>
                <%= message%>
            </div>
            <% }%>

            <!-- Bill Search Section -->
            <div class="bill-search">
                <h2 class="section-title">
                    <i class="fas fa-receipt"></i>
                    Search Bill by Transaction ID
                </h2>
                <p class="section-subtitle">Enter your transaction ID to view and print your bill</p>

                <form method="GET" class="search-form">
                    <div class="search-input">
                        <label class="form-label">Transaction ID</label>
                        <input type="text" name="searchTransactionId" class="form-input" 
                               placeholder="Enter Transaction ID (e.g., TXN1234567890)" 
                               value="<%= searchTransactionId != null ? searchTransactionId : ""%>">
                    </div>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-search"></i>
                        Search Bill
                    </button>
                </form>
            </div>

            <!-- Bill Display -->
            <% if (billData != null) {%>
            <div class="bill-container" id="billContainer">
                <div class="bill-header">
                    <div class="bill-title">Pahana Edu Invoice</div>
                    <div class="bill-subtitle">Book Reservation Receipt</div>
                </div>

                <div class="bill-details">
                    <div class="bill-section">
                        <h4><i class="fas fa-user"></i> Customer Details</h4>
                        <div class="bill-row">
                            <span class="bill-label">Name:</span>
                            <span class="bill-value"><%= billData.get("customerName")%></span>
                        </div>
                        <div class="bill-row">
                            <span class="bill-label">Email:</span>
                            <span class="bill-value"><%= billData.get("customerEmail")%></span>
                        </div>
                        <div class="bill-row">
                            <span class="bill-label">Phone:</span>
                            <span class="bill-value"><%= billData.get("customerPhone")%></span>
                        </div>
                        <div class="bill-row">
                            <span class="bill-label">Address:</span>
                            <span class="bill-value"><%= billData.get("customerAddress") != null ? billData.get("customerAddress") : "N/A"%></span>
                        </div>
                        <div class="bill-row">
                            <span class="bill-label">Account No:</span>
                            <span class="bill-value"><%= billData.get("customerAccountNo") != null ? billData.get("customerAccountNo") : "N/A"%></span>
                        </div>
                    </div>

                    <div class="bill-section">
                        <h4><i class="fas fa-book"></i> Book Details</h4>
                        <div class="bill-row">
                            <span class="bill-label">Title:</span>
                            <span class="bill-value"><%= billData.get("bookTitle")%></span>
                        </div>
                        <div class="bill-row">
                            <span class="bill-label">Author:</span>
                            <span class="bill-value"><%= billData.get("bookAuthor")%></span>
                        </div>
                        <div class="bill-row">
                            <span class="bill-label">Unit Price:</span>
                            <span class="bill-value">Rs. <%= String.format("%.2f", (Double) billData.get("bookPrice"))%></span>
                        </div>
                        <div class="bill-row">
                            <span class="bill-label">Quantity:</span>
                            <span class="bill-value"><%= billData.get("quantity")%></span>
                        </div>
                    </div>

                    <div class="bill-section">
                        <h4><i class="fas fa-info-circle"></i> Transaction Details</h4>
                        <div class="bill-row">
                            <span class="bill-label">Transaction ID:</span>
                            <span class="bill-value"><%= billData.get("transactionId")%></span>
                        </div>
                        <div class="bill-row">
                            <span class="bill-label">Reservation Date:</span>
                            <span class="bill-value"><%= billData.get("reservationDate")%></span>
                        </div>
                        <div class="bill-row">
                            <span class="bill-label">Status:</span>
                            <span class="bill-value status-badge status-<%= ((String) billData.get("status")).toLowerCase()%>">
                                <%= billData.get("status")%>
                            </span>
                        </div>
                        <% if (billData.get("notes") != null && !((String) billData.get("notes")).trim().isEmpty()) {%>
                        <div class="bill-row">
                            <span class="bill-label">Notes:</span>
                            <span class="bill-value"><%= billData.get("notes")%></span>
                        </div>
                        <% }%>
                    </div>
                </div>

                <div class="bill-total">
                    <div class="bill-total-label">Total Amount</div>
                    <div class="bill-total-amount">Rs. <%= String.format("%.2f", (Double) billData.get("totalAmount"))%></div>
                </div>

                <div class="bill-actions">
                    <button class="btn btn-primary" onclick="printBill()">
                        <i class="fas fa-print"></i>
                        Print Bill
                    </button>
                    <button class="btn btn-secondary" onclick="clearBill()">
                        <i class="fas fa-times"></i>
                        Clear
                    </button>
                </div>
            </div>
            <% } %>

            <!-- Hero Section for Non-logged Users -->
            <% if (customerId == null) { %>
            <div class="hero">
                <h1>Professional Book Reservation System</h1>
                <p>Efficiently manage your educational book reservations with our streamlined platform. Join us today for a seamless experience.</p>
                <button class="btn btn-primary" onclick="openModal('authModal')" style="background: rgba(255,255,255,0.2); border-color: rgba(255,255,255,0.3); color: white;">
                    <i class="fas fa-arrow-right"></i>
                    Get Started
                </button>
            </div>
            <% } %>

            <!-- Dashboard Stats for Logged Users -->
            <% if (customerId != null) {%>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-number"><%= totalReservations%></div>
                    <div class="stat-label">Total Reservations</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number"><%= pendingReservations%></div>
                    <div class="stat-label">Pending</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number"><%= confirmedReservations%></div>
                    <div class="stat-label">Confirmed</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">Rs. <%= String.format("%.0f", totalValue)%></div>
                    <div class="stat-label">Total Value</div>
                </div>
            </div>

            <!-- Notifications Section -->
            <% if (!myNotifications.isEmpty()) { %>
            <div class="section">
                <h2 class="section-title">
                    <i class="fas fa-bell"></i>
                    Recent Notifications
                </h2>
                <div style="display: grid; gap: 1rem;">
                    <% for (Map<String, Object> notification : myNotifications) {%>
                    <div class="reservation-card" style="<%= (Boolean) notification.get("isRead") ? "" : "border-left: 4px solid var(--primary);"%>">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.75rem;">
                            <div>
                                <h4 style="margin-bottom: 0.25rem; font-size: 1rem;">
                                    <% if (!((Boolean) notification.get("isRead"))) { %>
                                    <i class="fas fa-circle" style="font-size: 0.5rem; color: var(--primary); margin-right: 0.5rem;"></i>
                                    <% }%>
                                    <%= notification.get("title")%>
                                </h4>
                                <p style="color: var(--text-light); font-size: 0.875rem; margin: 0;">
                                    <%= notification.get("date")%>
                                </p>
                            </div>
                            <div class="status-badge" style="background: var(--light); color: var(--text); border: 1px solid var(--border); text-transform: capitalize;">
                                <%= ((String) notification.get("type")).toLowerCase().replace("_", " ")%>
                            </div>
                        </div>
                        <p style="color: var(--text); line-height: 1.5; margin: 0;">
                            <%= notification.get("message")%>
                        </p>
                    </div>
                    <% } %>
                </div>
            </div>
            <% } %>
            <% } %>

            <!-- Books Section -->
            <div class="section">
                <h2 class="section-title">
                    <i class="fas fa-books"></i>
                    Available Books
                </h2>

                <div class="books-grid">
                    <% for (BookData book : books) {%>
                    <div class="book-card">
                        <div class="book-image" style="background-image: url('<%= book.image%>');" 
                             onError="this.classList.add('error')">
                            <div class="book-image-placeholder">
                                <i class="fas fa-book"></i>
                            </div>
                            <% if (book.availableStock <= 3 && book.availableStock > 0) { %>
                            <div class="book-badge">Limited</div>
                            <% }%>
                        </div>
                        <div class="book-info">
                            <h3 class="book-title"><%= book.title%></h3>
                            <p class="book-author">by <%= book.author%></p>

                            <div class="book-meta">
                                <div class="book-price">Rs. <%= String.format("%.2f", book.price)%></div>
                                <div class="book-rating">
                                    <%
                                        double rating = book.rating;
                                        int fullStars = (int) rating;
                                        boolean hasHalfStar = (rating - fullStars) >= 0.5;

                                        for (int i = 0; i < fullStars; i++) {
                                            out.print("<i class='fas fa-star'></i>");
                                        }
                                        if (hasHalfStar) {
                                            out.print("<i class='fas fa-star-half-alt'></i>");
                                        }
                                        for (int i = fullStars + (hasHalfStar ? 1 : 0); i < 5; i++) {
                                            out.print("<i class='far fa-star'></i>");
                                        }
                                    %>
                                    <span>(<%= String.format("%.1f", rating)%>)</span>
                                </div>
                            </div>

                            <div class="book-stock">
                                <div class="stock-item">
                                    <div class="stock-number total"><%= book.totalStock%></div>
                                    <div class="stock-label">Total</div>
                                </div>
                                <div class="stock-item">
                                    <div class="stock-number reserved"><%= book.reservedStock%></div>
                                    <div class="stock-label">Reserved</div>
                                </div>
                                <div class="stock-item">
                                    <div class="stock-number <%= book.availableStock <= 0 ? "unavailable" : "available"%>">
                                        <%= book.availableStock%>
                                    </div>
                                    <div class="stock-label">Available</div>
                                </div>
                            </div>

                            <% if (customerId != null) { %>
                            <% if (book.availableStock > 0) {%>
                            <button class="btn btn-success btn-full" onclick="reserveBook(<%= book.id%>, '<%= book.title.replace("'", "\\'")%>', <%= book.availableStock%>)">
                                <i class="fas fa-bookmark"></i>
                                Reserve Book
                            </button>
                            <% } else { %>
                            <button class="btn btn-secondary btn-full" disabled>
                                <i class="fas fa-times"></i>
                                Not Available
                            </button>
                            <% } %>
                            <% } else { %>
                            <button class="btn btn-primary btn-full" onclick="openModal('authModal')">
                                <i class="fas fa-sign-in-alt"></i>
                                Login to Reserve
                            </button>
                            <% } %>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>

            <!-- Customer Dashboard -->
            <% if (customerId != null) { %>
            <div class="section">
                <h2 class="section-title">
                    <i class="fas fa-clipboard-list"></i>
                    My Reservations
                </h2>
                <p class="section-subtitle">Manage and track all your book reservations.</p>

                <% if (myReservations.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-book-open"></i>
                    <h3>No Reservations Yet</h3>
                    <p>You haven't made any reservations. Start browsing our collection!</p>
                    <button class="btn btn-primary" onclick="document.querySelector('.books-grid').scrollIntoView({behavior: 'smooth'})">
                        <i class="fas fa-search"></i>
                        Browse Books
                    </button>
                </div>
                <% } else { %>
                <div class="reservations-list">
                    <% for (ReservationData reservation : myReservations) {%>
                    <div class="reservation-card">
                        <div class="reservation-header">
                            <div class="reservation-info">
                                <h4><%= reservation.bookTitle%></h4>
                                <p>by <%= reservation.bookAuthor%></p>
                                <p>Reserved on <%= reservation.reservationDate%></p>
                                <p><strong>Transaction ID:</strong> <%= reservation.transactionId%></p>
                                <% if (reservation.notes != null && !reservation.notes.trim().isEmpty()) {%>
                                <p><strong>Note:</strong> <%= reservation.notes%></p>
                                <% }%>
                            </div>
                            <div style="display: flex; flex-direction: column; gap: 0.75rem; align-items: flex-end;">
                                <div class="status-badge status-<%= reservation.status.toLowerCase()%>">
                                    <i class="fas fa-<%= reservation.status.equals("PENDING") ? "clock" : reservation.status.equals("CONFIRMED") ? "check" : reservation.status.equals("COMPLETED") ? "check-double" : "times"%>"></i>
                                    <%= reservation.status%>
                                </div>
                                <% if ("PENDING".equals(reservation.status) || "CONFIRMED".equals(reservation.status)) {%>
                                <form method="POST" style="display: inline;">
                                    <input type="hidden" name="action" value="cancel">
                                    <input type="hidden" name="reservationId" value="<%= reservation.id%>">
                                    <button type="submit" class="btn btn-danger btn-sm" 
                                            onclick="return confirm('Are you sure you want to cancel this reservation?')">
                                        <i class="fas fa-times"></i>
                                        Cancel
                                    </button>
                                </form>
                                <% }%>
                                <button type="button" class="btn btn-primary btn-sm" 
                                        onclick="viewBill('<%= reservation.transactionId%>')">
                                    <i class="fas fa-receipt"></i>
                                    View Bill
                                </button>
                            </div>
                        </div>

                        <div class="reservation-meta">
                            <div class="meta-item">
                                <div class="meta-value"><%= reservation.quantity%></div>
                                <div class="meta-label">Quantity</div>
                            </div>
                            <div class="meta-item">
                                <div class="meta-value">Rs. <%= String.format("%.2f", reservation.bookPrice)%></div>
                                <div class="meta-label">Unit Price</div>
                            </div>
                            <div class="meta-item">
                                <div class="meta-value">Rs. <%= String.format("%.2f", reservation.bookPrice * reservation.quantity)%></div>
                                <div class="meta-label">Total</div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>
            <% } %>
        </div>

        <!-- Authentication Modal -->
        <div class="modal" id="authModal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3 class="modal-title">Account Access</h3>
                    <button class="modal-close" onclick="closeModal('authModal')">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="auth-tabs">
                        <button class="auth-tab active" onclick="switchAuthTab('login')">Login</button>
                        <button class="auth-tab" onclick="switchAuthTab('register')">Register</button>
                    </div>

                    <!-- Login Form -->
                    <div class="auth-content active" id="loginContent">
                        <form method="POST">
                            <input type="hidden" name="action" value="login">
                            <div class="form-group">
                                <label class="form-label">Email Address</label>
                                <input type="email" name="email" class="form-input" required placeholder="Enter your email">
                            </div>
                            <div class="form-group">
                                <label class="form-label">Password</label>
                                <input type="password" name="password" class="form-input" required placeholder="Enter your password">
                            </div>

                            <div style="text-align: right; margin-bottom: 1rem;">
                                <button type="button" class="btn" style="background: none; border: none; color: var(--primary); text-decoration: underline; padding: 0; font-size: 0.875rem;" 
                                        onclick="openResetPasswordModal()">
                                    Forgot Password?
                                </button>
                            </div>
                            <button type="submit" class="btn btn-primary btn-full">
                                <i class="fas fa-sign-in-alt"></i>
                                Login
                            </button>
                            <a href="login.jsp"><button type="button" class="btn btn-warning btn-full" style="margin-top: 1rem;">
                                    <i class="fas fa-user-shield"></i>
                                    Admin Login
                                </button></a>
                        </form>
                    </div>

                    <!-- Register Form -->
                    <div class="auth-content" id="registerContent">
                        <form method="POST">
                            <input type="hidden" name="action" value="register">
                            <div class="form-group">
                                <label class="form-label">Full Name</label>
                                <input type="text" name="name" class="form-input" required placeholder="Enter your full name">
                            </div>
                            <div class="form-group">
                                <label class="form-label">Email Address</label>
                                <input type="email" name="email" class="form-input" required placeholder="Enter your email">
                            </div>
                            <div class="form-row">
                                <div class="form-group">
                                    <label class="form-label">Phone Number</label>
                                    <input type="tel" name="phone" class="form-input" required placeholder="Enter your phone">
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Account No</label>
                                    <input type="text" name="accountNo" class="form-input" placeholder="Bank Account No (Optional)">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Address</label>
                                <textarea name="address" class="form-input form-textarea" placeholder="Enter your complete address"></textarea>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Password</label>
                                <input type="password" name="password" class="form-input" required placeholder="Create a password">
                            </div>
                            <button type="submit" class="btn btn-success btn-full">
                                <i class="fas fa-user-plus"></i>
                                Create Account
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- Profile Edit Modal -->
        <% if (customerId != null) {%>
        <div class="modal" id="profileModal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3 class="modal-title">Edit Profile</h3>
                    <button class="modal-close" onclick="closeModal('profileModal')">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
                <div class="modal-body">
                    <form method="POST">
                        <input type="hidden" name="action" value="updateProfile">
                        <div class="form-group">
                            <label class="form-label">Full Name</label>
                            <input type="text" name="name" class="form-input" required 
                                   value="<%= customerName != null ? customerName : ""%>">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Email Address</label>
                            <input type="email" class="form-input" readonly 
                                   value="<%= customerEmail != null ? customerEmail : ""%>"
                                   style="background-color: var(--light); color: var(--text-light);">
                            <small style="color: var(--text-light); font-size: 0.75rem;">Email cannot be changed</small>
                        </div>
                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">Phone Number</label>
                                <input type="tel" name="phone" class="form-input" required 
                                       value="<%= customerPhone != null ? customerPhone : ""%>">
                            </div>
                            <div class="form-group">
                                <label class="form-label">Account No</label>
                                <input type="text" name="accountNo" class="form-input" 
                                       value="<%= customerAccountNo != null ? customerAccountNo : ""%>">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Address</label>
                            <textarea name="address" class="form-input form-textarea"><%= customerAddress != null ? customerAddress : ""%></textarea>
                        </div>
                        <button type="submit" class="btn btn-primary btn-full">
                            <i class="fas fa-save"></i>
                            Update Profile
                        </button>
                    </form>
                </div>
            </div>
        </div>
        <% }%>

        <!-- Reset Password Modal -->
        <div class="modal" id="resetPasswordModal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3 class="modal-title">Reset Password</h3>
                    <button class="modal-close" onclick="closeModal('resetPasswordModal')">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
                <div class="modal-body">
                    <!-- Step 1: Verify Email -->
                    <div class="reset-step active" id="verifyStep">
                        <h4 style="margin-bottom: 1rem; color: var(--text);">Verify Your Account</h4>
                        <p style="color: var(--text-light); margin-bottom: 1.5rem;">Enter your username and email to verify your account.</p>

                        <form id="verifyForm">
                            <div class="form-group">
                                <label class="form-label">Username/Name</label>
                                <input type="text" id="resetName" class="form-input" required placeholder="Enter your name">
                            </div>
                            <div class="form-group">
                                <label class="form-label">Email Address</label>
                                <input type="email" id="resetEmail" class="form-input" required placeholder="Enter your email">
                            </div>
                            <button type="button" class="btn btn-primary btn-full" onclick="verifyAccount()">
                                <i class="fas fa-search"></i>
                                Verify Account
                            </button>
                        </form>
                    </div>

                    <!-- Step 2: Reset Password -->
                    <div class="reset-step" id="resetStep" style="display: none;">
                        <h4 style="margin-bottom: 1rem; color: var(--success);">
                            <i class="fas fa-check-circle"></i>
                            Account Verified
                        </h4>
                        <p style="color: var(--text-light); margin-bottom: 1.5rem;">Enter your new password below.</p>

                        <form method="POST" id="resetPasswordForm">
                            <input type="hidden" name="action" value="resetPassword">
                            <input type="hidden" name="resetCustomerId" id="resetCustomerId">

                            <div class="form-group">
                                <label class="form-label">New Password</label>
                                <input type="password" name="newPassword" id="newPassword" class="form-input" required 
                                       placeholder="Enter new password" minlength="6">
                            </div>
                            <div class="form-group">
                                <label class="form-label">Confirm Password</label>
                                <input type="password" id="confirmPassword" class="form-input" required 
                                       placeholder="Confirm new password" minlength="6">
                            </div>
                            <div id="passwordError" class="alert alert-error" style="display: none; margin-bottom: 1rem;">
                                <i class="fas fa-exclamation-circle"></i>
                                <span id="passwordErrorText"></span>
                            </div>
                            <button type="submit" class="btn btn-success btn-full">
                                <i class="fas fa-key"></i>
                                Update Password
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- Reservation Modal -->
        <div class="modal" id="reserveModal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3 class="modal-title">Reserve Book</h3>
                    <button class="modal-close" onclick="closeModal('reserveModal')">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
                <div class="modal-body">
                    <form method="POST" id="reserveForm">
                        <input type="hidden" name="action" value="reserve">
                        <input type="hidden" name="bookId" id="reserveBookId">

                        <div id="bookInfo" style="margin-bottom: 1.5rem;"></div>

                        <div class="form-group">
                            <label class="form-label">Quantity</label>
                            <select name="quantity" id="quantitySelect" class="form-input form-select" required>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Notes (Optional)</label>
                            <textarea name="notes" class="form-input form-textarea" placeholder="Any special requests or notes..."></textarea>
                        </div>

                        <button type="submit" class="btn btn-success btn-full">
                            <i class="fas fa-bookmark"></i>
                            Confirm Reservation
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <script>
            // Professional JavaScript
            function openModal(modalId) {
                document.getElementById(modalId).classList.add('active');
                document.body.style.overflow = 'hidden';
            }

            function closeModal(modalId) {
                document.getElementById(modalId).classList.remove('active');
                document.body.style.overflow = 'auto';
            }

            function switchAuthTab(tabName) {
                document.querySelectorAll('.auth-tab').forEach(tab => {
                    tab.classList.remove('active');
                });
                document.querySelectorAll('.auth-content').forEach(content => {
                    content.classList.remove('active');
                });

                event.target.classList.add('active');
                document.getElementById(tabName + 'Content').classList.add('active');
            }

            function reserveBook(bookId, bookTitle, availableQuantity) {
                document.getElementById('reserveBookId').value = bookId;

                const bookInfo = document.getElementById('bookInfo');
                bookInfo.innerHTML =
                        '<div style="padding: 1rem; background: var(--light); border-radius: var(--radius); text-align: center;">' +
                        '<h4 style="margin-bottom: 0.5rem; color: var(--text);">' + bookTitle + '</h4>' +
                        '<p style="color: var(--text-light); margin: 0;">Available: ' + availableQuantity + ' copies</p>' +
                        '</div>';

                const quantitySelect = document.getElementById('quantitySelect');
                quantitySelect.innerHTML = '';
                for (let i = 1; i <= Math.min(availableQuantity, 5); i++) {
                    const option = document.createElement('option');
                    option.value = i;
                    option.textContent = i + (i === 1 ? ' copy' : ' copies');
                    quantitySelect.appendChild(option);
                }

                openModal('reserveModal');
            }

            function viewBill(transactionId) {
                const form = document.createElement('form');
                form.method = 'GET';
                form.style.display = 'none';

                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'searchTransactionId';
                input.value = transactionId;

                form.appendChild(input);
                document.body.appendChild(form);
                form.submit();
            }

            function printBill() {
                window.print();
            }

            function clearBill() {
                window.location.href = window.location.pathname;
            }

            // Close modals when clicking outside
            document.addEventListener('click', function (event) {
                if (event.target.classList.contains('modal')) {
                    closeModal(event.target.id);
                }
            });

            // Close modals with Escape key
            document.addEventListener('keydown', function (event) {
                if (event.key === 'Escape') {
                    document.querySelectorAll('.modal.active').forEach(modal => {
                        closeModal(modal.id);
                    });
                }
            });

            // Reset Password Functions
            function openResetPasswordModal() {
                closeModal('authModal'); // Close login modal
                document.getElementById('verifyStep').style.display = 'block';
                document.getElementById('resetStep').style.display = 'none';
                document.getElementById('verifyForm').reset();
                openModal('resetPasswordModal');
            }

            function verifyAccount() {
                const name = document.getElementById('resetName').value.trim();
                const email = document.getElementById('resetEmail').value.trim();

                if (!name || !email) {
                    alert('Please enter both name and email.');
                    return;
                }

                // Create verification request
                const formData = new FormData();
                formData.append('action', 'verifyAccount');
                formData.append('verifyName', name);
                formData.append('verifyEmail', email);

                fetch(window.location.pathname, {
                    method: 'POST',
                    body: formData
                })
                        .then(response => response.text())
                        .then(data => {
                            // Parse response to check if verification was successful
                            if (data.includes('VERIFY_SUCCESS:')) {
                                const customerId = data.split('VERIFY_SUCCESS:')[1].split('|')[0];
                                document.getElementById('resetCustomerId').value = customerId;

                                // Show reset step
                                document.getElementById('verifyStep').style.display = 'none';
                                document.getElementById('resetStep').style.display = 'block';
                            } else {
                                alert('Account not found. Please check your name and email.');
                            }
                        })
                        .catch(error => {
                            alert('Verification failed. Please try again.');
                        });
            }

// Password validation
            document.addEventListener('DOMContentLoaded', function () {
                const resetForm = document.getElementById('resetPasswordForm');
                if (resetForm) {
                    resetForm.addEventListener('submit', function (e) {
                        const password = document.getElementById('newPassword').value;
                        const confirmPassword = document.getElementById('confirmPassword').value;
                        const errorDiv = document.getElementById('passwordError');
                        const errorText = document.getElementById('passwordErrorText');

                        // Reset error display
                        errorDiv.style.display = 'none';

                        // Validate passwords
                        if (password.length < 6) {
                            e.preventDefault();
                            errorText.textContent = 'Password must be at least 6 characters long.';
                            errorDiv.style.display = 'flex';
                            return;
                        }

                        if (password !== confirmPassword) {
                            e.preventDefault();
                            errorText.textContent = 'Passwords do not match.';
                            errorDiv.style.display = 'flex';
                            return;
                        }
                    });
                }
            });

            // Form loading states and prevent double submission
            document.querySelectorAll('form').forEach(form => {
                form.addEventListener('submit', function (e) {
                    const submitBtn = this.querySelector('button[type="submit"]');
                    if (submitBtn) {
                        // Prevent double submission
                        if (submitBtn.disabled) {
                            e.preventDefault();
                            return false;
                        }

                        submitBtn.disabled = true;
                        const originalText = submitBtn.innerHTML;
                        submitBtn.innerHTML = '<div class="loading"></div> Processing...';

                        // Set a timeout to re-enable the button in case of errors
                        setTimeout(() => {
                            submitBtn.disabled = false;
                            submitBtn.innerHTML = originalText;
                        }, 5000);
                    }
                });
            });

            // Auto-hide alerts
            document.addEventListener('DOMContentLoaded', function () {
                const alerts = document.querySelectorAll('.alert');
                alerts.forEach(alert => {
                    setTimeout(() => {
                        alert.style.opacity = '0';
                        alert.style.transform = 'translateY(-10px)';
                        setTimeout(() => {
                            if (alert.parentNode) {
                                alert.parentNode.removeChild(alert);
                            }
                        }, 300);
                    }, 5000);
                });

                // Handle image loading errors
                const bookImages = document.querySelectorAll('.book-image');
                bookImages.forEach((imageDiv, index) => {
                    const bgImage = imageDiv.style.backgroundImage;
                    if (bgImage && bgImage !== 'none') {
                        const imageUrl = bgImage.slice(5, -2); // Remove url(" and ")
                        const testImage = new Image();

                        testImage.onload = function () {
                            // Image loaded successfully
                            imageDiv.classList.remove('error');
                        };

                        testImage.onerror = function () {
                            // Image failed to load, use fallback
                            const fallbackImages = [
                                'https://via.placeholder.com/400x600/2563eb/ffffff?text=📚+Book',
                                'https://via.placeholder.com/400x600/059669/ffffff?text=📖+Study',
                                'https://via.placeholder.com/400x600/dc2626/ffffff?text=📝+Learn',
                                'https://via.placeholder.com/400x600/d97706/ffffff?text=🎓+Edu',
                                'https://via.placeholder.com/400x600/0891b2/ffffff?text=📊+Guide',
                                'https://via.placeholder.com/400x600/7c3aed/ffffff?text=🔬+Science'
                            ];
                            const fallbackImage = fallbackImages[index % fallbackImages.length];
                            imageDiv.style.backgroundImage = 'url(' + fallbackImage + ')';
                            imageDiv.classList.remove('error');
                        };

                        testImage.src = imageUrl;
                    } else {
                        // No background image set, use placeholder
                        imageDiv.classList.add('error');
                    }
                });
            });
        </script>
    </body>
</html>