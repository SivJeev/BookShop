package model;

import java.sql.Timestamp;

public class Sale {
    private int id;
    private Timestamp saleDate;
    private String customerName;
    private String customerEmail;
    private double subtotal;
    private double tax;
    private double discount;
    private double total;
    private String paymentMethod;
    private Double cashAmount;
    private Double cardAmount;
    private int userId;
    private String notes;
    private Timestamp createdAt;

    // Default constructor
    public Sale() {
    }

    // Constructor with essential fields
    public Sale(String customerName, String customerEmail, double subtotal, double tax, 
                double discount, double total, String paymentMethod, int userId) {
        this.customerName = customerName;
        this.customerEmail = customerEmail;
        this.subtotal = subtotal;
        this.tax = tax;
        this.discount = discount;
        this.total = total;
        this.paymentMethod = paymentMethod;
        this.userId = userId;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Timestamp getSaleDate() {
        return saleDate;
    }

    public void setSaleDate(Timestamp saleDate) {
        this.saleDate = saleDate;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerEmail() {
        return customerEmail;
    }

    public void setCustomerEmail(String customerEmail) {
        this.customerEmail = customerEmail;
    }

    public double getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(double subtotal) {
        this.subtotal = subtotal;
    }

    public double getTax() {
        return tax;
    }

    public void setTax(double tax) {
        this.tax = tax;
    }

    public double getDiscount() {
        return discount;
    }

    public void setDiscount(double discount) {
        this.discount = discount;
    }

    public double getTotal() {
        return total;
    }

    public void setTotal(double total) {
        this.total = total;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public Double getCashAmount() {
        return cashAmount;
    }

    public void setCashAmount(Double cashAmount) {
        this.cashAmount = cashAmount;
    }

    public Double getCardAmount() {
        return cardAmount;
    }

    public void setCardAmount(Double cardAmount) {
        this.cardAmount = cardAmount;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "Sale{" +
                "id=" + id +
                ", saleDate=" + saleDate +
                ", customerName='" + customerName + '\'' +
                ", customerEmail='" + customerEmail + '\'' +
                ", subtotal=" + subtotal +
                ", tax=" + tax +
                ", discount=" + discount +
                ", total=" + total +
                ", paymentMethod='" + paymentMethod + '\'' +
                ", cashAmount=" + cashAmount +
                ", cardAmount=" + cardAmount +
                ", userId=" + userId +
                ", notes='" + notes + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}