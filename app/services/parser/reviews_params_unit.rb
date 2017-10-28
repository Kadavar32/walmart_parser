# /app/services/parser/reviews_params_unit.rb
require 'oj'

class Parser::ReviewsParamsUnit

  def initialize(walmart_product_uid, pages_count)
    Rails.logger.info "walmart product_uid #{walmart_product_uid}, pages_count: #{pages_count}"
    @uid = walmart_product_uid
    @page_urls = map_page_urls(pages_count)
  end

  def call
    params = reviews_params
    Rails.logger.info "Parser reviews_params #{params}"
    params
  end

  private

  def map_page_urls(pages_count)
    (1..pages_count).to_a.map do |page|
      "https://www.walmart.com/terra-firma/item/#{@uid}/reviews?filters=&limit=&page=#{page}&sort=relevancy"
    end
  end

  def reviews_params
    workers = @page_urls.map do |url|
      Thread.new do
        begin
          json_data = Oj.load(request_to_walmart(url))
          Thread.current['reviews'] = reviews_data(json_data)
        rescue ThreadError => exc
          Rails.logger.info "Thread error: #{exc.message}"
        end
      end
    end

    workers.inject([]) { |reviews, t| t.join; reviews + t['reviews'] }
  end

  def reviews_data(json_data)
    customer_reviews_data = json_data['payload']['customerReviews']
    customer_reviews_data.map do |review_data|
      { nickname: review_data['userNickname'],
        walmart_review_id: review_data['reviewId'],
        title: review_data['reviewTitle'],
        text: review_data['reviewText'],
        submission_time: review_data['reviewSubmissionTime'],
        rating: review_data['rating'],
        author_location: review_data['userLocation'] }
    end
  end

  def request_to_walmart(url)
    uri = URI(url)
    request_result = Net::HTTP.get_response(uri)
    Rails.logger.info "GET reviews by url #{url}} request status OK"
    request_result.body
  end
end
