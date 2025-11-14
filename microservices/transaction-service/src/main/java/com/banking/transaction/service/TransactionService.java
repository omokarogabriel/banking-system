package com.banking.transaction.service;

import com.banking.transaction.dto.TransferRequest;
import com.banking.transaction.dto.TransactionResponse;
import com.banking.transaction.entity.Transaction;
import com.banking.transaction.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class TransactionService {
    private final TransactionRepository transactionRepository;
    private final AccountServiceClient accountServiceClient;
    private final SecureRandom secureRandom = new SecureRandom();

    @Transactional
    public TransactionResponse processTransfer(TransferRequest request) {
        try {
            // Validate accounts exist
            var sourceAccount = accountServiceClient.getAccount(request.getSourceAccountNumber());
            var destinationAccount = accountServiceClient.getAccount(request.getDestinationAccountNumber());

            if (!"200".equals(sourceAccount.getResponseCode())) {
                return buildErrorResponse("404", "Source account not found");
            }

            if (!"200".equals(destinationAccount.getResponseCode())) {
                return buildErrorResponse("404", "Destination account not found");
            }

            // Check sufficient balance
            if (sourceAccount.getAccountInfo().getAccountBalance().compareTo(request.getAmount()) < 0) {
                return buildErrorResponse("400", "Insufficient balance");
            }

            // Create transaction record
            Transaction transaction = Transaction.builder()
                    .transactionReference(generateTransactionReference())
                    .sourceAccountNumber(request.getSourceAccountNumber())
                    .destinationAccountNumber(request.getDestinationAccountNumber())
                    .amount(request.getAmount())
                    .transactionType(Transaction.TransactionType.TRANSFER)
                    .status(Transaction.TransactionStatus.COMPLETED)
                    .description(request.getDescription())
                    .build();

            Transaction savedTransaction = transactionRepository.save(transaction);
            log.info("Transfer completed: {}", savedTransaction.getTransactionReference());

            return TransactionResponse.builder()
                    .responseCode("200")
                    .responseMessage("Transfer completed successfully")
                    .transactionInfo(buildTransactionInfo(savedTransaction))
                    .build();

        } catch (Exception e) {
            log.error("Error processing transfer", e);
            return buildErrorResponse("500", "Internal server error occurred");
        }
    }

    public List<TransactionResponse.TransactionInfo> getTransactionHistory(String accountNumber, Pageable pageable) {
        Page<Transaction> transactions = transactionRepository
                .findBySourceAccountNumberOrDestinationAccountNumberOrderByCreatedAtDesc(
                        accountNumber, accountNumber, pageable);

        return transactions.getContent().stream()
                .map(this::buildTransactionInfo)
                .toList();
    }

    private String generateTransactionReference() {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        int randomNumber = secureRandom.nextInt(10000);
        return "TXN" + timestamp + String.format("%04d", randomNumber);
    }

    private TransactionResponse buildErrorResponse(String code, String message) {
        return TransactionResponse.builder()
                .responseCode(code)
                .responseMessage(message)
                .build();
    }

    private TransactionResponse.TransactionInfo buildTransactionInfo(Transaction transaction) {
        return TransactionResponse.TransactionInfo.builder()
                .transactionReference(transaction.getTransactionReference())
                .sourceAccountNumber(transaction.getSourceAccountNumber())
                .destinationAccountNumber(transaction.getDestinationAccountNumber())
                .amount(transaction.getAmount())
                .transactionType(transaction.getTransactionType())
                .status(transaction.getStatus())
                .description(transaction.getDescription())
                .createdAt(transaction.getCreatedAt())
                .build();
    }
}