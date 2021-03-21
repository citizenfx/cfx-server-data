import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';
import { ScoreboardProvider } from "./context/ScoreboardContext";

ReactDOM.render(
  <React.StrictMode>
    <ScoreboardProvider>
      <App />
    </ScoreboardProvider>
  </React.StrictMode>,
  document.getElementById('root')
);
