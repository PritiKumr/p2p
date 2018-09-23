require 'sinatra'
require 'pry'
require "httparty"

set :peer_list, {}
set :files, {}

post '/register_peer' do
  if already_registered?
    "Peer #{params['peer_id']} already registered"
  else
    settings.peer_list[params['peer_id']] = {
      host: params['host'],
      peer_id: params['peer_id']
    }

    "Peer #{params['peer_id']} successfully registered"
  end
end

post '/update_index' do
  if params['op'] == 'add'
    add_file_to_index params['file_path'], params['peer_id']
  elsif params['op'] == 'remove'
    remove_file_from_index params['file_path'], params['peer_id']
  end

  "Successfully updated the file index"
end

get '/file_index' do
  settings.files.to_s
  settings.peer_list.to_s
end

get '/search/:query' do
  content_type :json
  {results: search_files(params[:query]) }.to_json
end

post '/retrieve' do
  # params[:peer_id] and params[:file_name] and params[:peer_id_that_has_file]
  HTTParty.post(
      "#{settings.peer_list[params['peer_id_that_has_file']][:host]}/send_file", {
        body: { 
          file_name: params[:file_name],
          dest_folder: params[:dest_folder]
        }
      }
    )
  "Request passed to Peer Server"
end


private

def already_registered?
  settings.peer_list.has_key? params['peer_id']
end

def filename path
  File.basename path
end

def add_file_to_index file_path, peer_id
  settings.files[filename file_path] ||= []

  return if file_already_indexed? file_path, peer_id

  settings.files[filename file_path] << {
    peer_id: peer_id,
    file_path: file_path
  } 
end

def remove_file_from_index file_path, peer_id
  return if settings.files.fetch(filename(file_path), []).empty?
  settings.files[filename file_path].delete_if do |entry|
    entry[:peer_id] == peer_id && entry[:file_path] == file_path
  end
end

def file_already_indexed? file_path, peer_id
  settings.files[filename file_path].any? do |entry| 
    entry[:peer_id] == peer_id && entry[:file_path] == file_path
  end
end

def search_files query
  settings.files.keys.select do |name| 
    name.start_with? query
  end.map do |file|
    settings.files[file]
  end.flatten.map do |result|
    result.merge({
      url: "#{settings.peer_list[result[:peer_id]][:host]}/download?file_path=#{result[:file_path]}"
    }) rescue nil
  end.compact
end