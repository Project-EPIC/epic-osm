module Questions

	module Ways

		def buildings_by_month
	    	analysis_window.ways_x_month(constraints: {"tags.building" => "yes"}).each do |bucket|
	        	puts "#{bucket[:start_date]}, #{bucket[:end_date]}, #{bucket[:objects].count}"
	    	end
	    end

	    def number_of_ways_edited
      		puts analysis_window.way_edit_count
      	end

    	def number_of_buildings_edited
     		puts analysis_window.ways_x_all(constraints: {"tags.building" => "yes"}).count
     	end

	end
end