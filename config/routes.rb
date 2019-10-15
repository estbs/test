Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
  	namespace :v1 do
  		get 'artists', to: 'artists#index'
  		get 'artists/:id/albums', to: 'artists#show'
  		get 'albums/:id/songs', to: 'albums#show'
  		get 'genres/:genre_name/random_song', to: 'artists#songByGenre'
  	end
 	end
end
