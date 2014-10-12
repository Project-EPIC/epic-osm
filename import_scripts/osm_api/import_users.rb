def insert_to_mongo(collection, uid, payload)
	collection.update(
		{"uid" => uid}, 
		{'$set' => payload}, 
		opts={:upsert=>true})
end

if $0 == __FILE__
	require 'optparse'
	require 'json'
	require_relative '../osm_history_analysis'
	options = OpenStruct.new
  	opts = OptionParser.new do |opts|
	    opts.banner = "Usage: ruby import_users.rb -d DATABASE  [-l LIMIT]\n\tThis will import users specifically from the changesets found in the desired database"
	    opts.separator "\nSpecific options:"

	    opts.on("-d", "--database Database Name",
	            "Name of Database (Haiti, Philippines)"){|v| options.db = v }

	    opts.on("-l", "--limit [LIMIT]",
	            "[Optional] Limit of users to parse"){|v| options.limit = v.to_i }
	    opts.on_tail("-h", "--help", "Show this message") do
      		puts opts
      		exit
	  	end
    end
    opts.parse!(ARGV)
    unless options.db
    	puts opts
    	exit
  	end

  	#########################################################################
  	########################  RUNTIME  ######################################
  	#########################################################################
	
	puts "Attempting to import users found in changesets #{options.db}"

	#Open OSM database collection
	osm_driver = OSMHistoryAnalysis.new(:local)
	
	changesets = osm_driver.connect_to_mongo(db=options.db, coll="changesets")
	users      = osm_driver.connect_to_mongo(db=options.db, coll="users")
	
	#Open API accessor
	user_api = OSMAPI.new("http://api.openstreetmap.org/api/0.6/user/")

	distinct_users = changesets.distinct("uid").collect{|i| i.to_i}.sort #Sort it for safety
	if options.limit
		distinct_users = distinct_users.first(options.limit)
	end

	distinct_users = [1806350]

	success = LogFile.new("logs/user","failed")
	failed  = LogFile.new("logs/user","success")

	puts "Found #{distinct_users.count} distinct users"

	distinct_users.each_with_index do |user_id, index|
		begin
			puts "User ID: #{user_id}"
			user = user_api.hit_api(user_id)

			puts user

			#Standardize the id_strs:
			user["id_str"] = user["id"]
			#Deal with the date
			user["account_created"] = osm_driver.parse_date(user["account_created"])
			insert_to_mongo(users, user_id, user)
			success.log(user_id)
		rescue => e
			p $!
			puts e.backtrace
			failed.log(user_id.to_s)
		end

		if (index%10).zero?
			puts "#{index}.."
		end
	end
	success.close
  	fail.close
end