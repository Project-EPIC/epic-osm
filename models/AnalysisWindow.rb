# = The Analysis Window
#
# The analysis window is defined by an analysis window configuration file.
#
# They are aware of the geographical and temporal bounds of the study and handle all of the
# helper functions for performing calculations.  All Queries happen through the analysis window
# and the method missing located within defines functions such as _nodes_x_month_.
#
#
# While the analysis window is capable of asking quesitons of itself, these are strictly helper
# functions and should be used by the Questions Module

class AnalysisWindow

	# The TimeFrame object instance for this analysis window
	attr_reader :time_frame

	#The BoundingBox object instance for this analysis window
	attr_reader :bounding_box

	# The minimum area (in square meters) of changesets to be included in calculations
	attr_reader :min_area

	# The maximum area (in square meters) of changesets to be included in calculations
	attr_reader :max_area

	# Can pass in an instance of a timeframe and bounding box, or use defaults
	def initialize(args={})
		@bounding_box = args[:bounding_box] || BoundingBox.new
		@time_frame   = args[:time_frame]   || TimeFrame.new

		@max_area = args[:max_area] || 1000000000000
		@min_area = args[:min_area] || 1

		post_initialize
	end

	# If the frame failed or doesn't exist, then use all of the data by default
	def post_initialize
		unless time_frame.active?
			@time_frame = TimeFrame.new( start_date: Changeset_Query.earliest_changeset_date, end_date: Changeset_Query.latest_changeset_date )
		end
	end

	# Buckets are temporal units which the query results are binned into.
	#
	# Buckets can be defined with multiple units and steps.
	# Defaults to just one bucket, the size of the analysis window.
	def build_buckets(unit=:all, step=1)
		hour   = 60 * 60
		day    = 24 * hour

		if step.nil?
			step = 1
		end

		if unit.nil?
			unit = :all
		end

		buckets = []

		case unit
		when :all
			buckets << {start_date: time_frame.start_date, end_date: time_frame.end_date, objects: []}

		when :year
			year = time_frame.start_date.year
			bucket_start = Time.mktime(year, 1, 1)
			while bucket_start < time_frame.end_date
				bucket_end   = Time.mktime(year+=step, 1, 1)
				buckets << {start_date: bucket_start, end_date: bucket_end, objects: []}
				bucket_start = bucket_end
			end

		when :month
			month = time_frame.start_date.mon
			year  = time_frame.start_date.year
			bucket_start = time_frame.start_date
			while bucket_start < time_frame.end_date
				bucket_start = Time.mktime( year, (month) )

				month+=step
				if (month-12) > 0
					year  += 1
				    month = month-12
				end

				bucket_end   = Time.mktime(year, (month) )
				buckets << {start_date: bucket_start, end_date: bucket_end, objects: []}
			end

		when :day
			bucket_start = Time.mktime(time_frame.start_date.year, time_frame.start_date.mon, time_frame.start_date.day)
			while bucket_start < time_frame.end_date
				bucket_end   = Time.at( bucket_start.to_i + step*day )
				buckets << {start_date: bucket_start, end_date: bucket_end, objects: []}
				bucket_start = bucket_end
			end

		when :week
			#fuck us, this is going to be ugly.  How should we do this? just start from the first week of the analysis window?
			#We could just add 7 days.

		when :hour
			bucket_start = Time.mktime(time_frame.start_date.year, time_frame.start_date.mon, time_frame.start_date.day, time_frame.start_date.hour)
			while bucket_start < time_frame.end_date
				bucket_end   = Time.at( bucket_start.to_i + step*hour )
				buckets << {start_date: bucket_start, end_date: bucket_end, objects: []}
				bucket_start = bucket_end
			end
		end

		buckets.first[:start_date] = time_frame.start_date
		buckets.last[:end_date]    = time_frame.end_date

		return buckets
	end

	# = Method Missing
	#
	# The Analysis window overrides method-missing to offer new functions such as changesets_x_day
	def method_missing(m, *args, &block)
		# puts "Called method missing with this function: #{m} and these args: #{args}"
		begin
			#Break out the method by snake case
			pieces = m.to_s.split(/\_/)

			#Find the nodes_x_all, changesets_x_month, ways_x_year type of functions
			if pieces[1] == 'x'

				unless args.empty?
					cons = args[0][:constraints] #Better pass a hash, otherwise it'll explode!
					step = args[0][:step] || 1
				end

				instance_eval "#{pieces[0]}.run(unit: :#{pieces[2]}, step: step, constraints: cons)"
			end

		rescue => e
			puts $!
			super(args)
		end
	end

	# :category: Changesets
	#
	# Access the changesets query
	def changesets
		@changesets ||= Changeset_Query.new(analysis_window: self)
	end

	# :category: Changesets
	#
	# Get the number of changesets in the analysis window.
	def changeset_count
		changesets_x_all.first[:objects].count
	end

	# :category: Changesets
	#
	#
	def distinct_users_in_changesets
		changesets_x_all.first[:objects].collect{|changeset| changeset.uid}.uniq
	end

	# :category: Nodes
	def nodes
		@nodes ||= Node_Query.new( analysis_window: self )
	end

	# :category: Nodes
	def node_edit_count
		nodes_x_all.first[:objects].count
	end

	# :category: Nodes
	def node_added_count
		nodes_x_all.first[:objects].select{|node| node.version == 1}.count
	end

	# :category: Ways
	def ways
		@ways ||= Way_Query.new( analysis_window: self )
	end

	# :category: Ways
	def way_edit_count
		ways_x_all.first[:objects].count
	end

	# :category: Ways
	def way_added_count
		ways_x_all.first[:objects].select{|way| way.version == 1}.count
	end

	# :category: Relations
	def relations
		@relations ||= Relation_Query.new( analysis_window: self )
	end

	# :category: Relations
	def relation_edit_count
		relations_x_all.first[:objects].count
	end

	# :category: Relations
	def relation_added_count
		relations_x_all.first[:objects].select{|relation| relation.version == 1}.count
	end

	# :category: Users
	def all_users_data
		User_Query.new(uids: distinct_users_in_changesets).run
	end

	# :category: Users
	def new_contributors
		all_users_data.select{|user| user.account_created > time_frame.start_date and user.account_created < time_frame.end_date}.collect{|user| user.user}
	end

	# :category: Users
	def experienced_contributors
		all_users_data.select{|user| user.account_created < time_frame.start_date}.collect{|user| user.user}
	end

	# :category: Users
	def all_contributors
		all_users_data.collect{|user| user.user}
	end

	# :category: Notes
	def notes
		@notes ||= Note_Query.new( analysis_window: self )
	end

	# :category: Notes
	def notes_count
		notes_x_all.first[:objects].count
	end

	# :category: Notes
	def notes_geo
		var result = {}
		notes_x_all.first[:objects].each do | object |
			result[object.id] = {
				url: object.url,
				lat: object.lat,
				lon: object.lon,
				comments: object.comments	
			}
		end
		return result
	end
end

#=Geographical Bounding Box
#
#A bounding box is a geographical box determined by the configuration file.
#
#It is currently not being implemented in queries because the import scripts are cutting the excess data
#away, so there is nothing outside of the bounding box in the database.
#
#However, queries are capable of only querying within the bounding box, so it is possible to change
#the box throughout calculations to get a subset of the data -- change to @active = true
class BoundingBox

	attr_reader :bottom_left, :top_right, :active, :bbox_array

	def initialize(args=nil)
		if args.nil?
			@active = false
		elsif args[:bbox].is_a? String
			@bbox_array = args[:bbox].split(',')

			@bottom_left = [ bbox_array[0].to_f, bbox_array[1].to_f ]
			@top_right   = [ bbox_array[2].to_f, bbox_array[3].to_f ]

		else
			@bottom_left = args[:bottom_left]
			@top_right   = args[:top_right]
		end

		post_initialize
	end

	def post_initialize
		unless (bottom_left.is_a? Array) and (top_right.is_a? Array)
			@active = false
		else
			@active = false #Active is always set to false and not incorporated in current queries
		end
	end

	#Going to need some pretty robust methods to pass to Mongo queries, but painless for now
	def mongo_format
		h = {}
		h["$box"] = [bottom_left, top_right]
		return h
	end

	#Returns an array of the bounding box parameters.
	def geometry
		mongo_format["$box"].flatten
	end

	def geojson_geometry
		return {type: "Polygon",
				coordinates:[[  bottom_left,
							   [bottom_left[0], top_right[1]],
							    top_right,
							   [top_right[0],   bottom_left[1]],
							    bottom_left ]]}
	end
end

# = Time Frame
#
# Timeframes are the temporal bounds of the analysis window.
class TimeFrame
	require 'time'

	attr_reader :start_date, :end_date, :active

	#If the time frame is active, then start and end dates are defined and functioning
	def active?
		active
	end

	def initialize(args=nil)
		if args.nil?
			@active = false
		else
			@start_date = validate_time(args[:start_date])
			@end_date   = validate_time(args[:end_date])
			@active = true
		end
	end

	#Attempt to parse the time string that is entered in the configuration file.
	def validate_time(time)
		if time.is_a? Time
			return time
		else
			return Time.parse(time)
		end
	end
end
