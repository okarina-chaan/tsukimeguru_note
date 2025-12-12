import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
  }

  startLoading() {
    window.dispatchEvent(new Event("page:loading"))
  }

  ready() {
    window.dispatchEvent(new Event("page:ready"))
  }
}
