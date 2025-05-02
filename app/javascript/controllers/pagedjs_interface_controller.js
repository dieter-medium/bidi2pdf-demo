import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "baselineToggle", "baselineButton", "baselineSize", "baselinePosition",
        "marginboxToggle", "marginboxButton", "previewToggle", "pageCount",
        "buttonPrint"
    ]

    connect() {
        this.body = document.body
        this.fileTitle = document.title

        // initialize stored values and UI
        this.initBaseline()
        this.body.classList.add('no-marginboxes')
    }

    // Baseline logic
    initBaseline() {
        let toggle = this.getLocalStorage('baselineToggle')
        let toggleMarginbox = this.getLocalStorage('marginboxToggle')
        let size = this.getLocalStorage('baselineSize')
        let pos = this.getLocalStorage('baselinePosition')

        if (toggle === "baseline") {
            this.body.classList.remove('no-baseline')
            this.baselineToggleTarget.checked = true
            this.baselineButtonTarget.textContent = "hide"
        } else {
            this.body.classList.add('no-baseline')
            this.baselineButtonTarget.textContent = "see"
            this.setLocalStorage('baselineToggle', 'no-baseline')
        }

        if (toggleMarginbox === "marginboxes") {
            this.body.classList.remove('no-marginboxes')
            this.marginboxButtonTarget.textContent = "hide"
        } else {
            this.body.classList.add('no-marginboxes')
            this.marginboxButtonTarget.textContent = "see"
            this.setLocalStorage('marginboxToggle', 'no-marginboxes')
        }

        if (size) {
            this.baselineSizeTarget.value = size
            document.documentElement.style.setProperty('--pagedjs-baseline', size + 'px')
        } else {
            this.setLocalStorage('baselineSize', this.baselineSizeTarget.value)
        }

        if (pos) {
            this.baselinePositionTarget.value = pos
            document.documentElement.style.setProperty('--pagedjs-baseline-position', pos + 'px')
        } else {
            this.setLocalStorage('baselinePosition', this.baselinePositionTarget.value)
        }
    }

    toggleBaseline() {
        if (this.baselineToggleTarget.checked) {
            this.body.classList.remove('no-baseline')
            this.setLocalStorage('baselineToggle', 'baseline')
            this.baselineButtonTarget.textContent = "hide"
        } else {
            this.body.classList.add('no-baseline')
            this.setLocalStorage('baselineToggle', 'no-baseline')
            this.baselineButtonTarget.textContent = "see"
        }
    }

    changeBaselineSize() {
        let v = this.baselineSizeTarget.value
        document.documentElement.style.setProperty('--pagedjs-baseline', v + 'px')
        this.setLocalStorage('baselineSize', v)
    }

    changeBaselinePosition() {
        let v = this.baselinePositionTarget.value
        document.documentElement.style.setProperty('--pagedjs-baseline-position', v + 'px')
        this.setLocalStorage('baselinePosition', v)
    }

    toggleMarginbox() {
        if (this.marginboxToggleTarget.checked) {
            this.body.classList.remove('no-marginboxes')
            this.marginboxButtonTarget.textContent = "hide"
            this.setLocalStorage('marginboxToggle', 'marginboxes')
        } else {
            this.body.classList.add('no-marginboxes')
            this.marginboxButtonTarget.textContent = "see"
            this.setLocalStorage('marginboxToggle', 'no-marginboxes')
        }
    }

    togglePreview() {
        if (this.previewToggleTarget.checked) {
            this.body.classList.add('interface-preview')
        } else {
            this.body.classList.remove('interface-preview')
        }
    }

    updatePageCount(event) {
        this.pageCountTarget.textContent = event.detail.pageCount;
    }

    readyToPrint(event) {
        this.buttonPrintTarget.dataset.ready = true;
    }

    print(event) {
        const url = new URL(window.location.href);
        url.searchParams.set('format', 'pdf');
        window.open(url.toString(), '_blank');
    }

    setLocalStorage(key, value) {
        if (window.location.protocol === "data:") return;
        localStorage.setItem(key + this.fileTitle, value);
    }

    getLocalStorage(key) {
        if (window.location.protocol === "data:") return;
        return localStorage.getItem(key + this.fileTitle);
    }
}
