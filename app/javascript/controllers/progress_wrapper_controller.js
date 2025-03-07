import { Controller } from "@hotwired/stimulus"
import { loader } from "./utilities/password_icon"
export default class extends Controller {
    static targets = ['saveButton']

    showLoading(event) {
        let buttonElement = event.detail.formSubmission.submitter
        if (!buttonElement) return

        let isPrimary = this._isPrimary(buttonElement)

        // Store button text used for resetting button state
        let buttonName = buttonElement.innerHTML
        buttonElement.setAttribute("data-name", buttonName) // set the data attribute
        buttonElement.style.pointerEvents = 'none'
            buttonElement.innerHTML = `<div class="bs-d-flex bs-align-items-center bs-justify-content-center">
                    ${loader(isPrimary) + buttonName}
                </div>`
    }
    
    stopLoading(event) {
        let buttonElement = event.detail.formSubmission.submitter
        if (!buttonElement) return
        let buttoneName = buttonElement.dataset.name || buttonElement.innerHTML
        buttonElement.style.pointerEvents = 'auto'
        buttonElement.innerHTML = buttoneName
    }

    _isPrimary(button) {
        return button.classList.contains("bs-btn-primary");
    }

}
