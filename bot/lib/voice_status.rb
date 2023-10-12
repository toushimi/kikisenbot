# frozen_string_literal: true

VOICE_STATUS=[:join, :leave, :mute, :suppress, :online, :bot]

# @param [Discordrb::Events::VoiceStateUpdateEvent] event
# @return Symbol
def determination_voice_status(event)
  if event.user == event.bot.profile
    :bot
  elsif event.old_channel == nil && event.channel != nil # join
    :join
  elsif event.old_channel != nil && event.channel == nil # leave
    :leave
  elsif event.channel == event.old_channel
    if event.self_mute
      :mute
    elsif event.self_deaf
      :suppress
    else
      :online
    end
  else
    :online
  end
end