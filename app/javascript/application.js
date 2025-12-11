// Turbo
import "@hotwired/turbo-rails"

// Stimulus
import "./controllers"

import "./pages/dashboard"

// React初期化をTurboに対応させる
document.addEventListener("turbo:load", () => {
  const root = document.getElementById("dashboard-root");
  if (root) {
    const { createRoot } = require("react-dom/client");
    const Dashboard = require("./pages/dashboard").default;
    createRoot(root).render(<Dashboard />);
  }
});

