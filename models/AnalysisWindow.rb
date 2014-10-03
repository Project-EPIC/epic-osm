#
# AnalysisWindow Module
#
# Queries are built from Analysis windows, which are comprised of a TimeFrame and a Bounding Box.
#

class AnalysisWindow

	#TODO:
	# => Datastore? Will we spin up a new Mongo collection? PostGreSQL?

	attr_reader :time_frame, :bounding_box

	#These will get refactoredout of this class, but we're not sure how or when yet

	def initialize(args)
		@bounding_box = args[:bounding_box]
		@time_frame   = args[:time_frame]
	end

	def full_data_set
		nil
		# => Sets the boundaries to nil, or something... probably too coupled
	end

	def changesets
		@changesets ||= Changeset_Query.new(analysis_window: self).run
	end

	def changeset_count
		changesets.count
	end

	def distinct_users_in_changesets
		changesets.items.collect{|changeset| changeset.user_id}.uniq
	end

	def changesets_per_day
		changesets.items.group_by{|changeset| changeset.created_at.yday}
	end

	def users_per_day
		users_per_day = {}
		changesets.items.group_by{|changeset| changeset.created_at.yday}.each do |k,v|
			users_per_day[k] = v.collect{|changeset| changeset.user_id}.uniq
		end
		users_per_day
	end

	def nodes
		@nodes ||= Node_Query.new(analysis_window: self).run
	end

	def node_edit_count
		nodes.items.count
	end

	def node_added_count
		nodes.items.select{|node| node.version == 1}.count
	end

	def new_contributors
		users = User_Query.new(user_ids: distinct_users_in_changesets).run

		users.items.select{|user| user.join_date > time_frame.start and user.join_date < time_frame.end}.collect{|user| user.user_name}
	end

end


class BoundingBox #< RGeo::Geometry::Polygon #Or something...?

	attr_reader :bottom_left, :top_right, :active

	def initialize(args)
		if args.nil?
			@active = false
		else
			@bottom_left = args[:bottom_left]
			@top_right   = args[:top_right]
		end

		post_initialize
	end

	def post_initialize
		unless (bottom_left.is_a? Array) and (top_right.is_a? Array)
			@active = false
		end
	end

	#TODO: 
	# => Area, Width, Height, Hemisphere, Country, Continent, etc.


	#Going to need some pretty robust methods to pass to Mongo queries, but painless for now
	def mongo_format
		h = Hash.new
		h["$box"] = [bottom_left, top_right]
		puts h
	end

end

class TimeFrame

	#TODO:
	# => We want flexiblity in how we input dates, so this class will
	# => transform these dates to the proper format.

	attr_reader :start, :end, :active

	def initialize(args)
		@start = args[:start]
		@end   = args[:end]

		post_initialize(args)
	end

	def post_initialize(args)
		@active = true

		#be sure to handle dates in a consistent manner
	end

	def duration
		nil
	end

	#Silly management functions

end