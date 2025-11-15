package com.banking.transaction.service;

import com.banking.transaction.dto.AccountResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

@FeignClient(name = "account-service")
public interface AccountServiceClient {
    @GetMapping("/api/accounts/{accountNumber}")
    AccountResponse getAccount(@PathVariable String accountNumber);
    
    @PutMapping("/api/accounts/{accountNumber}/balance")
    AccountResponse updateBalance(
        @PathVariable String accountNumber,
        @RequestParam BigDecimal amount,
        @RequestParam String operation
    );
}