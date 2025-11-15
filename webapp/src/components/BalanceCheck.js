import React, { useState } from 'react';
import { bankingAPI } from '../services/api';

const BalanceCheck = () => {
  const [accountNumber, setAccountNumber] = useState('');
  const [response, setResponse] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const result = await bankingAPI.getAccount(accountNumber);
      setResponse(result.data);
    } catch (error) {
      setResponse({ responseMessage: 'Error fetching balance' });
    }
  };

  return (
    <div className="form-container">
      <h2>Check Balance</h2>
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          placeholder="Account Number"
          value={accountNumber}
          onChange={(e) => setAccountNumber(e.target.value)}
          required
        />
        <button type="submit">Check Balance</button>
      </form>
      {response && (
        <div className="response">
          <p>{response.responseMessage}</p>
          {response.accountInfo && (
            <div>
              <p>Account Holder: {response.accountInfo.accountName}</p>
              <p>Balance: ${response.accountInfo.accountBalance}</p>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default BalanceCheck;