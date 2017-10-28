# /app/services/parser/parser_unit.rb
class Parser::ParserUnit

  def initialize(url)
    @doc = Nokogiri::HTML(open(url))
    @uid = walmart_uid
    @product_params_unit = Parser::ProductParamsUnit.new(@doc)
    @reviews_params_unit = Parser::ReviewsParamsUnit.new(@uid, pages_count)
  end

  def product_params
    @product_params_unit.call
  end

  def reviews_params
    @reviews_params_unit.call
  end

  private

  def walmart_uid
    @doc.text[/selected":{"product":"(.*?)","defaultImage"/m, 1]
  end

  def pages_count
    @doc.css('#customer-reviews').css('.paginator-list').children.count
  end
end
