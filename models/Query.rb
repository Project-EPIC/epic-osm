#
# Query Class: 
#
# 1. Handles DB Connection ?
# 2. 
#

class Query
	require_relative 'DatabaseConnection'
	require_relative 'AnalysisWindow'
	require_relative 'Buckets'

	attr_reader :analysis_window, :constraints, :database

	attr_accessor :selector

	def initialize(args)
		@analysis_window = args[:analysis_window]
		@constraints     = args[:constraints] || {}

		@selector = {}

		post_initialize(args)
	end

	def post_initialize(args)
		@database = DatabaseConnection.new(country: "haiti").database

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
		#Again, over-riding because of the structure of the database
		@database = DatabaseConnection.new(country: "haiti").database

		if analysis_window.bounding_box.active
			selector[:geometry] = {'$within' => analysis_window.bounding_box.mongo_format }
		end

		if analysis_window.time_frame.active
			selector[:date] = {'$gt' => analysis_window.time_frame.start,
									 '$lt' => analysis_window.time_frame.end}
		end
	end

	def run

		results = database["nodes"].find( selector, {:limit=> 10000000} )

		nodes = []

		results.each do |node|
			nodes << Node.new(node) #When should it become a node object?
		end

		Nodes.new(items: nodes)
	end
end


class Changeset_Query < Query

	def initialize(args)
		super(args)
	end

	def run

		results = database["changesets"].find( selector, {:limit=> 10000000} )

		changesets = []

		results.each do |changeset|
			changesets << Changeset.new(changeset) #When should it become a node object?
		end

		Changesets.new(items: changesets)
	end
end

class User_Query < Query

	def initialize(args)
		super(args)
	end

	def post_initialize(args)
		@database = DatabaseConnection.new(country: "haiti").database

		selector = {}
		if args[:user_ids]
			selector[:uid] = {'$in' => args[:user_ids]}
		end
	end

	def run
		results = database["users"].find( selector )

		users = []

		results.each do |user|
			users << User.new(user) #When should it become a node object?
		end

		Users.new(items: users)
	end
end





