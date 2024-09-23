// Import and register all your controllers from the importmap under controllers/*

import { application } from "./application"
import FormSubmission from "./form_submission_controller"
import Login from "./login_controller"
import ModalForm from "./modal_form_controller"
import NotificationController from "./notification_controller"
import TurboModal from "./turbo_modal_controller"

// Eager load all controllers defined in the import map under controllers/**/*_controller
// import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
// eagerLoadControllersFrom("controllers", application)
application.register("notification", NotificationController)
application.register("turbo-modal", TurboModal)
application.register("modal-form", ModalForm)
application.register("submit-form", FormSubmission)
application.register("login", Login)


// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// lazyLoadControllersFrom("controllers", application)
