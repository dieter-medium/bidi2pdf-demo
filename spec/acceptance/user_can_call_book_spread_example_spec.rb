require "rails_helper"
require "bidi2pdf/test_helpers/testcontainers"

RSpec.feature "As a developer, I want to an example of book spread", :chromedriver, :pdf, type: :request do
  before do
    with_render_setting :browser_url, session_url
    with_pdf_settings :asset_host, "http://host.docker.internal:#{@port}"
    Bidi2pdfRails::ChromedriverManagerSingleton.initialize_manager force: true
  end

  after do
    Bidi2pdfRails::ChromedriverManagerSingleton.shutdown
  end

  scenario "Rendering a PDF using the book spread example" do
    when_ "I visit the PDF version of a report" do
      before do
        @response = get_pdf_response "/example_book_spread/show.pdf"
      end

      then_ "I receive a successful HTTP response" do
        expect(@response.code).to eq("200")
      end

      and_ "I receive a PDF file in response" do
        expect(@response['Content-Type']).to eq("application/pdf")
      end

      and_ "the PDF contains the expected number of pages" do
        expected_page_count = 5
        expect(@response.body).to have_pdf_page_count(expected_page_count)
      end

      and_ "the disposition header is set to attachment" do
        expect(@response['Content-Disposition']).to start_with('inline; filename="example_book_spread.pdf"')
      end

      and_ "the PDF contains the expected content" do
        expect(@response.body).to contains_pdf_text("My book Lorem ipsum dolor sit amet, consectetur").at_page(1)
      end
    end
  end
end
