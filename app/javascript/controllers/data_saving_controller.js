import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = []

  connect() {
    // Check if user has a preference saved
    const savedPreference = localStorage.getItem('dataSavingMode')
    
    if (savedPreference === 'true') {
      this.element.checked = true
      document.documentElement.setAttribute('data-saving-mode', 'true')
    }
  }

  toggle() {
    const isEnabled = this.element.checked
    
    // Save the preference
    localStorage.setItem('dataSavingMode', isEnabled)
    
    // Apply the preference immediately
    if (isEnabled) {
      document.documentElement.setAttribute('data-saving-mode', 'true')
    } else {
      document.documentElement.removeAttribute('data-saving-mode')
    }
    
    // Notify all s3-image controllers about the change
    const event = new CustomEvent('data-saving-changed', { 
      detail: { enabled: isEnabled } 
    })
    document.dispatchEvent(event)
  }
} 