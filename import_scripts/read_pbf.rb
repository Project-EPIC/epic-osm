'''
PBF Parser from: https://github.com/planas/pbf_parser

//These two are for parsing PBF:
brew install protobuf-c (Mac)
gem install pbf_parser
'''

require_relative './pbf_to_mongo'

if __FILE__==$0
	#This isn't the most robust command line parser, but it works (for now -- will use OptParser eventually.
	if ARGV[0].nil?
		puts "Call this in the following manner: "
		puts "\truby read_pbf.rb [database name] [pbf file]"
		puts "\tOptional arguments include: limit=, port=, and host="
	else
		db 		= ARGV[0]
		file 	= ARGV[1]

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
		port  ||= nil
		host  ||= nil

		unless port.nil?
			port = port.to_i
		end
		
		unless limit.nil?
			limit = limit.to_i
		end

		puts "Calling Mongo import with the following:"
		puts "DB: #{db}"
		puts "File: #{file}"
		puts "Limit: #{limit}"
		puts "Host: #{host}"
		puts "port: #{port}"

		
		conn = OSMPBF.new
		conn.open_parser(file)

		puts "Information about your file"
		conn.file_stats

		# Commenting out the actual import to just get file stats
		# puts "Beginning Mongo Import"
		# conn.read_pbf_to_mongo(lim=limit, [:ways, :relations])
	end
end
