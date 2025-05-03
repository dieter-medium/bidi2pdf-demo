class ExampleBasicProductDataSheetController < ApplicationController
  def show
    products = JSON.parse(File.read(Rails.root.join("vendor", "openui5", "mockdata", "Products.json")))

    @products = products.first(50)

    @bootstrap_disabled = true

    respond_to do |format|
      format.html
      format.pdf { render pdf: "example_basic_product_data_sheet" }
    end
  end
end
