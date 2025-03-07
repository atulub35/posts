import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        'button',
        'lightIcon',
        'darkIcon',
        'systemIcon',
        'option'
    ]

    static classes = ['active']

    connect() {
        let theme = this.getPreferredTheme()
        this.setTheme(theme)
        this.showActiveTheme(theme)
        
        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', this.systemThemeChanged.bind(this))
    }

    getStoredTheme() {
        return localStorage.getItem('theme')
    }

    setStoredTheme(theme) {
        localStorage.setItem('theme', theme)
    }

    getPreferredTheme() {
        const storedTheme = this.getStoredTheme()
        if (storedTheme) {
        return storedTheme
        }
        return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
    }

    setTheme(theme) {
        if (theme === 'auto') {
            document.documentElement.setAttribute('data-bs-theme', (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'))
        } else {
            document.documentElement.setAttribute('data-bs-theme', theme)
        }
    }

    getCurrentIcon(theme) {
        return this.element.querySelector(`[data-theme-theme-param="${theme}"] svg`).outerHTML
    }

    /**
     * 
     * @param {*} theme current theme
     * @returns {HTMLElement} - dropdown option
     */
    getCurrentOption(theme) {
        return this.element.querySelector(`[data-theme-theme-param="${theme}"]`)
    }

    // Reset previously active dropdown option
    resetActiveOption() {
        this.optionTargets.forEach(element => {
            element.classList.remove(this.activeClass)
        })
    }

    showActiveTheme(theme, focus = false) {
        this.buttonTarget.innerHTML = ''
        this.buttonTarget.innerHTML = this.getCurrentIcon(theme)
        this.getCurrentOption(theme).classList.add(this.activeClass)
    }

    systemThemeChanged() {
        const storedTheme = this.getStoredTheme()
        if (storedTheme !== 'light' && storedTheme !== 'dark') {
            this.setTheme(this.getPreferredTheme())
        }
    }

    toggleTheme({ params: { theme }}) {
        this.resetActiveOption()

        this.setStoredTheme(theme)
        this.setTheme(theme)
        this.showActiveTheme(theme, true)
    }
}
