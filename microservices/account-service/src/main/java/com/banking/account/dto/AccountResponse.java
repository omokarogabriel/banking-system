package com.banking.account.dto;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
public class AccountResponse {
    private String responseCode;
    private String responseMessage;
    private AccountInfo accountInfo;

    @Data
    @Builder
    public static class AccountInfo {
        private String accountName;
        private String accountNumber;
        private BigDecimal accountBalance;
    }
}