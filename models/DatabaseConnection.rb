# 
# 
# 
# 
# 

require 'mongo'

#Using a Singleton Design Pattern to have point of access to the database
class DatabaseConnection
	attr_reader :host, :port, :database

	def initialize(args)

		@host = args[:host] || 'localhost'
		@port = args[:port] || '27017'
		@database = args[:database] || 'osm-test'

		connect_to_mongo
	end

	def self.database
		@@database
	end

	def connect_to_mongo
		begin
      	
	    	conn = Mongo::MongoClient.new host, port
			@@database = conn[database]
			
		rescue
			puts "Error connecting to Database: #{database}"
			puts $!
			exit(1)
		end
	end
end