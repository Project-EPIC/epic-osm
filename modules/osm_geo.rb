#
# 
#
#
#

#Pulling out all Geo functions to this module for safety

module OSMGeo

	class MissingNodes < StandardError
	end

	require 'rgeo'
	Factory = RGeo::Geographic.simple_mercator_factory

	module Node

		def point
			@point ||= Factory.point(lat, lon)
		end

	end

	module Way

		#When you want a linestring, you have to pass in ALL of the nodes, which sucks.
		def build_line_string(all_nodes=nil)
			if all_nodes.nil?
				raise MissingNodes.new("A linestring must be passed all of the nodes { nodes_x_all.first[:objects] } so it knows what to do")
			end

			# Only have references to node id_strs, so we need to get the actual nodes.
			these_nodes = []
			missing_nodes = []

			nodes.each do |node_id|
				#Find all the versions of the nodes which may exist in this way
				matches = all_nodes.select{ |node| node.id == node_id }

				unless matches.empty?
					
					#If there is only one, then this is the node
					if matches.length == 1
						these_nodes << matches.first

					#Else, there are multiple versions, so take the node which was created with this changeset
					else
						these_nodes << matches.select{ |node| node.changeset == changeset}.first
					end
				else
					missing_nodes << node_id
				end
			end

			unless missing_nodes.empty?
				raise MissingNodes.new("Could not find #{missing_nodes.length} nodes for way #{id}.  Missing Nodes: #{missing_nodes}")
			end

			unless these_nodes.empty?
				return Factory.line_string( these_nodes.collect{|node| node.point})
			else
				raise MissingNodes.new("Could not find ANY nodes for way: #{id}")
			end
		end

		def line_string(nodes=nil)
			@line_string ||= build_line_string(nodes)
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
end