class ExampleShippingLabelController < ApplicationController
  def show
    qrcode = RQRCode::QRCode.new("https://github.com/dieter-medium/bidi2pdf-rails")

    svg = qrcode.as_svg(viewbox: "0 0 411 411", standalone: true)
    svg_data_uri = "data:image/svg+xml;charset=utf-8,#{ERB::Util.url_encode(svg)}".html_safe
    @qr_code_svg_bg = svg_data_uri

    respond_to do |format|
      format.html
      format.pdf { render pdf: "example_shipping_label" }
    end
  end
end
