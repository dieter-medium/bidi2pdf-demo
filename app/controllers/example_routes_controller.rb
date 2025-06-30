# frozen_string_literal: true

class ExampleRoutesController < ApplicationController
  def index
    @examples = [
      {
        title: "Book Spread Example (Paged.js)",
        controller: "ExampleBookSpreadController",
        action: "show",
        description: "This page demonstrates a Paged.js book spread example, inspired by",
        repo_url: "https://gitlab.coko.foundation/pagedjs/starter-kits/book-spread_esm",
        repo_text: "pagedjs/starter-kits/book-spread_esm",
        url: example_book_spread_url,
        pdf_url: example_book_spread_url(format: :pdf)
      },
      {
        title: "Book Template Interface (Paged.js)",
        controller: "ExampleAdvancedPagedjsInterfaceController",
        action: "show",
        description: "This page demonstrates a Paged.js book template with interface example, inspired by",
        repo_url: "https://gitlab.coko.foundation/pagedjs/starter-kits/book_avanced-interface",
        repo_text: "pagedjs/starter-kits/book_avanced-interface",
        url: example_advanced_pagedjs_interface_url,
        pdf_url: example_advanced_pagedjs_interface_url(format: :pdf)
      },
      {
        title: "Basic Product Data Sheet",
        controller: "ExampleBasicProductDataSheetController",
        action: "show",
        description: "This page demonstrates a basic product data sheet example, inspired by",
        repo_url: "https://github.com/CSS-Paged-Media/printcss-example-code/tree/main",
        repo_text: "CSS-Paged-Media/printcss-example-code",
        url: example_basic_product_data_sheet_url,
        pdf_url: example_basic_product_data_sheet_url(format: :pdf)
      },
      {
        title: "Shipping Label Example",
        controller: "ExampleShippingLabelController",
        action: "show",
        description: "This page demonstrates a shipping label example, inspired by",
        repo_url: "https://github.com/CSS-Paged-Media/printcss-example-code/tree/main",
        repo_text: "HTML Examples/E-Commerce Examples/Shipping Label",
        url: example_shipping_label_url,
        pdf_url: example_shipping_label_url(format: :pdf)
      },
      {
        title: "Async PDF Generation",
        controller: "ExampleAsyncPdfController",
        action: "generate",
        description: "This page demonstrates how to generate a PDF asynchronously using ActiveJob and ActionCable.",
        url: example_async_pdf_generate_url
      },
      {
        title: "Accessibility Example",
        controller: "ExampleAccessibilityController",
        action: "show",
        description: "This page demonstrates how to generate a PDF with accessibility features using Paged.js and post-processing with xmp_toolkit_ruby and qpdf_ruby. The quirky html is needed to get a good tagged PDF.",
        url: example_accessibility_url,
        pdf_url: example_accessibility_url(format: :pdf)
      },
      {
        title: "Encryption Example",
        controller: "ExampleEncryptionController",
        action: "show",
        description: "This page demonstrates how to generate a password-protected PDF using qpdf_ruby for postprocessing. The user password is '12345678' and the owner password is 'password'.",
        url: example_encryption_url,
        pdf_url: example_encryption_url(format: :pdf)
      }
    ]
  end
end
