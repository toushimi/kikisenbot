require 'discordrb'
require 'net/http'
require 'json'
require 'uri'
require 'twitter'
require 'thread'

# User Library
require_relative 'lib/text'
require_relative 'lib/signal'
require_relative 'lib/voice_status'
require_relative 'event'
require_relative 'tts'
require_relative 'user_action'

$bot = Discordrb::Bot.new(
  #  log_mode: :debug,
  token: ENV.fetch('DISCORD_BOT_TOKEN')
)
$commandbot = Discordrb::Commands::CommandBot.new(
  #  log_mode: :debug,
  token: ENV.fetch('DISCORD_BOT_TOKEN'),
  prefix: '/'
)

# @type [Hash] $tts Text -> Speech
$tts = {ENV.fetch('DISCORD_TEXTCHANNEL_ID').to_i => ENV.fetch('DISCORD_VOICECHANNEL_ID').to_i}
# @type [Hash] $stt Speech -> Text
$stt = {ENV.fetch('DISCORD_VOICECHANNEL_ID').to_i => ENV.fetch('DISCORD_TEXTCHANNEL_ID').to_i}
# @type [Hash<TTS>] $voice Speech -> TTS
$voice = {}
$thread = {}
$voice_queue = []
$say_mutex = Thread::Mutex.new
$post_mutex = Thread::Mutex.new
$bot_action_mutex = Thread::Mutex.new

$commandbot.command :add_extravoice do |event, *args|

end

$bot.direct_message do |event|
  text = event.text
  break unless text.start_with?('/')
  command, args = text.split(' ', 2)

  case command
  when '/list'
    $bot.send_message event.channel, list_voice_actors
  when '/change'
    change_voice_actor(args, event)
  end
end
# TTS
$bot.message do |event|
  puts "$tts.keys.include? #{$tts.keys.include?(event.channel.id)}"
  break unless $tts.keys.include?(event.channel.id)
  puts "$voice[$tts[event.channel.id]] is  #{$voice[$tts[event.channel.id]]}"
  break if $voice[$tts[event.channel.id]] == nil
  $voice[$tts[event.channel.id]].to_speech event
end
$bot.voice_state_update do |event|
  action = determination_voice_status(event)
  channel = event.channel
  channel = event.old_channel if channel.nil? # TODO: VoiceChannel間の移動
  next if channel.nil?
  # 新規接続またはBot起動時
  if [:online, :join].include?(action) && $tts.values.include?(channel.id)
    pp $stt[channel.id]

    $voice[channel.id] = TTS.new($stt[channel.id],channel,$bot) if $voice[channel.id].nil?
  end
  # Voice Channelに人がいないけどActive(Botのみの場合)
  if action == :leave && $voice[channel.id] != nil
    if channel.users.size == 1
      $voice[channel.id].destroy
      $voice[channel.id] = nil
      next
    end
  end
  $voice[channel.id].voice_channel_activity(event,action) if channel != nil && $voice[channel.id] != nil
end

$bot.ready do
  $bot.game = "読み上げ"
  $tts.values.each do |channel|
    chan = $bot.channel(channel)
    unless chan.users.empty?
      join_voice_channel($bot, chan)
    end
  end
end
#$bot.run
$bot.run(:async)
loop do

  sleep 5
end
