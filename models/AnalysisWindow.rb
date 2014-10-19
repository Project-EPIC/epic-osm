#
# AnalysisWindow Module
#
# Queries are built from Analysis windows, which are comprised of a TimeFrame and a Bounding Box.
#

class AnalysisWindow

	attr_reader :time_frame, :bounding_box

	#These will get refactoredout of this class, but we're not sure how or when yet

	def initialize(args={})
		@bounding_box = args[:bounding_box] || BoundingBox.new
		@time_frame   = args[:time_frame]   || TimeFrame.new

		post_initialize
	end

	def post_initialize
		unless time_frame.active?
			@time_frame = TimeFrame.new( start: Changeset_Query.earliest_changeset_date,
										 end:   Changeset_Query.latest_changeset_date )
		end
	end

	def build_buckets(unit=:all)
		hour   = 60 * 60
		day    = 24 * hour

		buckets = []
		
		case unit
		when :all
			buckets << {start_date: time_frame.start, end_date: time_frame.end, objects: []}
		
		when :yearly
			year = time_frame.start.year
			bucket_start = Time.mktime(year, 1, 1)
			while bucket_start < time_frame.end
				bucket_end   = Time.mktime(year+=1, 1, 1)
				buckets << {start_date: bucket_start, end_date: bucket_end, objects: []}
				bucket_start = bucket_end
			end

		when :monthly
			month = time_frame.start.mon
			year  = time_frame.start.year
			bucket_start = time_frame.start
			while bucket_start < time_frame.end
				bucket_start = Time.mktime( year, (month) )
				if (month%12).zero?
					year  += 1
					month = 0
				end
				month+=1
				bucket_end   = Time.mktime(year, (month) )
				buckets << {start_date: bucket_start, end_date: bucket_end, objects: []}
			end

		when :daily
			bucket_start = Time.mktime(time_frame.start.year, time_frame.start.mon, time_frame.start.day)
			while bucket_start < time_frame.end
				bucket_end   = Time.at( bucket_start.to_i + 1*day )
				buckets << {start_date: bucket_start, end_date: bucket_end, objects: []}
				bucket_start = bucket_end
			end
		
		when :weekly
			#fuck us, this is going to be ugly.  How should we do this? just start from the first week of the analysis window?
			#We could just add 7 days.



		when :hourly
			bucket_start = Time.mktime(time_frame.start.year, time_frame.start.mon, time_frame.start.day, time_frame.start.hour)
			while bucket_start < time_frame.end
				bucket_end   = Time.at( bucket_start.to_i + 1*hour )
				buckets << {start_date: bucket_start, end_date: bucket_end, objects: []}
				bucket_start = bucket_end
			end
		end

		buckets.first[:start_date] = time_frame.start
		buckets.last[:end_date]    = time_frame.end

		return buckets
	end


# Changesets
	def changesets
		@changesets ||= Changeset_Query.new(analysis_window: self)
	end

	def all_changesets
		@all_changesets ||= changesets.all
	end

	def changesets_per_year
		@yearly_changesets ||= changesets.yearly
	end

	def changesets_per_month
		@monthly_changesets ||= changesets.monthly
	end

	def changesets_per_day
		@daily_changesets ||= changesets.daily
	end

	def changeset_count
		all_changesets.count
	end

	def distinct_users_in_changesets
		all_changesets.collect{|changeset| changeset.uid}.uniq
	end

#Nodes
	def nodes
		@nodes ||= Node_Query.new(analysis_window: self)
	end

	def all_nodes
		@all_nodes ||= nodes.all
	end

	def monthly_nodes
		@monthly_nodes ||= nodes.monthly
	end

	def daily_nodes
		@daily_nodes ||= nodes.daily
	end

	def node_edit_count
		all_nodes.count
	end

	def node_added_count
		all_nodes.select{|node| node.version == 1}.count
	end

#Users
	def all_users_data
		@all_users_data ||= User_Query.new(uids: distinct_users_in_changesets).run
	end

	def users_editing_per_year
		years = {}
		changesets_per_year.each do |bucket|
			years[ bucket[:start_date] ] = bucket[:objects].collect{|changeset| changeset.user}.uniq
		end
		years
	end

	def users_editing_per_month
		months = {}
		changesets_per_month.each do |bucket|
			months[ bucket[:start_date] ] = bucket[:objects].collect{|changeset| changeset.user}.uniq
		end
		months
	end

	def new_contributors
		all_users_data.select{|user| user.account_created > time_frame.start and user.account_created < time_frame.end}.collect{|user| user.user}
	end

	def top_contributors_by_changesets(args={limit: 5, unit: :all_time })

		case args[:unit]
		when :all_time
			changesets_per_unit = all_changesets.group_by{|changeset| changeset.user}.sort_by{|k,v| v.length}.reverse
		when :month
			changesets_per_unit = changesets_per_month.group_by{|changeset| changeset.created_at.to_i / 100000}
		end
		changesets_per_unit.first(args[:limit])
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

	def active?
		active
	end

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