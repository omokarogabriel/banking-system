import axios from 'axios';

// Use the same host as the webapp but port 8080 for API
const API_BASE_URL = `http://${window.location.hostname}:8080/api`;

const accountAPI = axios.create({
  baseURL: `${API_BASE_URL}/accounts`,
  headers: {
    'Content-Type': 'application/json',
  },
});

const transactionAPI = axios.create({
  baseURL: `${API_BASE_URL}/transactions`,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const bankingAPI = {
  // Account operations
  createAccount: (userData) => {
    console.log('API Base URL:', API_BASE_URL);
    console.log('Calling:', `${API_BASE_URL}/accounts`);
    return accountAPI.post('', userData);
  },
  getAccount: (accountNumber) => accountAPI.get(`/${accountNumber}`),
  
  // Transaction operations
  transfer: (transferData) => transactionAPI.post('/transfer', transferData),
  getTransactionHistory: (accountNumber, page = 0, size = 10) => 
    transactionAPI.get(`/history/${accountNumber}?page=${page}&size=${size}`),
};