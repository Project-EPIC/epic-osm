#
# The Query Class
#
#
#

class Query
	require_relative 'AnalysisWindow'

	attr_reader :analysis_window, :constraints, :buckets

	attr_accessor :selector

	def initialize(args)
		@analysis_window = args[:analysis_window]
		@constraints     = args[:constraints]      || {}

		@selector = {}

		post_initialize(args)
	end

	def post_initialize(args)

		if analysis_window.bounding_box.active
			selector[:geometry] = { '$within' => analysis_window.bounding_box.mongo_format }
		end

		#This should be over-written farther down, but it's here for safety
		if analysis_window.time_frame.active
			selector[:created_at] = { '$gte' => analysis_window.time_frame.start,
									  '$lt' => analysis_window.time_frame.end    }
		end
	end

	#For when buckets are called
	def update_created_at(start_time, end_time)
		selector[:created_at] = { '$gte' => start_time,
								  '$lt'  => end_time    }
	end

	def run(args)
		puts "Got to super run function with args #{args}"
		@buckets = analysis_window.build_buckets(unit = args[:unit])

		buckets.each do |bucket|			
			update_created_at( bucket[:start_date], bucket[:end_date] )
			results = DatabaseConnection.database[args[:collection]].find( selector )
			results.each do |obj|
				bucket[:objects] << args[:type].new(obj.from_mongo)
			end
		end
		buckets
	end
end


#Queries (but they kiiiiind of act like buckets... )
class Node_Query < Query
	def run(args)
		puts "Got to instance of run in node query with args: #{args}"
		super collection: 'nodes', type: Node, unit: args[:unit]
	end
end

class Way_Query < Query
	def run(args)
		super collection: 'ways', type: Way, unit: args[:unit]
	end
end

class Relation_Query < Query
	def run(args)
		super collection: 'relations', type: Relation, unit: args[:unit]
	end
end


class Changeset_Query < Query
	def run(args)
		super collection: 'changesets', type: Changeset, unit: args[:unit]
	end

	def self.earliest_changeset_date
		DatabaseConnection.database['changesets'].find(
			selector={}, 
			opts= {:sort => {'created_at' => :asc} } ).limit(1).first['created_at']
	end

	def self.latest_changeset_date
		DatabaseConnection.database['changesets'].find(
			selector={}, 
			opts= {:sort => {'closed_at' => :desc} } ).limit(1).first['closed_at']
	end
end


class User_Query < Query
	def initialize(args)
		selector = args[:constraints] || {} #Empty selector
		
		if args[:uids]
			selector[:uid] = {'$in' => args[:user_ids]}
		end
	end

	def run
		users = []
		results = DatabaseConnection.database['users'].find( selector )
		results.each do |user|
			users << User.new(user.from_mongo)
		end
		users
	end
end





