import React, { useState } from 'react';
import { bankingAPI } from '../services/api';

const Transfer = () => {
  const [formData, setFormData] = useState({
    sourceAccountNumber: '',
    destinationAccountNumber: '',
    amount: '',
    description: ''
  });
  const [response, setResponse] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const transferData = {
        sourceAccountNumber: formData.sourceAccountNumber,
        destinationAccountNumber: formData.destinationAccountNumber,
        amount: parseFloat(formData.amount),
        description: formData.description
      };
      
      const result = await bankingAPI.transfer(transferData);
      setResponse(result.data);
    } catch (error) {
      setResponse({ responseMessage: 'Error processing transfer' });
    }
  };

  return (
    <div className="form-container">
      <h2>Transfer Money</h2>
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          placeholder="From Account Number"
          value={formData.sourceAccountNumber}
          onChange={(e) => setFormData({...formData, sourceAccountNumber: e.target.value})}
          required
        />
        <input
          type="text"
          placeholder="To Account Number"
          value={formData.destinationAccountNumber}
          onChange={(e) => setFormData({...formData, destinationAccountNumber: e.target.value})}
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
        <input
          type="text"
          placeholder="Description (optional)"
          value={formData.description}
          onChange={(e) => setFormData({...formData, description: e.target.value})}
        />
        <button type="submit">Transfer</button>
      </form>
      {response && (
        <div className="response">
          <p>{response.responseMessage}</p>
          {response.transactionInfo && (
            <div>
              <p>Transaction Reference: {response.transactionInfo.transactionReference}</p>
              <p>Amount: ${response.transactionInfo.amount}</p>
              <p>Status: {response.transactionInfo.status}</p>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default Transfer;