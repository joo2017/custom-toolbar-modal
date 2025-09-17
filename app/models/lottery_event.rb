# app/models/lottery_event.rb
class LotteryEvent < ActiveRecord::Base
  belongs_to :post
  has_many :lottery_winners, dependent: :destroy
  has_many :winner_users, through: :lottery_winners, source: :user
  
  has_one :topic, through: :post
  has_one :creator, through: :post, source: :user

  validates :activity_name, presence: true, length: { maximum: 200 }
  validates :prize_description, presence: true, length: { maximum: 1000 }
  validates :draw_time, presence: true
  validates :winner_count, presence: true, numericality: { greater_than: 0 }
  validates :participation_threshold, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :backup_strategy, inclusion: { in: %w[continue cancel] }

  scope :active, -> { where(status: 'active') }
  scope :pending_draw, -> { where(status: 'active').where('draw_time <= ?', Time.current) }

  def specific_floor_numbers
    return [] if specific_floors.blank?
    specific_floors.split(',').map(&:strip).map(&:to_i).reject(&:zero?)
  end

  def can_draw?
    status == 'active' && draw_time <= Time.current
  end

  def sufficient_participants?
    topic.posts.count >= participation_threshold
  end
end

# app/models/lottery_winner.rb
class LotteryWinner < ActiveRecord::Base
  belongs_to :lottery_event
  belongs_to :user

  validates :floor_number, presence: true, numericality: { greater_than: 0 }
  validates :win_type, inclusion: { in: %w[random specific] }
end
