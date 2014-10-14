# 
# 
# 
# 
# 

require 'mongo'
require 'yaml'

#Using a Singleton Design Pattern to have point of access to the database
class DatabaseConnection

	def initialize(env='production')
		connect_to_mongo(env)
	end

	def self.database
		@@database
	end

	def connect_to_mongo(env)
		begin
      		config = YAML.load_file('config.yml')[env]
      
	    	conn = Mongo::MongoClient.new config['host'], config['port']
			@@database = conn[config['database']]
			
		rescue
			puts "Error connecting to Database: #{config['database']}"
			puts $!
			exit(1)
		end
	end
end