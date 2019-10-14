require 'faraday'

namespace :spotify_task do
  desc "TODO"
  task get_info: :environment do
  	puts 'running the method get_info from spotify_task'
  	getAuthorization()
  end

  def getAuthorization()
  	client_id = '7f648529df7d466bb40130d95d4d7d9e'
  	client_secret = '7bb1ea5e329a43d98b3957af976dd3eb'
  	authorize_url = 'https://accounts.spotify.com/api/token'
  	base64_value = getBase64(client_id, client_secret)
  	responseRequest = sendRequest(authorize_url, base64_value)

  	puts "responseRequest: #{responseRequest}"
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
  	Faraday.new(url, headers: { 'Content-Type' => 'application/x-www-form-urlencoded', 'Authorization' => authorization_value }).get
  end

end
