/**
 * Manages and handles button loading state and pointer events
 * while in flight
 */

import { loader } from "./password_icon"

class ButtonState {

     constructor() {
        this.buttonName = ''
        this.preventClickClass = 'pe-none'
     }

    startLoading(button) {
        // Store button text used for resetting button state
        this.buttonName = button.innerHTML
        button.classList.add(this.preventClickClass)
            button.innerHTML = this.buttonWithLoader(button)
    }

    // Prepends loader icon with button name
    buttonWithLoader(button) {
        return `<div class="d-flex align-items-center justify-content-center">
            ${loader(this._isPrimary(button)) + this.buttonName}
        </div>`
    }

    stopLoading(button) {
        button.classList.remove(this.preventClickClass)
        button.innerHTML = this.buttonName
    }

    _isPrimary(button) {
        return button.classList.contains("btn-primary")
    }

}

export default new ButtonState()
