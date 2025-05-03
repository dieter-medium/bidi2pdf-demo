module ExampleBasicProductDataSheetHelper
  def format_product_price(price_string)
    return "" if price_string.blank?

    price_val = price_string.to_f

    formatted_price = number_to_currency(price_val, unit: "", separator: ",", delimiter: "", precision: 2)

    formatted_price.sub(/,00$/, ",-")
  end

  def image_tag_with_placeholder(asset_path, placeholder: "placeholder.svg", options: {})
    if asset_path.blank? || !Rails.application.assets.resolver.resolve(asset_path).present?
      Rails.logger.warn("Image asset not found or path blank, rendering placeholder: #{asset_path.presence || 'blank'}")
      image_tag(placeholder, options)
    else
      image_tag(asset_path, options)
    end
  end
end
