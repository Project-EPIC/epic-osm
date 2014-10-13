# 
# 
# 
# 
# 

require 'mongo'
require 'yaml'


class DatabaseConnection

	def initialize
		connect_to_mongo
	end

	def connect_to_mongo
		begin
      		config = YAML.load_file('config.yml')
      
	    	conn = Mongo::MongoClient.new#{config['host'],config['port']}
			@database = conn[config['database']]
			
		rescue
			puts "Error connecting to Database: #{config['database']}"
			puts $!
		end
	end
end







