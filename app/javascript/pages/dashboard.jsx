import React from "react"
import { createRoot } from "react-dom/client"
import Dashboard from "../components/dashboard/Dashboard.jsx"

const renderDashboard = () => {
  const rootElement = document.getElementById("dashboard-react-root")

  if (!rootElement) return

  if (rootElement.dataset.reactMounted === "true") return

  rootElement.dataset.reactMounted = "true"

  const data = window.dashboardData || {}
  const root = createRoot(rootElement)
  root.render(<Dashboard {...data} />)
}

document.addEventListener("turbo:load", renderDashboard)
document.addEventListener("DOMContentLoaded", renderDashboard)
