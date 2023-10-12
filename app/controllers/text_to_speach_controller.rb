class TextToSpeachController < ApplicationController
  def tts
    @user = User.find_or_create_by(discord_user_id: tts_param[:discord_user_id]) do |user|
      user.voice_actor_id = 1
      user.name = tts_param[:discord_user_name]
    end
    if @user.name != tts_param[:discord_user_name] && tts_param[:discord_user_name] != ''
      @user.name = tts_param[:discord_user_name]
      @user.save
    end
    @user.increment(:count,1)
    @user.save
    @voice_actor = @user.voice_actor
    vh = @voice_actor.to_speech(tts_param[:text])
    vh.increment(:count,1)
    vh.save

    send_data vh.voice.download, filename: "#{vh.voice.filename}"
  end

  private

  def tts_param
    params.permit(:discord_user_id, :discord_user_name, :text)
  end
end
