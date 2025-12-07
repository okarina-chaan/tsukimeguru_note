import React from "react"
import { createRoot } from "react-dom/client"
import Dashboard from "../components/dashboard/Dashboard.jsx"

document.addEventListener("DOMContentLoaded", () => {
  const rootElement = document.getElementById("dashboard-react-root")

  if (rootElement) {
    const data = window.dashboardData || {}

    const root = createRoot(rootElement)
    root.render(<Dashboard {...data} />)
  }
})
