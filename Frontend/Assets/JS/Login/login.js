document.getElementById('loginForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    const messageDiv = document.getElementById('message');
    const submitBtn = document.querySelector('.login-btn');
    
    // Clear previous messages
    messageDiv.className = 'message';
    messageDiv.textContent = '';
    
    // Validate inputs
    if (!username || !password) {
        showMessage('Please fill in all fields', 'error', messageDiv);
        return;
    }
    
    // Show loading state
    const originalBtnContent = submitBtn.innerHTML;
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Authenticating...';
    submitBtn.disabled = true;
    
    // Make API call to Java backend
    fetch('http://localhost:8080/login', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ 
            username: username,
            password: password 
        })
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
    })
    .then(data => {
        if (data.success) {
            showMessage('Login successful! Redirecting...', 'success', messageDiv);
            // Store token if available
            if (data.token) {
                localStorage.setItem('authToken', data.token);
            }
            // Redirect to dashboard
            setTimeout(() => {
                window.location.href = 'dashboard.html';
            }, 1500);
        } else {
            showMessage(data.message || 'Invalid credentials', 'error', messageDiv);
        }
    })
    .catch(error => {
        console.error('Login error:', error);
        showMessage('Login service unavailable. Please try again later.', 'error', messageDiv);
    })
    .finally(() => {
        // Restore button state
        submitBtn.innerHTML = originalBtnContent;
        submitBtn.disabled = false;
    });
});

function showMessage(text, type, element) {
    element.textContent = text;
    element.className = `message ${type}`;
    element.style.display = 'block';
    
    // Auto-hide message after 5 seconds
    if (type === 'error') {
        setTimeout(() => {
            element.style.display = 'none';
        }, 5000);
    }
}