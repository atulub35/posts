import { Controller } from "@hotwired/stimulus"
import { delayedAction } from "./utilities/misc"
import { debounce } from 'lodash';

export default class extends Controller {
    static targets = ["form", "searchInput"]

    initialize(){
        this.debounceSearch = debounce(this.onInput, 500).bind(this);
    }

    connect(){
        this.searchInputTarget.focus()
    }

    search() {
        delayedAction(() => this.formTarget.requestSubmit())
    }

    // Only search after 3rd character
    onInput({target: { value }}) {
        if (value.length >= 3) delayedAction(() => this.formTarget.requestSubmit())
    }

    querySearch(e){
        this.debounceSearch(e)
    }
}
