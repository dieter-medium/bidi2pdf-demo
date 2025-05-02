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
        let toggle = localStorage.getItem('baselineToggle' + this.fileTitle)
        let size = localStorage.getItem('baselineSize' + this.fileTitle)
        let pos = localStorage.getItem('baselinePosition')

        if (toggle === "baseline") {
            this.body.classList.remove('no-baseline')
            this.baselineToggleTarget.checked = true
            this.baselineButtonTarget.textContent = "hide"
        } else {
            this.body.classList.add('no-baseline')
            this.baselineButtonTarget.textContent = "see"
            localStorage.setItem('baselineToggle' + this.fileTitle, 'no-baseline')
        }

        if (size) {
            this.baselineSizeTarget.value = size
            document.documentElement.style.setProperty('--pagedjs-baseline', size + 'px')
        } else {
            localStorage.setItem('baselineSize' + this.fileTitle, this.baselineSizeTarget.value)
        }

        if (pos) {
            this.baselinePositionTarget.value = pos
            document.documentElement.style.setProperty('--pagedjs-baseline-position', pos + 'px')
        } else {
            localStorage.setItem('baselinePosition', this.baselinePositionTarget.value)
        }
    }

    toggleBaseline() {
        if (this.baselineToggleTarget.checked) {
            this.body.classList.remove('no-baseline')
            localStorage.setItem('baselineToggle' + this.fileTitle, 'baseline')
            this.baselineButtonTarget.textContent = "hide"
        } else {
            this.body.classList.add('no-baseline')
            localStorage.setItem('baselineToggle' + this.fileTitle, 'no-baseline')
            this.baselineButtonTarget.textContent = "see"
        }
    }

    changeBaselineSize() {
        let v = this.baselineSizeTarget.value
        document.documentElement.style.setProperty('--pagedjs-baseline', v + 'px')
        localStorage.setItem('baselineSize' + this.fileTitle, v)
    }

    changeBaselinePosition() {
        let v = this.baselinePositionTarget.value
        document.documentElement.style.setProperty('--pagedjs-baseline-position', v + 'px')
        localStorage.setItem('baselinePosition', v)
    }

    toggleMarginbox() {
        if (this.marginboxToggleTarget.checked) {
            this.body.classList.remove('no-marginboxes')
            this.marginboxButtonTarget.textContent = "hide"
        } else {
            this.body.classList.add('no-marginboxes')
            this.marginboxButtonTarget.textContent = "see"
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
}
