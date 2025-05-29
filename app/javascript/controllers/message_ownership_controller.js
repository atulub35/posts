import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message", "deleteButton"]
  static values = {
    currentUserId: String
  }

  connect() {
    // Get the current user ID from the data attribute
    const currentUserId = document.getElementById("messages_container").dataset.currentUserId
    if (currentUserId) {
      this.currentUserIdValue = currentUserId
    }
    
    this.checkMessageOwnership()
  }

  messageTargetConnected(element) {
    this.checkMessageOwnership()
  }

  checkMessageOwnership() {
    if (!this.currentUserIdValue) return
    
    this.messageTargets.forEach(message => {
      const messageUserId = message.dataset.userId
      const deleteButtons = message.querySelectorAll('.btn-delete-message')
      
      // If this message belongs to the current user, show the delete button
      if (messageUserId === this.currentUserIdValue) {
        deleteButtons.forEach(button => button.classList.remove('d-none'))
      } else {
        deleteButtons.forEach(button => button.classList.add('d-none'))
      }
    })
  }
} 