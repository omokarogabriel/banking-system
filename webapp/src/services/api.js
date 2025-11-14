import axios from 'axios';

const API_BASE_URL = '/api/user';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const bankingAPI = {
  createAccount: (userData) => api.post('/', userData),
  getBalance: (accountNumber) => api.get(`/balance/${accountNumber}`),
  deposit: (transactionData) => api.post('/deposit', transactionData),
  withdraw: (transactionData) => api.post('/withdraw', transactionData),
};