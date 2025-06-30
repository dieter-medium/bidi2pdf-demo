require "rails_helper"

RSpec.feature "As a developer, I want to an example of accessible pdf's", :chromedriver, :pdf, type: :request do
  scenario "Rendering a PDF using the accessibility example" do
    when_ "I visit the PDF version of a report" do
      before do
        @response = get_pdf_response "example_accessibility/show.pdf"
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
        expect(@response['Content-Disposition']).to start_with('inline; filename="example_accessibility.pdf"')
      end

      and_ "the PDF contains the expected content" do
        expect(@response.body).to contains_pdf_text("Accessible Web Content Overview Accessible Web Content Overview").at_page(1)
      end

      and_ "the PDF contains XMP metadata" do
        tempfile = Tempfile.new(['example_accessibility', '.pdf'])
        tempfile.binmode
        tempfile.write(@response.body)
        tempfile.flush
        tempfile.close

        xmp = XmpToolkitRuby.xmp_from_file(tempfile.path.to_s)

        expected_xmp = <<~XMP
                     <x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="XMP Core 6.0.0">
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
              <rdf:Description xmlns:xmp="http://ns.adobe.com/xap/1.0/" xmlns:pdf="http://ns.adobe.com/pdf/1.3/"
                               xmlns:pdfuaid="http://www.aiim.org/pdfua/ns/id/" xmlns:dc="http://purl.org/dc/elements/1.1/"
                               rdf:about="">
                <xmp:CreateDate>2025-06-18T10:21:4102:00</xmp:CreateDate>
                <xmp:CreatorTool>Bidi2pdfRails</xmp:CreatorTool>
                <xmp:ModifyDate>2025-06-18T10:21:4102:00</xmp:ModifyDate>
                <xmp:Language>en</xmp:Language>
                <pdf:Producer>Skia/PDF m137</pdf:Producer>
                <pdfuaid:part>1</pdfuaid:part>
                <dc:title>
                  <rdf:Alt>
                    <rdf:li xml:lang="x-default">Accessibility example</rdf:li>
                    <rdf:li xml:lang="en">Accessibility example</rdf:li>
                  </rdf:Alt>
                </dc:title>
                <dc:description>
                  <rdf:Alt>
                    <rdf:li xml:lang="x-default">Bidi2pdf Demo</rdf:li>
                    <rdf:li xml:lang="en">Bidi2pdf Demo</rdf:li>
                  </rdf:Alt>
                </dc:description>
                <dc:creator>
                  <rdf:Seq>
                    <rdf:li>Dieter S.</rdf:li>
                  </rdf:Seq>
                </dc:creator>
              </rdf:Description>
            </rdf:RDF>
          </x:xmpmeta>
        XMP

        actual_xml = Nokogiri::XML(xmp["xmp_data"], &:noblanks)
        expected_xml = Nokogiri::XML(expected_xmp, &:noblanks)

        %w[CreateDate ModifyDate].each do |date_field|
          metadata_date_node = actual_xml.at_xpath("//xmp:#{date_field}", "xmp" => XmpToolkitRuby::Namespaces::XMP_NS_XMP)
          metadata_date_node.content = "DUMMY_DATE" if metadata_date_node

          expected_date_node = expected_xml.at_xpath("//xmp:#{date_field}", "xmp" => XmpToolkitRuby::Namespaces::XMP_NS_XMP)
          expected_date_node.content = "DUMMY_DATE" if expected_date_node
        end

        metadata_date_node = actual_xml.at_xpath("//pdf:Producer", "pdf" => XmpToolkitRuby::Namespaces::XMP_NS_PDF)
        metadata_date_node.content = "DUMMY_PRODUCER" if metadata_date_node

        expected_date_node = expected_xml.at_xpath("//pdf:Producer", "pdf" => XmpToolkitRuby::Namespaces::XMP_NS_PDF)
        expected_date_node.content = "DUMMY_PRODUCER" if expected_date_node

        expect(actual_xml.to_s).to eq(expected_xml.to_s)
      end

      and_ "the tag structure is correct" do
        doc = QpdfRuby::Document.from_memory(@response.body, "")
        actual_structure = doc.show_structure

        structure_file = File.expand_path("../fixtures/example_accessibility_structure.xml", __dir__)
        expected_structure = File.read(structure_file)

        actual_xml = Nokogiri::XML(actual_structure, &:noblanks)
        expected_xml = Nokogiri::XML(expected_structure, &:noblanks)

        [actual_xml, expected_xml].each do |xml|
          xml.xpath('//@ID').remove
        end

        expect(actual_xml.to_s).to eq(expected_xml.to_s)
      end
    end
  end
end
