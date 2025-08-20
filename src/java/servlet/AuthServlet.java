package servlet;

import dao.UserDAO;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.annotation.WebServlet;
import util.PasswordUtil;

@WebServlet("/auth")
public class AuthServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        try {
            userDAO = new UserDAO();
            System.out.println("AuthServlet initialized successfully");
        } catch (SQLException ex) {
            System.err.println("Failed to initialize UserDAO: " + ex.getMessage());
            Logger.getLogger(AuthServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        System.out.println("AuthServlet doPost called with action: " + action);

        if (action == null) {
            action = "login";
        }

        switch (action) {
            case "login":
                handleLogin(request, response);
                break;
            case "register":
                handleRegister(request, response);
                break;
            case "logout":
                handleLogout(request, response);
                break;
            default:
                System.out.println("Unknown action: " + action + ", redirecting to login");
                response.sendRedirect("login.jsp");
                break;
        }
    }

    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        System.out.println("=== LOGIN ATTEMPT ===");
        System.out.println("Username received: '" + username + "'");

        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            System.out.println("Login failed - Missing credentials");
            request.setAttribute("errorMessage", "Username and password are required.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        try {
            // Hash the input password before authentication
            System.out.println("username : "+ username + " " + "User Password : " + password);

            // Single database call for authentication with hashed password
            User user = userDAO.authenticateUser(username.trim(), password.trim());

            if (user != null) {
                System.out.println("Login successful for: " + username);
                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                session.setMaxInactiveInterval(30 * 60);

                response.sendRedirect("dashboard.jsp");
            } else {
                System.out.println("Login failed - Invalid credentials for: " + username);
                request.setAttribute("errorMessage", "Invalid username or password.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            System.err.println("Exception during authentication: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "System error during login. Please try again.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    private void handleRegister(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String fullName = request.getParameter("fullName");

        System.out.println("=== REGISTRATION ATTEMPT ===");
        System.out.println("Username: " + username);
        System.out.println("Email: " + email);
        System.out.println("Full Name: " + fullName);

        // Validation (same as before)
        if (username == null || email == null || password == null
                || confirmPassword == null || fullName == null
                || username.trim().isEmpty() || email.trim().isEmpty()
                || password.trim().isEmpty() || fullName.trim().isEmpty()) {

            System.out.println("Registration failed - Missing required fields");
            request.setAttribute("errorMessage", "All fields are required.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            System.out.println("Registration failed - Password mismatch");
            request.setAttribute("errorMessage", "Passwords do not match.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            System.out.println("Registration failed - Password too short");
            request.setAttribute("errorMessage", "Password must be at least 6 characters long.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Check if username already exists
        if (userDAO.getUserByUsername(username.trim()) != null) {
            System.out.println("Registration failed - Username already exists");
            request.setAttribute("errorMessage", "Username already exists.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Hash the password before creating user
        String hashedPassword = PasswordUtil.hashPassword(password);
        System.out.println("Password hashed for new user");

        // Create new user with hashed password
        User newUser = new User(username.trim(), email.trim(), hashedPassword, fullName.trim());

        if (userDAO.createUser(newUser)) {
            System.out.println("User created successfully");

            // Assign default CUSTOMER role (role_id = 4)
            User createdUser = userDAO.getUserByUsername(username.trim());
            if (createdUser != null) {
                boolean roleAssigned = userDAO.assignRoleToUser(createdUser.getId(), 4); // CUSTOMER role
                System.out.println("Role assignment result: " + roleAssigned);
            }

            request.setAttribute("successMessage", "Registration successful! Please login.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } else {
            System.out.println("Registration failed - Database error");
            request.setAttribute("errorMessage", "Registration failed. Please try again.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }

    private void handleLogout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            System.out.println("Logging out user, invalidating session: " + session.getId());
            session.invalidate();
        }

        response.sendRedirect("login.jsp");
    }
}
