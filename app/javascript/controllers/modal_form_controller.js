import { Controller } from "@hotwired/stimulus"
import loader from "./utilities/loader"
/**
 * Helper for modal controllers to connect form with submit button
 * As body and footer are two separate elements
 */
export default class extends Controller {
    static targets = ['form', 'button']
    static values = { 
        tabItems: Number,
        hasIosIcon: String
    }
    static classes = [ "hidden" ]

    onSubmitStart(event) {
        loader.startLoading(this.buttonTarget)
    }

    onSubmitEnd(event) {
        loader.stopLoading(this.buttonTarget)
        this.formTarget.reset()
    }

}
