# /app/models/product.rb
class Product
  include Mongoid::Document
  include Mongoid::Search

  field :name, type: String
  field :walmart_url, type: String
  field :encoded_walmart_url, type: String
  field :amount, type: BigDecimal
  field :currency_icon, type: String
  field :currency_code, type: String
  field :reviews_url, type: String

  embeds_many :reviews

  index({ walmart_url: 1 }, { unique: true, name: 'walmart_url_index' })

  search_in :name, reviews: [ :text, :title ]

  def as_json(options = {})
    super({ except: [:_id, :_keywords, :reviews], methods: [:uid] }.merge(options))
  end

  def uid
    id.to_s
  end
end
