import {Handler} from "pagedjs"

export default function createPagedJsReadyHandler(controller) {
    return class extends Handler {
        constructor(chunker, polisher, caller) {
            super(chunker, polisher, caller);
            this.controller = controller
        }

        afterPageLayout(pageElement, page, breakToken) {
            let nbr = page.id.replace('page-', '');
            this.controller.notifyPageCount(nbr);
        }


        afterRendered(pages) {
            window.loaded = true;
            console.info("✅ Paged.js has rendered everything!");
            this.controller.notifyPagesReady(pages);
        }
    }
}