# 
# Base Domain Object Class.
# 
# 
#

require_relative '../modules/osm_to_mongo'

class OSMObject

	include OSMongoable::OSMObject

	attr_reader :id, :user_id, :user_name, :created_at, :tags, :version, :changeset

	def initialize(args)
		@id         ||= args[:id]
		@user_id    ||= args[:uid]
		@user_name  ||= args[:user]
		@created_at ||= args[:created_at]
		@tags       ||= args[:tags]
		@version    ||= args[:version]
		@changeset  ||= args[:changeset]

		post_initialize(args)
	end

	def post_initialize(args)
		nil
	end

end

class Node < OSMObject

	include OSMongoable::Node

	attr_reader :lat, :lon

	def intialize(args)  # Should this be post_initialize? What's the 
		@lon = args[:lon] #  benefits/cons of super vs. post_initialize?
		@lat = args[:lat]

		super(args)
	end
end

class Way < OSMObject

	include OSMongoable::Way

	attr_reader :nodes

	def initialize(args)
		@nodes = args[:nodes]
		super(args)
	end
end

class Relation < OSMObject

	include OSMongoable::Relation

	attr_reader :nodes, :ways
	
	def initialize(args)
		@nodes = args[:nodes]
		@ways  = args[:ways]
		super(args)
	end
end

class Changeset < OSMObject

	include OSMongoable::Changeset

	def initialize(args)
		@comment   = args[:comment]
		@closed_at = args[:closed_at]
		@open      = args[:open]
		super(args)
	end

	def post_initialize(args)
		#overriding for silly osm-history v1 database (testing purposes)
		@id         = args["id"]
		@user_id    = args["uid"]
		@user_name  = args["user"]
		@created_at = args["created_at"]
		@tags       = args["tags"]
	end

end

class User # => Do we inherit anything here? No... ?
	
	include OSMongoable::User

	attr_reader :user_name, :user_id, :join_date

	def initialize(args)
		@user_id   = args["uid"]
		@user_name = args["display_name"]
		#Note that this is again just for silly v1 database
		@join_date = args["account_created"]
	end

end

class Note # => Lots to learn here: Not sure what it will look like

	attr_reader :user_id, :user_name, :created_at

	def initialize(args)
		nil
	end
end
