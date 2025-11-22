import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    labels: Array,
    moods: Array,
    conditions: Array,
    moonEvents: Array
  }

  connect() {
    const Chart = window.Chart
    const annotationPlugin = window["chartjs-plugin-annotation"]

    if (!Chart) {
      console.warn("Chart.js failed to load")
      return
    }

    if (annotationPlugin) {
      const pluginModule = annotationPlugin.default || annotationPlugin
      if (!Chart.registry.plugins.get("annotation")) {
        Chart.register(pluginModule)
      }
    } else {
      console.warn("Chart.js annotation plugin failed to load")
    }

    const ctx = this.element.getContext("2d")

    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        labels: this.labelsValue,
        datasets: [
          {
            label: "体調",
            data: this.conditionsValue,
            borderColor: "#F9DECD",
            borderWidth: 3,
            tension: 0.4,
            pointRadius: 0,
            spanGaps: true
          },
          {
            label: "気分",
            data: this.moodsValue,
            borderColor: "#AF8DB0",
            borderWidth: 2,
            tension: 0.4,
            pointRadius: 0,
            spanGaps: true
          }
        ]
      },
      options: {
        plugins: {
          legend: { display: false },
          annotation: {
            annotations: this.buildMoonAnnotations()
          }
        },
        scales: {
          x: {
            grid: { display: false },
            ticks: { color: "#F9DECD" }
          },
          y: {
            min: 0,
            max: 5,
            ticks: { color: "#F9DECD" },
            grid: { color: "rgba(249,222,205,0.2)" }
          }
        }
      }
    })
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }

  buildMoonAnnotations() {
    return this.moonEventsValue.reduce((acc, event, idx) => {
      const color = event.type === "full_moon" ? "#ffd700" : "#87cefa"

      acc[`moon-${idx}`] = {
        type: "line",
        xMin: event.date,
        xMax: event.date,
        borderColor: color,
        borderWidth: 1.5,
        label: {
          display: true,
          content: event.emoji,
          position: "start",
          color: "#F9DECD",
          backgroundColor: "transparent",
          font: { size: 14 }
        }
      }
      return acc
    }, {})
  }
}
