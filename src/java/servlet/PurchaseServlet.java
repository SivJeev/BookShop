package servlet;

import dao.BookDAO;
import dao.PurchaseDAO;
import dao.SupplierDAO;
import model.Book;
import model.Purchase;
import model.PurchaseItem;
import model.PurchasePayment;
import model.Supplier;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/purchase")
public class PurchaseServlet extends HttpServlet {

    private PurchaseDAO purchaseDAO;
    private SupplierDAO supplierDAO;
    private BookDAO bookDAO;
    private static final Logger logger = Logger.getLogger(PurchaseServlet.class.getName());

    @Override
    public void init() throws ServletException {
        try {
            purchaseDAO = new PurchaseDAO();
            supplierDAO = new SupplierDAO();
            bookDAO = new BookDAO();
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error initializing DAOs", ex);
            throw new ServletException("Error initializing DAOs", ex);
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
                    listPurchases(request, response);
                    break;
                case "add":
                    showAddForm(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "delete":
                    deletePurchase(request, response);
                    break;
                case "view":
                    viewPurchase(request, response);
                    break;
                case "addPayment":
                    showAddPaymentForm(request, response);
                    break;
                case "receive":
                    showReceiveForm(request, response);
                    break;
                default:
                    listPurchases(request, response);
                    break;
            }
        } catch (IOException | SQLException | ServletException ex) {
            logger.log(Level.SEVERE, "Error processing request", ex);
            throw new ServletException("Error processing request", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            response.sendRedirect("purchase?action=list");
            return;
        }

        try {
            switch (action) {
                case "create":
                    createPurchase(request, response);
                    break;
                case "update":
                    updatePurchase(request, response);
                    break;
                case "addPayment":
                    addPayment(request, response);
                    break;
                case "receive":
                    receivePurchase(request, response);
                    break;
                case "updateStatus":
                    updateStatus(request, response);
                    break;
                default:
                    response.sendRedirect("purchase?action=list");
                    break;
            }
        } catch (IOException | SQLException | ParseException | ServletException ex) {
            logger.log(Level.SEVERE, "Error processing request", ex);
            request.setAttribute("errorMessage", "An error occurred: " + ex.getMessage());
            switch (action) {
                case "create":
                    try {
                        showAddForm(request, response);
                    } catch (SQLException ex1) {
                        Logger.getLogger(PurchaseServlet.class.getName()).log(Level.SEVERE, null, ex1);
                    }
                    break;
                case "update":
                    try {
                        showEditForm(request, response);
                    } catch (SQLException ex1) {
                        Logger.getLogger(PurchaseServlet.class.getName()).log(Level.SEVERE, null, ex1);
                    }
                    break;
                default:
                    response.sendRedirect("purchase?action=list");
                    break;
            }
        }
    }

    private void listPurchases(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        if (!checkPermission(request, "MANAGE_INVENTORY")) {
            request.setAttribute("errorMessage", "You don't have permission to view purchases.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }

        List<Purchase> purchases = purchaseDAO.getAllPurchases();
        request.setAttribute("purchases", purchases);
        request.getRequestDispatcher("purchase-list.jsp").forward(request, response);
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        if (!checkPermission(request, "MANAGE_INVENTORY")) {
            request.setAttribute("errorMessage", "You don't have permission to add purchases.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }

        List<Supplier> suppliers = supplierDAO.getAllSuppliers();
        List<Book> books = bookDAO.getAllBooks();

        request.setAttribute("suppliers", suppliers);
        request.setAttribute("books", books);
        request.getRequestDispatcher("purchase-add.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        if (!checkPermission(request, "MANAGE_INVENTORY")) {
            request.setAttribute("errorMessage", "You don't have permission to edit purchases.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }

        int purchaseId = Integer.parseInt(request.getParameter("id"));
        Purchase purchase = purchaseDAO.getPurchaseById(purchaseId);

        if (purchase != null) {
            List<Supplier> suppliers = supplierDAO.getAllSuppliers();
            List<Book> books = bookDAO.getAllBooks();
            List<PurchaseItem> items = purchaseDAO.getPurchaseItems(purchaseId);
            List<PurchasePayment> payments = purchaseDAO.getPurchasePayments(purchaseId);

            purchase.setItems(items);
            purchase.setPayments(payments);

            request.setAttribute("purchase", purchase);
            request.setAttribute("suppliers", suppliers);
            request.setAttribute("books", books);
            request.getRequestDispatcher("purchase-edit.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Purchase not found.");
            response.sendRedirect("purchase?action=list");
        }
    }

    private void viewPurchase(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        int purchaseId = Integer.parseInt(request.getParameter("id"));
        Purchase purchase = purchaseDAO.getPurchaseById(purchaseId);

        if (purchase != null) {
            List<PurchaseItem> items = purchaseDAO.getPurchaseItems(purchaseId);
            List<PurchasePayment> payments = purchaseDAO.getPurchasePayments(purchaseId);

            purchase.setItems(items);
            purchase.setPayments(payments);

            request.setAttribute("purchase", purchase);
            request.getRequestDispatcher("purchase-view.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Purchase not found.");
            response.sendRedirect("purchase?action=list");
        }
    }

    private void showAddPaymentForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        if (!checkPermission(request, "MANAGE_INVENTORY")) {
            request.setAttribute("errorMessage", "You don't have permission to add payments.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }

        int purchaseId = Integer.parseInt(request.getParameter("id"));
        Purchase purchase = purchaseDAO.getPurchaseById(purchaseId);

        if (purchase != null) {
            request.setAttribute("purchase", purchase);
            request.getRequestDispatcher("purchase-payment.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Purchase not found.");
            response.sendRedirect("purchase?action=list");
        }
    }

    private void showReceiveForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        if (!checkPermission(request, "MANAGE_INVENTORY")) {
            request.setAttribute("errorMessage", "You don't have permission to receive purchases.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }

        int purchaseId = Integer.parseInt(request.getParameter("id"));
        Purchase purchase = purchaseDAO.getPurchaseById(purchaseId);

        if (purchase != null) {
            List<PurchaseItem> items = purchaseDAO.getPurchaseItems(purchaseId);
            purchase.setItems(items);

            request.setAttribute("purchase", purchase);
            request.getRequestDispatcher("purchase-receive.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Purchase not found.");
            response.sendRedirect("purchase?action=list");
        }
    }

    private void createPurchase(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ParseException {

        if (!checkPermission(request, "MANAGE_INVENTORY")) {
            request.setAttribute("errorMessage", "You don't have permission to create purchases.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        try {
            // Get purchase details with null checks and validation
            String supplierParam = request.getParameter("supplier");
            if (supplierParam == null || supplierParam.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Please select a supplier.");
                showAddForm(request, response);
                return;
            }
            int supplierId = Integer.parseInt(supplierParam.trim());

            String purchaseDateParam = request.getParameter("purchaseDate");
            if (purchaseDateParam == null || purchaseDateParam.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Please select a purchase date.");
                showAddForm(request, response);
                return;
            }
            Date purchaseDate = new Date(new SimpleDateFormat("yyyy-MM-dd").parse(purchaseDateParam.trim()).getTime());

            Date expectedDeliveryDate = null;
            String expectedDeliveryParam = request.getParameter("expectedDeliveryDate");
            if (expectedDeliveryParam != null && !expectedDeliveryParam.trim().isEmpty()) {
                expectedDeliveryDate = new Date(new SimpleDateFormat("yyyy-MM-dd").parse(expectedDeliveryParam.trim()).getTime());
            }

            String shippingCostParam = request.getParameter("shippingCost");
            double shippingCost = 0.0;
            if (shippingCostParam != null && !shippingCostParam.trim().isEmpty()) {
                shippingCost = Double.parseDouble(shippingCostParam.trim());
            }

            String taxParam = request.getParameter("tax");
            double tax = 0.0;
            if (taxParam != null && !taxParam.trim().isEmpty()) {
                tax = Double.parseDouble(taxParam.trim());
            }

            String discountParam = request.getParameter("discount");
            double discount = 0.0;
            if (discountParam != null && !discountParam.trim().isEmpty()) {
                discount = Double.parseDouble(discountParam.trim());
            }

            String paymentMethod = request.getParameter("paymentMethod");
            if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Please select a payment method.");
                showAddForm(request, response);
                return;
            }
            paymentMethod = paymentMethod.trim();

            String notes = request.getParameter("notes");
            if (notes != null) {
                notes = notes.trim();
            }

            // Get items with validation
            String[] bookIds = request.getParameterValues("bookId");
            String[] quantities = request.getParameterValues("quantity");
            String[] unitPrices = request.getParameterValues("unitPrice");

            if (bookIds == null || bookIds.length == 0) {
                request.setAttribute("errorMessage", "Please add at least one item to the purchase.");
                showAddForm(request, response);
                return;
            }

            // Validate arrays have same length
            if (quantities == null || unitPrices == null
                    || bookIds.length != quantities.length
                    || bookIds.length != unitPrices.length) {
                request.setAttribute("errorMessage", "Invalid item data. Please refresh the page and try again.");
                showAddForm(request, response);
                return;
            }

            // Calculate total amount and validate items
            double subtotal = 0;
            List<PurchaseItem> items = new ArrayList<>();

            for (int i = 0; i < bookIds.length; i++) {
                try {
                    // Validate and parse each item
                    if (bookIds[i] == null || bookIds[i].trim().isEmpty()) {
                        request.setAttribute("errorMessage", "Invalid book selection for item " + (i + 1));
                        showAddForm(request, response);
                        return;
                    }
                    int bookId = Integer.parseInt(bookIds[i].trim());

                    if (quantities[i] == null || quantities[i].trim().isEmpty()) {
                        request.setAttribute("errorMessage", "Please enter quantity for item " + (i + 1));
                        showAddForm(request, response);
                        return;
                    }
                    int quantity = Integer.parseInt(quantities[i].trim());
                    if (quantity <= 0) {
                        request.setAttribute("errorMessage", "Quantity must be greater than 0 for item " + (i + 1));
                        showAddForm(request, response);
                        return;
                    }

                    if (unitPrices[i] == null || unitPrices[i].trim().isEmpty()) {
                        request.setAttribute("errorMessage", "Please enter unit price for item " + (i + 1));
                        showAddForm(request, response);
                        return;
                    }
                    double unitPrice = Double.parseDouble(unitPrices[i].trim());
                    if (unitPrice < 0) {
                        request.setAttribute("errorMessage", "Unit price cannot be negative for item " + (i + 1));
                        showAddForm(request, response);
                        return;
                    }

                    double totalPrice = quantity * unitPrice;
                    subtotal += totalPrice;

                    // Verify book exists
                    Book book = bookDAO.getBookById(bookId);
                    if (book == null) {
                        request.setAttribute("errorMessage", "Selected book not found for item " + (i + 1));
                        showAddForm(request, response);
                        return;
                    }

                    PurchaseItem item = new PurchaseItem();
                    item.setBookId(bookId);
                    item.setQuantity(quantity);
                    item.setReceivedQuantity(0);
                    item.setUnitPrice(unitPrice);
                    item.setTotalPrice(totalPrice);

                    items.add(item);

                } catch (NumberFormatException e) {
                    request.setAttribute("errorMessage", "Invalid number format for item " + (i + 1) + ": " + e.getMessage());
                    showAddForm(request, response);
                    return;
                }
            }

            // Validate totals
            if (shippingCost < 0) {
                request.setAttribute("errorMessage", "Shipping cost cannot be negative.");
                showAddForm(request, response);
                return;
            }

            if (tax < 0) {
                request.setAttribute("errorMessage", "Tax cannot be negative.");
                showAddForm(request, response);
                return;
            }

            if (discount < 0) {
                request.setAttribute("errorMessage", "Discount cannot be negative.");
                showAddForm(request, response);
                return;
            }

            double totalAmount = subtotal + shippingCost + tax - discount;
            if (totalAmount < 0) {
                request.setAttribute("errorMessage", "Total amount cannot be negative. Please check your discount amount.");
                showAddForm(request, response);
                return;
            }

            // Create purchase object
            Purchase purchase = new Purchase();
            purchase.setSupplierId(supplierId);
            purchase.setPurchaseDate(purchaseDate);
            purchase.setExpectedDeliveryDate(expectedDeliveryDate);
            purchase.setShippingCost(shippingCost);
            purchase.setTax(tax);
            purchase.setDiscount(discount);
            purchase.setTotalAmount(totalAmount);
            purchase.setPaidAmount(0);
            purchase.setPaymentMethod(paymentMethod);
            purchase.setPaymentStatus("PENDING");
            purchase.setStatus("ORDERED");
            purchase.setNotes(notes);
            purchase.setCreatedBy(user.getId());

            // Save purchase in transaction
            try {
                if (purchaseDAO.createPurchase(purchase)) {
                    // Save items
                    boolean itemsSaved = true;
                    for (PurchaseItem item : items) {
                        item.setPurchaseId(purchase.getId());
                        if (!purchaseDAO.addPurchaseItem(item)) {
                            itemsSaved = false;
                            break;
                        }
                    }

                    if (itemsSaved) {
                        // Success - redirect to view page
                        response.sendRedirect("purchase?action=view&id=" + purchase.getId());
                        return;
                    } else {
                        // Failed to save items - rollback purchase
                        purchaseDAO.deletePurchase(purchase.getId());
                        request.setAttribute("errorMessage", "Failed to save purchase items.");
                        showAddForm(request, response);
                        return;
                    }
                } else {
                    request.setAttribute("errorMessage", "Failed to create purchase.");
                    showAddForm(request, response);
                    return;
                }

            } catch (SQLException e) {
                logger.log(Level.SEVERE, "Database error while creating purchase", e);
                request.setAttribute("errorMessage", "Database error: " + e.getMessage());
                showAddForm(request, response);
                return;
            }

        } catch (NumberFormatException e) {
            logger.log(Level.WARNING, "Number format error in createPurchase", e);
            request.setAttribute("errorMessage", "Invalid number format: " + e.getMessage());
            showAddForm(request, response);
        } catch (ParseException e) {
            logger.log(Level.WARNING, "Date parse error in createPurchase", e);
            request.setAttribute("errorMessage", "Invalid date format: " + e.getMessage());
            showAddForm(request, response);
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Unexpected error in createPurchase", e);
            request.setAttribute("errorMessage", "An unexpected error occurred: " + e.getMessage());
            showAddForm(request, response);
        }
    }

    private void updatePurchase(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ParseException {

        if (!checkPermission(request, "MANAGE_INVENTORY")) {
            request.setAttribute("errorMessage", "You don't have permission to update purchases.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }

        try {
            String purchaseIdParam = request.getParameter("id");
            if (purchaseIdParam == null || purchaseIdParam.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Invalid purchase ID.");
                response.sendRedirect("purchase?action=list");
                return;
            }
            int purchaseId = Integer.parseInt(purchaseIdParam.trim());

            Purchase existingPurchase = purchaseDAO.getPurchaseById(purchaseId);
            if (existingPurchase == null) {
                request.setAttribute("errorMessage", "Purchase not found.");
                response.sendRedirect("purchase?action=list");
                return;
            }

            // Get purchase details with validation
            String supplierParam = request.getParameter("supplier");
            if (supplierParam == null || supplierParam.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Please select a supplier.");
                showEditForm(request, response);
                return;
            }
            int supplierId = Integer.parseInt(supplierParam.trim());

            String purchaseDateParam = request.getParameter("purchaseDate");
            if (purchaseDateParam == null || purchaseDateParam.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Please select a purchase date.");
                showEditForm(request, response);
                return;
            }
            Date purchaseDate = new Date(new SimpleDateFormat("yyyy-MM-dd").parse(purchaseDateParam.trim()).getTime());

            Date expectedDeliveryDate = null;
            String expectedDeliveryParam = request.getParameter("expectedDeliveryDate");
            if (expectedDeliveryParam != null && !expectedDeliveryParam.trim().isEmpty()) {
                expectedDeliveryDate = new Date(new SimpleDateFormat("yyyy-MM-dd").parse(expectedDeliveryParam.trim()).getTime());
            }

            String shippingCostParam = request.getParameter("shippingCost");
            double shippingCost = 0.0;
            if (shippingCostParam != null && !shippingCostParam.trim().isEmpty()) {
                shippingCost = Double.parseDouble(shippingCostParam.trim());
            }

            String taxParam = request.getParameter("tax");
            double tax = 0.0;
            if (taxParam != null && !taxParam.trim().isEmpty()) {
                tax = Double.parseDouble(taxParam.trim());
            }

            String discountParam = request.getParameter("discount");
            double discount = 0.0;
            if (discountParam != null && !discountParam.trim().isEmpty()) {
                discount = Double.parseDouble(discountParam.trim());
            }

            String paymentMethod = request.getParameter("paymentMethod");
            if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Please select a payment method.");
                showEditForm(request, response);
                return;
            }
            paymentMethod = paymentMethod.trim();

            String notes = request.getParameter("notes");
            if (notes != null) {
                notes = notes.trim();
            }

            // Get items with validation
            String[] itemIds = request.getParameterValues("itemId");
            String[] bookIds = request.getParameterValues("bookId");
            String[] quantities = request.getParameterValues("quantity");
            String[] unitPrices = request.getParameterValues("unitPrice");

            if (bookIds == null || bookIds.length == 0) {
                request.setAttribute("errorMessage", "Please add at least one item to the purchase.");
                showEditForm(request, response);
                return;
            }

            // Validate arrays have same length
            if (quantities == null || unitPrices == null
                    || bookIds.length != quantities.length
                    || bookIds.length != unitPrices.length
                    || (itemIds != null && itemIds.length != bookIds.length)) {
                request.setAttribute("errorMessage", "Invalid item data. Please refresh the page and try again.");
                showEditForm(request, response);
                return;
            }

            // Calculate total amount and validate items
            double subtotal = 0;
            List<PurchaseItem> items = new ArrayList<>();

            for (int i = 0; i < bookIds.length; i++) {
                try {
                    // Validate and parse each item
                    if (bookIds[i] == null || bookIds[i].trim().isEmpty()) {
                        request.setAttribute("errorMessage", "Invalid book selection for item " + (i + 1));
                        showEditForm(request, response);
                        return;
                    }
                    int bookId = Integer.parseInt(bookIds[i].trim());

                    if (quantities[i] == null || quantities[i].trim().isEmpty()) {
                        request.setAttribute("errorMessage", "Please enter quantity for item " + (i + 1));
                        showEditForm(request, response);
                        return;
                    }
                    int quantity = Integer.parseInt(quantities[i].trim());
                    if (quantity <= 0) {
                        request.setAttribute("errorMessage", "Quantity must be greater than 0 for item " + (i + 1));
                        showEditForm(request, response);
                        return;
                    }

                    if (unitPrices[i] == null || unitPrices[i].trim().isEmpty()) {
                        request.setAttribute("errorMessage", "Please enter unit price for item " + (i + 1));
                        showEditForm(request, response);
                        return;
                    }
                    double unitPrice = Double.parseDouble(unitPrices[i].trim());
                    if (unitPrice < 0) {
                        request.setAttribute("errorMessage", "Unit price cannot be negative for item " + (i + 1));
                        showEditForm(request, response);
                        return;
                    }

                    double totalPrice = quantity * unitPrice;
                    subtotal += totalPrice;

                    // Verify book exists
                    Book book = bookDAO.getBookById(bookId);
                    if (book == null) {
                        request.setAttribute("errorMessage", "Selected book not found for item " + (i + 1));
                        showEditForm(request, response);
                        return;
                    }

                    PurchaseItem item = new PurchaseItem();

                    // Handle existing vs new items
                    if (itemIds != null && i < itemIds.length
                            && itemIds[i] != null && !itemIds[i].trim().isEmpty()) {
                        item.setId(Integer.parseInt(itemIds[i].trim()));
                    } else {
                        item.setId(0); // New item
                    }

                    item.setPurchaseId(purchaseId);
                    item.setBookId(bookId);
                    item.setQuantity(quantity);
                    item.setUnitPrice(unitPrice);
                    item.setTotalPrice(totalPrice);

                    items.add(item);

                } catch (NumberFormatException e) {
                    request.setAttribute("errorMessage", "Invalid number format for item " + (i + 1) + ": " + e.getMessage());
                    showEditForm(request, response);
                    return;
                }
            }

            // Validate totals
            if (shippingCost < 0) {
                request.setAttribute("errorMessage", "Shipping cost cannot be negative.");
                showEditForm(request, response);
                return;
            }

            if (tax < 0) {
                request.setAttribute("errorMessage", "Tax cannot be negative.");
                showEditForm(request, response);
                return;
            }

            if (discount < 0) {
                request.setAttribute("errorMessage", "Discount cannot be negative.");
                showEditForm(request, response);
                return;
            }

            double totalAmount = subtotal + shippingCost + tax - discount;
            if (totalAmount < 0) {
                request.setAttribute("errorMessage", "Total amount cannot be negative. Please check your discount amount.");
                showEditForm(request, response);
                return;
            }

            // Update purchase object
            existingPurchase.setSupplierId(supplierId);
            existingPurchase.setPurchaseDate(purchaseDate);
            existingPurchase.setExpectedDeliveryDate(expectedDeliveryDate);
            existingPurchase.setShippingCost(shippingCost);
            existingPurchase.setTax(tax);
            existingPurchase.setDiscount(discount);
            existingPurchase.setTotalAmount(totalAmount);
            existingPurchase.setPaymentMethod(paymentMethod);
            existingPurchase.setNotes(notes);

            // Save purchase and items in transaction
            try {
                if (purchaseDAO.updatePurchase(existingPurchase)) {
                    // Get existing items for comparison
                    List<PurchaseItem> existingItems = purchaseDAO.getPurchaseItems(purchaseId);

                    // Update or add new items
                    boolean itemsUpdated = true;
                    for (PurchaseItem item : items) {
                        if (item.getId() > 0) {
                            // Update existing item
                            PurchaseItem existingItem = existingItems.stream()
                                    .filter(e -> e.getId() == item.getId())
                                    .findFirst()
                                    .orElse(null);

                            if (existingItem != null) {
                                item.setReceivedQuantity(existingItem.getReceivedQuantity());
                                if (!purchaseDAO.updatePurchaseItem(item)) {
                                    itemsUpdated = false;
                                    break;
                                }
                                existingItems.remove(existingItem);
                            }
                        } else {
                            // Add new item
                            item.setReceivedQuantity(0);
                            if (!purchaseDAO.addPurchaseItem(item)) {
                                itemsUpdated = false;
                                break;
                            }
                        }
                    }

                    if (itemsUpdated) {
                        // Delete removed items
                        for (PurchaseItem item : existingItems) {
                            if (!purchaseDAO.deletePurchaseItem(item.getId())) {
                                logger.warning("Failed to delete purchase item: " + item.getId());
                            }
                        }

                        // Success - redirect to view page
                        response.sendRedirect("purchase?action=view&id=" + purchaseId);
                        return;
                    } else {
                        request.setAttribute("errorMessage", "Failed to update purchase items.");
                        showEditForm(request, response);
                        return;
                    }
                } else {
                    request.setAttribute("errorMessage", "Failed to update purchase.");
                    showEditForm(request, response);
                    return;
                }

            } catch (SQLException e) {
                logger.log(Level.SEVERE, "Database error while updating purchase", e);
                request.setAttribute("errorMessage", "Database error: " + e.getMessage());
                showEditForm(request, response);
                return;
            }

        } catch (NumberFormatException e) {
            logger.log(Level.WARNING, "Number format error in updatePurchase", e);
            request.setAttribute("errorMessage", "Invalid number format: " + e.getMessage());
            showEditForm(request, response);
        } catch (ParseException e) {
            logger.log(Level.WARNING, "Date parse error in updatePurchase", e);
            request.setAttribute("errorMessage", "Invalid date format: " + e.getMessage());
            showEditForm(request, response);
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Unexpected error in updatePurchase", e);
            request.setAttribute("errorMessage", "An unexpected error occurred: " + e.getMessage());
            showEditForm(request, response);
        }
    }

    private void addPayment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ParseException {

        if (!checkPermission(request, "MANAGE_INVENTORY")) {
            request.setAttribute("errorMessage", "You don't have permission to add payments.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        int purchaseId = Integer.parseInt(request.getParameter("id"));
        double amount = Double.parseDouble(request.getParameter("amount"));
        String paymentMethod = request.getParameter("paymentMethod");
        Date paymentDate = new Date(new SimpleDateFormat("yyyy-MM-dd").parse(request.getParameter("paymentDate")).getTime());
        String notes = request.getParameter("notes");

        PurchasePayment payment = new PurchasePayment();
        payment.setPurchaseId(purchaseId);
        payment.setAmount(amount);
        payment.setPaymentMethod(paymentMethod);
        payment.setPaymentDate(paymentDate);
        payment.setNotes(notes);
        payment.setCreatedBy(user.getId());

        if (purchaseDAO.addPurchasePayment(payment)) {
            // Update paid amount and payment status
            double totalPaid = purchaseDAO.getTotalPaidAmount(purchaseId);
            Purchase purchase = purchaseDAO.getPurchaseById(purchaseId);

            purchase.setPaidAmount(totalPaid);

            if (totalPaid >= purchase.getTotalAmount()) {
                purchase.setPaymentStatus("PAID");
            } else if (totalPaid > 0) {
                purchase.setPaymentStatus("PARTIAL");
            } else {
                purchase.setPaymentStatus("PENDING");
            }

            purchaseDAO.updatePurchase(purchase);

            request.setAttribute("successMessage", "Payment added successfully!");
            response.sendRedirect("purchase?action=view&id=" + purchaseId);
        } else {
            request.setAttribute("errorMessage", "Failed to add payment.");
            showAddPaymentForm(request, response);
        }
    }

    private void receivePurchase(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        if (!checkPermission(request, "MANAGE_INVENTORY")) {
            request.setAttribute("errorMessage", "You don't have permission to receive purchases.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }

        int purchaseId = Integer.parseInt(request.getParameter("id"));
        String[] itemIds = request.getParameterValues("itemId");
        String[] receivedQuantities = request.getParameterValues("receivedQuantity");

        if (itemIds == null || itemIds.length == 0) {
            request.setAttribute("errorMessage", "No items to receive.");
            showReceiveForm(request, response);
            return;
        }

        // Update received quantities
        boolean allReceived = true;
        boolean anyReceived = false;

        for (int i = 0; i < itemIds.length; i++) {
            int itemId = Integer.parseInt(itemIds[i]);
            int receivedQty = Integer.parseInt(receivedQuantities[i]);

            if (receivedQty > 0) {
                anyReceived = true;

                PurchaseItem item = new PurchaseItem();
                item.setId(itemId);
                item.setReceivedQuantity(receivedQty);

                // Get the full item to update
                List<PurchaseItem> items = purchaseDAO.getPurchaseItems(purchaseId);
                PurchaseItem existingItem = items.stream()
                        .filter(it -> it.getId() == itemId)
                        .findFirst()
                        .orElse(null);

                if (existingItem != null) {
                    item.setPurchaseId(purchaseId);
                    item.setBookId(existingItem.getBookId());
                    item.setQuantity(existingItem.getQuantity());
                    item.setUnitPrice(existingItem.getUnitPrice());
                    item.setTotalPrice(existingItem.getTotalPrice());

                    purchaseDAO.updatePurchaseItem(item);

                    // Update book quantity
                    bookDAO.updateBookQuantity(existingItem.getBookId(), receivedQty);
                }

                if (receivedQty < existingItem.getQuantity()) {
                    allReceived = false;
                }
            }
        }

        if (!anyReceived) {
            request.setAttribute("errorMessage", "Please enter received quantities for at least one item.");
            showReceiveForm(request, response);
            return;
        }

        // Update purchase status
        String status = allReceived ? "RECEIVED" : "PARTIAL_RECEIVED";
        purchaseDAO.updatePurchaseStatus(purchaseId, status);

        request.setAttribute("successMessage", "Purchase received successfully!");
        response.sendRedirect("purchase?action=view&id=" + purchaseId);
    }

    private void updateStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        if (!checkPermission(request, "MANAGE_INVENTORY")) {
            request.setAttribute("errorMessage", "You don't have permission to update purchase status.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }

        int purchaseId = Integer.parseInt(request.getParameter("id"));
        String status = request.getParameter("status");

        if (purchaseDAO.updatePurchaseStatus(purchaseId, status)) {
            request.setAttribute("successMessage", "Purchase status updated successfully!");
        } else {
            request.setAttribute("errorMessage", "Failed to update purchase status.");
        }

        response.sendRedirect("purchase?action=view&id=" + purchaseId);
    }

    private void deletePurchase(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        if (!checkPermission(request, "MANAGE_INVENTORY")) {
            request.setAttribute("errorMessage", "You don't have permission to delete purchases.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }

        int purchaseId = Integer.parseInt(request.getParameter("id"));

        if (purchaseDAO.deletePurchase(purchaseId)) {
            request.setAttribute("successMessage", "Purchase deleted successfully!");
        } else {
            request.setAttribute("errorMessage", "Failed to delete purchase.");
        }

        response.sendRedirect("purchase?action=list");
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
