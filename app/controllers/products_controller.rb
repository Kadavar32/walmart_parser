require 'open-uri'
# app/controllers/products_controller.rb
class ProductsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    url = product_params[:url]

    service_params = { walmart_url: url }
    product = ::Parser::Service.new.call(service_params)

    render json: product.as_json
  rescue => exc
    Rails.logger.error "search error #{exc.message}"
    render json: { errors: exc.message }
  end

  def search
    q = params[:q]
    products = Product.fulltext_search(q)

    render json: products.as_json
  rescue => exc
    Rails.logger.error "search error #{exc.message}"
    render json: []
  end

  def new; end

  private

  def product_params
    params.require(:product).permit(:url)
  end
end
