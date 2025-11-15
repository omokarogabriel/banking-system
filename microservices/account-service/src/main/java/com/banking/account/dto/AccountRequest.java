package com.banking.account.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class AccountRequest {
    @NotBlank(message = "First name is required")
    @Size(min = 2, max = 50)
    private String firstName;

    @NotBlank(message = "Last name is required")
    @Size(min = 2, max = 50)
    private String lastName;

    private String otherName;

    @NotBlank(message = "Gender is required")
    private String gender;

    @NotBlank(message = "Address is required")
    private String address;

    private String stateOfOrigin;

    @Email(message = "Invalid email format")
    @NotBlank(message = "Email is required")
    private String email;

    @Pattern(regexp = "^(\\+?[1-9]\\d{1,14}|0\\d{10})$", message = "Invalid phone number format")
    private String phoneNumber;

    private String alternativePhoneNumber;
}