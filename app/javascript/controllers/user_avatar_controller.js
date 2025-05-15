import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["placeholder"]
  static values = {
    userId: String,
    size: { type: Number, default: 48 }
  }

  connect() {
    // Only proceed if we have a user ID
    if (this.hasUserIdValue) {
      this.fetchAvatarUrl()
    } else {
      // Use initials as fallback if we have them
      if (this.element.dataset.initials) {
        this.showInitials(this.element.dataset.initials)
      } else {
        this.showDefaultAvatar()
      }
    }
  }

  fetchAvatarUrl() {
    fetch(`/api/users/${this.userIdValue}/avatar`)
      .then(response => {
        if (!response.ok) {
          throw new Error(`HTTP error! Status: ${response.status}`)
        }
        return response.json()
      })
      .then(data => {
        if (data.avatar_url) {
          this.renderAvatar(data.avatar_url)
        } else {
          // No avatar - show initials or default placeholder
          if (data.initials) {
            this.showInitials(data.initials)
          } else {
            this.showDefaultAvatar()
          }
        }
      })
      .catch(error => {
        console.error("Error fetching avatar:", error)
        this.showDefaultAvatar()
      })
  }

  renderAvatar(url) {
    const img = document.createElement('img')
    img.src = url
    img.alt = "User avatar"
    img.className = "rounded-circle"
    img.style.width = `${this.sizeValue}px`
    img.style.height = `${this.sizeValue}px`
    img.style.objectFit = "cover"
    
    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.replaceWith(img)
    } else {
      // Clear and append the image to the element
      this.element.innerHTML = ''
      this.element.appendChild(img)
    }
  }

  showInitials(initials) {
    const div = document.createElement('div')
    div.className = "rounded-circle bg-primary text-white d-flex align-items-center justify-content-center"
    div.style.width = `${this.sizeValue}px`
    div.style.height = `${this.sizeValue}px`
    div.style.fontSize = `${this.sizeValue / 2.5}px`
    div.textContent = initials.substring(0, 1).toUpperCase()
    
    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.replaceWith(div)
    } else {
      this.element.innerHTML = ''
      this.element.appendChild(div)
    }
  }

  showDefaultAvatar() {
    const div = document.createElement('div')
    div.className = "rounded-circle bg-secondary d-flex align-items-center justify-content-center"
    div.style.width = `${this.sizeValue}px`
    div.style.height = `${this.sizeValue}px`
    
    const icon = document.createElement('i')
    icon.className = "bx bx-user text-white"
    icon.style.fontSize = `${this.sizeValue / 1.5}px`
    
    div.appendChild(icon)
    
    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.replaceWith(div)
    } else {
      this.element.innerHTML = ''
      this.element.appendChild(div)
    }
  }
} 