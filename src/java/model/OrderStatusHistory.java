package model;

import java.sql.Timestamp;

public class OrderStatusHistory {
    private int id;
    private int orderId;
    private String status;
    private Integer changedBy;
    private String notes;
    private Timestamp createdAt;
    private User changedByUser;
    
    // Getters and setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public Integer getChangedBy() { return changedBy; }
    public void setChangedBy(Integer changedBy) { this.changedBy = changedBy; }
    
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public User getChangedByUser() { return changedByUser; }
    public void setChangedByUser(User changedByUser) { this.changedByUser = changedByUser; }
}