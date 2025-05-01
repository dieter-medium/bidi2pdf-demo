import {Handler} from "pagedjs"

export default class PagedJsReadyHandler extends Handler {
    constructor(chunker, polisher, caller) {
        super(chunker, polisher, caller);
    }

    afterRendered(pages) {
        window.loaded = true;
        console.info("✅ Paged.js has rendered everything!");
    }
}