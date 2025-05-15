import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "input", "messages", "imageInput", "imagePreview", "previewImage"]
  static values = {
    userId: Number
  }

  connect() {
    console.log("Chat form connected with user ID:", this.element.dataset.currentUserId);
    // Initialize setup
    this.styleAllMessages();
    
    // Set up a mutation observer to style any new messages
    this.setupMessageObserver();
    
    // Listen for Turbo Stream broadcasts
    this.setupBroadcastListener();

    // Add image input change listener if the target exists
    if (this.hasImageInputTarget) {
      this.imageInputTarget.addEventListener('change', this.handleImageSelection.bind(this));
    }
  }
  
  // Handle image selection
  handleImageSelection(event) {
    const file = event.target.files[0];
    if (!file) return;
    
    // Check if file is an image
    if (!file.type.match('image.*')) {
      alert('Please select an image file');
      this.imageInputTarget.value = '';
      return;
    }
    
    // Check file size (limit to 5MB)
    if (file.size > 5 * 1024 * 1024) {
      alert('Image size should be less than 5MB');
      this.imageInputTarget.value = '';
      return;
    }
    
    // Show preview
    const reader = new FileReader();
    reader.onload = (e) => {
      this.previewImageTarget.src = e.target.result;
      this.imagePreviewTarget.classList.remove('d-none');
    };
    reader.readAsDataURL(file);
  }
  
  // Remove image
  removeImage(event) {
    event.preventDefault();
    this.imageInputTarget.value = '';
    this.previewImageTarget.src = '';
    this.imagePreviewTarget.classList.add('d-none');
  }
  
  setupBroadcastListener() {
    // Listen for turbo-stream events specifically
    document.addEventListener('turbo:before-stream-render', (event) => {
      const turboStream = event.target;
      const action = turboStream.getAttribute('action');
      
      // Only intercept appends, which are likely new messages
      if (action === 'append') {
        const templateContent = turboStream.querySelector('template').content;
        const newElements = Array.from(templateContent.children);
        
        // Process each new element for styling
        newElements.forEach(element => {
          if (element.classList.contains('message') && element.dataset.senderId) {
            const currentUserId = parseInt(this.element.dataset.currentUserId, 10);
            const senderId = parseInt(element.dataset.senderId, 10);
            
            // Apply styling before the element is rendered
            this.applyMessageStyling(element, currentUserId, senderId);
          }
        });
      }
    });
    
    // Also listen for after render to handle any cases we missed
    document.addEventListener('turbo:stream-render', (event) => {
      // Style any new messages and trigger scroll
      setTimeout(() => {
        this.styleAllMessages();
        
        // Trigger chat scroll on nearby controllers
        const scrollController = this.application.getControllerForElementAndIdentifier(
          this.element, 'chat-scroll'
        );
        
        if (scrollController) {
          scrollController.scrollToBottom();
        }
      }, 10);
    });
  }
  
  styleAllMessages() {
    // Get current user ID from the data attribute on the controller element
    const currentUserId = parseInt(this.element.dataset.currentUserId, 10);
    console.log("Styling messages for user ID:", currentUserId);
    
    // Find all messages that need styling
    const messages = document.querySelectorAll(".message[data-sender-id]");
    
    messages.forEach(message => {
      const senderId = parseInt(message.dataset.senderId, 10);
      this.applyMessageStyling(message, currentUserId, senderId);
    });
    
    // Check for any messages with placeholder images that need to be loaded
    this.loadMessageImages();
  }
  
  // Load images for any messages that have placeholders
  loadMessageImages() {
    const messageContainers = document.querySelectorAll(".message-wrapper[data-message-id]");
    
    messageContainers.forEach(container => {
      const messageId = container.dataset.messageId;
      const imagePlaceholder = container.querySelector('.placeholder-glow');
      if (!imagePlaceholder) return;
      
      // Make an AJAX request to get the pre-signed URL
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
          console.log('Image data received:', data);
          if (data.image_url) {
            // Replace placeholder with actual image using pre-signed URL
            const imageHTML = `
              <a href="${data.full_url}" target="_blank" class="d-block">
                <img src="${data.image_url}" class="img-fluid rounded" 
                     alt="${data.filename || 'Attached image'}"
                     loading="lazy">
              </a>
            `;
            imagePlaceholder.parentNode.innerHTML = imageHTML;
          } else {
            throw new Error('No pre-signed URL provided');
          }
        })
        .catch(error => {
          console.error('Error loading image:', error);
          imagePlaceholder.parentNode.innerHTML = '<div class="alert alert-warning">Image could not be loaded</div>';
        });
    });
  }
  
  applyMessageStyling(messageElement, currentUserId, senderId) {
    const messageContent = messageElement.querySelector(".message-content");
    if (!messageContent) return;
    
    console.log(`Styling message from sender ${senderId}, current user is ${currentUserId}`);
    
    // Reset styling first to avoid duplicates
    messageElement.classList.remove("message-sent", "message-received");
    messageContent.classList.remove("bg-primary", "text-white", "bg-body-tertiary");
    
    // Apply the appropriate styling based on sender
    if (senderId === currentUserId) {
      // This message was sent by the current user
      messageElement.classList.add("message-sent");
      messageContent.classList.add("bg-primary", "text-white");
      
      // Style all small text elements inside
      messageElement.querySelectorAll("small").forEach(small => {
        small.classList.remove("text-muted");
        small.classList.add("text-white-50");
      });
    } else {
      // This message was received from another user
      messageElement.classList.add("message-received");
      messageContent.classList.add("bg-body-tertiary");
      
      // Style all small text elements inside
      messageElement.querySelectorAll("small").forEach(small => {
        small.classList.remove("text-white-50");
        small.classList.add("text-muted");
      });
    }
  }
  
  setupMessageObserver() {
    // Create a mutation observer to watch for new messages
    const observer = new MutationObserver(mutations => {
      let newMessage = false;
      
      mutations.forEach(mutation => {
        if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
          mutation.addedNodes.forEach(node => {
            if (node.nodeType === Node.ELEMENT_NODE) {
              if (node.classList.contains('message') && node.dataset.senderId) {
                newMessage = true;
                const currentUserId = parseInt(this.element.dataset.currentUserId, 10);
                const senderId = parseInt(node.dataset.senderId, 10);
                this.applyMessageStyling(node, currentUserId, senderId);
              }
            }
          });
        }
      });
      
      if (newMessage) {
        // Trigger a custom event that chat-scroll controller can listen for
        document.dispatchEvent(new CustomEvent('chat:new-message-styled'));
        
        // Also try to trigger scroll directly if possible
        const scrollController = this.application.getControllerForElementAndIdentifier(
          this.element, 'chat-scroll'
        );
        
        if (scrollController) {
          setTimeout(() => {
            scrollController.scrollToBottom();
          }, 100);
        }
      }
    });
    
    // Start observing the messages container
    observer.observe(this.messagesTarget, { 
      childList: true,
      subtree: true
    });
  }

  submit(event) {
    event.preventDefault();
    
    const message = this.inputTarget.value.trim();
    const hasImage = this.hasImageInputTarget && this.imageInputTarget.files.length > 0;
    
    // Require either text or an image
    if (!message && !hasImage) return;
    
    // Submit the form
    this.formTarget.requestSubmit();
    this.inputTarget.value = "";
    
    // Reset image preview if we have one
    if (this.hasImagePreviewTarget) {
      this.imagePreviewTarget.classList.add('d-none');
      if (this.hasImageInputTarget) {
        this.imageInputTarget.value = '';
      }
    }
  }

  createMessageHtml(content, role) {
    console.log("createMessageHtml", content, role);
    
    const time = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true })
    return `
      <div class="message-wrapper ${role}">
        <div class="message-bubble ${role === 'user' ? 'user-message' : 'ai-message'}">
          <div class="message-content">
            ${content}
          </div>
          <div class="message-meta d-flex justify-content-between align-items-center mt-2">
            <div class="message-role">
              ${role === 'user' ? 
                '<i class="bx bx-user-circle"></i>You' : 
                '<i class="bx bx-bot"></i>AI Assistant'
              }
            </div>
            <div class="message-time">
              ${time}
            </div>
          </div>
        </div>
      </div>
    `
  }
} 