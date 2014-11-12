module Questions

	module Nodes

    #This is starting to look less and less necessary
		def number_of_nodes_edited
			analysis_window.node_edit_count
		end

		def number_of_nodes_added
     		analysis_window.node_added_count
  		end

    
    	# def temporal_test
    	# 	analysis_window.nodes_x_hour(1)
	 end
  	
end