package Services;
import java.sql.SQLException;
import Repositories.UserRepository;

public class AuthService {
    private UserRepository userRepo = new UserRepository();
    
    public boolean login(String username, String password) {
        try {
            return userRepo.authenticate(username, password);
        } catch (SQLException e) {
            System.err.println("Authentication error: " + e.getMessage());
            return false;
        }
    }
}