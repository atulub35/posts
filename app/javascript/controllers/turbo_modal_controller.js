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
    }

    get modalInstance() {
        return Modal.getOrCreateInstance(document.getElementById(this.modalIdValue))
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
