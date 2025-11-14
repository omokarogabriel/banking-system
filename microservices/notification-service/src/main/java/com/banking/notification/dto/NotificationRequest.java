package com.banking.notification.dto;

import lombok.Data;

@Data
public class NotificationRequest {
    private String recipient;
    private String subject;
    private String message;
    private NotificationType type;

    public enum NotificationType {
        EMAIL, SMS
    }
}