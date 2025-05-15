import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    console.log("Avatar preview controller connected")
  }

  previewAvatar(event) {
    const input = event.target
    if (input.files && input.files[0]) {
      const reader = new FileReader()
      
      reader.onload = (e) => {
        const preview = this.element.querySelector('img')
        const placeholderDiv = this.element.querySelector('.rounded-circle.bg-primary')
        
        if (preview) {
          // Update existing preview image
          preview.src = e.target.result
        } else if (placeholderDiv) {
          // Replace placeholder with a real image
          const img = document.createElement('img')
          img.src = e.target.result
          img.className = 'rounded-circle'
          img.style = 'width: 100px; height: 100px; object-fit: cover;'
          
          placeholderDiv.parentNode.replaceChild(img, placeholderDiv)
        }
      }
      
      reader.readAsDataURL(input.files[0])
    }
  }
} 