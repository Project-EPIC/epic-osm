#
#
#
#
#
#

class Query

	attr_reader :analysis_window, :type

	def initialize(args)
		@analysis_window = args[:analysis_window]
		@type            = args[:type] # => More to this....
	end

	def run
		# => Connect to Mongo, run the Query, etc....

		# => Return the right bucket
	end

end