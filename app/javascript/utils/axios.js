import axios from 'axios';

// CSRFトークンを動的に設定する関数
const setCSRFToken = () => {
  const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
  if (token) {
    axios.defaults.headers.common['X-CSRF-Token'] = token;
  }
};

// 初回設定
setCSRFToken();

// Turboナビゲーション後にも再設定
document.addEventListener('turbo:load', setCSRFToken);

export default axios;
