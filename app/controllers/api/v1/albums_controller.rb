class Api::V1::AlbumsController < ApplicationController

	# GET /artists/:id/albums
  def show
  	album = Album.find(params[:id])
  	if( album.nil?)
  		render status: :not_found
  	else
	    songs = album.songs
			songsDTO = []
			songs.each do |song|
				songDTO = {
					:name => song["name"],
					:spotify_url => song["spotify_url"],
					:preview_url => song["preview_url"],
					:duration_ms => song["duration_ms"],
					:explicit => song["explicit"]
				}
				songsDTO.push(songDTO)
			end
	    response = {"data" => songsDTO}
	    render json: response, status: :ok
	  end
  end
end
