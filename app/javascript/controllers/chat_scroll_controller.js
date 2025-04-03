import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.scrollToBottom()
  }

  scrollToBottom() {
    // Add a small delay to ensure content is loaded
    setTimeout(() => {
      this.containerTarget.scrollTo({
        top: this.containerTarget.scrollHeight,
        behavior: "smooth"
      })
    }, 100)
  }

  // Called when new messages are added via Turbo
  messageReceived() {
    this.scrollToBottom()
  }
} 