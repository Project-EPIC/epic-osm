module OSMGeo #:nodoc: all

	require 'rgeo'
	Factory = RGeo::Geographic.simple_mercator_factory

	module OSMObject

	end

	module Node

		def point
			@point ||= Factory.point(lat, lon)
		end

		def geojson_geometry
			"{type: \"Point\", \"coordinates\": [#{lon},#{lat}]}"
		end

	end

	module Way

		#TODO
		def line_string

			points = geometry["coordinates"].collect{|p| Factory.point(p.first, p.last)}

			return Factory.line_string(points)

			#This needs to parse the GeoJSON in Mongo #but, should it?

			#Needs to be aware of the case where it's a point, not a line.
		end

		def length
			line_string.length
		end

	end

	module Changeset

		#Returns a square polygon for the bounding box
		def bounding_box
			bounds = [
				Factory.point(min_lon, min_lat),
				Factory.point(min_lon, max_lat),
				Factory.point(max_lon, max_lat),
				Factory.point(max_lon, min_lat),
				Factory.point(min_lon, min_lat) ]

			@bounding_box ||= Factory.polygon( Factory.linear_ring( bounds ) )
		end

		#Returns Changeset area in square meters
		def area
			@area ||= bounding_box.area
		end
	end

	module Relation
		def geometry
			nil #This is a geometry collection of nodes + ways
		end

		def bounding_box
			nil #geometry.convex_hull
		end
	end

	module Note
		def geojson_geometry
			"{type: \"Point\", \"coordinates\": [#{lon},#{lat}]}"
		end
	end
end
