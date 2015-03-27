module Questions # :nodoc: all

	class Ways < QuestionsRunner

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
