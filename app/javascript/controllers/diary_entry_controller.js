import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "healthInput", "healthEmoji",
    "moodInput", "moodEmoji",
    "moreFields", "moreButton",
    "memoArea", "memoButton"
  ]

  selectHealth(event) {
    const value = event.currentTarget.dataset.value
    this.healthInputTarget.value = value

    const emojiList = ["😰", "😔", "😐", "😊", "🥰"]
    this.healthEmojiTarget.textContent = emojiList[value - 1]

    this.activateButton(event.currentTarget, "health")
  }

  selectMood(event) {
    const value = event.currentTarget.dataset.value
    this.moodInputTarget.value = value

    const emojiList = ["😰", "😔", "😐", "😊", "🥰"]
    this.moodEmojiTarget.textContent = emojiList[value - 1]

    this.activateButton(event.currentTarget, "mood")
  }

  toggleMore() {
    this.moreFieldsTarget.classList.toggle("hidden")
    this.moreButtonTarget.textContent =
      this.moreFieldsTarget.classList.contains("hidden")
        ? "もっと書く ↓"
        : "閉じる ↑"
  }

  toggleMemo() {
    this.memoAreaTarget.classList.toggle("hidden")
  }

  activateButton(button, group) {
    const parent = this.element.querySelector(`[data-group="${group}"]`)
    const buttons = parent.querySelectorAll(`[data-group="${group}"]`)
    buttons.forEach(btn => btn.classList.remove("active"))
    button.classList.add("active")
  }
}
