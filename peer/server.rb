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
  HTTParty.get("#{index_server_host}/search/#{params[:query]}").parsed_response
end

get '/download' do
  send_file "#{settings.file_directory}/#{params[:file_path]}", :filename => File.basename(params[:file_path]), :type => 'Application/octet-stream'
end