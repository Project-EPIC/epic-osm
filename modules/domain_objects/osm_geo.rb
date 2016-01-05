module OSMGeo #:nodoc: all

	require 'rgeo'
	$factory = RGeo::Geographic.simple_mercator_factory

	module OSMObject

		def geojson_geometry
			@geojson_geometry || get_geojson_geometry
		end

	end

	module Node
		def point
			@point ||= $factory.point(lon.to_f, lat.to_f)
		end

		def geojson_geometry
			@geojson_geometry ||= {
				type: "Point",
				coordinates: [
					lon.to_f,
					lat.to_f
				]
			}
		end

	end

	module Way

		def line_string
			unless geometry.nil?
				if geometry["coordinates"].first.is_a? Array
					@line_string ||= $factory.line_string(geometry["coordinates"].collect{|p| $factory.point(p.first, p.last)})
					return @line_string
				else
					@point ||= $factory.point( geometry["coordinates"].first, geometry["coordinates"].last )
					return @point
				end
			else
				return nil
			end
		end

		def length
			line_string.length
		end

	end

	module Changeset

		#Returns a square polygon for the bounding box
		def bounding_box
			bounds = [
				$factory.point(min_lon, min_lat),
				$factory.point(min_lon, max_lat),
				$factory.point(max_lon, max_lat),
				$factory.point(max_lon, min_lat),
				$factory.point(min_lon, min_lat) ]
			@bounding_box ||= $factory.polygon( $factory.linear_ring( bounds ) )
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
			{
				type: "Point",
				coordinates: [
					lon.to_f,
					lat.to_f
				]
			}
		end
	end

	#Helper function to return the envelope of the new objects in a specific changeset
	def extents_of_new_objects_in_changesets(changeset_id)
		ways  = Way_Query.new(  analysis_window: aw, constraints: {changeset: changeset_id, version: 1} ).run.first[:objects]
		nodes = Node_Query.new( analysis_window: aw, constraints: {changeset: changeset_id, version: 1} ).run.first[:objects]

		nodes_in_ways = ways.collect{|way| way.nodes}.flatten
		nodes.reject!{|n| nodes_in_ways.include? n.id}

		geo_objs = (ways.collect{|way| way.line_string} + nodes.collect{|node| node.point}).compact

		geo = $factory.collection(geo_objs)
		if geo.dimension > 0
			return geo.envelope
		else
			return nil
		end
	end
end
