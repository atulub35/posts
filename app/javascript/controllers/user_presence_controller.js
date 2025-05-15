import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "statusField"]
  static values = {
    conversationId: Number,
    otherUserId: Number
  }

  connect() {
    console.log("User presence controller connected")
    
    // Set up visibility change listener for tab switching
    document.addEventListener('visibilitychange', this.handleVisibilityChange.bind(this))
    
    // Set up unload listener for page navigation
    window.addEventListener('beforeunload', this.handleUnload.bind(this))
    
    // Update presence immediately on connect
    this.updateStatus('online')
  }
  
  disconnect() {
    // Remove event listeners
    document.removeEventListener('visibilitychange', this.handleVisibilityChange.bind(this))
    window.removeEventListener('beforeunload', this.handleUnload.bind(this))
    
    // Update status to offline when controller disconnects
    // Using direct approach instead of updateStatus since controller is disconnecting
    this.sendStatusUpdate('offline')
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
    this.sendStatusUpdate('offline')
  }
  
  sendStatusUpdate(status) {
    if (this.hasFormTarget && this.hasStatusFieldTarget) {
      // Set status field value
      this.statusFieldTarget.value = status
      
      // Use sendBeacon to reliably send the form data during page unload/disconnect
      const formData = new FormData(this.formTarget)
      navigator.sendBeacon(this.formTarget.action, formData)
    }
  }
  
  updateStatus(status) {
    // Update the hidden status field
    if (this.hasStatusFieldTarget) {
      this.statusFieldTarget.value = status
    }
    
    // Submit the form
    if (this.hasFormTarget) {
      this.formTarget.requestSubmit()
    }
  }
} 