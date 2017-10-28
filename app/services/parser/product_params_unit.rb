# /app/services/parser/product_params_unit.rb
class Parser::ProductParamsUnit

  def initialize(doc)
    @doc = doc
  end

  def call
    params = product_data
    Rails.logger.info "Parser product_params #{params}"

    params
  end

  private

  def product_data
    name = @doc.css('.prod-ProductTitle').text
    amount_value = @doc.css('.Price-characteristic').first.text
    amount_mantissa = @doc.css('.Price-mantissa').first.text
    amount = BigDecimal.new("#{amount_value}.#{amount_mantissa}")

    currency_icon = @doc.css('.Price-currency').first.text

    { name: name, amount: amount, currency_icon: currency_icon }
  end
end
