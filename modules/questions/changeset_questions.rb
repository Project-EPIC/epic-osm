module Questions # :nodoc: all

	module Changesets

		def total_changesets_created
			{"Number of Changesets" => aw.changeset_count}
		end

		def changesets_per_mapper
			changesets_by_uid = aw.changesets_x_all.first[:objects].group_by{|changeset| changeset.uid}
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
			{"Median Changeset Node Density" => DescriptiveStatistics.median(changeset_node_densities) }
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
