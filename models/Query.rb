# = Query
#
# The Query contains a _run_ function which is called by its children (Nodes, Ways, Relations, etc.)
# with specific arguments which tells the database connection which collection to query.
#
# The Query#run function will always return buckets as build by AnalysisWindow#build_buckets
#
class Query
	include DomainObject
	require_relative 'AnalysisWindow'

	attr_reader :analysis_window, :buckets

	attr_accessor :selector

	def initialize(args)
		@analysis_window = args[:analysis_window]

		@selector = {}

		post_initialize(args)
	end

	# Updates the bounding box, time frame, and constraints for the query to Mongo.
	#
	# The bounding_box geographic constriaints are currently unimplemented because
	# the database doesn't contain any points outside of the bounding box.
	def post_initialize(args)

		if analysis_window.bounding_box.active
			selector[:geometry] = { '$within' => analysis_window.bounding_box.mongo_format }
		end

		#This should be over-written farther down, but it's here for safety
		if analysis_window.time_frame.active
			selector[:created_at] = { '$gte' => analysis_window.time_frame.start_date,
									  '$lt' => analysis_window.time_frame.end_date    }
		end

		#If the query was called with new constraints, then they should get added here
		unless args[:constraints].nil?
			selector.update(args[:constraints])
		end
	end

	def update_created_at(start_time, end_time) # :nodoc:
		selector[:created_at] = { '$gte' => start_time,
								  '$lt'  => end_time    }
	end

	# The main run function which is called as super from children.
	#
	# Accesses the database through the Singleton DatabaseConnection reference and
	# queries with the _selector_ that was built.
	def run(args = {})
		# puts "Got to super run function with args #{args}"
		@buckets = analysis_window.build_buckets( unit = args[:unit], step = args[:step] )

		unless args[:constraints].nil?
			selector.update(args[:constraints])
		end

		buckets.each do |bucket|

			update_created_at( bucket[:start_date], bucket[:end_date] )

			results = DatabaseConnection.database[args[:collection]].find( selector )
			results.each do |obj|
				bucket[:objects] << args[:type].new( obj )
			end
		end
		buckets
	end
end

class Node_Query < Query #:nodoc:
	def run(args={})
		super args.update( {collection: 'nodes', type: Node} )
	end
end

class Note_Query < Query #:nodoc:
	def run(args={})
		super args.update( {collection: 'notes', type: Note} )
	end
end

class Way_Query < Query #:nodoc:
	def run(args={})
		super args.update( {collection: 'ways', type: Way } )
	end
end

class Relation_Query < Query #:nodoc:
	def run(args={})
		super args.update( {collection: 'relations', type: Relation } )
	end
end

# = Changeset Query
#
# Returns a bucket of changesets
class Changeset_Query < Query
	def run(args={})
		super args.update( {collection: 'changesets', type: Changeset} )
	end

	#Get the date of the earliest changeset in the analysis window
	def self.earliest_changeset_date
		DatabaseConnection.database['changesets'].find().sort({created_at: 1}).limit(1).first['created_at']
	end

	#Get the date of the latest changeset in the analysis window
	def self.latest_changeset_date
		DatabaseConnection.database['changesets'].find().sort({created_at: -1}).limit(1).first['created_at']
	end
end

# User Query
#
# Returns an array of users, either all of the users or if _args[:uids] is set, it
# will only return users whose uid is in the :uids array argument.
class User_Query < Query
	attr_reader :selector
	def initialize(args)
		@selector = args[:constraints] || {} #Empty selector
		if args[:uids]
			selector[:uid] = {'$in' => args[:uids]}
		end
	end

	# Overrides the parent _run_ function because it does not need to return buckets,
	# merely an array of User objects.
	def run
		users = []
		results = DatabaseConnection.database['users'].find( selector )
		results.each do |user|
			users << User.new( user )
		end
		users
	end
end
