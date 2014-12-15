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