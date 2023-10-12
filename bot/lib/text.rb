# frozen_string_literal: true
require_relative 'twitter_url'

class Text
  # @param text [String]
  # @return Text
  def initialize(text,server_id)
    @text = text
    @result = ""
    @server_id = server_id
  end

  # @return [String]
  def tts
    @result = @text
    @result = reply2name(@result,$bot)
    @result = url2text(@result)
    @result = shorten_text(@result)
    puts "text[#{@text}] => result[#{@result}]"
    @result
  end

  # @return [Boolean]
  def empty?
    @text.empty?
  end


  private
  # @param [String] text
  # @return [String]
  # textからreplyをusernameに変える
  def reply2name(text,bot)
    text.gsub(/<@(\d+)>/) do |g|
      nick = bot.user($1).on(@server_id).nick.to_s
      nick = bot.user($1).username if nick == ''
      "#{nick}へのメンション"
    end
  end

  # @param [String] text
  # @return [String]
  # textからreplyをusernameに変える
  def shorten_text(text)
    if text.size > 30
      "#{text[0..30]}以下略"
    else
      text
    end
  end

  def repeat2short(text)
    if text.split(".").uniq.size == 1
      text[0..1]
    else
      text
    end
  end

  def twitter(url)
    TwitterURL.twitter_client_authentication
    tweet = TwitterURL.status File.basename(URI.parse(url).path)
    "#{tweet.user.name}のツイート"
  end

  def detect_url(url)
    if url.include?("https://twitter.com")
#      twitter(url)
      "URL省略"
    else
      "URL省略"
    end
  end

  def url2text(text)
    urls = URI.extract(text)
    urls.each do |url|
      text.gsub!(url, detect_url(url))
    end
    text
  end

end
