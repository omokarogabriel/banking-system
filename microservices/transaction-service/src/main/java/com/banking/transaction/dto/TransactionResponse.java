package com.banking.transaction.dto;

import com.banking.transaction.entity.Transaction;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
public class TransactionResponse {
    private String responseCode;
    private String responseMessage;
    private TransactionInfo transactionInfo;

    @Data
    @Builder
    public static class TransactionInfo {
        private String transactionReference;
        private String sourceAccountNumber;
        private String destinationAccountNumber;
        private BigDecimal amount;
        private Transaction.TransactionType transactionType;
        private Transaction.TransactionStatus status;
        private String description;
        private LocalDateTime createdAt;
    }
}