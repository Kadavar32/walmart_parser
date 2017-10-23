# /app/services/parser/service.rb
class Parser::Service
  include Rails.application.routes.url_helpers

  def call(params)
    url = params[:walmart_url]
    encoded_url = Base64.encode64(url)
    product = Product.find_or_initialize_by(encoded_walmart_url: encoded_url, walmart_url: url)
    Rails.logger.info"walmart_url: #{url}, product is new_record? #{product.new_record?}"

    if product.new_record?
      parser_unit = ::Parser::Service::ParserUnit.new(url)
      product.assign_attributes(parser_unit.get_product_params)
      product.reviews = parser_unit.get_reviews_params.map { |e| Review.new e }
      product.reviews_url = product_reviews_path(product.id)
      product.save! rescue Rails.logger.error "Parser::Service product save with error :#{product.error.full_messages}"
    end

    product
  end
end
