package util;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;
import javax.servlet.http.Part;

public class FileUploadUtil {
    private static final String UPLOAD_DIR = "book-images";
    
    public static String saveImage(Part filePart, String applicationPath) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }
        
        // Get the filename and extension
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        String extension = fileName.substring(fileName.lastIndexOf("."));
        
        // Generate unique filename
        String uniqueFileName = UUID.randomUUID().toString() + extension;
        
        // Create upload directory if it doesn't exist
        String uploadPath = applicationPath + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        
        // Save the file
        Path filePath = Paths.get(uploadPath, uniqueFileName);
        Files.copy(filePart.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
        
        return UPLOAD_DIR + File.separator + uniqueFileName;
    }
    
    public static boolean deleteImage(String imagePath, String applicationPath) {
        if (imagePath == null || imagePath.isEmpty()) {
            return true;
        }
        
        File imageFile = new File(applicationPath + File.separator + imagePath);
        return imageFile.delete();
    }
}