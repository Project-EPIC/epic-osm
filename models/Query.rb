#
# The Query Class
#
#
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
			selector[:geometry] = { '$within' => analysis_window.bounding_box.mongo_format }
		end

		if analysis_window.time_frame.active
			selector[:created_at] = { '$gt' => analysis_window.time_frame.start,
									  '$lt' => analysis_window.time_frame.end    }
		end
	end

	def get_edit_time_bounds
		nil
		#This should set a time_frame for this analysis window based on the first and last changesets
	end

	def run(args)
		results = DatabaseConnection.database[args[:collection]].find( selector )
		objs = []
		results.each do |obj|
			objs << args[:type].new(obj.from_mongo)
		end
		return objs
	end

end

class Node_Query < Query
	def run
		super collection: 'nodes', type: Node
	end
end

class Way_Query < Query
	def run
		super collection: 'ways', type: Way
	end
end

class Relation_Query < Query
	def run
		super collection: 'relations', type: Relation
	end
end


class Changeset_Query < Query
	def run
		super collection: 'changesets', type: Changeset
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
		super collection: 'users', type: User
	end
end





