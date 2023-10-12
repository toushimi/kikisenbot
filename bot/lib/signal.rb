# frozen_string_literal: true

Signal.trap(:INT) {
  unless $voice == nil
    $voice.destroy
  end
  $bot.invisible
  exit 0
}
