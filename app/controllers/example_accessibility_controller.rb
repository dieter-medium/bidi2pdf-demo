class ExampleAccessibilityController < ApplicationController
  def show
    respond_to do |format|
      format.html
      format.pdf {
        render pdf: "example_accessibility",

               print_options: {
                 background: false,
                 cmd_type: :cdp,
                 generate_tagged_pdf: true,
                 generate_document_outline: true
               },
               callbacks: {
                 after_print: ->(url_or_content, browser_tab, binary_pdf_content, filename, controller) {
                   after_print_callback(url_or_content, browser_tab, binary_pdf_content, filename, controller)
                 }
               }
      }
    end
  end

  private

  def after_print_callback(url_or_content, _browser_tab, binary_pdf_content, filename, _controller)
    Tempfile.create([filename, ".pdf"]) do |temp_pdf|
      temp_pdf.binmode
      temp_pdf.write(binary_pdf_content)
      temp_pdf.flush
      temp_pdf.close

      meta = extract_meta_tags(url_or_content)
      update_pdf_xmp_metadata(temp_pdf.path, meta)

      pdf_with_fixed_xmp = File.binread(temp_pdf.path)

      fix_misc_pdf_quirks(pdf_with_fixed_xmp)
    end
  end

  # Extracts meta tags from the HTML content
  def extract_meta_tags(html_content)
    doc = Nokogiri::HTML(html_content)
    {
      author: doc.at('meta[name="author"]')&.[]("content") || "Default Author",
      title: doc.at("title")&.text&.strip || "Default Title",
      subject: doc.at('meta[name="description"]')&.[]("content") || "Default Subject",
      language: doc.at("html")&.[]("lang") || "en-US"
    }
  end

  # Updates the PDF's XMP metadata using ExifTool
  def update_pdf_xmp_metadata(pdf_path, meta)
    if defined?(XmpToolkitRuby::XmpFile)
      logger.info "Updating PDF metadata using XmpToolkitRuby with plugin-path: #{XmpToolkitRuby::PLUGINS_PATH}"

      XmpToolkitRuby::XmpFile.with_xmp_file(pdf_path,
                                            open_flags: XmpToolkitRuby::XmpFileOpenFlags.bitmask_for(:open_for_update, :open_use_smart_handler)
      ) do |xmp_file|
        now = XmpToolkitRuby::XmpValue.new(DateTime.now, type: :date)

        XmpToolkitRuby::XmpFile.register_namespace XmpToolkitRuby::Namespaces::XMP_NS_PDFUA_ID, "pdfuaid"

        xmp_file.update_property XmpToolkitRuby::Namespaces::XMP_NS_PDFUA_ID, "part", "1"
        xmp_file.update_property XmpToolkitRuby::Namespaces::XMP_NS_XMP, "CreateDate", now
        xmp_file.update_property XmpToolkitRuby::Namespaces::XMP_NS_XMP, "ModifyDate", now

        xmp_file.update_property XmpToolkitRuby::Namespaces::XMP_NS_XMP, "CreatorTool", "Bidi2pdfRails"
        xmp_file.update_property XmpToolkitRuby::Namespaces::XMP_NS_XMP, "Language", meta[:language]

        xmp_file.update_localized_property schema_ns: XmpToolkitRuby::Namespaces::XMP_NS_DC,
                                           alt_text_name: "title",
                                           generic_lang: "",
                                           specific_lang: meta[:language],
                                           item_value: meta[:title],
                                           options: 0

        xmp_file.update_localized_property schema_ns: XmpToolkitRuby::Namespaces::XMP_NS_DC,
                                           alt_text_name: "description",
                                           generic_lang: "",
                                           specific_lang: meta[:language],
                                           item_value: meta[:subject],
                                           options: 0

        author = meta[:author]
        xmp_file.update_property(
          XmpToolkitRuby::Namespaces::XMP_NS_PDF,
          "Author",
          author
        )
      end
    else
      raise "XmpToolkitRuby is not available. Please install the gem to update PDF metadata."
    end
  end

  def fix_misc_pdf_quirks(pdf_content)
    doc = QpdfRuby::Document.from_memory(pdf_content, "")
    doc.mark_paths_as_artifacts
    doc.ensure_bbox

    # doc.show_structure

    doc.to_memory
  end
end
