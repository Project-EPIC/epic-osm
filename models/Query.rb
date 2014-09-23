#
#
#
#
#
#

class Query
	require_relative 'AnalysisWindow'

	attr_reader :analysis_window, :type

	def initialize(args)
		@analysis_window = args[:analysis_window]
		@type            = args[:type] # => More to this....
	end

	def run
		# => Connect to Mongo, run the Query based on the bounds of the Analysis Window, etc....
		# => Is it possible to have a nil analysis window?
		# => Return the analysis window composed of the right buckets
	end
end