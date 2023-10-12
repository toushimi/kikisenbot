class VoiceHistoriesController < ApplicationController
  def index
    @voice_histories = VoiceHistory.all.order("`count` desc").order("id asc").includes(:voice_actor)
  end

  def show
    @voice_history = VoiceHistory.find(params[:id])
  end

  def destroy
    e = VoiceHistory.find(params[:id])
    e.destroy
    redirect_to voice_histories_path
  end

  def housekeeping
    VoiceHistory.housekeeping
  end
end