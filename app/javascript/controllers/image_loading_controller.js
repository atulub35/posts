import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.loadDirectImageUrl();
  }
  
  loadDirectImageUrl() {
    const messageId = this.element.dataset.messageId;
    if (!messageId) return;
    
    // Try to load the direct URL for better performance
    fetch(`/messages/${messageId}`, {
      headers: {
        'Accept': 'application/json'
      }
    })
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        return response.json();
      })
      .then(data => {
        if (data.direct_url) {
          console.log('Using direct S3 URL for image:', messageId);
          this.element.src = data.direct_url;
        }
      })
      .catch(error => {
        console.error('Error loading direct image URL:', error);
        // Keep using the default URL if there's an error
      });
  }
} 