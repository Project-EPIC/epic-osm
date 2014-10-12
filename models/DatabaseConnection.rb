#
#
#
#
#

require 'mongo'

class DatabaseConnection

	attr_reader :country, :database

	def initialize(args)
		@country = args[:country]

		connect_to_mongo
	end

	#This will eventually call from a config.yml file.
	def connect_to_mongo
		begin
	    	conn = Mongo::MongoClient.new#('epic-analytics.cs.colorado.edu',27018)
			@database = conn[country]

		rescue
			puts "Error connecting to Database: #{country}"
			puts $!
		end
	end
end







