/* this controller is based on https://gitlab.coko.foundation/pagedjs/starter-kits/book_avanced-interface/-/blob/master/pagedjs/reload-in-place.js
* Reload-in-place v1.3
*  Nicolas Taffin + Sameh Chafik - 2020
* MIT License https://opensource.org/licenses/MIT
*  A simple script to add your pagedjs project. On reload, it will make the web browser scroll to the place it was before reload.
* Useful when styling or proof correcting your book. Multi docs compatible and doesn't wait for complete compilation to go.
*
* Transformed to a Stimulus controller by Dieter S.
*
* */

import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        // Blur pages during instant scroll-in-place
        blur: {type: Boolean, default: true},
        // Alternatively, use opacity instead of blur
        opacity: {type: Boolean, default: false},
        // Debounce wait time in milliseconds
        debounceWait: {type: Number, default: 100}
    }

    connect() {
        this.machineScroll = false;
        this.pagedjsEnd = false;
        this.fileTitle = document.title;

        this.createStyleElement();
        this.scrollToSavedPosition();
        this.setupScrollListener();
    }

    disconnect() {
        this.removeScrollListener();
        this.cleanupStyle();
    }

    handlePagesReady(event) {
        this.pagedjsEnd = true;
    }

    createStyleElement() {
        this.styleEl = document.createElement("style");
        document.head.appendChild(this.styleEl);
        this.styleSheet = this.styleEl.sheet;

        if (this.blurValue) {
            this.styleSheet.insertRule(
                ".pagedjs_pages { filter: blur(4px); }",
                0
            );
        } else if (this.opacityValue) {
            this.styleSheet.insertRule(
                ".pagedjs_pages { opacity: 0.3; }",
                0
            );
        }
    }

    cleanupStyle() {
        this.styleEl?.remove();
        this.styleEl = null;
    }

    scrollToSavedPosition() {
        this.machineScroll = true;
        const saved = JSON.parse(localStorage.getItem(this.fileTitle) || "{}");
        const x = saved.x ?? 0, y = saved.y ?? 0;
        const winHeight = window.innerHeight || document.documentElement.clientHeight;

        this.currentInterval = setInterval(() => {
            const docHeight = this.getDocHeight();
            if (y > 0 && y > docHeight - winHeight && !this.pagedjsEnd) {
                window.scrollTo(x, docHeight);
            } else {
                window.scrollTo(x, y);
                clearInterval(this.currentInterval);
                setTimeout(() => {
                    window.scrollTo(x, y);
                    this.machineScroll = false;
                    this.cleanupStyle();
                }, 100);
            }
        }, 50);
    }

    setupScrollListener() {
        this.debouncedSave = this.debounce(
            this.saveScrollPosition.bind(this),
            this.debounceWaitValue
        );
        setTimeout(() => {
            window.addEventListener("scroll", this.debouncedSave);
        }, 1000);
    }

    removeScrollListener() {
        window.removeEventListener("scroll", this.debouncedSave);
    }

    saveScrollPosition() {
        if (this.machineScroll) return;
        const x = Math.round(window.pageXOffset || document.documentElement.scrollLeft);
        const y = Math.round(window.pageYOffset || document.documentElement.scrollTop);
        localStorage.setItem(this.fileTitle, JSON.stringify({x, y}));
    }

    getDocHeight() {
        const d = document;
        return Math.max(
            d.body.scrollHeight,
            d.documentElement.scrollHeight,
            d.body.offsetHeight,
            d.documentElement.offsetHeight,
            d.body.clientHeight,
            d.documentElement.clientHeight
        );
    }

    debounce(func, wait = 100, immediate = false) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                timeout = null;
                if (!immediate) func(...args);
            };
            const callNow = immediate && !timeout;
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
            if (callNow) func(...args);
        };
    }
}