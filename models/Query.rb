#
# Query Class: 
#
# 1. Handles DB Connection ?
# 2. 
#

class Query
	require_relative 'AnalysisWindow'
	require_relative 'Buckets'

	attr_reader :analysis_window, :type

	def initialize(args)
		@analysis_window = args[:analysis_window]
		@type            = args[:type] # => More to this....
	end

	def run(args)
		db = args[:db] #This is stubbed for testing

		objs = db[type].select{|object| object.created_at < analysis_window.time_frame.end and object.created_at > analysis_window.time_frame.start}
		
		#print objs
		#Return a bucket of the objects

		results = Changesets.new(items: objs)

		return results

		# => Connect to Mongo, run the Query based on the bounds of the Analysis Window, etc....
		# => Is it possible to have a nil analysis window?
		# => Return the analysis window composed of the right buckets
	end
end