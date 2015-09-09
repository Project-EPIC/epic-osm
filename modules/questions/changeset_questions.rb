module Questions # :nodoc: all

	module Changesets

		require 'rgeo-geojson'

		def total_changesets_created
			{"Number of Changesets" => aw.changeset_count}
		end

		def changesets_per_mapper
			changesets_by_uid = aw.changesets_x_all.first[:objects].group_by{|changeset| changeset.uid}
		end

		def changeset_ids_per_mapper
			users = {}
			aw.changesets_x_all.first[:objects].group_by{|changeset| changeset.user}.each do |user, changesets|
				users[user] = changesets.collect{|x| x.id}
			end
			return users
		end

		def number_of_changesets_per_mapper
			changesets_by_uid = aw.changesets_x_all.first[:objects].group_by{|changeset| changeset.user}
			changeset_counts = {}
			changesets_by_uid.each do |user, changesets|
				changeset_counts[user] = changesets.count
			end
			changeset_counts
		end

		def mean_changesets_per_mapper
			num_changesets = changesets_per_mapper.collect{|uid, changesets| changesets.length}
			{"Mean Changesets Per Mapper" => DescriptiveStatistics.mean(num_changesets) }
		end

		def median_changesets_per_mapper
			num_changesets = changesets_per_mapper.collect{|uid, changesets| changesets.length}
			{"Median Changesets Per Mapper" => DescriptiveStatistics.median(num_changesets) }
		end

		def number_of_changesets_by_new_mappers
			changesets_by_new_mappers = Changeset_Query.new(analysis_window: aw, constraints: {'user' => {'$in' => aw.new_contributors}}).run
			{'Number of Changesets by New Mappers' => changesets_by_new_mappers.first[:objects].length }
		end

		def number_of_changesets_by_experienced_mappers
			changesets_by_experienced_mappers = Changeset_Query.new(analysis_window: aw, constraints: {'user' => {'$in' => aw.experienced_contributors}}).run
			{'Number of Changesets by Experienced Mappers' => changesets_by_experienced_mappers.first[:objects].length }
		end

    def number_of_changesets_per_tag
      changesets_per_tag = []
      tags = aw.changeset_tags.split(" ")
      tags.each do |tag|
        changesets_per_tag.push({"tag"=> tag, "count"=> Changeset_Query.new(analysis_window: aw, constraints: {'comment' => {'$regex' => ".*"+tag+".*"}}).run.first[:objects].length })
      end
      changesets_per_tag
    end

		def changeset_node_density(changeset)
			nodes_in_changeset = Node_Query.new(analysis_window: aw, constraints: {'changeset'=> changeset.id}).run
			node_count = nodes_in_changeset.first[:objects].count
			if node_count.zero?
				return nil
			else
				area = filtered_changeset_area(changeset)
				unless area.nil?
					return node_count / ( area / 1000000 )
				else
					return nil
				end
			end
		end

		attr_reader :changeset_node_densities
		def changeset_node_densities
			@changeset_densities ||= aw.changesets_x_all.first[:objects].collect{ |changeset| changeset_node_density(changeset) }.compact
		end

		def average_changeset_node_density
			{"Average Changeset Node Density" => DescriptiveStatistics.mean(changeset_node_densities) }
		end

		def median_changeset_node_density
			{"Median Changeset Node Density"  => DescriptiveStatistics.median(changeset_node_densities) }
		end

		def filtered_changeset_area(changeset)
			#Apply filters
			a = changeset.area
			if a.nil?
				return nil
			elsif a > aw.min_area and a < aw.max_area
				return a
			else
				return nil
			end
		end

		def compare_changeset_objects_bbox_to_changeset_area(args)
			directory = args['files'] || '/data/www/tmp'
			FileUtils.mkpath(directory) unless Dir.exists? directory

			$osm_areas = []
			$my_areas = []

			changeset_ids = aw.changesets_x_all.first[:objects].each do |changeset|
				# geojson_export = FileIO::JSONExporter.new(path: directory, name: "ChangesetGeometry-#{changeset.id}.geojson")
				# puts "Changeset: #{changeset.id}"
				ways = Way_Query.new(analysis_window: aw, constraints: {changeset: changeset.id, version: 1}).run.first[:objects]
				nodes = Node_Query.new(analysis_window: aw, constraints: {changeset: changeset.id, version: 1}).run.first[:objects]

				nodes_in_ways = ways.collect{|way| way.nodes}.flatten

				nodes.reject!{|n| nodes_in_ways.include? n.id}

				geo_objs = (ways.collect{|way| way.line_string} + nodes.collect{|node| node.point}).compact

				geo = $factory.collection(geo_objs)

				if geo.dimension > 0

					geojson_geometries = []
					(ways + nodes).each do |obj|
						geojson_geometries << {type: "Feature", geometry: obj.geometry, properties: {
							id: obj.id,
							uid: obj.uid,
							user: obj.user,
							c_set: obj.changeset
							}}
					end

					bbox = geo.envelope

					geojson_geometries <<
						{type: "Feature",
						 geometry: RGeo::GeoJSON.encode(bbox, factory: $factory),
						 properties: {
							 Calculation: "ConvexHull",
							 changeset: changeset.id
						 }
					 }

					geojson_geometries <<
						{type: "Feature",
						 geometry: RGeo::GeoJSON.encode(changeset.bounding_box, factory: $factory),
						 properties: {
							 Calculation: "OSM",
							 changeset: changeset.id
						 }
					 }


					$my_areas << bbox.area
					$osm_areas << changeset.area

					# geojson_export.write({type: "FeatureCollection", features: geojson_geometries})
				end
			end
			# return {my_areas: my_areas, osm_areas: osm_areas}
		end

		def average_changeset_area
			areas = aw.changesets_x_all.first[:objects].collect{ |changeset| filtered_changeset_area(changeset) }.compact
			{"Average Changeset Area" => DescriptiveStatistics.mean(areas) }
		end

		#Not very efficient, but, well, it works...
		def average_overlaps_per_changeset
			changeset_overlaps = {}

			#Ensure they're sorted
			changesets = aw.changesets_x_all.first[:objects]

			changesets.select!{|changeset| filtered_changeset_area(changeset)}

			#Iterate through the changesets
			changesets.each_with_index do |base_changeset|

				#Initialize this changeset into the Hash
				changeset_overlaps[base_changeset.id] ||= []

				changesets.each do |check_changeset|
					changeset_overlaps[base_changeset.id] << check_changeset.id if base_changeset.bounding_box.intersects? check_changeset.bounding_box
				end
			end
			changeset_overlap_sums = changeset_overlaps.collect{|changeset_id, overlaps| overlaps.length}
			{"Average Overlaps Per Changeset" => DescriptiveStatistics.mean(changeset_overlap_sums)}
		end
	end

end
