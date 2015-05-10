# May 2015: Rewriting this to work with new Mongo API and Bulk upsert operations

require 'mongo'
require 'yaml'

# = Singleton Database Connection
#
# There is only one point of access to the database
class DatabaseConnection
	Mongo::Logger.logger.level = Logger::WARN #Suppress default debug messages
	attr_reader :host, :port, :database, :mongo_only, :mem_only

	def initialize(args={})

		@host     = args[:host]     || 'localhost'
		@port     = args[:port]     || '27017'
		@database = args[:database] || 'osm-test'

		@@mongo_only = args[:mongo_only] || false
		@@mem_only   = args[:mem_only]   || false

		#Create the connection to Mongo
		connect_to_mongo

		unless mongo_only
			@@memory_nodes = {}
			@@memory_ways  = {}
		end

		#Define pieces for bulk operations
		@@bulk_nodes     = OSMBulkOp.new(coll: 'nodes')
		@@bulk_ways      = OSMBulkOp.new(coll: 'ways')
		@@bulk_relations = OSMBulkOp.new(coll: 'relations')

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

	def connect_to_mongo
		begin
	    @@database = Mongo::Client.new("mongodb://127.0.0.1:#{port}", {database: database})
		rescue => e
			puts e
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
				@@bulk_nodes.insert( osm_object.to_mongo )
				@@counter += 1
			end

		when "DomainObject::Way"
			unless mongo_only
				@@memory_ways[osm_object.id] ||= []
				@@memory_ways[osm_object.id] << osm_object.to_mongo
			end

			unless mem_only
				@@bulk_ways.insert( osm_object.to_mongo )
				@@counter += 1
			end

		when "DomainObject::Relation"
			unless mem_only
				@@bulk_relations.insert( osm_object.to_mongo )
				@@counter += 1
			end
		end
	end

	def self.persistent_nodes(node_id)

		#If configured for memory, then check for memory first
		unless mongo_only
			return @@memory_nodes[node_id]

		#If not configured for memory, look in mongo
		else
			return database['nodes'].find(id: node_id).collect{ |node| node }
		end
	end


	def self.persistent_ways(way_id)

		#If configured for memory, then check for memory first
		unless mongo_only
			return @@memory_ways[way_id]
		#If not configured for memory, look in mongo
		else
			return database['ways'].find(id: way_id).collect{ |way| way }
		end
	end
end

# = Bulk Write Operations save the abilities
#
#
class OSMBulkOp
	attr_reader :collection, :insert_threshold, :objects

	def initialize(args)
		@collection = args[:coll]
		@insert_threshold = args[:insert_treshold] || 500
		@objects = []
	end

	def insert(object)
		@objects << { :update_one =>
                   {:find =>
									    {:version => object[:version],
                       :id => object[:id]},
										:update => {'$set' => object},
										:upsert => true}
								}
		if objects.length >= insert_threshold
			execute
		end
	end

	def execute
		unless objects.empty?
			DatabaseConnection.database[collection].bulk_write(objects, :ordered => false)
			@objects = []
			DatabaseConnection.database[collection].indexes.create_many([
	  		{ name: 'object_version', key: { version: 1 }, background: true},
	  		{ name: 'object_id',      key: { id:      1 }, background: true}
			])
		end
	end
end
