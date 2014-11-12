module Questions

	module Ways

		def buildings_by_month
	    	analysis_window.ways_x_month(constraints: {"tags.building" => "yes"}).each do |bucket|
	        	puts "#{bucket[:start_date]}, #{bucket[:end_date]}, #{bucket[:objects].count}"
	    	end
	    end
	 end
  	
end