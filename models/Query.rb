#
# Query Class: 
#
# 1. Handles DB Connection ?
# 2. 
#

class Query
	require_relative 'AnalysisWindow'

	attr_reader :analysis_window, :constraints

	attr_accessor :selector

	def initialize(args)
		@analysis_window = args[:analysis_window]
		@constraints     = args[:constraints] || {}

		@selector = {}

		post_initialize(args)
	end

	def post_initialize(args)

		if analysis_window.bounding_box.active
			selector[:geometry] = {'$within' => analysis_window.bounding_box.mongo_format }
		end

		if analysis_window.time_frame.active
			selector[:created_at] = {'$gt' => analysis_window.time_frame.start,
									 '$lt' => analysis_window.time_frame.end}
		end
	end

end

class Node_Query < Query

	def post_initialize(args)
		super(args)

		selector.delete :created_at

		if analysis_window.time_frame.active
			selector[:date] = {'$gt' => analysis_window.time_frame.start,
									 '$lt' => analysis_window.time_frame.end}
		end
	end

	def run

		results = DatabaseConnection.database["nodes"].find( selector, {:limit=> 10000000} )

		nodes = []

		results.each do |node|
			nodes << Node.new(node.from_mongo) #When should it become a node object?
		end

		nodes
	end
end


class Changeset_Query < Query

	def run

		results = DatabaseConnection.database["changesets"].find( selector, {:limit=> 10000000} )

		changesets = []

		results.each do |changeset|
			changesets << Changeset.new(changeset.from_mongo) 
		end

		changesets
	end
end

class User_Query < Query

	def initialize(args)

		super(args)
		
		selector.delete :created_at
		selector.delete :geometry
		
		selector = {}
		if args[:user_ids]
			selector[:uid] = {'$in' => args[:user_ids]}
		end

	end

	def run
		results = DatabaseConnection.database["users"].find( selector )

		users = []

		results.each do |user|
			users << User.new(user.from_mongo) #When should it become a node object?
		end

		users
	end
end





