package com.banking.notification.service;

import com.banking.notification.dto.NotificationRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationService {
    private final JavaMailSender mailSender;

    public void sendNotification(NotificationRequest request) {
        try {
            switch (request.getType()) {
                case EMAIL -> sendEmail(request);
                case SMS -> sendSMS(request);
            }
        } catch (Exception e) {
            log.error("Failed to send notification", e);
        }
    }

    private void sendEmail(NotificationRequest request) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(request.getRecipient());
        message.setSubject(request.getSubject());
        message.setText(request.getMessage());
        mailSender.send(message);
        log.info("Email sent to: {}", request.getRecipient());
    }

    private void sendSMS(NotificationRequest request) {
        // SMS implementation would go here
        log.info("SMS sent to: {}", request.getRecipient());
    }
}