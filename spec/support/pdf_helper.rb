# frozen_string_literal: true

module PdfHelper
  def get_pdf_response(path)
    uri = URI(path.starts_with?("http") ? path : "http://#{rails_host}:#{@port}#{path}")
    Net::HTTP.get_response(uri)
  end

  def rails_host
    if ENV["CI"]
      Socket.gethostname
    else
      "localhost"
    end
  end

  def follow_redirects(response, max_redirects = 10)
    redirect_count = 0
    while response.is_a?(Net::HTTPRedirection) && redirect_count < max_redirects
      redirect_url = response["location"]
      response = get_pdf_response redirect_url
      redirect_count += 1
    end
    response
  end
end

RSpec.configure do |config|
  config.include PdfHelper, pdf: true
end
