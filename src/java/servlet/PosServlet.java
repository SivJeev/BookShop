package servlet;

import dao.BookDAO;
import dao.SaleDAO;
import model.Book;
import model.Sale;
import model.SaleProduct;
import model.User;
import util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import javax.servlet.http.HttpSession;

@WebServlet("/pos")
public class PosServlet extends HttpServlet {

    private BookDAO bookDAO;
    private SaleDAO saleDAO;

    @Override
    public void init() throws ServletException {
        try {
            bookDAO = new BookDAO();
            saleDAO = new SaleDAO();
        } catch (SQLException e) {
            throw new ServletException("Error initializing DAOs", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        System.out.println("GET Action: " + action);

        if (action == null) {
            action = "new";
        }

        try {
            switch (action) {
                case "getBooks":
                    handleGetBooksAjax(request, response);
                    break;
                case "new":
                    showNewSaleForm(request, response);
                    break;
                case "list":
                    listSales(request, response);
                    break;
                case "view":
                    viewSale(request, response);
                    break;
                default:
                    showNewSaleForm(request, response);
                    break;
            }
        } catch (Exception e) {
            if ("getBooks".equals(action)) {
                sendJsonError(response, "Error loading books: " + e.getMessage());
            } else {
                throw new ServletException("Error processing request", e);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Set response type to JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();

        try {
            // Debug: Log all parameters first
            System.out.println("=== doPost Debug Info ===");
            System.out.println("Request URL: " + request.getRequestURL());
            System.out.println("Query String: " + request.getQueryString());
            System.out.println("Content Type: " + request.getContentType());
            System.out.println("Method: " + request.getMethod());

            // Log all parameters
            System.out.println("=== All Parameters ===");
            Enumeration<String> paramNames = request.getParameterNames();
            boolean hasParams = false;
            while (paramNames.hasMoreElements()) {
                hasParams = true;
                String paramName = paramNames.nextElement();
                String paramValue = request.getParameter(paramName);
                System.out.println(paramName + " = " + paramValue);
            }

            if (!hasParams) {
                System.out.println("NO PARAMETERS FOUND!");
            }

            String action = request.getParameter("action");
            System.out.println("POST Action retrieved: '" + action + "'");

            if (action == null || action.trim().isEmpty()) {
                System.err.println("Action parameter is null or empty!");
                out.print("{\"success\":false,\"error\":\"Action parameter is missing\"}");
                return;
            }

            switch (action.trim()) {
                case "completeSale":
                    System.out.println("Calling handleCompleteSale...");
                    handleCompleteSale(request, response, out);
                    break;

                default:
                    System.err.println("Unknown action: '" + action + "'");
                    out.print("{\"success\":false,\"error\":\"Unknown action: " + escapeJson(action) + "\"}");
                    break;
            }

        } catch (Exception e) {
            System.err.println("Error in doPost: " + e.getMessage());
            e.printStackTrace();

            // Return proper JSON error response
            out.print("{\"success\":false,\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
        } finally {
            out.flush();
            out.close();
        }
    }

    private void handleGetBooksAjax(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();

        try {
            System.out.println("Handling getBooks AJAX request");

            List<Book> books = bookDAO.getAllBooks();

            // Convert to JSON manually
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < books.size(); i++) {
                if (i > 0) {
                    json.append(",");
                }
                Book book = books.get(i);
                json.append("{")
                        .append("\"id\":").append(book.getId()).append(",")
                        .append("\"title\":\"").append(escapeJson(book.getTitle())).append("\",")
                        .append("\"author\":\"").append(escapeJson(book.getAuthor())).append("\",")
                        .append("\"selling_price\":").append(book.getSellingPrice()).append(",")
                        .append("\"quantity\":").append(book.getQuantity()).append(",")
                        .append("\"image_path\":\"").append(escapeJson(book.getImagePath() != null ? book.getImagePath() : "")).append("\"")
                        .append("}");
            }
            json.append("]");

            System.out.println("Returning books JSON: " + json.toString());
            out.print(json.toString());

        } catch (Exception e) {
            System.err.println("Error in handleGetBooksAjax: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
        } finally {
            out.flush();
            out.close();
        }
    }

    private void handleCompleteSale(HttpServletRequest request, HttpServletResponse response, PrintWriter out) {
        try {
            // Log all parameters for debugging
            System.out.println("=== Sale Parameters ===");
            Enumeration<String> paramNames = request.getParameterNames();
            while (paramNames.hasMoreElements()) {
                String paramName = paramNames.nextElement();
                String paramValue = request.getParameter(paramName);
                System.out.println(paramName + " = " + paramValue);
            }

            // Get parameters
            String customerName = request.getParameter("customerName");
            String customerEmail = request.getParameter("customerEmail");
            String subtotalStr = request.getParameter("subtotal");
            String taxStr = request.getParameter("tax");
            String discountStr = request.getParameter("discount");
            String totalStr = request.getParameter("total");
            String paymentMethod = request.getParameter("paymentMethod");
            String notes = request.getParameter("notes");
            String cartItemsJson = request.getParameter("cartItems");

            // Validate required parameters
            if (subtotalStr == null || taxStr == null || totalStr == null
                    || paymentMethod == null || cartItemsJson == null) {
                out.print("{\"success\":false,\"error\":\"Missing required parameters\"}");
                return;
            }

            // Parse numeric values
            double subtotal = Double.parseDouble(subtotalStr);
            double tax = Double.parseDouble(taxStr);
            double discount = Double.parseDouble(discountStr != null ? discountStr : "0");
            double total = Double.parseDouble(totalStr);

            System.out.println("Parsed values - Subtotal: " + subtotal + ", Tax: " + tax
                    + ", Discount: " + discount + ", Total: " + total);

            // Parse cart items
            System.out.println("Cart Items JSON: " + cartItemsJson);

            List<SaleProduct> saleProducts = parseCartItems(cartItemsJson);

            if (saleProducts.isEmpty()) {
                out.print("{\"success\":false,\"error\":\"No items in cart\"}");
                return;
            }

            // Create Sale object
            Sale sale = new Sale();
            sale.setCustomerName(customerName);
            sale.setCustomerEmail(customerEmail);
            sale.setSubtotal(subtotal);
            sale.setTax(tax);
            sale.setDiscount(discount);
            sale.setTotal(total);
            sale.setPaymentMethod(paymentMethod);
            sale.setNotes(notes);
            sale.setUserId(1); // Get from session

            // Handle mixed payment
            if ("MIXED".equals(paymentMethod)) {
                String cashAmountStr = request.getParameter("cashAmount");
                String cardAmountStr = request.getParameter("cardAmount");
                if (cashAmountStr != null && !cashAmountStr.isEmpty()) {
                    sale.setCashAmount(Double.parseDouble(cashAmountStr));
                }
                if (cardAmountStr != null && !cardAmountStr.isEmpty()) {
                    sale.setCardAmount(Double.parseDouble(cardAmountStr));
                }
            } else if ("CASH".equals(paymentMethod)) {
                sale.setCashAmount(total);
                sale.setCardAmount(0.0);
            } else if ("CARD".equals(paymentMethod)) {
                sale.setCashAmount(0.0);
                sale.setCardAmount(total);
            }

            // Save to database
            boolean success = saleDAO.createSale(sale, saleProducts);

            if (success) {
                System.out.println("Sale completed successfully. Sale ID: " + sale.getId());
                out.print("{\"success\":true,\"saleId\":\"" + sale.getId() + "\"}");
            } else {
                System.err.println("Failed to save sale to database");
                out.print("{\"success\":false,\"error\":\"Failed to save sale\"}");
            }

        } catch (NumberFormatException e) {
            System.err.println("Number format error: " + e.getMessage());
            out.print("{\"success\":false,\"error\":\"Invalid number format\"}");
        } catch (Exception e) {
            System.err.println("Error completing sale: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"success\":false,\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private List<SaleProduct> parseCartItems(String cartItemsJson) {
        List<SaleProduct> saleProducts = new ArrayList<>();

        try {
            // Simple JSON parsing - you should use a proper JSON library
            cartItemsJson = cartItemsJson.trim();
            if (cartItemsJson.startsWith("[") && cartItemsJson.endsWith("]")) {
                cartItemsJson = cartItemsJson.substring(1, cartItemsJson.length() - 1);

                // Handle empty cart
                if (cartItemsJson.trim().isEmpty()) {
                    return saleProducts;
                }

                // Split by objects - improved regex
                String[] items = cartItemsJson.split("\\},\\s*\\{");

                for (String item : items) {
                    item = item.replace("{", "").replace("}", "");

                    // Parse each field
                    SaleProduct sp = new SaleProduct();
                    String[] pairs = item.split(",(?=\\s*\")"); // Split on commas that are followed by quotes

                    for (String pair : pairs) {
                        String[] keyValue = pair.split(":");
                        if (keyValue.length == 2) {
                            String key = keyValue[0].trim().replace("\"", "");
                            String value = keyValue[1].trim().replace("\"", "");

                            try {
                                switch (key) {
                                    case "id":
                                        sp.setBookId(Integer.parseInt(value));
                                        break;
                                    case "quantity":
                                        sp.setQuantity(Integer.parseInt(value));
                                        break;
                                    case "selling_price":
                                        sp.setUnitPrice(Double.parseDouble(value));
                                        break;
                                    case "total":
                                        sp.setTotalPrice(Double.parseDouble(value));
                                        break;
                                }
                            } catch (NumberFormatException e) {
                                System.err.println("Error parsing " + key + " with value: " + value);
                            }
                        }
                    }

                    // Only add if we have essential data
                    if (sp.getBookId() > 0 && sp.getQuantity() > 0) {
                        saleProducts.add(sp);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Error parsing cart items: " + e.getMessage());
            e.printStackTrace();
        }

        System.out.println("Parsed " + saleProducts.size() + " sale products");
        return saleProducts;
    }

    private String escapeJson(String str) {
        if (str == null) {
            return "";
        }
        return str.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    private void sendJsonError(HttpServletResponse response, String errorMessage) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        out.print("{\"success\":false,\"error\":\"" + escapeJson(errorMessage) + "\"}");
        out.flush();
        out.close();
    }

    // Traditional JSP handling methods
    private void showNewSaleForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        // Get available books
        List<Book> books = bookDAO.getAllBooks();
        request.setAttribute("books", books);

        // Initialize empty cart if not exists
        HttpSession session = request.getSession();
        @SuppressWarnings("unchecked")
        List<SaleProduct> cart = (List<SaleProduct>) session.getAttribute("cart");
        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("cart", cart);
        }

        // Calculate subtotal
        double subtotal = cart.stream().mapToDouble(SaleProduct::getTotalPrice).sum();
        request.setAttribute("subtotal", subtotal);

        request.getRequestDispatcher("/pos.jsp").forward(request, response);
    }

    private void listSales(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        // Implementation for listing sales
        request.getRequestDispatcher("/pos-list.jsp").forward(request, response);
    }

    private void viewSale(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        int saleId = Integer.parseInt(request.getParameter("id"));
        Sale sale = saleDAO.getSaleById(saleId);

        if (sale != null) {
            request.setAttribute("sale", sale);
            request.getRequestDispatcher("/pos-view.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Sale not found.");
            listSales(request, response);
        }
    }
}
