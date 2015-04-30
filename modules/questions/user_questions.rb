module Questions # :nodoc: all

	module Users

		def user_time_frame(time='month', args={})
			begin
				#The Users editing case: users_editing_per_year
				unless args.empty?
					cons = args[:constraints] #Better pass a hash
					step = args[:step] || 1
				end

				time_buckets = {}
				changesets = aw.instance_eval "changesets_x_#{time}(step: step, cons: cons)"


				changesets.each do |bucket|
					time_buckets[ bucket[:start_date] ] = bucket[:objects].collect{|changeset| changeset.user}.uniq
				end

				return time_buckets
			rescue => e
				puts $!
				puts e.backtrace
			end
		end

		# :category: Users
		def all_contributors_with_count
			user_data = []
			aw.all_users_data.each{ |user|
				user_data.push({
					"user" => user.user,
					"nodes" => nodes_x_all(constraints: {'uid' => user.uid}).first[:objects].select{ |node| !node.tags.empty?}.count,
					"ways" => ways_x_all(constraints: {'uid' => user.uid}).first[:objects].count,
					"relations" => relations_x_all(constraints: {'uid' => user.uid}).first[:objects].count,
					"changesets" => changesets_x_all(constraints: {'uid' => user.uid}).first[:objects].count,
				})
			}
			user_data
		end

		# :category: Users
		def all_contributors_with_geometry
			user_data = {}
			aw.all_users_data.each{ |user|
				user_data[ user.user ] = {
					"type" => "FeatureCollection",
					"features" =>
						ways_x_all(constraints: {'uid' => user.uid}).first[:objects].collect{|way|
							{ "type" => "Feature", "properties"=> way.tags, "geometry" => way.geometry }
						} +
						nodes_x_all(constraints: {'uid' => user.uid}).first[:objects].select{|node| !node.tags.empty?}.collect{|node|
							{ "type" => "Feature", "properties"=> node.tags, "geometry" => node.geometry }
						}
				}
			}
			user_data
		end

		# :category: Users
		def top_contributors_by_changesets(args={limit: 5, unit: :all_time })

			case args[:unit]
			when :all_time
				changesets_per_unit = aw.changesets_x_all.first[:objects].group_by{|changeset| changeset.user}.sort_by{|k,v| v.length}.reverse
			when :month
				changesets_per_unit = aw.changesets_x_month.group_by{ |changeset|
					if defined? changeset.created_at
						changeset.created_at.to_i / 100000
					end
				}
			end
			changesets_per_unit.first(args[:limit])
		end

		def total_user_count
			{"Total User Count" => aw.distinct_users_in_changesets.length }
		end

		def new_user_count
			{"New User Count" => aw.new_contributors.length }
		end

		def experienced_user_count
			{"Experienced User Count" => aw.experienced_contributors.length}
		end

		def user_list
			all_contributors_with_count
		end

	end
end
