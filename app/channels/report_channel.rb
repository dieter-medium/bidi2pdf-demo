# frozen_string_literal: true

class ReportChannel < Turbo::StreamsChannel
  include Rails.application.routes.url_helpers

  def subscribed
    if (stream_name = verified_stream_name_from_params).present? &&
       subscription_allowed?
      stream_from stream_name
    else
      reject
    end

    report_id = params[:report_id]
    report = ReportResult.find_by(report_id: report_id)

    ReportChannel.broadcast_replace_to(
      "report_#{report_id}",
      target: "report-status",
      partial: "example_async_pdf/pdf_frame",
      locals: { url: url_for(report.pdf) }
    ) if report&.pdf&.attached?
  end

  def subscription_allowed?
    true
  end

  def default_url_options
    request = connection.instance_variable_get "@request"
    base = request.base_url
    uri = URI.parse(base)
    {
      protocol: uri.scheme,
      host: uri.host,
      port: uri.port.nonzero? && uri.port != Rack::Request::DEFAULT_PORTS[uri.scheme] ? uri.port : nil
    }.compact
  end
end
