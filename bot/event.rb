# frozen_string_literal: true
require_relative 'tts'

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

