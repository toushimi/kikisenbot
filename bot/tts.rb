# frozen_string_literal: true
require 'thread'

class TTS
  attr_accessor :thread

  # @param [String] text_channel
  # @param [String] voice_channel
  # @param [Discordrb::Bot] bot
  def initialize(text_channel,voice_channel,bot)
    @uuid = SecureRandom.uuid
    puts "#{@uuid}: initialize TTS to #{text_channel}, #{voice_channel}"
    # @type [Discordrb::Bot] @bot
    @bot = bot
    @text_chan  = text_channel
    @voice_chan = voice_channel
    @voice = nil
    @voice_queue = []
    @say_mutex = Thread::Mutex.new
    @bot_action_mutex = Thread::Mutex.new
    connect
    puts "#{@uuid}: boot message"
    @voice_queue << bot_speech("あかりとーきんぐが起動したのだ")
    puts "#{@uuid}: boot message in queued"
    thread.wakeup
    puts "initialize complete! TTS to #{text_channel}, #{voice_channel}"
  end

  # @param [Discordrb::Events::VoiceStateUpdateEvent] event
  # @param [Symbol] type
  def voice_channel_activity(event,type)
    case type
    when :join
      @voice_queue << bot_speech("#{get_name(event)}さんが来ました")
    when :leave
      @voice_queue << bot_speech("#{get_name(event)}さんが抜けました")
    when :mute
    when :supress
    when :online
    end
    @thread.wakeup
  end

  # Voice Connectionの削除
  def destroy
    @voice.destroy
    @voice = nil
    thread.kill if thread.alive?
    @voice_queue.each do|q|
      File.delete("#{q}.wav")
    end
  end

  # @param [Discordrb::Message] event
  # @return [Array<String>]
  def to_speech(event)
    author = event.author.nick.to_s
    author = event.author.username if author == ''
    if event.text == 'ずんだもんがしゃべらないのだ'
      reconnect
      return
    end
    if event.text == 'プラグアウト'
      plugout(event)
    end
    text = Text.new(event.text,event.server.id)
    speeches = get_speech(event, author, text)
    @voice_queue << speeches
    thread.wakeup
    @voice_queue
  end

  def bot_speech(text)
    [send_request($bot.bot_user.id, text, $bot.profile.username)]
  end

  # @param [Discordrb::Message] event
  # @param [String] discord_user_name
  # @param [Text] text
  def get_speech(event, discord_user_name,text)
    author_id = event.author.id
    author_name = event.author.username
    author = send_request($bot.bot_user.id, "#{discord_user_name}さん", $bot.bot_user.name)
    speech = send_request(author_id, text.tts ,author_name) unless text.empty?

    [author, speech].compact
  end
  # @param [Integer] author_id
  # @param [String] text
  # @param [String] author_name
  def send_request(author_id, text, author_name="")
    res = nil
    uri = URI.parse('http://web:3000/tts')
    params = { "discord_user_id": author_id, "text": text, "discord_user_name": author_name }
    req = Net::HTTP::Post.new(uri)
    req.content_type = 'application/json'
    req.body = params.to_json
    res = Net::HTTP.start(uri.hostname, uri.port) { |http|
      http.request(req)
    }
    uuid = SecureRandom.uuid
    open("#{uuid}.wav","wb"){|f| f.write(res.body)}
    uuid
  end


  def say
    return if @voice == nil
    return if @voice_queue.empty?
    return if @say_mutex.locked?
    @say_mutex.synchronize do
      while (speech = @voice_queue.shift) != nil
        speech.each do |item|
          @voice.play_file("#{item}.wav")
          File.delete("#{item}.wav")
        end
      end
    end
  end

  # @param [Discordrb::Message] event
  def plugout(event)
    author = event.author
    server = event.server
    Discordrb::API::Server.update_member($bot.token, server.id, author.id, channel_id: nil)
  end

  def connect
    puts "#{@uuid}: Voice connecting..."
    #@param @voice [Discordrb::Voice::VoiceBot]
    @voice = @bot.voice_connect(@voice_chan)
    puts "#{@uuid}: Connect completed. "
    print "#{@uuid}: "; p @voice
    puts "#{@uuid}: Create thread..."
    # @type [Thread] @thread
    @thread = create_thread if @thread == nil || !@thread.alive?
    puts "#{@uuid}: Create thread completed. Naming..."
    @thread.name = @text_chan.to_s
    puts "#{@uuid}: Named #{@thread.name}"
  end

  def disconnect
    @voice.destroy
    @voice = nil
  end

  def reconnect
    @say_mutex.synchronize do
      disconnect
      connect
      @voice_queue << bot_speech("あかりとーきんぐが再起動したのだ")
      thread.wakeup
    end
  end

  def create_thread
    Thread.new do
      loop do
        Thread.stop
        say
      end
    end
  end

  private

  # @param [Discordrb::Events::VoiceStateUpdateEvent] event
  def get_name(event)
    nick = event.user.on(event.server.id).nick.to_s
    nick = event.user.name if nick == ''
    nick
  end
end
