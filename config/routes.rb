Rails.application.routes.draw do
  resources :users, param: :discord_user_id
  resources :extra_voices
  resources :voice_actors
  resources :voice_histories, only: [:show, :index, :destroy]
  post "tts", to: "text_to_speach#tts"
  get "housekeeping", to: "voice_histories#housekeeping"
  #
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
