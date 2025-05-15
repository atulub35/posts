import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "message"]
  static values = { currentUserId: String }

  connect() {
    // Initial scroll when the chat loads
    this.scrollToBottom()
    
    // Get the current user ID from the parent element if available
    if (!this.hasCurrentUserIdValue && this.element.dataset.currentUserId) {
      this.currentUserIdValue = this.element.dataset.currentUserId
    }
    
    console.log("Connected with current user ID:", this.currentUserIdValue)
    
    // Process any existing messages
    if (this.hasMessageTargets) {
      this.messageTargets.forEach(message => this.processMessageStyles(message))
    }
    
    // Listen for turbo stream events
    document.addEventListener('turbo:before-stream-render', this.handleStreamRender.bind(this))
  }

  disconnect() {
    document.removeEventListener('turbo:before-stream-render', this.handleStreamRender.bind(this))
  }

  handleStreamRender(event) {
    // Only process if we have a current user ID and this is a messages container
    if (!this.currentUserIdValue) return
    
    if (event.target.getAttribute('target') === 'messages_container') {
      // Get the HTML template from the stream
      const templateElement = event.detail.newStream.templateElement
      if (templateElement) {
        const newMessageElement = templateElement.content.querySelector('[data-user-id]')
        if (newMessageElement) {
          console.log("Processing new message from stream:", newMessageElement)
          
          // Check if this message is from the current user
          const messageUserId = newMessageElement.dataset.userId
          console.log("Message user ID:", messageUserId, "Current user ID:", this.currentUserIdValue)
          
          if (messageUserId === this.currentUserIdValue) {
            console.log("This is the current user's message")
            
            // Update classes to show this is the current user's message
            newMessageElement.classList.add('user')
            
            const bubbleElement = newMessageElement.querySelector('.message-bubble')
            if (bubbleElement) {
              bubbleElement.classList.add('user-message')
            }
            
            // Update the role text
            const roleElement = newMessageElement.querySelector('.message-role')
            if (roleElement) {
              roleElement.innerHTML = '<i class="bx bx-user-circle"></i> You'
            }
          } else {
            console.log("This is NOT the current user's message")
            // Make sure we mark it as another user's message
            newMessageElement.classList.add('ai')
            
            const bubbleElement = newMessageElement.querySelector('.message-bubble')
            if (bubbleElement) {
              bubbleElement.classList.add('ai-message')
            }
          }
        }
      }
    }
    
    // Make sure we trigger a scroll
    this.messageReceived()
  }

  // Called when a new message element is added to the DOM
  // This is the most reliable way to detect new messages
  messageTargetConnected(element) {
    console.log("New message connected:", element)
    this.processMessageStyles(element)
    this.scrollToBottom()
  }
  
  processMessageStyles(element) {
    // Check if this message has a user-id attribute and should be processed
    const userId = element.dataset.userId
    if (!userId || !this.currentUserIdValue) return
    
    console.log("Processing message styles. Message user ID:", userId, "Current user ID:", this.currentUserIdValue)
    
    if (userId === this.currentUserIdValue) {
      console.log("This is the current user's message")
      // This is the current user's message
      element.classList.remove('ai')
      element.classList.add('user')
      
      const bubbleElement = element.querySelector('.message-bubble')
      if (bubbleElement) {
        bubbleElement.classList.remove('ai-message')
        bubbleElement.classList.add('user-message')
      }
      
      // Update the role text
      const roleElement = element.querySelector('.message-role')
      if (roleElement) {
        roleElement.innerHTML = '<i class="bx bx-user-circle"></i> You'
      }
    } else {
      console.log("This is NOT the current user's message")
      // This is another user's message
      element.classList.remove('user')
      element.classList.add('ai')
      
      const bubbleElement = element.querySelector('.message-bubble')
      if (bubbleElement) {
        bubbleElement.classList.remove('user-message')
        bubbleElement.classList.add('ai-message')
      }
    }
  }

  // Fallback for form submissions
  messageReceived() {
    this.scrollToBottom()
  }

  scrollToBottom() {
    // First immediate scroll - helps in some scenarios
    if (this.containerTarget) {
      this.containerTarget.scrollTop = this.containerTarget.scrollHeight;
    }
    
    // Then add a series of delayed scrolls to catch all scenarios
    // This approach ensures that at least one of these will work
    [0, 50, 200].forEach(delay => {
      setTimeout(() => {
        if (this.containerTarget) {
          this.containerTarget.scrollTo({
            top: this.containerTarget.scrollHeight,
            behavior: delay > 100 ? "smooth" : "auto" // First scrolls are instant for reliability
          });
        }
      }, delay);
    });
  }
} 