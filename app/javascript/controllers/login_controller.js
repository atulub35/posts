import { Controller } from '@hotwired/stimulus'
import loader from './utilities/loader'
/**
 * Handle loader state
 */
export default class extends Controller {
    static targets = ['button']

    static values = {
    }

    submitEnd() {
        this.hasButtonTarget && loader.stopLoading(this.buttonTarget)
    }

    submitStart() {
        this.hasButtonTarget && loader.startLoading(this.buttonTarget)
    }

}
