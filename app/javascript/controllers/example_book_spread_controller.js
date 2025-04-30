import {Controller} from "@hotwired/stimulus"
import {Previewer} from "pagejs"
import PageJsReadyHandler from "handlers/page_js_ready_handler"

export default class extends Controller {
    static values = {
        stylesheets: Array
    }

    static targets = ["content", "rendered"]

    connect() {
        let previewer = new Previewer();
        let content = this.contentTarget.innerHTML;

        this.contentTarget.innerHTML = "";

        previewer.registerHandlers(PageJsReadyHandler);

        previewer.preview(
            content,
            this.stylesheetsValue,
            this.renderedTarget
        );

    }
}