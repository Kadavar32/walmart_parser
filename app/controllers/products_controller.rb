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
    render json: { errors: exc.message }
  end

  def new; end

  private

  def product_params
    params.require(:product).permit(:url)
  end
end
