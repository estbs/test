require 'faraday'
require 'json'

namespace :spotify_task do
  desc "TODO"
  task get_info: :environment do
  	puts 'running the rake task spotify_task:get_info'
  	begin
		  # 1. Get authorization
			token = getTokenAuthorization()
			if token.nil?
		    raise ArgumentError
		  end

	  	searchAndSaveArtistList(token)
		rescue Exception => e
		  puts "Error in request"
		end
  end

  # Get the token by Spotify
  def getTokenAuthorization()
  	client_id = '7f648529df7d466bb40130d95d4d7d9e'
  	client_secret = '7bb1ea5e329a43d98b3957af976dd3eb'
  	authorize_url = 'https://accounts.spotify.com/api/token'
  	base64_value = getBase64(client_id, client_secret)
  	response_request = sendAuthorizationRequest(authorize_url, base64_value)

  	if( response_request.status == 200 )
  		body_response = JSON.parse(response_request.body)
  		token = body_response["access_token"]
  	else
  		puts "Error in Authorization request with status code: #{response_request.status}"
  	end
  end

	# Get base64 code between cliend_id and client_secret 
  def getBase64(client_id, client_secret)
  	combination_structure = client_id + ":" + client_secret
  	begin 
	    combination_base64 = Base64.encode64(combination_structure)
	  rescue Exception => e 
	    puts "Error trying to get base64 combination" 
	  end
  end

  # Send the post request to get authorization from Spotify
  def sendAuthorizationRequest(url, base64_value)
  	authorization_value = "Basic " + base64_value
  	body_data = {
		  :grant_type => "client_credentials"
		}

  	response = Faraday.post(url) do |req|
		  req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
		  req.headers['Authorization'] = authorization_value.delete!("\r\n\\")
		  req.body = URI.encode_www_form(body_data)
		end
  end

  # Get the artist info from spotify
  def searchAndSaveArtistList(token)
  	artists = []
  	url = "https://api.spotify.com/v1/search?"
  	authorization_value = "Bearer " + token
  	
  	ARTIST['artists'].each do |artist_name|
  		puts "artistName: #{artist_name}"
  		# Send request based on artist name
  		response_artist = Faraday.get(url) do |req|
	  		req.params['q'] = artist_name
	  		req.params['type'] = 'artist'
	  		req.params['limit'] = 1
			  req.headers['Authorization'] = authorization_value
			end
			if( response_artist.status == 200 )
				body_responseArtist = JSON.parse(response_artist.body)
				if( body_responseArtist["artists"]["items"].length > 0 )
					artist_response = body_responseArtist["artists"]["items"][0]
					artist = Artist.new(
						name: artist_response["name"], 
						image: artist_response["images"][0]["url"], 
						genres: artist_response["genres"], 
						popularity: artist_response["popularity"], 
						spotify_id: artist_response["id"], 
						spotify_url: artist_response["href"])
					
					artist.albums = getAlbumsInfoBySpotifyArtistId(artist["spotify_id"], token)
					
					if artist.save
			      puts "#{artist["name"]} saved!"
			    else
			      puts "Error trying to save an artist"
			    end
				else
					puts "Empty items for artist: #{artist_name}"
				end 
			else
				puts "Error in Artist request with status code: #{response_artist.status}"
			end
		end
  end

  # get Albums info by spotify artist id and token
  def getAlbumsInfoBySpotifyArtistId(spotify_artist_id, token)
  	albums = []

  	url = "https://api.spotify.com/v1/artists/{id}/albums"
  	authorization_value = "Bearer " + token
  	custom_url = url.gsub! '{id}', spotify_artist_id

  	response_albums = Faraday.get(custom_url) do |req|
		  req.headers['Authorization'] = authorization_value
		end
		
		if( response_albums.status == 200 )
			body_response_album = JSON.parse(response_albums.body)

			body_response_album["items"].each do |album_response|
				album = Album.new(
					name: album_response["name"],
					image: album_response["images"][0]["url"],
					spotify_url: album_response["external_urls"]["spotify"],
					total_tracks: album_response["total_tracks"],
					spotify_id: album_response["id"])
				album.songs = getSongsInfoBySpotifyAlbumId(album["spotify_id"], token)
				albums.push(album)
			end
		else
			puts "Error in Album request with status code: #{response_albums.status}"
		end
		albums
  end

  def getSongsInfoBySpotifyAlbumId(spotify_album_id, token)
  	songs = []

  	url = "https://api.spotify.com/v1/albums/{album-id}/tracks"
  	authorization_value = "Bearer " + token
  	custom_url = url.gsub! '{album-id}', spotify_album_id

  	response_song = Faraday.get(custom_url) do |req|
		  req.headers['Authorization'] = authorization_value
		end

		if( response_song.status == 200 )
			body_response_songs = JSON.parse(response_song.body)
			body_response_songs["items"].each do |song_response|
				song = Song.new(
					name: song_response["name"],
					spotify_url: song_response["external_urls"]["spotify"],
					preview_url: song_response["preview_url"],
					duration_ms: song_response["duration_ms"],
					explicit: song_response["explicit"],
					spotify_id: song_response["id"])
				songs.push(song)
			end
		else
			puts "Error in Songs request"
		end
		songs
  end

end
