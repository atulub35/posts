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

    connect() {
        // Set up stacked toast container
        this.toastPositionOffset = 10; // Starting offset
        this.toastZIndex = 1080; // Starting z-index
    }

    animate() {
        const toastElement = last(this.toastTargets)
        
        // Calculate position for stacked toasts
        const previousToasts = this.toastTargets.slice(0, -1);
        let topOffset = this.toastPositionOffset;
        
        previousToasts.forEach(toast => {
            if (toast.classList.contains('show')) {
                topOffset += toast.offsetHeight + 10; // Add margin between toasts
            }
        });
        
        // Set initial position, with newer toasts appearing at the top
        toastElement.style.position = "relative";
        toastElement.style.zIndex = this.toastZIndex++;
        toastElement.style[this.animateFrom] = `-${48 + topOffset}px`;

        toastElement.addEventListener(
            "show.bs.toast",
            () => {
                setTimeout(() => {
                    const transition = parseFloat(getComputedStyle(toastElement).transitionDuration) * 1000
                    toastElement.style.transition = `all ${transition * 4}ms cubic-bezier(0.165, 0.840, 0.440, 1.000), opacity ${transition}ms linear`
                    toastElement.style[this.animateFrom] = `${topOffset}px`; // Final position
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
                
                // Reposition remaining toasts when one is removed
                this.updateToastPositions(toastElement);
            },
            { once: true }
        )

        toastElement.classList.add("toaster")
        // Configure toast to auto-hide after 5 seconds
        const instance = Toast.getOrCreateInstance(toastElement, {
            delay: 5000,
            autohide: true
        })
        instance.show()
    }
    
    updateToastPositions(removedToast) {
        const toasts = this.toastTargets.filter(t => t !== removedToast && t.classList.contains('show'));
        let currentOffset = this.toastPositionOffset;
        
        toasts.forEach(toast => {
            toast.style[this.animateFrom] = `${currentOffset}px`;
            currentOffset += toast.offsetHeight + 10;
        });
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
        return Toast.getOrCreateInstance(toastElement, {
            delay: 5000,
            autohide: true
        })
    }

    callback(event) {
        delayedAction(() => {
            event.target.removeEventListener("hidden.bs.toast", this.callback)
            event.target.remove()
        })
    }
}
