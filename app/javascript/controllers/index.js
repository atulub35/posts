// Import and register all your controllers from the importmap under controllers/*

import { application } from "./application"

// Automatically register all controllers from the controllers directory
const controllers = import.meta.glob("./**/*_controller.js", { eager: true })

Object.entries(controllers).forEach(([path, controller]) => {
  // Convert the file path to a controller name
  // e.g., ./post_actions_controller.js -> post-actions
  const name = path
    .replace(/^\.\//, '')
    .replace(/_controller\.js$/, '')
    .replace(/_/g, '-')
  
  application.register(name, controller.default)
})

// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// lazyLoadControllersFrom("controllers", application)
