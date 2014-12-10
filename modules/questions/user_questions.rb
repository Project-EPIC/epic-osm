module Questions

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
	end

end