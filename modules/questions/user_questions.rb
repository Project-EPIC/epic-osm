module Questions # :nodoc: all

	class Users < QuestionsRunner

		def total_user_count
			{"Total User Count" => aw.distinct_users_in_changesets.length }
		end

		def new_user_count
			{"New User Count" => aw.new_contributors.length }
		end

		def experienced_user_count
			{"Experienced User Count" => aw.experienced_contributors.length}
		end

		def users_editing_per_month
			months = {}
			aw.changesets_x_month.each do |bucket|
				months[ bucket[:start_date] ] = bucket[:objects].collect{|changeset| changeset.user}.uniq
			end
			months
		end
	end

end