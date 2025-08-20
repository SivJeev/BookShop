package model;

public class PurchaseItem {
    private int id;
    private int purchaseId;
    private int bookId;
    private int quantity;
    private int receivedQuantity;
    private double unitPrice;
    private double totalPrice;
    
    // Additional fields for display
    private String bookTitle;
    private String bookAuthor;
    private String bookIsbn;
    
    public PurchaseItem() {}
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getPurchaseId() { return purchaseId; }
    public void setPurchaseId(int purchaseId) { this.purchaseId = purchaseId; }
    
    public int getBookId() { return bookId; }
    public void setBookId(int bookId) { this.bookId = bookId; }
    
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    
    public int getReceivedQuantity() { return receivedQuantity; }
    public void setReceivedQuantity(int receivedQuantity) { this.receivedQuantity = receivedQuantity; }
    
    public double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(double unitPrice) { this.unitPrice = unitPrice; }
    
    public double getTotalPrice() { return totalPrice; }
    public void setTotalPrice(double totalPrice) { this.totalPrice = totalPrice; }
    
    public String getBookTitle() { return bookTitle; }
    public void setBookTitle(String bookTitle) { this.bookTitle = bookTitle; }
    
    public String getBookAuthor() { return bookAuthor; }
    public void setBookAuthor(String bookAuthor) { this.bookAuthor = bookAuthor; }
    
    public String getBookIsbn() { return bookIsbn; }
    public void setBookIsbn(String bookIsbn) { this.bookIsbn = bookIsbn; }
    
    @Override
    public String toString() {
        return "PurchaseItem{" +
                "id=" + id +
                ", bookId=" + bookId +
                ", quantity=" + quantity +
                ", unitPrice=" + unitPrice +
                '}';
    }
}