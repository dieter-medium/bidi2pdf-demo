require "rails_helper"
require "docker"
require "bidi2pdf/test_helpers/testcontainers"
require "pp"

RSpec.feature "As a developer, I want to an example of book spread", :chromedriver, :pdf, type: :request do
  before :all do
    if inside_container?
      container_id = Socket.gethostname
      container = Docker::Container.get(container_id)

      RSpec.configuration.shared_network&.connect(container.id, nil, { "EndpointConfig" => { "Aliases" => ["my-rails-app"] } })

      # restart_server
    end
  end

  after :all do
    if inside_container?
      container_id = Socket.gethostname
      container = Docker::Container.get(container_id)
      RSpec.configuration.shared_network&.disconnect(container.id)
    end
  end

  before do
    with_render_setting :browser_url, session_url

    with_lifecycle_settings :after_print, ->(_url_or_content, _browser_tab, binary_pdf_content, _filename, _controller) { store_pdf_file(binary_pdf_content, "rendered") }

    if inside_container?
      with_pdf_settings :asset_host, "http://my-rails-app:#{server_port}/"
    else
      with_pdf_settings :asset_host, "http://host.docker.internal:#{server_port}"
    end
    Bidi2pdfRails::ChromedriverManagerSingleton.initialize_manager force: true
  end

  after do
    Bidi2pdfRails::ChromedriverManagerSingleton.shutdown
  end

  scenario "Rendering a PDF using the book spread example" do
    when_ "I visit the PDF version of a report" do
      before do
        @response = get_pdf_response "example_book_spread/show.pdf"
      end

      then_ "I receive a successful HTTP response" do
        expect(@response.code).to eq("200")
      end

      and_ "I receive a PDF file in response" do
        expect(@response['Content-Type']).to eq("application/pdf")
      end

      and_ "the PDF contains the expected number of pages" do
        expected_page_count = 4

        with_pdf_debug(@response.body) do |pdf_data|
          expect(pdf_data).to have_pdf_page_count(expected_page_count)
        end
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
