package com.gabriel.java_bank_app.util;

import java.time.Year;

public class AccountUtils {
    public static final String ACCOUNT_EXISTS_CODE = "001";
    public static final String ACCOUNT_EXISTS_MESSAGE = "The user already has an account created";

    public static final String ACCOUNT_SUCCESS_CODE = "100";
    public static final String ACCOUNT_SUCCESS_MESSAGE = "Your Account was Successfully Created";


    public static String generateAccountNumber() {
        /*
        To generate an acct number i want to use 10 digits number
        First i will use the current year the account was created, to add with the number
        Second i will give it a range value, min and max
        eg. 2024 + randomSixDigits
         */
        Year currentYear = Year.now();

        int min = 100000;
        int max = 999999;

        int randomNumber = (int) Math.floor(Math.random() * (max - min + 1) + min);

        /*
        concatenate currentYear and randomNumber,to give you a String format
         */

        String year = String.valueOf(currentYear);
        String randomValues = String.valueOf(randomNumber);
//        System.out.println(year + randomValues);

        StringBuffer accountNumber = new StringBuffer();
        accountNumber.append(year).append(randomValues);
        System.out.println(accountNumber.toString());


        return String.valueOf(accountNumber);
    };
}
