# /app/models/review.rb
class Review
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  field :walmart_review_id, type: Integer
  field :text, type: String
  field :nickname, type: String
  field :text, type: String
  field :title, type: String
  field :submission_time, type: String

  embedded_in :review

  def as_json(options = {})
    super({ except: [:_id, :_keywords] })
  end
end
