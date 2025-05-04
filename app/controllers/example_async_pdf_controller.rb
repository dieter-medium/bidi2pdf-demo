class ExampleAsyncPdfController < ApplicationController
  def generate
    products = JSON.parse(File.read(Rails.root.join("vendor", "openui5", "mockdata", "Products.json")))

    @products = products.first(10)

    @bootstrap_disabled = true

    options = { template: "example_basic_product_data_sheet/show" }

    filename = "example_async_basic_product_data_sheet"
    handler = Bidi2pdfRails::Services::RenderOptionsHandler.new(filename, options, self)
    report_id = SecureRandom.uuid

    handler.render_inline! if handler.inline_rendering_needed?

    AsyncReportJob.perform_later(handler, report_id, request.base_url)

    redirect_to example_async_pdf_progress_path(report_id)
  end

  def progress
    @report_id = params[:id]

    respond_to do |format|
      format.html
      format.json {
        result = ReportResult.find_by(report_id: @report_id)
        if result&.pdf&.attached?
          render json: { status: "ready", url: url_for(result.pdf) }
        else
          render json: { status: "processing" }
        end
      }
    end
  end
end
