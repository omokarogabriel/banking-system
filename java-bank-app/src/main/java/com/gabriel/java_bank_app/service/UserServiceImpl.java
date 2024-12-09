package com.gabriel.java_bank_app.service;

import com.gabriel.java_bank_app.dto.AccountInfo;
import com.gabriel.java_bank_app.dto.BankResponse;
import com.gabriel.java_bank_app.dto.UserRequest;
import com.gabriel.java_bank_app.entity.User;
import com.gabriel.java_bank_app.repository.UserRepository;
import com.gabriel.java_bank_app.util.AccountUtils;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

@Service
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;

    public UserServiceImpl(UserRepository userRepository) {
        this.userRepository = userRepository;
    }


    @Override
    public BankResponse createAccount(UserRequest userRequest) {
        /*
        this means you want to create an account, and save it's profile to the database
        i also want to check if the user already has an account
         */
        if (userRepository.existByEmail(userRequest.getEmail())) {
             BankResponse.builder()
                    .responseCode(AccountUtils.ACCOUNT_EXISTS_CODE)
                    .responseMessage(AccountUtils.ACCOUNT_EXISTS_MESSAGE)
                     .accountInfo(null)
                    .build();
             }
        /*
        This is the object creation
         */

        User newUser = User.builder()
                .firstName(userRequest.getFirstName())
                .lastName(userRequest.getLastName())
                .otherName(userRequest.getOtherName())
                .gender(userRequest.getGender())
                .address(userRequest.getAddress())
                .stateOfOrigin(userRequest.getStateOfOrigin())
                .accountNumber(AccountUtils.generateAccountNumber())
                .accountBalance(BigDecimal.ZERO)
                .email(userRequest.getEmail())
                .phoneNumber(userRequest.getPhoneNumber())
                .alternativePhoneNumber(userRequest.getAlternativePhoneNumber())
                .status("ACTIVE")
                .build();

        User savedUser = userRepository.save(newUser);

        /*
        This is the Response Code for a Successful Account Created
         */


        return BankResponse.builder()
                .responseCode(AccountUtils.ACCOUNT_SUCCESS_CODE)
                .responseMessage(AccountUtils.ACCOUNT_SUCCESS_MESSAGE)
                .accountInfo(AccountInfo.builder()
                        .accountName(savedUser.getFirstName() + " " +
                                savedUser.getLastName() + " " +
                                savedUser.getOtherName())
                        .accountBalance(savedUser.getAccountBalance())
                        .getAccountNumber(savedUser.getAccountNumber())
                        .build())
                .build();
    }
}
