import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "loading", "content"]

  connect() {
    console.log("Variant form controller connected");
    this.formTarget.addEventListener("submit", this.handleSubmit.bind(this));
  }

  disconnect() {
    this.formTarget.removeEventListener("submit", this.handleSubmit.bind(this));
  }

  handleSubmit(event) {
    // We don't need to prevent default, we're using Turbo
    console.log("Form submitted");
    this.submitForm(event);
  }

  submitForm(event) {
    // Show loading indicator when form is submitted
    console.log("Showing loading indicator");
    this.loadingTarget.style.display = "block";
    // Clear any previous content
    console.log("Clearing previous content");
    this.contentTarget.innerHTML = "";
  }

  // Handle successful form submission
  success(event) {
    console.log("Form submission successful");
    this.loadingTarget.style.display = "none";
    
    // Prevent any potential redirects
    if (event && event.preventDefault) {
      event.preventDefault();
    }
  }

  // Handle failed form submission
  error(event) {
    console.log("Form submission error");
    this.loadingTarget.style.display = "none";
    this.contentTarget.innerHTML = "<div class='alert alert-danger'>Error generating variant. Please try again.</div>";
    
    // Prevent any potential redirects
    if (event && event.preventDefault) {
      event.preventDefault();
    }
  }
} 