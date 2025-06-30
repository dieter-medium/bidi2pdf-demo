require "rails_helper"

RSpec.feature "As a developer, I want to an example of encrypted pdf's", :chromedriver, :pdf, type: :request do
  scenario "Rendering a PDF using the encryption example" do
    when_ "I visit the PDF version of a report" do
      before do
        @response = get_pdf_response "example_encryption/show.pdf"
      end

      then_ "I receive a successful HTTP response" do
        expect(@response.code).to eq("200")
      end

      and_ "I receive a PDF file in response" do
        expect(@response['Content-Type']).to eq("application/pdf")
      end

      and_ "the PDF contains the expected number of pages" do
        expected_page_count = 1

        with_pdf_debug(unencrypted_pdf("password")) do |pdf_data|
          expect(pdf_data).to have_pdf_page_count(expected_page_count)
        end
      end

      and_ "the disposition header is set to attachment" do
        expect(@response['Content-Disposition']).to start_with('inline; filename="example_encryption.pdf"')
      end

      and_ "the PDF contains the expected content" do
        expect(unencrypted_pdf("password")).to contains_pdf_text("PDF Encryption Example This example demonstrates how to generate a password-protected PDF").at_page(1)
      end

      and_ "the PDF is encrypted with the correct password" do
        expect do
          unencrypted_pdf "wrong_password"
        end.to raise_error(QpdfRuby::Error, /invalid password/)
      end

      and_ "the PDF can be decrypted with the user password" do
        decrypted_pdf = unencrypted_pdf("12345678")

        with_pdf_debug(decrypted_pdf) do |pdf_data|
          expect(pdf_data).to contains_pdf_text("PDF Encryption Example This example demonstrates how to generate a password-protected PDF").at_page(1)
        end
      end
    end
  end

  def unencrypted_pdf(password)
    doc = QpdfRuby::Document.from_memory(@response.body, password)
    doc.encrypt(
      user_pw: "",
      owner_pw: "",
      encryption_revision: QpdfRuby::ENCRYPTION_REVISION_AES_256U,
      allow_print: QpdfRuby::PRINT_LOW
    )
    doc.to_memory
  end
end
