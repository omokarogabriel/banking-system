import React, { useState } from 'react';
import { bankingAPI } from '../services/api';

const Transaction = ({ type }) => {
  const [formData, setFormData] = useState({
    accountNumber: '',
    amount: ''
  });
  const [response, setResponse] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const transactionData = {
        accountNumber: formData.accountNumber,
        amount: parseFloat(formData.amount)
      };
      
      const result = type === 'deposit' 
        ? await bankingAPI.deposit(transactionData)
        : await bankingAPI.withdraw(transactionData);
      
      setResponse(result.data);
    } catch (error) {
      setResponse({ responseMessage: `Error processing ${type}` });
    }
  };

  return (
    <div className="form-container">
      <h2>{type === 'deposit' ? 'Deposit' : 'Withdraw'}</h2>
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          placeholder="Account Number"
          value={formData.accountNumber}
          onChange={(e) => setFormData({...formData, accountNumber: e.target.value})}
          required
        />
        <input
          type="number"
          step="0.01"
          placeholder="Amount"
          value={formData.amount}
          onChange={(e) => setFormData({...formData, amount: e.target.value})}
          required
        />
        <button type="submit">{type === 'deposit' ? 'Deposit' : 'Withdraw'}</button>
      </form>
      {response && (
        <div className="response">
          <p>{response.responseMessage}</p>
          {response.accountInfo && (
            <p>New Balance: ${response.accountInfo.accountBalance}</p>
          )}
        </div>
      )}
    </div>
  );
};

export default Transaction;