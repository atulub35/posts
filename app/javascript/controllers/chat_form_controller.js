import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "input", "messages"]
  static values = {
    userId: Number
  }

  connect() {
    // Initialize any necessary setup
  }

  submit(event) {
    event.preventDefault()
    
    const message = this.inputTarget.value.trim()
    if (!message) return

    // Create and append user message immediately
    const userMessageHtml = this.createMessageHtml(message, "user")
    this.messagesTarget.insertAdjacentHTML("beforeend", userMessageHtml)
    
    // Clear input
    
    // Submit the form
    this.formTarget.requestSubmit()
    this.inputTarget.value = ""
  }

  createMessageHtml(content, role) {
    console.log("createMessageHtml", content, role);
    
    const time = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true })
    return `
      <div class="message-wrapper ${role}">
        <div class="message-bubble ${role === 'user' ? 'user-message' : 'ai-message'}">
          <div class="message-content">
            ${content}
          </div>
          <div class="message-meta d-flex justify-content-between align-items-center mt-2">
            <div class="message-role">
              ${role === 'user' ? 
                '<i class="bx bx-user-circle"></i>You' : 
                '<i class="bx bx-bot"></i>AI Assistant'
              }
            </div>
            <div class="message-time">
              ${time}
            </div>
          </div>
        </div>
      </div>
    `
  }
} 