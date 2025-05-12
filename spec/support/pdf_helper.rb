# frozen_string_literal: true

module PdfHelper
  def get_pdf_response(path)
    uri = URI(path.starts_with?("http") ? path : "http://#{rails_host}:#{@port}#{path}")
    Net::HTTP.get_response(uri)
  end

  def rails_host
    if ENV["CI"]
      "localhost" # Socket.ip_address_list.detect(&:ipv4_private?).ip_address
    else
      "localhost"
    end
  end

  def inside_container?
    File.exist?("/.dockerenv")
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

  def with_pdf_debug(pdf_data)
    yield pdf_data
  rescue RSpec::Expectations::ExpectationNotMetError => e
    failure_output = store_pdf_file pdf_data, "test-failure"
    puts "Test failed! PDF saved to: #{failure_output}"
    raise e
  end

  def store_pdf_file(pdf_data, filename_prefix = "test")
    pdf_file = tmp_file("pdf-files", "#{filename_prefix}-#{Time.now.to_i}.pdf")
    FileUtils.mkdir_p(File.dirname(pdf_file))
    File.binwrite(pdf_file, pdf_data)

    pdf_file
  end
end

RSpec.configure do |config|
  config.include PdfHelper, pdf: true
end
