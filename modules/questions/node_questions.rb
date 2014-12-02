module Questions

	#Node Questions
	class Nodes < QuestionsRunner

    	def total_nodes_edited
			return {'Total Nodes Edited' => aw.node_edit_count }
		end

		def number_of_nodes_added
     		aw.node_added_count
  		end
	 end
end