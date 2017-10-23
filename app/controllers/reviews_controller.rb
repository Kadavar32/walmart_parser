# app/controllers/reviews_controller.rb
class ReviewsController < ApplicationController

  def index
    product = Product.find_by(id: params[:product_id])

    render json: product.reviews
  end
end
