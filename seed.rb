a = [1,2,5]
f = [1,10,100]
f.each do |i|
	a.each do |a|
		File.open("../p2p/peer/peer1/ex#{i*a}.txt", 'w') do |f|
		  contents = "x" * (1024)
		  (i*a).times { f.write(contents) }
		  puts "Created File - ex#{i*a}.txt"
		end
		sleep(5)
		File.open("../p2p/peer/peer2/ex#{i*a*2}.txt", 'w') do |f|
		  contents = "x" * (1024)
		  (i*a*2).times { f.write(contents) }
		  puts "Created File - ex#{i*a*2}.txt"
		end
		sleep(5)
		File.open("../p2p/peer/peer3/ex#{(i*a)/2}.txt", 'w') do |f|
		  contents = "x" * (1024)
		  (i*a*2).times { f.write(contents) }
		  puts "Created File - ex#{(i*a)/2}.txt"
		end
		sleep(5)
		File.open("../p2p/peer/peer4/ex#{(i*a)*3}.txt", 'w') do |f|
		  contents = "x" * (1024)
		  (i*a*2).times { f.write(contents) }
		  puts "Created File - ex#{(i*a)*3}.txt"
		end
	end
end