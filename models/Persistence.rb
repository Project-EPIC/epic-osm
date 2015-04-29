require 'mongo'
require 'yaml'

# = Singleton Database Connection
#
# There is only one point of access to the database
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

		@@bulk_nodes = @@database['nodes'].initialize_unordered_bulk_op
		@@bulk_ways = @@database['ways'].initialize_unordered_bulk_op
		@@bulk_relations = @@database['relations'].initialize_unordered_bulk_op
		@@counter = 0
	end

	def self.bulk_nodes
		@@bulk_nodes
	end

	def self.bulk_ways
		@@bulk_ways
	end

	def self.bulk_relations
		@@bulk_relations
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

	def self.nodes_for_bulk_insert
		@@nodes_for_bulk_insert
	end

	def self.ways_for_bulk_insert
		@@ways_for_bulk_insert
	end

	def self.relations_for_bulk_insert
		@@relations_for_bulk_insert
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
		when "DomainObject::Node"
			unless mongo_only
				@@memory_nodes[osm_object.id] ||= []
				@@memory_nodes[osm_object.id] << osm_object.to_mongo
			end

			unless mem_only
				@@bulk_nodes.insert ( osm_object.to_mongo )
				@@counter += 1

				if @@counter == 5000
					@@bulk_nodes.execute()
					@@counter = 0
				end
			end

		when "DomainObject::Way"
			unless mongo_only
				@@memory_ways[osm_object.id] ||= []
				@@memory_ways[osm_object.id] << osm_object.to_mongo
			end

			unless mem_only
				@@bulk_ways.insert ( osm_object.to_mongo )
				@@counter += 1

				if @@counter == 5000
					@@bulk_ways.execute()
					@@counter = 0
				end
			end
		when "DomainObject::Relation"
			unless mem_only
				@@bulk_relations.insert ( osm_object.to_mongo )
				@@counter += 1

				if @@counter == 5000
					@@bulk_relations.execute()
					@@counter = 0
				end
			end
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
