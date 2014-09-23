#
#
#
#
#

class OSMObject

	attr_reader :id, :user_id, :user_name, :created_at

	def initialize(args)
		@id         = args[:id]
		@user_id    = args[:user_id]
		@user_name  = args[:user_name]
		@created_at = args[:created_at]
		@tags       = args[:tags]

		post_initialize(args)
	end

	def post_initialize(args)
		nil
	end
end

class Node < OSMObject

	attr_reader :lat, :lon

	def initialize(args)  # Should this be post_initialize? What's the 
		@lon = args[:lon] #  benefits/cons of super vs. post_initialize?
		@lat = args[:lat]
		super(args)
	end
end

class Way < OSMObject

	attr_reader :nodes

	def initialize(args)
		@nodes = args[:nodes]
	end
end