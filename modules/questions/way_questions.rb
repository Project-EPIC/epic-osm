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

      def number_of_ways_per_tag
        ways_per_tag = []
        tags = aw.changeset_tags.split(" ")
        tags.each do |tag|
            changesets = Changeset_Query.new(analysis_window: aw, constraints: {'comment' => {'$regex' => ".*"+tag+".*"}}).run.first[:objects].map do |changeset|
              changeset.id.to_s
            end
            ways_per_tag.push({"tag"=> tag, "count"=> Way_Query.new(analysis_window: aw, constraints: {'changeset' => {'$in' => changesets}}).run.first[:objects].length })
        end
        ways_per_tag
      end

      def number_of_highways_per_tag
        ways_per_tag = []
        tags = aw.changeset_tags.split(" ")
        tags.each do |tag|
            changesets = Changeset_Query.new(analysis_window: aw, constraints: {'comment' => {'$regex' => ".*"+tag+".*"}}).run.first[:objects].map do |changeset|
              changeset.id.to_s
            end
            ways_per_tag.push({"tag"=> tag, "count"=> Way_Query.new(analysis_window: aw, constraints: {'changeset' => {'$in' => changesets}, "tags.highway" => {'$exists' => true} }).run.first[:objects].length })
        end
        ways_per_tag
      end

      def number_of_buildings_per_tag
        ways_per_tag = []
        tags = aw.changeset_tags.split(" ")
        tags.each do |tag|
            changesets = Changeset_Query.new(analysis_window: aw, constraints: {'comment' => {'$regex' => ".*"+tag+".*"}}).run.first[:objects].map do |changeset|
              changeset.id.to_s
            end
            ways_per_tag.push({"tag"=> tag, "count"=> Way_Query.new(analysis_window: aw, constraints: {'changeset' => {'$in' => changesets}, "tags.building" => {'$exists' => true} }).run.first[:objects].length })
        end
        ways_per_tag
      end

	end
end
