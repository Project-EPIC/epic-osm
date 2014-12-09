module Questions

  #Node Questions
  class Nodes < QuestionsRunner

    #Total nodes edited in the analysis window
    def total_nodes_edited
  		{'Total Nodes Edited' => aw.node_edit_count }
  	end

    #Nodes Added (finds nodes in AW where version==1)
  	def number_of_new_nodes
    	{'New Nodes Added' => aw.node_added_count }
  	end

  	#Count the number of nodes edited by new mappers (those who created account during the aw)
  	def number_of_nodes_edited_by_new_mappers
  		nodes_by_new_mappers = Node_Query.new(analysis_window: aw, constraints: {'user' => {'$in' => aw.new_contributors}}).run
      {'Nodes Edited by New Mappers' => nodes_by_new_mappers.first[:objects].length }
  	end

    #Count the number of nodes edited by experienced mappers (those who had accounts before the aw)
    def number_of_nodes_edited_by_experienced_mappers
      nodes_by_experienced_mappers = Node_Query.new(analysis_window: aw, constraints: {'user' => {'$in' => aw.experienced_contributors}}).run
      {'Nodes Edited by Experienced Mappers' => nodes_by_experienced_mappers.first[:objects].length }
    end
  end
end