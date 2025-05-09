import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "message"]

  connect() {
    // Initial scroll when the chat loads
    this.scrollToBottom()
  }

  // Called when a new message element is added to the DOM
  // This is the most reliable way to detect new messages
  messageTargetConnected(element) {
    console.log("New message connected:", element)
    this.scrollToBottom()
  }

  // Fallback for form submissions
  messageReceived() {
    this.scrollToBottom()
  }

  scrollToBottom() {
    // First immediate scroll - helps in some scenarios
    if (this.containerTarget) {
      this.containerTarget.scrollTop = this.containerTarget.scrollHeight;
    }
    
    // Then add a series of delayed scrolls to catch all scenarios
    // This approach ensures that at least one of these will work
    [0, 50, 200].forEach(delay => {
      setTimeout(() => {
        if (this.containerTarget) {
          this.containerTarget.scrollTo({
            top: this.containerTarget.scrollHeight,
            behavior: delay > 100 ? "smooth" : "auto" // First scrolls are instant for reliability
          });
        }
      }, delay);
    });
  }
} 