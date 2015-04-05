module Questions # :nodoc: all

	module Ways

		def buildings_by_month
			return aw.ways_x_month(constraints: {"tags.building" => "yes"})
		end

		def number_of_ways_edited
			{"Number of Ways Edited" => aw.way_edit_count}
		end

		def new_ways_per_day
			ways_added_per_day = []
			new_ways_cumulative = 0
			aw.ways_x_day(constraints: {"version" => 1}).each do |bucket|
				new_ways_cumulative += bucket[:objects].length
				ways_added_per_day << {start_date: bucket[:start_date], end_date: bucket[:end_date], new_node_count: bucket[:objects].length, cumulative_ways: new_ways_cumulative}
			end
			ways_added_per_day
	    end

		def number_of_buildings_edited
			{"Number of Buildings Edited" => aw.ways_x_all(constraints: {"tags.building" => "yes"}).first[:objects].count}
		end

		def size_of_buildings
			buildings_by_month.each do |bucket|
				bucket[:objects].each do |building|
					puts building.line_string.length
				end
			end
		end

	end
end
