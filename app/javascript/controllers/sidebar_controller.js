import { Controller } from '@hotwired/stimulus'
import { Tooltip } from 'bootstrap'

export default class extends Controller {
    static targets = ['sidebar', 'closeBtn', 'white', 'navList', 'link']
    static classes = ['open', 'scroll', 'menu', 'menuAltRight', 'white', 'active']

    connect() {
        const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
        const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new Tooltip(tooltipTriggerEl))
    }

    toggleSidebar() {
        this.sidebarTarget.classList.toggle(this.openClass) // Use dynamic class for open state
        this.navListTarget.classList.toggle(this.scrollClass) // Use dynamic class for scroll state
        
        this.menuBtnChange() // Call function to change button icon
        this.whiteTargets.forEach(element => {
            element.classList.toggle(this.whiteClass)
        })
    }

    menuBtnChange() {
        if (this.sidebarTarget.classList.contains(this.openClass)) {
            this.closeBtnTarget.classList.replace(this.menuClass, this.menuAltRightClass) // Use dynamic class for menu icon
        } else {
            this.closeBtnTarget.classList.replace(this.menuAltRightClass, this.menuClass) // Revert back to original icon
        }
    }

    resetHilightedLink() {
        this.linkTargets.forEach(element => {
            element.classList.remove(this.activeClass)
        })
    }

    hilightLink(event) {
        this.resetHilightedLink()
        event.currentTarget.classList.add(this.activeClass)
    }
}
