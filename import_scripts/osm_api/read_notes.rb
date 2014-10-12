require 'json'
require 'pp'
require 'net/http'

require_relative 'OSMAPIHitter'
require_relative 'OSMGeoJSONMongo.rb'

URI_HAITI = ["http://api.openstreetmap.org/api/0.6/notes.json?limit=1500&closed=-1&bbox=-74.5532226563,17.8794313865,-71.7297363281,19.9888363024"]
URI_PHILIPPINES = [
	"http://api.openstreetmap.org/api/0.6/notes.json?limit=10000&closed=-1&bbox=120.0805664063,9.3840321096,123.343505859,13.9447299749",
	"http://api.openstreetmap.org/api/0.6/notes.json?limit=10000&closed=-1&bbox=123.343505859,9.3840321096,126.6064453125,13.9447299749",
]


if __FILE__==$0
	if ARGV[0].nil?
		puts "Call this in the following manner: "
		puts "\truby read_notes.rb [database name]"
	else
		db 			= ARGV[0]

		unless ["haiti", "philippines"].include? db
			puts "[ERROR]: Need to specify 'haiti' or 'philippines'..."
			exit
		end

		limit_string = ARGV.join.scan(/limit=\d+/i)
		unless limit_string.empty?
			limit = limit_string.first.scan(/\d+/).first
		end

		port_string = ARGV.join.scan(/port=\d+/i)
		unless port_string.empty?
			port = port_string.first.scan(/\d+/).first
		end

		host_string = ARGV.join.scan(/host=.+\s*/i)
		unless host_string.empty?
			host  = host_string.first.gsub!('host=','').strip
		end

		limit ||= nil
		port  ||= 27018
		host  ||= 'epic-analytics.cs.colorado.edu'
		# host  ||= 'localhost'

		port = port.to_i
		unless limit.nil?
			limit = limit.to_i
		end

		puts "Calling Mongo import with the following:"
		puts "DB: #{db}"
		puts "Limit: #{limit}"
		puts "Host: #{host}"
		puts "port: #{port}"

		#Create connection
		conn = OSMGeoJSONMongo.new(db, host, port) #Defaults

		#Switch for notes.
		payloads = nil
		case db

		when "haiti"
			payloads = OSMAPIHitter.hit_API (URI_HAITI.collect { |uri| [:notes, uri] })
		when "philippines"
			payloads = OSMAPIHitter.hit_API (URI_PHILIPPINES.collect { |uri| [:notes, uri] })
		end

		payloads.each do |payload|
			notes = payload["features"]
			puts "[INFO]: Collected #{notes.size} Notes from the '#{db}' Bounding Box Set."
			conn.read_notes_to_mongo(notes, lim=limit)
		end
	end
end
