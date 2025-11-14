import React, { useState } from 'react';
import CreateAccount from './components/CreateAccount';
import BalanceCheck from './components/BalanceCheck';
import Transaction from './components/Transaction';
import './App.css';

function App() {
  const [activeTab, setActiveTab] = useState('create');

  return (
    <div className="App">
      <header className="app-header">
        <h1>Banking System</h1>
        <nav className="nav-tabs">
          <button 
            className={activeTab === 'create' ? 'active' : ''}
            onClick={() => setActiveTab('create')}
          >
            Create Account
          </button>
          <button 
            className={activeTab === 'balance' ? 'active' : ''}
            onClick={() => setActiveTab('balance')}
          >
            Check Balance
          </button>
          <button 
            className={activeTab === 'deposit' ? 'active' : ''}
            onClick={() => setActiveTab('deposit')}
          >
            Deposit
          </button>
          <button 
            className={activeTab === 'withdraw' ? 'active' : ''}
            onClick={() => setActiveTab('withdraw')}
          >
            Withdraw
          </button>
        </nav>
      </header>
      
      <main className="main-content">
        {activeTab === 'create' && <CreateAccount />}
        {activeTab === 'balance' && <BalanceCheck />}
        {activeTab === 'deposit' && <Transaction type="deposit" />}
        {activeTab === 'withdraw' && <Transaction type="withdraw" />}
      </main>
    </div>
  );
}

export default App;