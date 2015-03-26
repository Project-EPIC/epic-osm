require_relative '../modules/domain_objects/osm_to_mongo'
require_relative '../modules/domain_objects/osm_geo'

# = OSM Object
#
# A main 
class OSMObject

	include OSMongoable::OSMObject
	include OSMGeo::OSMObject

	attr_reader :id, :uid, :user, :created_at, :tags, :geometry

	def initialize(args)
		@id         ||= args[:id].to_s
		@uid    	||= args[:uid]
		@user  		||= args[:user]
		@created_at ||= args[:created_at]
		@tags       ||= args[:tags]
		@geometry       ||= args[:geometry]
	end
end

class Node < OSMObject #:nodoc:

	include OSMongoable::Node
	include OSMGeo::Node

	attr_reader :lat, :lon, :version, :changeset

	def initialize(args)  # Should this be post_initialize? What's the 
		@lon = args[:lon] #  benefits/cons of super vs. post_initialize?
		@lat = args[:lat]
		@version	||= args[:version]
		@changeset  ||= args[:changeset]

		super(args)
	end
end

class Way < OSMObject #:nodoc:

	include OSMongoable::Way
	include OSMGeo::Way

	attr_reader :nodes, :version, :changeset, :missing_nodes

	def initialize(args)
		@nodes 		||= args[:nodes].collect{|node| node.to_s}
		@version    ||= args[:version]
		@changeset  ||= args[:changeset]
		super(args)
	end

		def get_missing_nodes
			return nil if nodes.nil?
			return nil if nodes.empty?

			missing_nodes = []
			
			#Iterate over this way's nodes
			nodes.each do |node_id| #The id of the node needed
				mem_nodes = DatabaseConnection.persistent_nodes(node_id)
				
				if mem_nodes.nil?	#Look for this node in memory
					missing_nodes << node_id     #Add it to missing and skip
				else
					if mem_nodes.length > 1 #If there is only one, use it
						mem_nodes.sort! { |a,b| a.changeset <=> b.changeset }
						this_node = mem_nodes.select{|node| node.changeset <= changeset}
						if this_node.empty?
							missing_nodes << node_id
						end
					end
				end
			end

			@missing_nodes = missing_nodes
			return missing_nodes
	end

end

class Relation < OSMObject #:nodoc:

	include OSMongoable::Relation

	attr_reader :nodes, :ways, :version, :changeset, :missing_nodes, :missing_ways
	
	def initialize(args)
		@nodes = args[:nodes]
		@ways  = args[:ways]
		@version    ||= args[:version]
		@changeset  ||= args[:changeset]
		super(args)
	end
end

class Changeset < OSMObject #:nodoc:

	include OSMongoable::Changeset
	include OSMGeo::Changeset

	attr_reader :comment, :closed_at, :open, :min_lat, :max_lat, :min_lon, :max_lon

	def initialize(args)
		@comment   = args[:comment]
		@closed_at = args[:closed_at]
		@open      = args[:open]
		@min_lat   = args[:min_lat].to_f
		@max_lat   = args[:max_lat].to_f
		@min_lon   = args[:min_lon].to_f
		@max_lon   = args[:max_lon].to_f
		super(args)
	end

end

class User #:nodoc:
	
	include OSMongoable::User

	attr_reader :user, :uid, :account_created

	def initialize(args)
		@uid   = args[:uid]
		@user  = args[:user]
		
		#Note that this is again just for silly v1 database
		@account_created = args[:account_created]
	end

end

class Note #:nodoc:

	attr_reader :uid, :user, :created_at

	def initialize(args)
		nil
	end
end
