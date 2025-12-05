// Turbo
import "@hotwired/turbo-rails"

// Stimulus
import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

// React
import React from "react"
import { createRoot } from "react-dom/client"
import App from "./components/App"

document.addEventListener("DOMContentLoaded", () => {
  const rootElement = document.getElementById("react-root")
  if (rootElement) {
    const root = createRoot(rootElement)
    root.render(<App />)
  }
})

const application = Application.start()
const context = require.context("controllers", true, /\.js$/)
application.load(definitionsFromContext(context))
window.Stimulus = application

