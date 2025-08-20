<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pahana Edu - Help Guide</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Use the same CSS from your main page for consistency */
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

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
        }

        .help-container {
            background: var(--white);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            padding: 2rem;
        }

        .help-header {
            text-align: center;
            margin-bottom: 2rem;
        }

        .help-title {
            font-size: 2rem;
            color: var(--primary);
            margin-bottom: 1rem;
        }

        .help-subtitle {
            color: var(--text-light);
            font-size: 1.125rem;
        }

        .help-section {
            margin-bottom: 3rem;
        }

        .section-title {
            font-size: 1.5rem;
            color: var(--primary);
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid var(--border);
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .section-title i {
            font-size: 1.25rem;
        }

        .step {
            display: flex;
            gap: 1.5rem;
            margin-bottom: 1.5rem;
            padding: 1.5rem;
            background: var(--light);
            border-radius: var(--radius);
        }

        .step-number {
            background: var(--primary);
            color: white;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            flex-shrink: 0;
        }

        .step-content {
            flex: 1;
        }

        .step-title {
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .step-image {
            margin-top: 1rem;
            border-radius: var(--radius);
            border: 1px solid var(--border);
            max-width: 100%;
            height: auto;
            box-shadow: var(--shadow);
        }

        .note {
            background: #f0f9ff;
            border-left: 4px solid var(--primary);
            padding: 1rem;
            border-radius: 0 var(--radius) var(--radius) 0;
            margin: 1rem 0;
        }

        .note-title {
            font-weight: 600;
            color: var(--primary);
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        @media (max-width: 768px) {
            .container {
                padding: 1rem;
            }
            .step {
                flex-direction: column;
                gap: 1rem;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="header-content">
            <a href="index.jsp" class="logo">
                <i class="fas fa-book"></i>
                Pahana Edu
            </a>
            <a href="index.jsp" class="btn btn-primary">
                <i class="fas fa-arrow-left"></i>
                Back to System
            </a>
        </div>
    </header>

    <div class="container">
        <div class="help-container">
            <div class="help-header">
                <h1 class="help-title">Pahana Edu Help Guide</h1>
                <p class="help-subtitle">Learn how to use our book reservation system effectively</p>
            </div>

            <!-- Registration Section -->
            <div class="help-section">
                <h2 class="section-title">
                    <i class="fas fa-user-plus"></i>
                    How to Register an Account
                </h2>
                
                <div class="step">
                    <div class="step-number">1</div>
                    <div class="step-content">
                        <h3 class="step-title">Access the Registration Form</h3>
                        <p>Click on the "Login / Register" button in the top right corner of the page. Then click on the "Register" tab in the modal that appears.</p>
                        <img src="Images/login_register.PNG" alt="Registration form" class="step-image">
                    </div>
                </div>
                
                <div class="step">
                    <div class="step-number">2</div>
                    <div class="step-content">
                        <h3 class="step-title">Fill in Your Details</h3>
                        <p>Complete all required fields including your full name, email address, phone number, and password. Address and account number are optional.</p>
                        <img src="Images/register.PNG" alt="Filling registration form" class="step-image">
                    </div>
                </div>
                
                <div class="step">
                    <div class="step-number">3</div>
                    <div class="step-content">
                        <h3 class="step-title">Submit the Form</h3>
                        <p>Click the "Create Account" button to complete your registration. You'll be automatically logged in and receive a welcome notification.</p>
                        <div class="note">
                            <h4 class="note-title"><i class="fas fa-lightbulb"></i> Note</h4>
                            <p>Make sure to use a valid email address as it will be used for account recovery and notifications.</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Login Section -->
            <div class="help-section">
                <h2 class="section-title">
                    <i class="fas fa-sign-in-alt"></i>
                    How to Login to Your Account
                </h2>
                
                <div class="step">
                    <div class="step-number">1</div>
                    <div class="step-content">
                        <h3 class="step-title">Access the Login Form</h3>
                        <p>Click on the "Login / Register" button in the top right corner of the page. The login tab is selected by default.</p>
                        <img src="Images/login_register.PNG" alt="Login form" class="step-image">
                    </div>
                </div>
                
                <div class="step">
                    <div class="step-number">2</div>
                    <div class="step-content">
                        <h3 class="step-title">Enter Your Credentials</h3>
                        <p>Provide the email address and password you used during registration.</p>
                        <img src="Images/login.PNG" alt="Entering login credentials" class="step-image">
                    </div>
                </div>
                
                <div class="step">
                    <div class="step-number">3</div>
                    <div class="step-content">
                        <h3 class="step-title">Click Login</h3>
                        <p>After entering your details, click the "Login" button to access your account.</p>
                        <div class="note">
                            <h4 class="note-title"><i class="fas fa-exclamation-triangle"></i> Important</h4>
                            <p>If you forget your password, please contact our support team for assistance.</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Book Reservation Section -->
            <div class="help-section">
                <h2 class="section-title">
                    <i class="fas fa-bookmark"></i>
                    How to Reserve a Book
                </h2>
                
                <div class="step">
                    <div class="step-number">1</div>
                    <div class="step-content">
                        <h3 class="step-title">Browse Available Books</h3>
                        <p>After logging in, scroll down to view all available books. Each book card shows the title, author, price, and availability.</p>
                        <img src="Images/availableBooks.PNG" alt="Book listing" class="step-image">
                    </div>
                </div>
                
                <div class="step">
                    <div class="step-number">2</div>
                    <div class="step-content">
                        <h3 class="step-title">Select a Book</h3>
                        <p>Click the "Reserve Book" button on any available book you wish to reserve.</p>
                        <img src="Images/availableBooksReserveBtn.png" alt="Reserve book button" class="step-image">
                    </div>
                </div>
                
                <div class="step">
                    <div class="step-number">3</div>
                    <div class="step-content">
                        <h3 class="step-title">Complete Reservation Details</h3>
                        <p>In the reservation modal, select the quantity (up to the available amount) and add any optional notes. Then click "Confirm Reservation".</p>
                        <img src="Images/reserveBtn.PNG" alt="Reservation form" class="step-image">
                    </div>
                </div>
                
                <div class="step">
                    <div class="step-number">4</div>
                    <div class="step-content">
                        <h3 class="step-title">View Your Reservation</h3>
                        <p>After successful reservation, you'll see a confirmation message and can view the reservation in your "My Reservations" section.</p>
                        <img src="Images/Notifications.PNG" alt="Reservation confirmation" class="step-image">
                        <div class="note">
                            <h4 class="note-title"><i class="fas fa-info-circle"></i> Tip</h4>
                            <p>Make note of your Transaction ID for future reference when checking your reservation status.</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Managing Reservations Section -->
            <div class="help-section">
                <h2 class="section-title">
                    <i class="fas fa-clipboard-list"></i>
                    How to Manage Reservations
                </h2>
                
                <div class="step">
                    <div class="step-number">1</div>
                    <div class="step-content">
                        <h3 class="step-title">View Your Reservations</h3>
                        <p>Scroll down to the "My Reservations" section to see all your current and past reservations with their status.</p>
                        <img src="Images/myReservationsView.png" alt="Reservations list" class="step-image">
                    </div>
                </div>
                
                <div class="step">
                    <div class="step-number">2</div>
                    <div class="step-content">
                        <h3 class="step-title">Check Reservation Status</h3>
                        <p>Each reservation shows its current status (Pending, Confirmed, Completed, or Cancelled) with a colored badge.</p>
                        <img src="Images/ReservationStatus.png" alt="Reservation status" class="step-image">
                    </div>
                </div>
                
                <div class="step">
                    <div class="step-number">3</div>
                    <div class="step-content">
                        <h3 class="step-title">Cancel a Reservation</h3>
                        <p>For pending or confirmed reservations, click the "Cancel" button to cancel your reservation.</p>
                        <img src="Images/Reservation-cancel.png" alt="Cancel reservation" class="step-image">
                        <div class="note">
                            <h4 class="note-title"><i class="fas fa-exclamation-triangle"></i> Important</h4>
                            <p>Completed or already cancelled reservations cannot be modified.</p>
                        </div>
                    </div>
                </div>
                
                <div class="step">
                    <div class="step-number">4</div>
                    <div class="step-content">
                        <h3 class="step-title">View Bill/Receipt</h3>
                        <p>Click "View Bill" on any reservation to see detailed information and print a receipt.</p>
                        <img src="Images/ReservationView.png" alt="View bill button" class="step-image">
                    </div>
                </div>
            </div>

            <!-- Profile Management Section -->
            <div class="help-section">
                <h2 class="section-title">
                    <i class="fas fa-user-edit"></i>
                    How to Update Your Profile
                </h2>
                
                <div class="step">
                    <div class="step-number">1</div>
                    <div class="step-content">
                        <h3 class="step-title">Access Profile Settings</h3>
                        <p>Click on the "Profile" button in the top right corner (visible after login).</p>
                        <img src="Images/ProfileClick.png" alt="Profile button" class="step-image">
                    </div>
                </div>
                
                <div class="step">
                    <div class="step-number">2</div>
                    <div class="step-content">
                        <h3 class="step-title">Edit Your Information</h3>
                        <p>Update your name, phone number, address, or account number in the profile form.</p>
                        <img src="Images/EditProfile.PNG" alt="Profile form" class="step-image">
                    </div>
                </div>
                
                <div class="step">
                    <div class="step-number">3</div>
                    <div class="step-content">
                        <h3 class="step-title">Save Changes</h3>
                        <p>Click "Update Profile" to save your changes. Note that your email cannot be changed.</p>
                        <div class="note">
                            <h4 class="note-title"><i class="fas fa-lightbulb"></i> Tip</h4>
                            <p>Keep your profile information up-to-date to ensure smooth communication about your reservations.</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Logout Section -->
            <div class="help-section">
                <h2 class="section-title">
                    <i class="fas fa-sign-out-alt"></i>
                    How to Logout
                </h2>
                
                <div class="step">
                    <div class="step-number">1</div>
                    <div class="step-content">
                        <h3 class="step-title">Find the Logout Button</h3>
                        <p>In the top right corner, click the "Logout" button (visible when logged in).</p>
                        <img src="Images/LogOut.png" alt="Logout button" class="step-image">
                    </div>
                </div>
                
                <div class="step">
                    <div class="step-number">2</div>
                    <div class="step-content">
                        <h3 class="step-title">Confirm Logout</h3>
                        <p>You'll be automatically logged out and redirected to the home page as a guest user.</p>
                        <div class="note">
                            <h4 class="note-title"><i class="fas fa-info-circle"></i> Note</h4>
                            <p>For security, always logout when using shared or public computers.</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Search Bill Section -->
            <div class="help-section">
                <h2 class="section-title">
                    <i class="fas fa-receipt"></i>
                    How to Search for a Bill
                </h2>
                
                <div class="step">
                    <div class="step-number">1</div>
                    <div class="step-content">
                        <h3 class="step-title">Locate the Search Section</h3>
                        <p>At the top of the page, find the "Search Bill by Transaction ID" section.</p>
                        <img src="Images/SearchSection.png" alt="Bill search section" class="step-image">
                    </div>
                </div>
                
                <div class="step">
                    <div class="step-number">2</div>
                    <div class="step-content">
                        <h3 class="step-title">Enter Your Transaction ID</h3>
                        <p>Type in the Transaction ID you received when making the reservation (format: TXN followed by numbers).</p>
                        <img src="Images/IDenter.png" alt="Enter transaction ID" class="step-image">
                    </div>
                </div>
                
                <div class="step">
                    <div class="step-number">3</div>
                    <div class="step-content">
                        <h3 class="step-title">View and Print</h3>
                        <p>Click "Search Bill" to view your reservation details. Use the "Print Bill" button to print the receipt.</p>
                        <img src="Images/FinalBil.PNG" alt="Bill details" class="step-image">
                    </div>
                </div>
            </div>

            <!-- Support Section -->
            <div class="help-section">
                <h2 class="section-title">
                    <i class="fas fa-question-circle"></i>
                    Need More Help?
                </h2>
                <p>If you encounter any issues or have questions not covered in this guide, please contact our support team:</p>
                <ul style="margin: 1rem 0 1rem 2rem;">
                    <li style="margin-bottom: 0.5rem;"><strong>Email:</strong> support@pahanaedu.com</li>
                    <li style="margin-bottom: 0.5rem;"><strong>Phone:</strong> +94 77 859 6123</li>
                    <li><strong>Hours:</strong> Monday-Friday, 9AM-5PM</li>
                </ul>
                <p>We're happy to assist you with any questions about our book reservation system!</p>
            </div>
        </div>
    </div>
</body>
</html>