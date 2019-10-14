require 'faraday'
require 'json'

namespace :spotify_task do
  desc "TODO"
  task get_info: :environment do
  	puts 'running the method get_info from spotify_task'
  	getAuthorization()
  	# ARTIST['artists']
  end

  def getAuthorization()
  	client_id = '7f648529df7d466bb40130d95d4d7d9e'
  	client_secret = '7bb1ea5e329a43d98b3957af976dd3eb'
  	authorize_url = 'https://accounts.spotify.com/api/token'
  	base64_value = getBase64(client_id, client_secret)
  	responseRequest = sendRequest(authorize_url, base64_value)

  	if( responseRequest.status == 200 )
  		body_response = JSON.parse(responseRequest.body)
  		token = body_response['access_token']
  		getArtistInfo(token)
  	else
  		puts "Error in Authorization request"
  	end
  end

  def getBase64(client_id, client_secret)
  	combination_structure = client_id + ":" + client_secret
  	begin 
	    combination_base64 = Base64.encode64(combination_structure)
	  rescue Exception => e 
	    puts e 
	  end
  end

  def sendRequest(url, base64_value)
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

  def getArtistInfo(token)
  	authorization_value = "Bearer " + token
  	artist = ARTIST['artists'][1]
  	url = "https://api.spotify.com/v1/search?"

  	response = Faraday.get(url) do |req|
  		req.params['q'] = artist
  		req.params['type'] = 'artist'
  		req.params['limit'] = 1
		  req.headers['Authorization'] = authorization_value
		end

		if( response.status == 200 )
			body_response = JSON.parse(response.body)
		else
		end

		puts response.body
  end

end
