package model;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.List;

public class Purchase {
    private int id;
    private int supplierId;
    private Date purchaseDate;
    private Date expectedDeliveryDate;
    private double shippingCost;
    private double tax;
    private double discount;
    private double totalAmount;
    private double paidAmount;
    private String paymentMethod;
    private String paymentStatus;
    private String status;
    private String notes;
    private int createdBy;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // Additional fields for display
    private String supplierName;
    private String createdByName;
    private List<PurchaseItem> items;
    private List<PurchasePayment> payments;
    
    public Purchase() {}
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getSupplierId() { return supplierId; }
    public void setSupplierId(int supplierId) { this.supplierId = supplierId; }
    
    public Date getPurchaseDate() { return purchaseDate; }
    public void setPurchaseDate(Date purchaseDate) { this.purchaseDate = purchaseDate; }
    
    public Date getExpectedDeliveryDate() { return expectedDeliveryDate; }
    public void setExpectedDeliveryDate(Date expectedDeliveryDate) { this.expectedDeliveryDate = expectedDeliveryDate; }
    
    public double getShippingCost() { return shippingCost; }
    public void setShippingCost(double shippingCost) { this.shippingCost = shippingCost; }
    
    public double getTax() { return tax; }
    public void setTax(double tax) { this.tax = tax; }
    
    public double getDiscount() { return discount; }
    public void setDiscount(double discount) { this.discount = discount; }
    
    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }
    
    public double getPaidAmount() { return paidAmount; }
    public void setPaidAmount(double paidAmount) { this.paidAmount = paidAmount; }
    
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    
    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    
    public String getSupplierName() { return supplierName; }
    public void setSupplierName(String supplierName) { this.supplierName = supplierName; }
    
    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }
    
    public List<PurchaseItem> getItems() { return items; }
    public void setItems(List<PurchaseItem> items) { this.items = items; }
    
    public List<PurchasePayment> getPayments() { return payments; }
    public void setPayments(List<PurchasePayment> payments) { this.payments = payments; }
    
    public double getDueAmount() {
        return totalAmount - paidAmount;
    }
    
    @Override
    public String toString() {
        return "Purchase{" +
                "id=" + id +
                ", supplierId=" + supplierId +
                ", purchaseDate=" + purchaseDate +
                ", totalAmount=" + totalAmount +
                ", status='" + status + '\'' +
                '}';
    }
}