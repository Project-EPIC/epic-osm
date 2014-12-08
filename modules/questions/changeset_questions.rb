module Questions

	class Changesets < QuestionsRunner

		def total_changesets_created
			{"Number of Changesets" => aw.changeset_count}
		end
		
		def mean_changesets_per_mapper
			changesets_by_uid = aw.changesets_x_all.first[:objects].group_by{|changeset| changeset.uid}
			sum = 0
			changesets_by_uid.each do |uid, changesets|
				sum += changesets.length
			end
			{"Mean Changesets Per Mapper" => sum.to_f / changesets_by_uid.keys.length}	  # / changesets_by_uid.count
		end

		#Going to need a statistics module
		def median_changesets_per_mapper

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
			return nodes_in_changeset.first[:objects].count / ( changeset.area / 100000 )
		end

		def average_changeset_node_density
			aw.changesets_x_all.first[:objects].each do |changeset|
				puts changeset_node_density(changeset)
			end
		end
	end

end
