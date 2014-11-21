module OSMGeo

	require 'rgeo'
	Factory = RGeo::Geographic.simple_mercator_factory

	module OSMObject

		def geojson_geometry
			@geometry ||= get_geojson_geometry
		end

	end

	module Node

		def point
			@point ||= Factory.point(lat, lon)
		end

	end

	module Way

		#TODO
		def line_string
			nil
			#This needs to parse the GeoJSON in Mongo

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
end