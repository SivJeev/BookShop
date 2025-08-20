package servlet;

import dao.BookDAO;
import dao.OrderDAO;
import model.*;
import util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.sql.Connection;

@WebServlet("/order")
public class OrderServlet extends HttpServlet {
    private BookDAO bookDAO;
    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        try {
            bookDAO = new BookDAO();
            orderDAO = new OrderDAO();
        } catch (SQLException e) {
            throw new ServletException("Error initializing DAOs", e);
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
                    listOrders(request, response);
                    break;
                case "view":
                    viewOrder(request, response);
                    break;
                case "new":
                    showNewOrderForm(request, response);
                    break;
                default:
                    listOrders(request, response);
                    break;
            }
        } catch (Exception e) {
            throw new ServletException("Error processing request", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if (action == null) {
            response.sendRedirect("order?action=list");
            return;
        }
        
        try {
            switch (action) {
                case "create":
                    createOrder(request, response);
                    break;
                case "updateStatus":
                    updateOrderStatus(request, response);
                    break;
                default:
                    response.sendRedirect("order?action=list");
                    break;
            }
        } catch (Exception e) {
            throw new ServletException("Error processing request", e);
        }
    }

    private void listOrders(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        List<Order> orders = orderDAO.getAllOrders();
        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/order-list.jsp").forward(request, response);
    }

    private void viewOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        int orderId = Integer.parseInt(request.getParameter("id"));
        Order order = orderDAO.getOrderById(orderId);
        
        if (order != null) {
            request.setAttribute("order", order);
            request.getRequestDispatcher("/order-view.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Order not found.");
            listOrders(request, response);
        }
    }

    private void showNewOrderForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        List<Book> books = bookDAO.getAllBooks();
        request.setAttribute("books", books);
        request.getRequestDispatcher("/order-new.jsp").forward(request, response);
    }

    private void createOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        // Get order details from request
        String customerName = request.getParameter("customerName");
        String customerEmail = request.getParameter("customerEmail");
        String customerPhone = request.getParameter("customerPhone");
        String shippingAddress = request.getParameter("shippingAddress");
        String billingAddress = request.getParameter("billingAddress");
        String paymentMethod = request.getParameter("paymentMethod");
        String notes = request.getParameter("notes");
        
        // Get cart items from session
        List<SaleProduct> cart = (List<SaleProduct>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            request.setAttribute("errorMessage", "Cart is empty. Add items before placing order.");
            showNewOrderForm(request, response);
            return;
        }
        
        // Calculate totals
        double subtotal = cart.stream().mapToDouble(SaleProduct::getTotalPrice).sum();
        double shippingCost = calculateShippingCost(cart);
        double tax = subtotal * 0.1; // 10% tax
        double total = subtotal + shippingCost + tax;
        
        // Create order
        Order order = new Order();
        order.setOrderDate(Timestamp.valueOf(LocalDateTime.now()));
        order.setCustomerId(user != null ? user.getId() : null);
        order.setCustomerName(customerName);
        order.setCustomerEmail(customerEmail);
        order.setCustomerPhone(customerPhone);
        order.setShippingAddress(shippingAddress);
        order.setBillingAddress(billingAddress != null ? billingAddress : shippingAddress);
        order.setSubtotal(subtotal);
        order.setShippingCost(shippingCost);
        order.setTax(tax);
        order.setTotal(total);
        order.setPaymentMethod(paymentMethod);
        order.setPaymentStatus("PAID"); // Assuming payment is processed
        order.setOrderStatus("ORDER_PLACED");
        order.setNotes(notes);
        
        // Convert cart items to order items
        List<OrderItem> orderItems = new ArrayList<>();
        for (SaleProduct item : cart) {
            OrderItem orderItem = new OrderItem();
            orderItem.setBookId(item.getBookId());
            orderItem.setQuantity(item.getQuantity());
            orderItem.setUnitPrice(item.getUnitPrice());
            orderItem.setTotalPrice(item.getTotalPrice());
            orderItems.add(orderItem);
        }
        order.setItems(orderItems);
        
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            conn.setAutoCommit(false);
            
            try {
                // Create order
                int orderId = orderDAO.createOrder(order);
                
                // Create order items
                for (OrderItem item : orderItems) {
                    item.setOrderId(orderId);
                }
                orderDAO.createOrderItems(orderId, orderItems);
                
                // Add initial status history
                OrderStatusHistory history = new OrderStatusHistory();
                history.setOrderId(orderId);
                history.setStatus("ORDER_PLACED");
                history.setChangedBy(user != null ? user.getId() : null);
                history.setNotes("Order placed by customer");
                orderDAO.addOrderStatusHistory(history);
                
                // Update book quantities
                for (OrderItem item : orderItems) {
                    bookDAO.updateBookQuantity(item.getBookId(), -item.getQuantity());
                }
                
                conn.commit();
                
                // Clear cart
                session.removeAttribute("cart");
                
                // Redirect to order view
                response.sendRedirect("order?action=view&id=" + orderId);
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error creating order: " + e.getMessage());
            showNewOrderForm(request, response);
        }
    }

    private void updateOrderStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        int orderId = Integer.parseInt(request.getParameter("orderId"));
        String newStatus = request.getParameter("newStatus");
        String trackingNumber = request.getParameter("trackingNumber");
        String notes = request.getParameter("notes");
        
        try {
            // Update order status
            boolean success = orderDAO.updateOrderStatus(orderId, newStatus, 
                    user != null ? user.getId() : null, notes);
            
            if (success) {
                // If status is SHIPPED and tracking number is provided, update it
                if ("SHIPPED".equals(newStatus) && trackingNumber != null && !trackingNumber.isEmpty()) {
                    updateTrackingNumber(orderId, trackingNumber);
                }
                
                request.setAttribute("successMessage", "Order status updated successfully.");
            } else {
                request.setAttribute("errorMessage", "Failed to update order status.");
            }
            
            // Redirect back to order view
            response.sendRedirect("order?action=view&id=" + orderId);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error updating order status: " + e.getMessage());
            viewOrder(request, response);
        }
    }

    private void updateTrackingNumber(int orderId, String trackingNumber) throws SQLException {
        String sql = "UPDATE orders SET tracking_number = ? WHERE id = ?";
        
        try (Connection conn = DBConnection.getInstance().getConnection();
             var stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, trackingNumber);
            stmt.setInt(2, orderId);
            stmt.executeUpdate();
        }
    }

    private double calculateShippingCost(List<SaleProduct> cart) {
        // Simple shipping calculation - you can implement your own logic
        int totalItems = cart.stream().mapToInt(SaleProduct::getQuantity).sum();
        return 5.0 + (totalItems * 0.5); // $5 base + $0.5 per item
    }
}