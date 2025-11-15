import React, { useState } from 'react';
import { bankingAPI } from '../services/api';

const CreateAccount = () => {
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    email: '',
    phoneNumber: '',
    address: '',
    gender: '',
    stateOfOrigin: ''
  });
  const [response, setResponse] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const result = await bankingAPI.createAccount(formData);
      setResponse(result.data);
    } catch (error) {
      console.error('Account creation error:', error);
      let errorMsg = 'Error creating account';
      if (error.response?.data?.responseMessage) {
        errorMsg = error.response.data.responseMessage;
      } else if (error.response?.status === 400) {
        errorMsg = 'Validation failed. Please check phone number format (+1234567890 or 08130262842) and ensure email is unique.';
      } else if (error.message) {
        errorMsg = error.message;
      }
      setResponse({ responseMessage: errorMsg });
    }
  };

  return (
    <div className="form-container">
      <h2>Create Account</h2>
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          placeholder="First Name"
          value={formData.firstName}
          onChange={(e) => setFormData({...formData, firstName: e.target.value})}
          required
        />
        <input
          type="text"
          placeholder="Last Name"
          value={formData.lastName}
          onChange={(e) => setFormData({...formData, lastName: e.target.value})}
          required
        />
        <input
          type="email"
          placeholder="Email"
          value={formData.email}
          onChange={(e) => setFormData({...formData, email: e.target.value})}
          required
        />
        <input
          type="tel"
          placeholder="Phone Number (e.g., +1234567890 or 08130262842)"
          value={formData.phoneNumber}
          onChange={(e) => setFormData({...formData, phoneNumber: e.target.value})}
          pattern="^(\+?[1-9]\d{1,14}|0\d{10})$"
          title="Phone number formats: +1234567890, 1234567890, or 08130262842"
          required
        />
        <input
          type="text"
          placeholder="Address"
          value={formData.address}
          onChange={(e) => setFormData({...formData, address: e.target.value})}
          required
        />
        <select
          value={formData.gender}
          onChange={(e) => setFormData({...formData, gender: e.target.value})}
          required
        >
          <option value="">Select Gender</option>
          <option value="Male">Male</option>
          <option value="Female">Female</option>
        </select>
        <input
          type="text"
          placeholder="State of Origin"
          value={formData.stateOfOrigin}
          onChange={(e) => setFormData({...formData, stateOfOrigin: e.target.value})}
          required
        />
        <button type="submit">Create Account</button>
      </form>
      {response && (
        <div className="response">
          <p>{response.responseMessage}</p>
          {response.accountInfo && (
            <p>Account Number: {response.accountInfo.accountNumber}</p>
          )}
        </div>
      )}
    </div>
  );
};

export default CreateAccount;