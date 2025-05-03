class ExampleBasicProductDataSheetController < ApplicationController
  def show
    # load the first 5 products from Rails.root.join("vendor", "openui5", "mockdata", "Products.json")
    products = JSON.parse(File.read(Rails.root.join("vendor", "openui5", "mockdata", "Products.json")))

    @products = products.first(5)
    @bootstrap_disabled = true

    respond_to do |format|
      format.html
      format.pdf { render pdf: "example_basic_product_data_sheet" }
    end
  end
end
