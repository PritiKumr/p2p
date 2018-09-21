require 'sinatra'

set :peer_list, []

get '/register_peer' do
	if host_present?
		"Devise already registered"
	else
		settings.peer_list[params['peer_id']] = {
			'host': params['host'],
			'files': []
		}
		"Devise added"
	end
end

post '/index_files' do
	settings.peer_list[params['peer_id']['files']] << params['file_path']
	"File path added - #{settings.peer_list.to_s}"
end

get '/search_files/:file_name' do
	settings.peer_list.to_s
end


private

def host_present?
	settings.peer_list.has_key? params['peer_id'] if settings.peer_list.present?
end