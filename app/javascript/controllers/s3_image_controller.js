import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "placeholder"]
  static values = {
    messageId: String,
    dataSaving: { type: Boolean, default: false }
  }

  connect() {
    // Add classes for styling
    this.element.classList.add('s3-image-container')
    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.classList.add('s3-image-placeholder')
    }
    
    // Check global data-saving preference
    this.checkDataSavingPreference()
    
    // Listen for changes to data-saving preferences
    document.addEventListener('data-saving-changed', this.handleDataSavingChange.bind(this))
    
    // Use Intersection Observer to load the image only when it's in the viewport
    this.setupIntersectionObserver()
  }

  disconnect() {
    // Disconnect the observer when the controller disconnects
    if (this.observer) {
      this.observer.disconnect()
      this.observer = null
    }
    
    // Clean up event listeners
    document.removeEventListener('data-saving-changed', this.handleDataSavingChange.bind(this))
  }
  
  handleDataSavingChange(event) {
    this.dataSavingValue = event.detail.enabled
    
    // Reset and reinitialize the observer with new settings
    if (this.observer) {
      this.observer.disconnect()
      this.observer = null
      this.setupIntersectionObserver()
    }
  }
  
  checkDataSavingPreference() {
    // Check if data-saving mode is enabled globally
    const htmlElement = document.documentElement
    if (htmlElement.hasAttribute('data-saving-mode')) {
      this.dataSavingValue = true
    } else {
      // Also check localStorage directly
      const savedPreference = localStorage.getItem('dataSavingMode')
      if (savedPreference === 'true') {
        this.dataSavingValue = true
      }
    }
  }

  setupIntersectionObserver() {
    if (!this.hasMessageIdValue) {
      console.error("No message ID provided for s3-image controller")
      this.showError("Error: Missing message ID")
      return
    }

    // Create an observer instance with different rootMargin based on data-saving mode
    const rootMargin = this.dataSavingValue ? '0px' : '200px'
    
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        // If the element is in the viewport
        if (entry.isIntersecting) {
          // In data-saving mode, we need to check if user wants to load the image
          if (this.dataSavingValue) {
            this.showLoadPrompt()
          } else {
            // Load the image automatically
            this.loadImage()
          }
          
          // Stop observing after action is taken
          this.observer.disconnect()
          this.observer = null
        }
      })
    }, {
      root: null, // Use the viewport as the root
      rootMargin: rootMargin, // Preload margin depends on data-saving mode
      threshold: 0.1 // Trigger when 10% of the target is visible
    })

    // Start observing the element
    this.observer.observe(this.element)
  }

  showLoadPrompt() {
    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.innerHTML = `
        <div class="text-center p-3">
          <small class="d-block mb-2">Tap to load image</small>
          <button class="btn btn-sm btn-outline-primary" data-action="s3-image#loadImage">
            <i class="bx bx-image me-1"></i> Load image
          </button>
        </div>
      `
    }
  }

  loadImage() {
    const messageId = this.messageIdValue
    
    if (!messageId) {
      console.error("No message ID available")
      this.showError("Error: Unable to load image")
      return
    }

    // Show loading state
    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.innerHTML = `
        <div class="d-flex flex-column align-items-center justify-content-center p-3">
          <div class="spinner-border text-primary mb-2"></div>
          <small class="text-muted">Loading image...</small>
        </div>
      `
    }

    fetch(`/api/presigned_url/${messageId}`)
      .then(response => {
        if (!response.ok) {
          throw new Error(`HTTP error! Status: ${response.status}`)
        }
        return response.json()
      })
      .then(data => {
        if (!data.url) {
          throw new Error("No URL in response")
        }
        
        const img = document.createElement('img')
        img.src = data.url
        img.alt = data.filename || "Message attachment"
        img.className = "img-fluid rounded"
        img.style.maxWidth = "100%"
        img.loading = "lazy"
        
        // Add click event to open full image in new tab
        img.addEventListener('click', () => {
          window.open(data.url, '_blank')
        })
        img.style.cursor = 'pointer'
        
        // Replace placeholder with image
        if (this.hasPlaceholderTarget) {
          this.placeholderTarget.replaceWith(img)
        } else if (this.hasContainerTarget) {
          this.containerTarget.innerHTML = ''
          this.containerTarget.appendChild(img)
        }
      })
      .catch(error => {
        console.error("Error fetching image:", error)
        this.showError("Error loading image")
      })
  }
  
  showError(message) {
    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.innerHTML = `
        <div class="alert alert-warning">
          <i class="bx bx-error-circle me-2"></i>
          ${message}
        </div>
      `
    }
  }
} 