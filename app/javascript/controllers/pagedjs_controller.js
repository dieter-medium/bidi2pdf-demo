import {Controller} from "@hotwired/stimulus"
import {Previewer} from "pagedjs"
import createPagedJsReadyHandler from "handlers/paged_js_ready_handler"

export default class extends Controller {
    static values = {
        stylesheets: Array,
        clearContent: {type: Boolean, default: true},
    }

    static targets = ["content", "rendered"]

    connect() {
        let previewer = new Previewer();
        let content = this.contentTarget.innerHTML;
        const PagedJsReadyHandler = createPagedJsReadyHandler(this);

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

    notifyPageCount(pageCount) {
        this.dispatch("page-count", {
            detail: {
                pageCount: pageCount
            }
        });
    }

    notifyPagesReady(pages) {
        this.dispatch("pages-ready", {
            detail: {
                pages: pages
            }
        });
    }
}