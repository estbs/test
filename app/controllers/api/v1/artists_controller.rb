class Api::V1::ArtistsController < ApplicationController

	# GET - /artists
	def index
    artists = Artist.all
		artistsDTO = []
		artists.each do |artist|
			artistDTO = {
				:id => artist["id"], 
				:name => artist["name"],
				:image => artist["image"],
				:genres => artist["genres"],
				:popularity => artist["popularity"],
				:spotify_url => artist["spotify_url"]
			}
			artistsDTO.push(artistDTO)
		end
		
    response = {"data" => artistsDTO}
    render json: response, status: :ok
  end

  # GET /artists/:id/albums
  def show
  	artist = Artist.find(params[:id])
  	if( artist.nil?)
  		render status: :not_found
  	else
	    albums = artist.albums
	    albumsDTO = []
			albums.each do |album|
				albumDTO = {
					:id => album["id"],
					:name => album["name"],
					:image => album["image"],
					:spotify_url => album["spotify_url"],
					:total_tracks => album["total_tracks"]
				}
				albumsDTO.push(albumDTO)
			end
	    response = {"data" => albumsDTO}
	    render json: response, status: :ok
	  end
  end

  # GET /genres/:genre_name/random_song
  def songByGenre
  	genre = params[:genre_name]
  	songs_by_album = []
  	artists = Artist.all
  	artists.each do |artist|
  		genres_artist = artist["genres"].split(",")
  		if( genres_artist.include? genre )
  			albums = artist.albums
  			albums.each do |album|
  				songs = album.songs
  				songs.each do |song|
  					songs_by_album.push(song)
  				end
  			end
  		end 
  	end

  	if( songs_by_album.length == 0)
			render status: :not_found
  	else
  		random_song = songs_by_album.sample(1)[0]
	  	songsDTO = []
	  	songDTO = {
	  		:name => random_song["name"],
				:spotify_url => random_song["spotify_url"],
				:preview_url => random_song["preview_url"],
				:duration_ms => random_song["duration_ms"],
				:explicit => random_song["explicit"]
			}
			songsDTO.push(songDTO)
	  	response = {"data" => songsDTO}
	  	render json: response, status: :ok
  	end
  end
  
end
