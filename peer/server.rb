require 'sinatra'
require 'pry'
require 'httparty'

require 'dotenv'
Dotenv.load(".env", "#{ENV['PEER_ID']}.env")

set :port, ENV['PEER_PORT']
set :index_server_host, ENV['INDEX_HOST']
set :file_directory, ENV['DIRECTORY']

get '/search/:query' do
  content_type :json
  HTTParty.get("#{settings.index_server_host}/search/#{params[:query]}").parsed_response
end

get '/retrieve/:file_name/:peer_id_that_has_file' do
	uri = URI.parse(URI.encode(settings.index_server_host.to_s + "/retrieve"))
	HTTParty.post(
      uri, {
        body: { 
          file_name: params[:file_name],
          dest_folder: settings.file_directory,
          peer_id_that_has_file: params[:peer_id_that_has_file]
        }
      }
    )
	puts "Requesting passed to Index server"
end

post '/send_file' do
	file_path = "#{settings.file_directory}/" + params[:file_name]
	puts file_path
	FileUtils.cp(file_path, params[:dest_folder])
	puts "File seent"
end

get '/download' do
  send_file "#{settings.file_directory}/#{params[:file_path]}", :filename => File.basename(params[:file_path]), :type => 'Application/octet-stream'
end