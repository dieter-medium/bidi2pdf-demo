import {Controller} from "@hotwired/stimulus"
import {Previewer} from "pagedjs"
import PagedJsReadyHandler from "handlers/paged_js_ready_handler"

export default class extends Controller {
    static values = {
        stylesheets: Array,
        clearContent: {type: Boolean, default: true},
    }

    static targets = ["content", "rendered"]

    connect() {
        let previewer = new Previewer();
        let content = this.contentTarget.innerHTML;

        if (this.clearContentValue) {
            this.contentTarget.innerHTML = "";
        }

        previewer.registerHandlers(PagedJsReadyHandler);

        previewer.preview(
            content,
            this.stylesheetsValue,
            this.renderedTarget
        );

    }
}