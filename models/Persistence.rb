require 'mongo'
require 'yaml'

#Using a Singleton Design Pattern to have point of access to the database
class DatabaseConnection
	attr_reader :host, :port, :database, :mongo_only, :mem_only

	def initialize(args={})

		@host = args[:host] || 'localhost'
		@port = args[:port] || '27017'
		@database = args[:database] || 'osm-test'

		@@mongo_only = args[:mongo_only] || false
		@@mem_only = args[:mem_only] || false

		connect_to_mongo

		unless mongo_only
			@@memory_nodes = {}
			@@memory_ways  = {}
		end
	end

	def self.database
		@@database
	end

	def self.mongo_only
		@@mongo_only
	end

	def self.mem_only
		@@mem_only
	end

	def connect_to_mongo
		begin
	    	conn = Mongo::MongoClient.new host, port
			@@database = conn[database]	
		rescue
			raise ArgumentError.new("Unable to connect to database: #{database}")
		end
	end

	def self.insert(osm_object)
		
		#If configured to use memory, then write to memory first.
		case osm_object.class.to_s
		when "Node"
			unless mongo_only
				@@memory_nodes[osm_object.id] ||= []
				@@memory_nodes[osm_object.id] << osm_object
			end
			database['nodes'].insert( osm_object.to_mongo ) unless mem_only
		when "Way"
			unless mongo_only
				@@memory_ways[osm_object.id] ||= []
				@@memory_ways[osm_object.id] << osm_object
			end
			database['ways'].insert( osm_object.to_mongo ) unless mem_only
		when "Relation"
			database['relations'].insert( osm_object.to_mongo ) unless mem_only
		end
	end

	def self.persistent_nodes(node_id)
		
		#If configured for memory, then check for memory first
		unless mongo_only
			return @@memory_nodes[node_id]
		
		#If not configured for memory, look in mongo
		else
			return database['nodes'].find(id: node_id).collect{ |node| node.from_mongo }
		end
	end


	def self.persistent_ways(way_id)
		
		#If configured for memory, then check for memory first
		unless mongo_only
			return @@memory_ways[way_id]
		#If not configured for memory, look in mongo
		else
			return database['ways'].find(id: way_id).collect{ |way| way.from_mongo }
		end
	end
end
