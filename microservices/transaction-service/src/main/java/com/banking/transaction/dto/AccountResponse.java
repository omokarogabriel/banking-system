package com.banking.transaction.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class AccountResponse {
    private String responseCode;
    private String responseMessage;
    private AccountInfo accountInfo;

    @Data
    public static class AccountInfo {
        private String accountName;
        private String accountNumber;
        private BigDecimal accountBalance;
    }
}