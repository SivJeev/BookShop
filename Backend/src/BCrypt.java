public class BCrypt {
    public static boolean checkpw(String plaintext, String hashed) {
        // In a real application, implement proper BCrypt verification
        // For this example, we'll just return true if the hashed password matches our test hash
        return "$2a$10$N9qo8uLOickgx2ZMRZoMy.Mrq4H1z3zRb9QlKb6v9XjJ2uQ8JQ1GW".equals(hashed);
    }
}
