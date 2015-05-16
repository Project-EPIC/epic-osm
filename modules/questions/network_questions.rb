module Questions # :nodoc: all

	module Networks # :nodoc: all

		def overlapping_changesets(args)

			unit, step, directory, constraints = args['unit'], args['step'], args['files'], args['constraints'] || {}

			#make the directory
			FileUtils.mkpath(directory) unless Dir.exists? directory

			buckets = instance_eval "aw.changesets_x_#{unit}(step: #{step}, constraints: #{constraints})"

			experienced_users = aw.experienced_contributors
			new_users         = aw.new_contributors

			unique_users = []
			buckets.each do |bucket|
				this_file = FileIO::JSONExporter.new(path: directory, name: "#{bucket[:start_date]}-#{bucket[:end_date]}.json")
				users = {}
				edges = {}

				size = bucket[:objects].count

				size.times do |i|
					((i+1)..(size-1)).each do |j|
						changeset_1 = bucket[:objects][i]
						changeset_2 = bucket[:objects][j]

						user_1 = bucket[:objects][i].user
						user_2 = bucket[:objects][j].user

						unique_users << user_1
						unique_users << user_2

						users[user_1] ||= {id: user_1, weight: 1}
						users[user_2] ||= {id: user_2, weight: 1}


						unless user_1 == user_2
							if (changeset_1.area < 100000000) and (changeset_2.area < 100000000)
								if changeset_1.bounding_box.intersects? changeset_2.bounding_box

									unless edges["#{user_1}-#{user_2}"].nil?
										edges["#{user_1}-#{user_2}"][:weight] += 1
										edges["#{user_2}-#{user_1}"][:weight] += 1
									else
										edges["#{user_1}-#{user_2}"] = {source: user_1, target: user_2, weight: 1}
										edges["#{user_2}-#{user_1}"] = {source: user_2, target: user_1, weight: 1}
									end
								end
							end
						end
					end
				end
				puts "Found #{users.values.length} users during #{bucket[:start_date]}"
				users.values.each do |node|
					unique_users << node[:id]
				end

				users.values.each do |node|
					if experienced_users.include? node[:id]
						node["status"] = "Experienced"
					else
						node["status"] = "New"
					end
				end

				this_file.write_network(nodes: users.values, edges: edges.values, options: {directed: false}, title: "Overlapping Changeset Network: \n#{bucket[:start_date]} - #{bucket[:end_date]}")
			end
			puts "Found #{unique_users.uniq.count} users"
		end


		#
		#	An intersecting road are any two ways which are tagged with highway != null which share
		#	1 node.
		#
		def intersecting_roads(args)
			unit, step, directory, constraints = args['unit'], args['step'], args['files'], args['constraints'] || {}

			#make the directory
			FileUtils.mkpath(directory) unless Dir.exists? directory

			buckets = instance_eval "aw.ways_x_#{unit}(step: #{step}, constraints: #{constraints})"

			experienced_users = aw.experienced_contributors
			new_users         = aw.new_contributors

			buckets.each do |bucket|
				# this_file = make_file(filename="#{bucket[:start_date]}-#{bucket[:end_date]}", directory=directory)
				this_file = FileIO::JSONExporter.new(path: directory, name: "#{bucket[:start_date]}-#{bucket[:end_date]}.json")

				#http://stackoverflow.com/questions/5470725/how-to-group-by-count-in-array-without-using-loop
				# node_count_in_bucket = buckets.collect{|bucket| bucket[:objects].collect{|way| way.nodes}}.flatten.inject(Hash.new(0)){|h,e| h[e]+=1 ; h}

				nodes = {}
				edges = {}

				#Go through each way and look at the ways after it.
				bucket[:objects].each_with_index do |first_way, index|
					nodes[first_way.user] ||= {id: first_way.user, weight: 1}
					nodes[first_way.user][:weight] +=1
					#Iterate through all of the ways that come after
					bucket[:objects][index..-1].each do |way_after|
						#If the users are different, check if they share any nodes
						if way_after.user != first_way.user
							if (first_way.nodes & way_after.nodes).count == 1
								unless edges["#{way_after.user}-#{first_way.user}"].nil?
									edges["#{way_after.user}-#{first_way.user}"][:weight] += 1
								else
									edges["#{way_after.user}-#{first_way.user}"] = {source: way_after.user, target: first_way.user, weight: 1, name: "#{way_after.user}-#{first_way.user}"}
								end
							end
						end
					end
				end
				nodes.values.each do |node|
					if experienced_users.include? node[:id]
						node["status"] = "Experienced"
					else
						node["status"] = "New"
					end
				end

				this_file.write_network(nodes: nodes.values, edges: edges.values, options: {directed: true}, title: "Connected Roads Network: \n#{bucket[:start_date]} - #{bucket[:end_date]}")
			end
		end
	end
end
