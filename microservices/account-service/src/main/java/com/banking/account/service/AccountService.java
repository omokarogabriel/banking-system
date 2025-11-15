package com.banking.account.service;

import com.banking.account.dto.AccountRequest;
import com.banking.account.dto.AccountResponse;
import com.banking.account.entity.Account;
import com.banking.account.repository.AccountRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.time.Year;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class AccountService {
    private final AccountRepository accountRepository;
    private final SecureRandom secureRandom = new SecureRandom();

    @Transactional
    public AccountResponse createAccount(AccountRequest request) {
        try {
            if (accountRepository.existsByEmail(request.getEmail())) {
                return AccountResponse.builder()
                        .responseCode("001")
                        .responseMessage("Account already exists with this email")
                        .build();
            }

            Account account = Account.builder()
                    .firstName(request.getFirstName())
                    .lastName(request.getLastName())
                    .otherName(request.getOtherName())
                    .gender(request.getGender())
                    .address(request.getAddress())
                    .stateOfOrigin(request.getStateOfOrigin())
                    .accountNumber(generateAccountNumber())
                    .accountBalance(BigDecimal.ZERO)
                    .email(request.getEmail())
                    .phoneNumber(request.getPhoneNumber())
                    .alternativePhoneNumber(request.getAlternativePhoneNumber())
                    .status("ACTIVE")
                    .build();

            Account savedAccount = accountRepository.save(account);
            log.info("Account created successfully with account number: {}", savedAccount.getAccountNumber());

            return AccountResponse.builder()
                    .responseCode("200")
                    .responseMessage("Account created successfully")
                    .accountInfo(AccountResponse.AccountInfo.builder()
                            .accountName(String.join(" ", savedAccount.getFirstName(), 
                                    savedAccount.getLastName(), 
                                    savedAccount.getOtherName() != null ? savedAccount.getOtherName() : ""))
                            .accountNumber(savedAccount.getAccountNumber())
                            .accountBalance(savedAccount.getAccountBalance())
                            .build())
                    .build();

        } catch (Exception e) {
            log.error("Error creating account: {}", e.getMessage());
            return AccountResponse.builder()
                    .responseCode("500")
                    .responseMessage("Internal server error occurred")
                    .build();
        }
    }

    public AccountResponse getAccountByNumber(String accountNumber) {
        try {
            return accountRepository.findByAccountNumber(accountNumber)
                    .map(account -> AccountResponse.builder()
                            .responseCode("200")
                            .responseMessage("Account found")
                            .accountInfo(AccountResponse.AccountInfo.builder()
                                    .accountName(String.join(" ", account.getFirstName(), 
                                            account.getLastName(), 
                                            account.getOtherName() != null ? account.getOtherName() : ""))
                                    .accountNumber(account.getAccountNumber())
                                    .accountBalance(account.getAccountBalance())
                                    .build())
                            .build())
                    .orElse(AccountResponse.builder()
                            .responseCode("404")
                            .responseMessage("Account not found")
                            .build());
        } catch (Exception e) {
            log.error("Error retrieving account: {}", e.getMessage());
            return AccountResponse.builder()
                    .responseCode("500")
                    .responseMessage("Internal server error occurred")
                    .build();
        }
    }

    @Transactional
    public AccountResponse updateBalance(String accountNumber, BigDecimal amount, String operation) {
        try {
            Optional<Account> accountOpt = accountRepository.findByAccountNumber(accountNumber);
            if (accountOpt.isEmpty()) {
                return AccountResponse.builder()
                        .responseCode("404")
                        .responseMessage("Account not found")
                        .build();
            }

            Account account = accountOpt.get();
            BigDecimal currentBalance = account.getAccountBalance();
            BigDecimal newBalance;

            switch (operation.toUpperCase()) {
                case "CREDIT", "DEPOSIT" -> {
                    newBalance = currentBalance.add(amount);
                }
                case "DEBIT", "WITHDRAW" -> {
                    if (currentBalance.compareTo(amount) < 0) {
                        return AccountResponse.builder()
                                .responseCode("400")
                                .responseMessage("Insufficient balance")
                                .build();
                    }
                    newBalance = currentBalance.subtract(amount);
                }
                default -> {
                    return AccountResponse.builder()
                            .responseCode("400")
                            .responseMessage("Invalid operation. Use CREDIT or DEBIT")
                            .build();
                }
            }

            account.setAccountBalance(newBalance);
            Account updatedAccount = accountRepository.save(account);
            
            log.info("Balance updated for account: {}, operation: {}, amount: {}", 
                    accountNumber, operation, amount);

            return AccountResponse.builder()
                    .responseCode("200")
                    .responseMessage("Balance updated successfully")
                    .accountInfo(AccountResponse.AccountInfo.builder()
                            .accountName(String.join(" ", updatedAccount.getFirstName(), 
                                    updatedAccount.getLastName(), 
                                    updatedAccount.getOtherName() != null ? updatedAccount.getOtherName() : ""))
                            .accountNumber(updatedAccount.getAccountNumber())
                            .accountBalance(updatedAccount.getAccountBalance())
                            .build())
                    .build();

        } catch (Exception e) {
            log.error("Error updating balance: {}", e.getMessage());
            return AccountResponse.builder()
                    .responseCode("500")
                    .responseMessage("Internal server error occurred")
                    .build();
        }
    }

    private String generateAccountNumber() {
        Year currentYear = Year.now();
        int randomNumber = secureRandom.nextInt(900000) + 100000;
        return currentYear.toString() + randomNumber;
    }
}