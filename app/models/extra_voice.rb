class ExtraVoice < ApplicationRecord
  belongs_to :voice_actor
  has_one_attached :voice
end
