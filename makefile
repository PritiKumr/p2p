
start_index_server:
	ruby index_server/index_server.rb

start_peers: peer1 peer2 peer3 peer4

peer1: peer1_server peer1_client

peer1_server:
	cd peer && PEER_ID=peer1 ruby server.rb

peer1_client:
	cd peer && PEER_ID=peer1 ruby client.rb


peer2: peer2_server peer2_client

peer2_server:
	cd peer && PEER_ID=peer2 ruby server.rb
	
peer2_client:
	cd peer && PEER_ID=peer2 ruby client.rb


peer3: peer3_server peer3_client

peer3_server:
	cd peer && PEER_ID=peer3 ruby server.rb
	
peer3_client:
	cd peer && PEER_ID=peer3 ruby client.rb


peer4: peer4_server peer4_client

peer4_server:
	cd peer && PEER_ID=peer4 ruby server.rb
	
peer4_client:
	cd peer && PEER_ID=peer4 ruby client.rb