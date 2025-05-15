require "rails_helper"

RSpec.feature "As a developer, I want to an example of book template interface", :chromedriver, :pdf, type: :request do
  scenario "Rendering a PDF using the book spread example" do
    when_ "I visit the PDF version of a report" do
      before do
        @response = get_pdf_response "example_advanced_pagedjs_interface/show.pdf"
      end

      then_ "I receive a successful HTTP response" do
        expect(@response.code).to eq("200")
      end

      and_ "I receive a PDF file in response" do
        expect(@response['Content-Type']).to eq("application/pdf")
      end

      and_ "the PDF contains the expected number of pages" do
        expected_page_count = 5

        with_pdf_debug(@response.body) do |pdf_data|
          expect(pdf_data).to have_pdf_page_count(expected_page_count)
        end
      end

      and_ "the disposition header is set to attachment" do
        expect(@response['Content-Disposition']).to start_with('inline; filename="example_pagedjs_interface.pdf"')
      end

      and_ "the PDF contains the expected content" do
        expect(@response.body).to contains_pdf_text("My book Lorem ipsum dolor sit amet, consectetur").at_page(1)
      end
    end
  end
end
