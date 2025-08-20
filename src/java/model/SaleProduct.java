package model;

public class SaleProduct {
    private int id;
    private int saleId;
    private int bookId;
    private int quantity;
    private double unitPrice;
    private double totalPrice;

    // Default constructor
    public SaleProduct() {
    }

    // Constructor with essential fields
    public SaleProduct(int saleId, int bookId, int quantity, double unitPrice, double totalPrice) {
        this.saleId = saleId;
        this.bookId = bookId;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
        this.totalPrice = totalPrice;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getSaleId() {
        return saleId;
    }

    public void setSaleId(int saleId) {
        this.saleId = saleId;
    }

    public int getBookId() {
        return bookId;
    }

    public void setBookId(int bookId) {
        this.bookId = bookId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
    }

    public double getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(double totalPrice) {
        this.totalPrice = totalPrice;
    }

    @Override
    public String toString() {
        return "SaleProduct{" +
                "id=" + id +
                ", saleId=" + saleId +
                ", bookId=" + bookId +
                ", quantity=" + quantity +
                ", unitPrice=" + unitPrice +
                ", totalPrice=" + totalPrice +
                '}';
    }
}