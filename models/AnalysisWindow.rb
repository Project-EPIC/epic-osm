#
#
#
#
#

class AnalysisWindow

	#TODO:
	# => Datastore? Will we spin up a new Mongo collection? PostGreSQL?

	attr_reader :time_frame, :bounding_box

	def initialize(args)
		@bounding_box = args[:bounding_box]
		@time_frame   = args[:time_frame]
	end

	def full_data_set
		nil
		# => Sets the boundaries to nil, or something... probably too coupled
	end
end


class BoundingBox #< RGeo::Geometry::Polygon #Or something...

	attr_reader :bottom_left, :top_right

	def initialize(args)
		@bottom_left = args[:bottom_left]
		@top_right   = args[:top_right]
	end

	#TODO: 
	# => Area, Width, Height, Hemisphere, Country, Continent, etc.

end

class TimeFrame

	#TODO:
	# => We want flexiblity in how we input dates, so this class will
	# => transform these dates to the proper format.

	attr_reader :start, :end

	def initialize(args)
		@start = args[:start]
		@end   = args[:end]
	end

	def post_initialize(args)
		#be sure to handle dates in a consistent manner
	end

	def duration
		nil
	end

	#Silly management functions

end