class Api::V1::ArtistsController < ApplicationController

	# GET - /artists
	def index
    artists = Artist.all
    render json: artists, status: :ok
  end

  # GET /artists/:id/albums
  def show
  	puts "enter show"
  	artist = Artist.find(params[:id])
    albums = artist.albums
    render json: albums, status: :ok
  end
  
end
