import { Controller } from "@hotwired/stimulus"
/**
 * Helper for modal controllers to connect form with submit button
 * As body and footer are two separate elements
 */
export default class extends Controller {
    static targets = ['form']
    static values = { 
        tabItems: Number,
        hasIosIcon: String
    }
    static classes = [ "hidden" ]

    submitModalForm(event) {
        this.formTarget.requestSubmit()
    }

}
