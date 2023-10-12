class VoiceActorsController < ApplicationController
  before_action :set_voice_actor, only: %i[ show edit update destroy ]

  # GET /voice_actors or /voice_actors.json
  def index
    @voice_actors = VoiceActor.all
  end

  # GET /voice_actors/1 or /voice_actors/1.json
  def show
  end

  # GET /voice_actors/new
  def new
    @voice_actor = VoiceActor.new
  end

  # GET /voice_actors/1/edit
  def edit
  end

  # POST /voice_actors or /voice_actors.json
  def create
    @voice_actor = VoiceActor.new(voice_actor_params)

    respond_to do |format|
      if @voice_actor.save
        format.html { redirect_to voice_actor_url(@voice_actor), notice: "VoiceActor was successfully created." }
        format.json { render :show, status: :created, location: @voice_actor }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @voice_actor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /voice_actors/1 or /voice_actors/1.json
  def update
    respond_to do |format|
      if @voice_actor.update(voice_actor_params)
        format.html { redirect_to voice_actor_url(@voice_actor), notice: "VoiceActor was successfully updated." }
        format.json { render :show, status: :ok, location: @voice_actor }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @voice_actor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /voice_actors/1 or /voice_actors/1.json
  def destroy
    @voice_actor.destroy

    respond_to do |format|
      format.html { redirect_to voice_actors_url, notice: "VoiceActor was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_voice_actor
    @voice_actor = VoiceActor.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def voice_actor_params
    params.fetch(:voice_actor, {})
  end
end
