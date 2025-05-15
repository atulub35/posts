import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "statusField"]
  static values = {
    conversationId: Number,
    otherUserId: Number
  }

  connect() {
    console.log("User presence controller connected")
    
    if (!this.hasFormTarget) {
      console.error("Missing form target in user_presence_controller")
      return
    }
    
    if (!this.hasStatusFieldTarget) {
      console.error("Missing statusField target in user_presence_controller")
      return
    }
    
    console.log("Form action:", this.formTarget.action)
    
    // Set up visibility change listener for tab switching
    document.addEventListener('visibilitychange', this.handleVisibilityChange.bind(this))
    
    // Set up unload listener for page navigation
    window.addEventListener('beforeunload', this.handleUnload.bind(this))
    
    // Update presence immediately on connect - with slight delay to ensure DOM is ready
    setTimeout(() => {
      this.updateStatus('online')
    }, 100)
  }
  
  disconnect() {
    // Remove event listeners
    document.removeEventListener('visibilitychange', this.handleVisibilityChange.bind(this))
    window.removeEventListener('beforeunload', this.handleUnload.bind(this))
    
    // Update status to offline when controller disconnects
    this.updateStatus('offline')
  }
  
  handleVisibilityChange() {
    if (document.visibilityState === 'visible') {
      // User has returned to the tab, publish online status
      this.updateStatus('online')
    } else {
      // User has left the tab, publish away status
      this.updateStatus('away')
    }
  }
  
  handleUnload(event) {
    // For page unload, use the more reliable sendBeacon API
    if (navigator.sendBeacon && this.hasFormTarget) {
      // Set status to offline
      this.statusFieldTarget.value = 'offline'
      
      // Use sendBeacon to reliably send the form data during page unload
      navigator.sendBeacon(this.formTarget.action, new FormData(this.formTarget))
    }
  }
  
  updateStatus(status) {
    // Update the hidden status field
    if (this.hasStatusFieldTarget) {
      this.statusFieldTarget.value = status
      console.log(`Setting status to: ${status}`)
    } else {
      console.error("Can't update status - missing statusField target")
      return
    }
    
    // Submit the form
    if (this.hasFormTarget) {
      try {
        console.log(`Submitting form with status: ${status}`)
        
        // Use fetch for more reliable submission
        const formData = new FormData(this.formTarget)
        fetch(this.formTarget.action, {
          method: 'POST',
          body: formData,
          headers: {
            'Accept': 'text/vnd.turbo-stream.html'
          }
        }).then(response => {
          if (response.ok) {
            console.log('Status updated successfully')
          } else {
            console.error(`Status update failed with status: ${response.status}`)
          }
        }).catch(error => {
          console.error('Error updating status:', error)
        })
      } catch (error) {
        console.error("Error submitting form:", error)
      }
    } else {
      console.error("Can't submit form - missing form target")
    }
  }
} 