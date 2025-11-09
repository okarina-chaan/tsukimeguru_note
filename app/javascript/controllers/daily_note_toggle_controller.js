import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="daily-note-toggle"
export default class extends Controller {
  static targets = ["details", "button"]

  toggle() {
    this.detailsTarget.classList.toggle("hidden")

    if (this.detailsTarget.classList.contains("hidden")) {
      this.buttonTarget.textContent = "詳細を見る ↓"
    } else {
      this.buttonTarget.textContent = "閉じる ↑"
    }
  }
}
