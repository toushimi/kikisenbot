# frozen_string_literal: true

class TwitterURL
  FERRUM_OPTION={headless: :new, window_size: [1280,720], browser_options: {'no-sandbox': nil}}
  USER_AGENT='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36'
  OGTITLE_REGEXP=/(?<author>.+)on\sX:\s\"(?<description>.+)\"/m
  attr_reader :author, :icon, :description, :image, :article, :thumbnail
  def initialize(url)
    @browser = Ferrum::Browser.new(FERRUM_OPTION)
    @twitter_url = url
    @browser.headers.set('User-Agent': USER_AGENT)
    @browser.go_to(@twitter_url)
    @browser.network.wait_for_idle
    fetch
    close
  end

  private
  def fetch
    @author ||= _author
    @description ||= _description
    @thumbnail ||= _thumbnail
    @image ||= _image
    @article ||= _article
  end

  def close
    @browser.quit
  end

  def _author
    author_name = _author_name
    author_icon = _icon
    author_url  = _author_url
    Discordrb::Webhooks::EmbedAuthor.new(name: author_name,url: author_url.to_s,icon_url: author_icon.to_s)
  end

  def _author_name
    tmp = @browser.at_css("meta[property='og:title']").attribute 'content'
    m = OGTITLE_REGEXP.match(tmp)
    m[:author]
  end
  def _icon
    URI.parse(@browser.at_css('article img[src*=profile_images]').attribute 'src')
  end

  def _description
    tmp = @browser.at_css("meta[property='og:title']").attribute 'content'
    m = OGTITLE_REGEXP.match(tmp)
    m[:description]
  end

  def _thumbnail
    Discordrb::Webhooks::EmbedThumbnail.new(url: _icon)
  end
  def _image
    Discordrb::Webhooks::EmbedImage.new(url: URI.parse(@browser.at_css("article img[src*='media']").attribute 'src'))
  end

  def _article
    URI.parse(@twitter_url)
  end

  def _author_url
    author_url = URI.parse(@twitter_url)
    author_url.path = File.dirname(File.dirname(author_url.path))
    author_url
  end
end
