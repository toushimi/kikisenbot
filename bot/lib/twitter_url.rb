# frozen_string_literal: true

class TwitterURL

  # class variables
  @@twitter = false

  def initialize
    def twitter_client_authentication
      @@twitter ||= Twitter::REST::Client.new do |config|
        config.consumer_key    = ENV.fetch("TWITTER_CONSUMER_KEY")
        config.consumer_secret = ENV.fetch("TWITTER_CONSUMER_SECRET")
      end
    end

    def self.status(id)
      @@twitter.status(id)
    end
  end
end
