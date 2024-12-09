package com.gabriel.java_bank_app.service;

import com.gabriel.java_bank_app.dto.BankResponse;
import com.gabriel.java_bank_app.dto.UserRequest;

public interface UserService {
   BankResponse createAccount(UserRequest userRequest);
}
