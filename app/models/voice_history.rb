class VoiceHistory < ApplicationRecord
  belongs_to :voice_actor
  has_one_attached :voice
  def self.housekeeping
    histories = VoiceHistory.where('updated_at <= ?', Time.now.last_month)
    histories.each do |item|
      item.destroy
    end
  end
end
