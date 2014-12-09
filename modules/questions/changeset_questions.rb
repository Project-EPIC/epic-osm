module Questions

	class Changesets < QuestionsRunner

		def total_changesets_created
			{"Number of Changesets" => aw.changeset_count}
		end

		def changesets_per_mapper
			changesets_by_uid = aw.changesets_x_all.first[:objects].group_by{|changeset| changeset.uid}
		end
		
		def mean_changesets_per_mapper
			num_changesets = changesets_per_mapper.collect{|uid, changesets| changesets.length}
			{"Mean Changesets Per Mapper" => DescriptiveStatistics.mean(num_changesets) }	  # / changesets_by_uid.count
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
			elsif changeset.area < 1 or changeset.area == Float::INFINITY #Need a new filter for this part
				return nil
			else
				return node_count / ( changeset.area / 100000 )
			end
		end

		def average_changeset_node_density
			density_sum = 0.0
			cnt = 0
			aw.changesets_x_all.first[:objects].each do |changeset|
				density =  changeset_node_density(changeset)
				density_sum += density unless density.nil?
				cnt+=1 unless density.nil?
			end
			{"Average Changeset Node Density" => density_sum / cnt}
		end

		def average_changeset_area
			area_sum = 0
			cnt = 0
			aw.changesets_x_all.first[:objects].each do |changeset|
				area_sum += changeset.area
				cnt +=1
			end
			{"Average Changeset Area" => area_sum / cnt}
		end
	end

end
