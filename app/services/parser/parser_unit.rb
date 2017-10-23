# /app/services/parser/parser_unit.rb
class Parser::ParserUnit

  def initialize(url)
    @doc = Nokogiri::HTML(open(url))
    @walmart_uid = walmart_uid
  end

  def get_product_params
    name = @doc.css('.prod-ProductTitle').text
    amount = @doc.css('.Price-characteristic').first.values.last rescue nil
    currency_code = @doc.css('.Price-currency').first.attributes['content'].value rescue nil
    currency_icon = @doc.css('.Price-currency').last.text rescue nil

    product_params = { name: name,
                       amount: amount,
                       currency_icon: currency_icon,
                       currency_code: currency_code }
    Rails.logger.info "Parser product_params #{product_params}"

    product_params
  end

  def get_reviews_params
    pagination_url = 'page=&sort=relevancy'
    reviews = []
    Rails.logger.info "walmart_uid #{@walmart_uid}"

    loop do
      url = "https://www.walmart.com/terra-firma/item/#{@walmart_uid}/reviews?filters=&limit=&#{pagination_url}"
      uri = URI(url)
      request_result = Net::HTTP.get_response(uri)

      break unless request_result.is_a?(Net::HTTPSuccess)

      Rails.logger.info "reviews request OK"
      json_data = JSON.parse(request_result.body).with_indifferent_access

      payload = json_data[:payload]
      next_page_data = payload[:pagination][:next]
      reviews_data = payload[:customerReviews]

      Rails.logger.info "Next page data: #{next_page_data}"
      Rails.logger.info "reviews present? #{reviews_data.present?}"

      reviews_data.each do |e|
        data = review_data(e)
        reviews.push(data)
      end

      if (next_page_data.present? && (next_page_data[:url] != pagination_url))
        pagination_url = next_page_data[:url]
      else
        break
      end
    end

    Rails.logger.info "reviews count #{reviews.count}"

    reviews
  end

  private

  def walmart_uid
    @doc.text[/selected":{"product":"(.*?)","defaultImage"/m, 1]
  end


  def review_data(review_data)
    { nickname: review_data['userNickname'],
      walmart_review_id: review_data['reviewId'],
      title: review_data['reviewTitle'],
      text: review_data['reviewText'],
      submission_time: review_data['reviewSubmissionTime'],
      rating: review_data['rating'],
      author_location: review_data['userLocation'] }
  end
end
