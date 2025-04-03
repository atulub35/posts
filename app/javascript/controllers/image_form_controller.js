import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["prompt", "referenceImage", "submitButton", "loadingIndicator"]

  connect() {
    // Initialize any necessary setup
    console.log('Image form controller connected');
    
  }

  usePrompt(event) {
    const prompt = event.currentTarget.dataset.prompt
    this.promptTarget.value = prompt
  }

  submit(event) {
    // Prevent default form submission
    event.preventDefault()
    this.element.requestSubmit()
    
    // Disable submit button and show loading indicator
    this.submitButtonTarget.disabled = true
    this.loadingIndicatorTarget.style.display = "block"
    
    // Submit the form using Turbo

  }
} 