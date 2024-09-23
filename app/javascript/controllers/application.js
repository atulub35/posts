import { Application } from "@hotwired/stimulus"

const application = Application.start()
import { Turbo } from '@hotwired/turbo-rails'
// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
