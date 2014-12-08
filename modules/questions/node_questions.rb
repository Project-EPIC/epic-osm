module Questions

	#Node Questions
	class Nodes < QuestionsRunner

    	def total_nodes_edited
			return {'Total Nodes Edited' => aw.node_edit_count }
		end

		def number_of_nodes_added
     		aw.node_added_count
  		end

  		#Count the number of nodes edited by new mappers
  		def number_of_nodes_edited_by_new_mappers
  			new_contributors = aw.new_contributors
  			#Node_Query.new(analysis_window: aw, constraints: {'user' => {'$in' => new_contributors}}).run
  			#puts nodes[:objects].length
  		end
	end
end