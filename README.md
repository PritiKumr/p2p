# Peer to Peer File Sharing

## Starting the server

1. `cd index_server` and run `bundle install`
2. Start the server by running `ruby index_server.rb`

## Starting Peers

1. Each peer is configured using its own config file saved as `peer1.env`, `peer2.env`, etc.
2. `cd peer` and run `bundle install`
3. Start a peer client by running `PEER_ID=peer1 ruby client.rb` and a server by running `PEER_ID=peer1 ruby server.rb`
