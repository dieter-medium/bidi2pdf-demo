class AsyncReportJob < ApplicationJob
  include Rails.application.routes.url_helpers
  queue_as :default

  def perform(render_option_handler, report_id, base_url)
    @base_url = base_url

    pdf_content = Bidi2pdfRails::Services::PdfRenderer.new(render_option_handler).render_pdf

    report = ReportResult.new(
      report_id: report_id,
    )

    report.pdf.attach(
      io: StringIO.new(pdf_content),
      filename: "#{render_option_handler.pdf.filename}.pdf",
      content_type: "application/pdf",
      identify: false
    )

    report.save!

    ReportChannel.broadcast_replace_to(
      "report_#{report_id}",
      target: "report-status",
      partial: "example_async_pdf/pdf_frame",
      locals: { url: url_for(report.pdf) }
    )
  end

  def default_url_options
    uri = URI.parse(@base_url)
    {
      protocol: uri.scheme,
      host: uri.host,
      port: uri.port.nonzero? && uri.port != Rack::Request::DEFAULT_PORTS[uri.scheme] ? uri.port : nil
    }.compact
  end
end
