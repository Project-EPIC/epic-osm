require_relative 'TimeFrame'
require_relative 'BoundingBox'

#=The Analysis Window
#
#The analysis window is defined by an analysis window configuration file.
#
#They are aware of the geographical and temporal bounds of the study and handle all of the
#helper functions for performing calculations.  All Queries happen through the analysis window
#and the method missing located within defines functions such as _nodes_x_month_.
class AnalysisWindow
	attr_reader :time_frame, :bounding_box, :min_area, :max_area

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
			@time_frame = TimeFrame.new( start: Changeset_Query.earliest_changeset_date,
										 end:   Changeset_Query.latest_changeset_date )
		end
	end

	# Buckets are temporal units which the query results are binned into.
	#
	# Buckets can be defined with multiple units and steps.
	# Defaults to just one bucket, the size of the analysis window.
	def build_buckets(unit=:all, step=1) # :doc:
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
			buckets << {start_date: time_frame.start, end_date: time_frame.end, objects: []}
		
		when :year
			year = time_frame.start.year
			bucket_start = Time.mktime(year, 1, 1)
			while bucket_start < time_frame.end
				bucket_end   = Time.mktime(year+=step, 1, 1)
				buckets << {start_date: bucket_start, end_date: bucket_end, objects: []}
				bucket_start = bucket_end
			end

		when :month
			month = time_frame.start.mon
			year  = time_frame.start.year
			bucket_start = time_frame.start
			while bucket_start < time_frame.end
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
			bucket_start = Time.mktime(time_frame.start.year, time_frame.start.mon, time_frame.start.day)
			while bucket_start < time_frame.end
				bucket_end   = Time.at( bucket_start.to_i + step*day )
				buckets << {start_date: bucket_start, end_date: bucket_end, objects: []}
				bucket_start = bucket_end
			end
		
		when :week
			#fuck us, this is going to be ugly.  How should we do this? just start from the first week of the analysis window?
			#We could just add 7 days.

		when :hour
			bucket_start = Time.mktime(time_frame.start.year, time_frame.start.mon, time_frame.start.day, time_frame.start.hour)
			while bucket_start < time_frame.end
				bucket_end   = Time.at( bucket_start.to_i + step*hour )
				buckets << {start_date: bucket_start, end_date: bucket_end, objects: []}
				bucket_start = bucket_end
			end
		end

		buckets.first[:start_date] = time_frame.start
		buckets.last[:end_date]    = time_frame.end

		return buckets
	end

	#=Method Missing
	#
	#The Analysis window overrides method-missing to offer new functions such as changesets_x_day
	def method_missing(m, *args, &block)
		# puts "Called method missing with this function: #{m} and these args: #{args}"
		begin
			#Break out the method by snake case
			pieces = m.to_s.split(/\_/)

			#Find the nodes_x_all, changesets_x_month, ways_x_yearly type of functions
			if pieces[1] == 'x'

				unless args.empty?
					cons = args[0][:constraints] #Better pass a hash
					step = args[0][:step] || 1
				end
				
				instance_eval "@#{pieces[2]}_#{pieces[0]} ||= #{pieces[0]}.run(unit: :#{pieces[2]}, step: step, constraints: cons)"
			end

		rescue => e
			puts $!
			super
		end
	end

	# Changesets
	def changesets #:doc:
		@changesets ||= Changeset_Query.new(analysis_window: self)
	end

	def changeset_count
		changesets_x_all.first[:objects].count
	end

	def distinct_users_in_changesets
		changesets_x_all.first[:objects].collect{|changeset| changeset.uid}.uniq
	end

	#Nodes
	def nodes
		@nodes ||= Node_Query.new( analysis_window: self )
	end

	def node_edit_count
		nodes_x_all.first[:objects].count
	end

	def node_added_count
		nodes_x_all.first[:objects].select{|node| node.version == 1}.count
	end

	#Ways
	def ways
		@ways ||= Way_Query.new( analysis_window: self )
	end

	def way_edit_count
		ways_x_all.first[:objects].count
	end

	def way_added_count
		ways_x_all.first[:objects].select{|way| way.version == 1}.count
	end

	#Relations
	def relations # :doc:
		@relations ||= Relation_Query.new( analysis_window: self )
	end

	def relation_edit_count
		relations_x_all.first[:objects].count
	end

	def relation_added_count
		relations_x_all.first[:objects].select{|relation| relation.version == 1}.count
	end
	
	#Users
	def all_users_data
		User_Query.new(uids: distinct_users_in_changesets).run		
	end

	def users_editing_per_year
		years = {}
		changesets_x_year.each do |bucket|
			years[ bucket[:start_date] ] = bucket[:objects].collect{|changeset| changeset.user}.uniq
		end
		years
	end

	def users_editing_per_month
		months = {}
		changesets_x_month.each do |bucket|
			months[ bucket[:start_date] ] = bucket[:objects].collect{|changeset| changeset.user}.uniq
		end
		months
	end

	def new_contributors
		all_users_data.select{|user| user.account_created > time_frame.start and user.account_created < time_frame.end}.collect{|user| user.user}
	end

	def experienced_contributors
		all_users_data.select{|user| user.account_created < time_frame.start}.collect{|user| user.user}
	end

	def top_contributors_by_changesets(args={limit: 5, unit: :all_time })

		case args[:unit]
		when :all_time
			changesets_per_unit = changesets_x_all.first[:objects].group_by{|changeset| changeset.user}.sort_by{|k,v| v.length}.reverse
		when :month
			changesets_per_unit = changesets_x_month.group_by{|changeset| changeset.created_at.to_i / 100000}
		end
		changesets_per_unit.first(args[:limit])
	end
end