require 'mongo'

#Using a Singleton Design Pattern to have point of access to the database
class DatabaseConnection
	attr_reader :host, :port, :database

	def initialize(args={})

		@host = args[:host] || 'localhost'
		@port = args[:port] || '27017'
		@database = args[:database] || 'osm-test'

		@@memory_nodes = {}
		@@memory_ways  = {}

		connect_to_mongo
	end

	# Cheating for speed...
	def self.write_memory_node(node)
		@@memory_nodes[node.id] ||= []
		@@memory_nodes[node.id] << node
	end

	def self.write_memory_way(way)
		@@memory_ways[way.id] ||= []
		@@memory_ways[way.id] << way
	end

	def self.memory_nodes
		@@memory_nodes
	end

	def self.memory_ways
		@@memory_ways
	end

	def self.database
		@@database
	end

	def connect_to_mongo
		begin
	    	conn = Mongo::MongoClient.new host, port
			@@database = conn[database]	
		rescue
			raise ArgumentError.new("Unable to connect to database: #{database}")
		end
	end
end