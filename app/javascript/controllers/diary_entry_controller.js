import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "healthInput", "healthEmoji",
    "moodInput", "moodEmoji"
  ]

  connect() {
    const healthValue = this.healthInputTarget.value
    if (healthValue) {
      this.setHealth(parseInt(healthValue))
    }

    const moodValue = this.moodInputTarget.value
    if (moodValue) {
      this.setMood(parseInt(moodValue))
    }
  }

  selectHealth(event) {
    const value = parseInt(event.currentTarget.dataset.value)
    this.setHealth(value)
  }

  selectMood(event) {
    const value = parseInt(event.currentTarget.dataset.value)
    this.setMood(value)
  }

  setHealth(value) {
    this.healthInputTarget.value = value

    const emojiList = ["😰", "😔", "😐", "😊", "🥰"]
    this.healthEmojiTarget.textContent = emojiList[value - 1]

    const button = this.element.querySelector(
      `[data-group="health"] [data-value="${value}"]`
    )
    if (button) {
      this.activateButton(button, "health")
    }
  }

  setMood(value) {
    this.moodInputTarget.value = value

    const emojiList = ["😰", "😔", "😐", "😊", "🥰"]
    this.moodEmojiTarget.textContent = emojiList[value - 1]

    const button = this.element.querySelector(
      `[data-group="mood"] [data-value="${value}"]`
    )
    if (button) {
      this.activateButton(button, "mood")
    }
  }

  activateButton(button, group) {
    const parent = this.element.querySelector(`[data-group="${group}"]`)
    if (parent) {
      const buttons = parent.querySelectorAll(`[data-value]`)
      buttons.forEach(btn => btn.classList.remove("active"))
    }
    button.classList.add("active")
  }
}
