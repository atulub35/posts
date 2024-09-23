import { Controller } from "@hotwired/stimulus"
import { Toast } from 'bootstrap'
import { debounce, last } from "lodash"
export const delayedAction = debounce(
    (callback) => {
        callback()
    },
    500,
    {
        leading: false,
        trailing: true,
    }
)
export default class extends Controller {
    static values = { toastId: String }
    static targets = ["toast"]

    animate() {
        const toastElement = last(this.toastTargets)
        toastElement.style.position = "relative"
        toastElement.style[this.animateFrom] = this.animateOffset

        toastElement.addEventListener(
            "show.bs.toast",
            () => {
                setTimeout(() => {
                    const transition = parseFloat(getComputedStyle(toastElement).transitionDuration) * 1000
                    toastElement.style.transition = `all ${transition * 4}ms cubic-bezier(0.165, 0.840, 0.440, 1.000), opacity ${transition}ms linear`
                    toastElement.style[this.animateFrom] = 0
                }, 0)
            },
            { once: true }
        )
        toastElement.addEventListener("hidden.bs.toast", this.callback)

        toastElement.addEventListener(
            "hide.bs.toast",
            () => {
                toastElement.style.transform = `scale(0)`
                toastElement.style.marginTop = `-${this.getAbsoluteHeight(toastElement)}px`
            },
            { once: true }
        )

        toastElement.classList.add("toaster")
        const instance = Toast.getOrCreateInstance(toastElement)
        instance.show()
    }

    get animateFrom() {
        return "top" // Adjust if needed
    }

    get animateOffset() {
        return "-48px" // Adjust if needed
    }

    getAbsoluteHeight(el) {
        const styles = window.getComputedStyle(el)
        const margin = parseFloat(styles["marginTop"]) + parseFloat(styles["marginBottom"])
        return Math.ceil(el.offsetHeight + margin)
    }

    toastTargetConnected() {
        
        this.animate()
    }

    showToast() {
        const toastElement = last(this.toastTargets)
        toastElement.addEventListener("hidden.bs.toast", this.callback)
        this.bootstrapToast.show()
    }

    get bootstrapToast() {
        const toastElement = last(this.toastTargets)
        return Toast.getOrCreateInstance(toastElement)
    }

    callback(event) {
        delayedAction(() => {
            event.target.removeEventListener("hidden.bs.toast", this.callback)
            event.target.remove()
        })
    }
}
