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

		post_initialize
	end

	def post_initialize
		@database = DatabaseConnection.new(country: "haiti").database

		if analysis_window.bounding_box.active
			selector[:geometry] = {'$within' => analysis_window.bounding_box.mongo_format }
		end

		if analysis_window.time_frame.active
			selector[:date] = 		{'$gt' => analysis_window.time_frame.start,
									 '$lt' => analysis_window.time_frame.end}
		end
	end

end

class Node_Query < Query

	def initialize(args)
		super(args)
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






