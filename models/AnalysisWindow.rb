#
# AnalysisWindow Module
#
# Queries are built from Analysis windows, which are comprised of a TimeFrame and a Bounding Box.
#

class AnalysisWindow

	attr_reader :time_frame, :bounding_box

	attr_writer :time_frame #So it can be overridden for some queries

	#These will get refactoredout of this class, but we're not sure how or when yet

	def initialize(args={})
		@bounding_box = args[:bounding_box] || BoundingBox.new
		@time_frame   = args[:time_frame]   || TimeFrame.new
	end

	def changesets
		@changesets ||= Changeset_Query.new(analysis_window: self).run
	end

	def changeset_count
		changesets.count
	end

	def distinct_users_in_changesets
		changesets.collect{|changeset| changeset.uid}.uniq
	end

	def changesets_per_day
		changesets.group_by{|changeset| changeset.created_at.yday}
	end

	def users_per_day
		users_per_day = {}
		changesets.group_by{|changeset| changeset.created_at.yday}.each do |k,v|
			users_per_day[k] = v.collect{|changeset| changeset.uid}.uniq
		end
		users_per_day
	end

	def nodes
		@nodes ||= Node_Query.new(analysis_window: self).run
	end

	def node_edit_count
		nodes.count
	end

	def node_added_count
		nodes.select{|node| node.version == 1}.count
	end

	def new_contributors
		users = User_Query.new(analysis_window: self, uids: distinct_users_in_changesets).run

		users.select{|user| user.account_created > time_frame.start and user.account_created < time_frame.end}.collect{|user| user.user}
	end

end


class BoundingBox

	attr_reader :bottom_left, :top_right, :active

	def initialize(args=nil)
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

	def initialize(args=nil)
		if args.nil?
			@active = false
		else
			@start = args[:start]
			@end   = args[:end]
			@active = true
		end
	end


end