import { Controller } from '@hotwired/stimulus'
import { Modal } from 'bootstrap'
import loader from './utilities/loader'
/**
 * This controller launches Modal when target is connected ie response received in browser
 */
export default class extends Controller {
    static targets = ['button']

    static values = {
            modalId: String,
            turboFrameId: String
    }

    connect() {
        this.modalInstance.show()
        
        this.modalElement.addEventListener('hidden.bs.modal', this.cleanUp)
    }

    cleanUp = () => {
        this.element.closest('turbo-frame').innerHTML = ''
    }

    disconnect() {
        // this.modalElement.removeEventListener('hidden.bs.modal', this.cleanUp)
    }

    get modalElement () {
        return document.getElementById(this.modalIdValue)
    }

    get modalInstance() {
        return Modal.getOrCreateInstance(this.modalElement)
    }

    hideModal() {
        this.modalInstance.hide()
    }

    submitEnd(event) {
        // const type = this.getRequestType(event)
        if (event.detail.fetchResponse.response.status === 200 && event.detail.formSubmission) {
            this.hideModal()
        }
        this.hasButtonTarget && loader.stopLoading(this.buttonTarget)
    }

    submitStart() {
        this.hasButtonTarget && loader.startLoading(this.buttonTarget)
    }

    getRequestType(event) {
        return event.target.getAttribute("method") || event.target.method
    }


}
