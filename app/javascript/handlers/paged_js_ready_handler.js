import {Handler} from "pagedjs"

export default function createPagedJsReadyHandler(controller) {
    console.debug("Creating Paged.js ready handler");

    return class extends Handler {
        constructor(chunker, polisher, caller) {
            super(chunker, polisher, caller);
            this.controller = controller
        }

        afterPageLayout(pageElement, page, breakToken) {
            console.debug("Paged.js page layout", page.id);

            let nbr = page.id.replace('page-', '');
            this.controller.notifyPageCount(nbr);
        }

        beforeParsed(content) {
            this.controller.notifyBeforeParsed(content);
        }


        afterRendered(pages) {
            console.debug("Paged.js after rendered");

            window.loaded = true;
            console.info("✅ Paged.js has rendered everything!");
            this.controller.notifyPagesReady(pages);
        }
    }
}