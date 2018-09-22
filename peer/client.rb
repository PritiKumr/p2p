require "listen"
require "httparty"

require 'dotenv'
Dotenv.load(".env", "#{ENV['PEER_ID']}.env")

@watching_directory = ENV['DIRECTORY']
@peer_host = ENV['PEER_HOST']
@peer_id = ENV['PEER_ID']
@index_server_host = ENV['INDEX_HOST']

def register_peer
  puts "Registering with Index Server at #{@index_server_host}"
  begin 
    HTTParty.post(
      "#{@index_server_host}/register_peer", 
      {body: {peer_id: @peer_id, host: @peer_host}}
    )
  rescue => e
    puts "Failed to register with Index Server. Exiting..."
    exit false
  end
  puts "Successfully registered with Index Server"
end

def file_added file_path
  puts "File added #{file_path}"
  update_file_on_index 'add', file_path
end

def file_removed file_path
  puts "File removed #{file_path}"
  update_file_on_index 'remove', file_path
end

def update_file_on_index op, file_path
  begin 
    HTTParty.post(
      "#{@index_server_host}/update_index", {
        body: {
          peer_id: @peer_id, 
          file_path: file_path,
          op: op
        }
      }
    )
    puts "Successfully updated the index server"
  rescue => e
    puts "Failed to update the index server"
  end
end

def clean_file_path path
  path.gsub "#{@watching_directory}/", ""
end


puts "Initializing Peer"
register_peer

listener = Listen.to(@watching_directory) do |modified, added, removed|
  # file_modified modified unless modified.empty?
  file_added clean_file_path(added.first) unless added.empty?
  file_removed clean_file_path(removed.first) unless removed.empty?
end

listener.start # not blocking
puts "Watching file changes at #{@watching_directory}"
sleep

