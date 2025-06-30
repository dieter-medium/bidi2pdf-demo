class ExampleEncryptionController < ApplicationController
  def show
    respond_to do |format|
      format.html
      format.pdf {
        render pdf: "example_encryption",
               callbacks: {
                 after_print: ->(url_or_content, browser_tab, binary_pdf_content, filename, controller) {
                   after_print_callback(url_or_content, browser_tab, binary_pdf_content, filename, controller)
                 }
               }
      }
    end
  end

  private

  def after_print_callback(_url_or_content, _browser_tab, binary_pdf_content, _filename, _controller)
    raise "QpdfRuby::Document is not available. Please install the gem qpdf_ruby to add password." unless defined?(QpdfRuby::Document)

    doc = QpdfRuby::Document.from_memory(binary_pdf_content, "")

    doc.encrypt(
      user_pw: "12345678",
      owner_pw: "password",
      encryption_revision: QpdfRuby::ENCRYPTION_REVISION_AES_256U,
      allow_print: QpdfRuby::PRINT_LOW,
      allow_modify: true,
      allow_extract: false,
      accessibility: true,
      assemble: false,
      annotate_and_form: false,
      form_filling: false,
      encrypt_metadata: true,
      use_aes: true
    )
    doc.to_memory
  end
end
