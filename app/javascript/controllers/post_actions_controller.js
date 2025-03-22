import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["post"]
  static values = {
    currentUserId: Number
  }

  postTargetConnected() {
    this.checkPermissions()
  }

  checkPermissions() {
    this.postTargets.forEach(post => {
      const postUserId = parseInt(post.dataset.id)
      if (postUserId === this.currentUserIdValue) {
        post.classList.remove('d-none')
      } else {
        post.classList.add('d-none')
      }
    })
  }
} 