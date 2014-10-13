# 
# 
# 
# 
# 

require 'mongo'
require 'yaml'


class DatabaseConnection

	attr_reader :db

	def initialize(args)
		connect_to_mongo(args[:env])
	end

	def connect_to_mongo(env)
		begin
      		config = YAML.load_file('config.yml')[env]
      
	    	conn = Mongo::MongoClient.new config['host'], config['port']
			@database = conn[config['database']]
			
		rescue
			puts "Error connecting to Database: #{config['database']}"
			puts $!
		end
	end
end