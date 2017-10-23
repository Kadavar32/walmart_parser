# /app/models/review.rb
class Review
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Search

  field :walmart_review_id, type: Integer
  field :text, type: String
  field :nickname, type: String
  field :text, type: String
  field :title, type: String
  field :submission_time, type: String

  embedded_in :review, inverse_of: :members

  search_in :text, :title

  def as_json(options = {})
    super({ except: [:_id, :_keywords] })
  end
end
