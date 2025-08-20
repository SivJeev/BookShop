package servlet;

import dao.SupplierDAO;
import model.Supplier;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/supplier")
public class SupplierServlet extends HttpServlet {
    private SupplierDAO supplierDAO;
    
    @Override
    public void init() throws ServletException {
        try {
            supplierDAO = new SupplierDAO();
        } catch (SQLException ex) {
            Logger.getLogger(SupplierServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "list";
        }
        
        switch (action) {
            case "list":
                listSuppliers(request, response);
                break;
            case "add":
                showAddForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "view":
                viewSupplier(request, response);
                break;
            case "delete":
                deleteSupplier(request, response);
                break;
            default:
                listSuppliers(request, response);
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if (action == null) {
            response.sendRedirect("supplier?action=list");
            return;
        }
        
        switch (action) {
            case "create":
                createSupplier(request, response);
                break;
            case "update":
                updateSupplier(request, response);
                break;
            default:
                response.sendRedirect("supplier?action=list");
                break;
        }
    }
    
    private void listSuppliers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_SUPPLIERS")) {
            request.setAttribute("errorMessage", "You don't have permission to view suppliers.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        List<Supplier> suppliers = supplierDAO.getAllSuppliers();
        request.setAttribute("suppliers", suppliers);
        request.getRequestDispatcher("supplier-list.jsp").forward(request, response);
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_SUPPLIERS")) {
            request.setAttribute("errorMessage", "You don't have permission to add suppliers.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        request.getRequestDispatcher("supplier-add.jsp").forward(request, response);
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_SUPPLIERS")) {
            request.setAttribute("errorMessage", "You don't have permission to edit suppliers.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        int supplierId = Integer.parseInt(request.getParameter("id"));
        Supplier supplier = supplierDAO.getSupplierById(supplierId);
        
        if (supplier != null) {
            request.setAttribute("supplier", supplier);
            request.getRequestDispatcher("supplier-edit.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Supplier not found.");
            response.sendRedirect("supplier?action=list");
        }
    }
    
    private void viewSupplier(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int supplierId = Integer.parseInt(request.getParameter("id"));
        Supplier supplier = supplierDAO.getSupplierById(supplierId);
        
        if (supplier != null) {
            request.setAttribute("supplier", supplier);
            request.getRequestDispatcher("supplier-view.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Supplier not found.");
            response.sendRedirect("supplier?action=list");
        }
    }
    
    private void createSupplier(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_SUPPLIERS")) {
            request.setAttribute("errorMessage", "You don't have permission to create suppliers.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        Supplier newSupplier = new Supplier();
        newSupplier.setName(request.getParameter("name"));
        newSupplier.setContactPerson(request.getParameter("contactPerson"));
        newSupplier.setEmail(request.getParameter("email"));
        newSupplier.setPhone(request.getParameter("phone"));
        newSupplier.setAddress(request.getParameter("address"));
        newSupplier.setCity(request.getParameter("city"));
        newSupplier.setState(request.getParameter("state"));
        newSupplier.setCountry(request.getParameter("country"));
        newSupplier.setPostalCode(request.getParameter("postalCode"));
        newSupplier.setWebsite(request.getParameter("website"));
        newSupplier.setNotes(request.getParameter("notes"));
        
        // Validation
        if (newSupplier.getName() == null || newSupplier.getName().trim().isEmpty() ||
            newSupplier.getContactPerson() == null || newSupplier.getContactPerson().trim().isEmpty() ||
            newSupplier.getEmail() == null || newSupplier.getEmail().trim().isEmpty() ||
            newSupplier.getPhone() == null || newSupplier.getPhone().trim().isEmpty()) {
            
            request.setAttribute("errorMessage", "Name, Contact Person, Email, and Phone are required.");
            showAddForm(request, response);
            return;
        }
        
        if (supplierDAO.createSupplier(newSupplier)) {
            request.setAttribute("successMessage", "Supplier created successfully!");
            response.sendRedirect("supplier?action=list");
        } else {
            request.setAttribute("errorMessage", "Failed to create supplier.");
            showAddForm(request, response);
        }
    }
    
    private void updateSupplier(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_SUPPLIERS")) {
            request.setAttribute("errorMessage", "You don't have permission to update suppliers.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        int supplierId = Integer.parseInt(request.getParameter("id"));
        Supplier supplier = supplierDAO.getSupplierById(supplierId);
        
        if (supplier != null) {
            supplier.setName(request.getParameter("name"));
            supplier.setContactPerson(request.getParameter("contactPerson"));
            supplier.setEmail(request.getParameter("email"));
            supplier.setPhone(request.getParameter("phone"));
            supplier.setAddress(request.getParameter("address"));
            supplier.setCity(request.getParameter("city"));
            supplier.setState(request.getParameter("state"));
            supplier.setCountry(request.getParameter("country"));
            supplier.setPostalCode(request.getParameter("postalCode"));
            supplier.setWebsite(request.getParameter("website"));
            supplier.setNotes(request.getParameter("notes"));
            
            // Validation
            if (supplier.getName() == null || supplier.getName().trim().isEmpty() ||
                supplier.getContactPerson() == null || supplier.getContactPerson().trim().isEmpty() ||
                supplier.getEmail() == null || supplier.getEmail().trim().isEmpty() ||
                supplier.getPhone() == null || supplier.getPhone().trim().isEmpty()) {
                
                request.setAttribute("errorMessage", "Name, Contact Person, Email, and Phone are required.");
                showEditForm(request, response);
                return;
            }
            
            if (supplierDAO.updateSupplier(supplier)) {
                request.setAttribute("successMessage", "Supplier updated successfully!");
                response.sendRedirect("supplier?action=list");
            } else {
                request.setAttribute("errorMessage", "Failed to update supplier.");
                showEditForm(request, response);
            }
        } else {
            request.setAttribute("errorMessage", "Supplier not found.");
            response.sendRedirect("supplier?action=list");
        }
    }
    
    private void deleteSupplier(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkPermission(request, "MANAGE_SUPPLIERS")) {
            request.setAttribute("errorMessage", "You don't have permission to delete suppliers.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }
        
        int supplierId = Integer.parseInt(request.getParameter("id"));
        
        if (supplierDAO.deleteSupplier(supplierId)) {
            request.setAttribute("successMessage", "Supplier deleted successfully!");
        } else {
            request.setAttribute("errorMessage", "Failed to delete supplier.");
        }
        
        response.sendRedirect("supplier?action=list");
    }
    
    private boolean checkPermission(HttpServletRequest request, String permission) {
        // Implement your permission checking logic here
        // Similar to your UserServlet's checkPermission method
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            return false;
        }
        
        // You would need to inject or access your PermissionDAO here
        // For now, returning true to allow all operations
        // In a real application, you would check permissions properly
        return true;
    }
}