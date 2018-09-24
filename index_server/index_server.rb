require 'sinatra'
require 'pry'
require "httparty"

# A hash of arrays that hold the peer list. Format :
# peer_list: {
#   'peer1': {
#     host: 'http://localhost:3001',
#     peer_id: 'peer1'
#   },
#    'peer2': {
#     host: 'http://localhost:3002',
#     peer_id: 'peer2'
#   }
# }
set :peer_list, {}

# Files hash that holds the list of files with their peer details,
# files: {
#   'file_name' : {
#     peer_id: 'peer1',
#     file_path: '/p2p/peer1/file_name'
#   },
#   'file_name2' : {
#     peer_id: 'peer2',
#     file_path: '/p2p/peer2/file_name2'
#   }
# }
set :files, {}

puts "Index Server starting..."

# Index server registers peers once they connect, adds it to registry if it isn't already present.
post '/register_peer' do
  if already_registered?
    puts "Peer #{params['peer_id']} already registered"
  else
    # Registering peer to the index server by adding it to the peer_list data structure.
    settings.peer_list[params['peer_id']] = {
      host: params['host'],
      peer_id: params['peer_id']
    }
    puts "Peer #{params['peer_id']} - #{params['host']} successfully registered"
  end
end

# File registry updated when there is any changes to the peer file system.
post '/update_index' do
  if params['op'] == 'add'
    # Update registry when new files added.
    add_file_to_index params['file_path'], params['peer_id']
    puts "New File #{params['file_path']} - #{params['peer_id']} added to index."
  elsif params['op'] == 'remove'
    # Update registry when files are removed from the system.
    remove_file_from_index params['file_path'], params['peer_id']
    puts "File #{params['file_path']} - #{params['peer_id']} removed from index."
  end
end

get '/file_index' do
  # Registry index
  settings.files.to_s
end

get '/search/:query' do
  content_type :json
  {results: search_files(params[:query]) }.to_json
end

post '/retrieve' do
  # Index server posts to peer server to serve clients
  puts "Download request forwarded to Peer Server to process download."
  HTTParty.post(
      "#{settings.peer_list[params['peer_id_that_has_file']][:host]}/send_file", {
        body: { 
          file_name: params[:file_name],
          dest_folder: params[:dest_folder]
        }
      }
    )
end


private

def already_registered?
  # Checks to see if peer already present. Returns boolean
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
  # Remove files from the registry once the file is removed from the peer directory.
  return if settings.files.fetch(filename(file_path), []).empty?
  settings.files[filename file_path].delete_if do |entry|
    entry[:peer_id] == peer_id && entry[:file_path] == file_path
  end
end

def file_already_indexed? file_path, peer_id
  # Checks if file already indexed. Returns boolean.
  settings.files[filename file_path].any? do |entry| 
    entry[:peer_id] == peer_id && entry[:file_path] == file_path
  end
end

def search_files query
  # Used by peers to see the list of peers that has the requested file. Returns file name and peer that has the file to th client peer that is requesting.
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