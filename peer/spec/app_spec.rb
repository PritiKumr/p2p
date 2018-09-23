# a = [1,2,5]
# f = [1,10,100,1000]
# f.each do |i|
# 	a.each do |a|
# 		File.open("data/ex#{i*a}.txt", 'w') do |f|
# 		  contents = "x" * (1024)
# 		  (i*a).times { f.write(contents) }
# 		end
# 	end
# end
require 'pry'
require '../peer/client'

ENV['PEER_ID'] = 'peer1'

describe 'The HelloWorld App' do
  include Rack::Test::Methods
  


  def app
    Sinatra::Application
  end
end