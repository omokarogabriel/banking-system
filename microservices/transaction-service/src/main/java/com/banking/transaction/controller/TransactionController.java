package com.banking.transaction.controller;

import com.banking.transaction.dto.TransferRequest;
import com.banking.transaction.dto.TransactionResponse;
import com.banking.transaction.service.TransactionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/transactions")
@RequiredArgsConstructor
public class TransactionController {
    private final TransactionService transactionService;

    @PostMapping("/transfer")
    public ResponseEntity<TransactionResponse> processTransfer(@Valid @RequestBody TransferRequest request) {
        TransactionResponse response = transactionService.processTransfer(request);
        HttpStatus status = "200".equals(response.getResponseCode()) ? HttpStatus.OK : 
                           "404".equals(response.getResponseCode()) ? HttpStatus.NOT_FOUND : 
                           "400".equals(response.getResponseCode()) ? HttpStatus.BAD_REQUEST : 
                           HttpStatus.INTERNAL_SERVER_ERROR;
        return ResponseEntity.status(status).body(response);
    }

    @GetMapping("/history/{accountNumber}")
    public ResponseEntity<List<TransactionResponse.TransactionInfo>> getTransactionHistory(
            @PathVariable String accountNumber,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        List<TransactionResponse.TransactionInfo> history = transactionService.getTransactionHistory(accountNumber, pageable);
        return ResponseEntity.ok(history);
    }
}