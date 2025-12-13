import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay"]

  connect() {
    this.hide()
    this._onBeforeFetch = () => this.show()
    this._onReady = () => this.hide()
    this._onLoading = () => this.show()

    document.addEventListener(
      "turbo:before-fetch-request",
      this._onBeforeFetch
    )
    window.addEventListener("page:loading", this._onLoading)
    window.addEventListener("page:ready", this._onReady)
  }

  disconnect() {
    document.removeEventListener(
      "turbo:before-fetch-request",
      this._onBeforeFetch
    )
    window.removeEventListener("page:ready", this._onReady)
  }

  show() {
    this.overlayTarget.classList.remove("hidden")
    this.overlayTarget.classList.remove("opacity-0")
    this.overlayTarget.classList.add("opacity-100")
  }

  hide() {
    this.overlayTarget.classList.add("opacity-0")

    setTimeout(() => {
      this.overlayTarget.classList.add("hidden")
    }, 300)
  }
}
