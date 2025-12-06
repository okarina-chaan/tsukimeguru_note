import { createRoot } from "react-dom/client"
import Dashboard from "../components/dashboard/Dashboard.jsx"

const rootElement = document.getElementById("dashboard-react-root")

if (rootElement) {
  const root = createRoot(rootElement)

  const data = window.dashboardData || {}

  root.render(
    <Dashboard
      today={data.today}
      moonPhase={data.moonPhase}
    />
  )
}

