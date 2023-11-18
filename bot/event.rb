# frozen_string_literal: true
require_relative 'tts'
require_relative 'lib/twitter_url'
# @param [Discordrb::Bot] bot
# @param [Discordrb::Channel] chan
# on boot/connect channel notification
def join_voice_channel(bot,chan)
  return if $voice[chan.id] != nil
  $voice[chan.id] = TTS.new($stt[chan.id],chan.id,bot)
end

# @param [Discordrb::Events::VoiceStateUpdateEvent] event
def bot_join_voice_channel(event)
  unless event.channel.users.empty?
    join_voice_channel($bot,event.channel)
  end
end

# @param [Discordrb::Events::MessageEvent] event
def embedded_twitter_url(event)
  m = /(https:\/\/x\.com\/.+)|(https:\/\/twitter\.com\/.+) *\Z/.match(event.message.content)
  return unless m
  url = m[1]
  twitter_status = TwitterURL.new(event.message.content)
  event.channel.send_embed do |embed|
    embed.color = 0xfaab00
    embed.author = twitter_status.author
    embed.thumbnail = twitter_status.thumbnail
    embed.image = twitter_status.image
    embed.title = twitter_status.description
    embed.url = twitter_status.article
  end
end