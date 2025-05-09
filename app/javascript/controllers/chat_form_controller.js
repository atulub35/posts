import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "input", "messages"]
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
    if (!message) return;
    
    // Submit the form
    this.formTarget.requestSubmit();
    this.inputTarget.value = "";
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