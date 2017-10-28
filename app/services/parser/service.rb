# /app/services/parser/service.rb
class Parser::Service
  include Rails.application.routes.url_helpers

  def call(params)
    url = params[:walmart_url]
    encoded_url = Base64.strict_encode64(url)
    product = Product.new(encoded_walmart_url: encoded_url, walmart_url: url)
    Rails.logger.info"walmart_url: #{url}, product is new_record? #{product.new_record?}"

    if product.new_record?
      parser_unit = Parser::ParserUnit.new(url)
      product_params = parser_unit.product_params
      reviews_params = parser_unit.reviews_params
      product = persist_product(product, product_params, reviews_params)

      product.save! rescue Rails.logger.error "Parser::Service product save with error :#{product.error.full_messages}"
    end

    product
  end

  def persist_product(product, product_params, reviews_params)
    product.assign_attributes(product_params)
    reviews = reviews_params.map { |e| Review.new(e) }
    product.reviews = reviews
    product.reviews_url = product_reviews_path(product.id)

    product
  end
end
