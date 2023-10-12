class ExtraVoicesController < ApplicationController
  def index
    @extra_voices = ExtraVoice.all.includes(:voice_actor)
  end

  def show
    @extra_voice = ExtraVoice.find(params[:id]).includes(:voice_actor)
  end

  def new
    @extra_voice = ExtraVoice.new
  end

  def create
    ExtraVoice.create(extra_voice_param)
  end

  def edit
    @extra_voice = ExtraVoice.find(params[:id])
  end

  def update
    @extra_voice = ExtraVoice.find(params[:id])
    @extra_voice.update(update_param)
  end

  def destroy
    e = ExtraVoice.find(params[:id])
    e.destroy
    redirect_to extra_voices_path
  end
  
  private

  def set_extra_voice
    @extra_voice = ExtraVoice.find(params[:id])
  end

  def extra_voice_param
    params.require(:extra_voice).permit(:voice_actor_id, :voice, :matching)
  end

  def update_param
    params.require(:extra_voice).permit(:voice_actor_id, :voice, :matching)
  end

end
