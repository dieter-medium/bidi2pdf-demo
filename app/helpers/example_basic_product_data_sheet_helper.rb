module ExampleBasicProductDataSheetHelper
  def format_product_price(price_string)
    return "" if price_string.blank?

    price_val = price_string.to_f

    formatted_price = number_to_currency(price_val, unit: "", separator: ",", delimiter: "", precision: 2)

    formatted_price.sub(/,00$/, ",-")
  end
end
