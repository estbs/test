class Api::V1::AlbumsController < ApplicationController

	# GET /artists/:id/albums
  def show
  	album = Album.find(params[:id])
    songs = album.songs
    render json: songs, status: :ok
  end
end
