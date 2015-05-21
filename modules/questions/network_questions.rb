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

				geojson_export = FileIO::JSONExporter.new(path: directory, name: "ActualWays-#{bucket[:start_date]}-#{bucket[:end_date]}.geojson")

				#http://stackoverflow.com/questions/5470725/how-to-group-by-count-in-array-without-using-loop
				# node_count_in_bucket = buckets.collect{|bucket| bucket[:objects].collect{|way| way.nodes}}.flatten.inject(Hash.new(0)){|h,e| h[e]+=1 ; h}

				nodes = {}
				edges = {}

				overlapping_ways = []

				#Go through each way and look at the ways after it.
				bucket[:objects].each_with_index do |first_way, index|
					nodes[first_way.user] ||= {id: first_way.user, size: 1}
					nodes[first_way.user][:size] +=1
					#Iterate through all of the ways that come after
					bucket[:objects][index..-1].each do |way_after|
						#If the users are different, check if they share any nodes
						if way_after.user != first_way.user
							if (first_way.nodes & way_after.nodes).count == 1
								overlapping_ways << first_way << way_after
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
				these_ways = FileIO::unpack_objects([ {:objects => overlapping_ways} ])
				clean_ways = []
				# puts these_ways
				these_ways.first[:objects].each do |w|
					clean_ways << {"type"=>"Feature","properties"=>{
						"user" => w["user"],
						"date" => w["created_at"],
						"uid"  => w["uid"],
						"changeset" => w["changeset"]
						},"geometry"=>w["geometry"]}
					end
				geojson_export.write(type: "FeatureCollection", features: clean_ways)
				this_file.write_network(nodes: nodes.values, edges: edges.values, options: {directed: true}, title: "Connected Roads Network: \n#{bucket[:start_date]} - #{bucket[:end_date]}")
			end
		end

		def overlapping_changesets_distinct_objects(args)

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

				overlapping_edits = []
				this_geojson = FileIO::JSONExporter.new(path: directory, name: "actual_ways-#{bucket[:start_date]}-#{bucket[:end_date]}.geojson")

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
							if (changeset_1.area < 1000000) and (changeset_2.area < 1000000)
								if changeset_1.bounding_box.intersects? changeset_2.bounding_box

									unless edges["#{user_1}-#{user_2}"].nil?
										edges["#{user_1}-#{user_2}"][:weight] += 1
										edges["#{user_2}-#{user_1}"][:weight] += 1
									else
										edges["#{user_1}-#{user_2}"] = {source: user_1, target: user_2, weight: 1}
										edges["#{user_2}-#{user_1}"] = {source: user_2, target: user_1, weight: 1}
									end
									# We have an overlapping changeset -- lets look at some of the objects???
									c1_ways = Way_Query.new(analysis_window: aw, constraints: {'changeset' => changeset_1.id}).run
									c2_ways = Way_Query.new(analysis_window: aw, constraints: {'changeset' => changeset_2.id}).run
									if (c1_ways.first[:objects].collect{|w| w.nodes} & c2_ways.first[:objects].collect{|w| w.nodes}).length == 0
										overlapping_edits << c1_ways.first[:objects] << c2_ways.first[:objects]
									end
									overlapping_edits.flatten!
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
				clean_ways = []
				these_ways = FileIO::unpack_objects([ {:objects => overlapping_edits} ])
				puts these_ways
				these_ways.first[:objects].each do |w|
					clean_ways << {"type"=>"Feature","properties"=>{
						"user" => w["user"],
						"date" => w["created_at"],
						"uid"  => w["uid"],
						"changeset" => w["changeset"]
						},"geometry"=>w["geometry"]}
					end
				this_geojson.write({type: "FeatureCollection", features: clean_ways})

				this_file.write_network(nodes: users.values, edges: edges.values, options: {directed: false}, title: "Overlapping Changeset Network: \n#{bucket[:start_date]} - #{bucket[:end_date]}")
			end
			puts "Found #{unique_users.uniq.count} users"
		end

		def co_editing_objects(args)
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

				#The users in this bucket
				these_users = bucket[:objects].collect{|cSet| [cSet.uid, cSet.user]}.uniq
				puts bucket[:start_date], bucket[:end_date]
				puts "User Count: #{these_users.count}"
				puts "================================"
				these_users.each do |user|
					uid = user[0]
					puts "user: #{user[1]}"
					n = Node_Query.new(analysis_window: aw, constraints: {'uid'=>uid,
						:created_at=>{'$gte'=>bucket[:start_date], '$lt'=>bucket[:end_date]}}).run.first[:objects].collect{|x| x.id}
					w = Way_Query.new(analysis_window: aw, constraints: {'uid'=>uid,
					  :created_at=>{'$gte'=>bucket[:start_date], '$lt'=>bucket[:end_date]}}).run.first[:objects].collect{|x| x.id}
					r = Relation_Query.new(analysis_window: aw, constraints: {'uid'=>uid,
						:created_at=>{'$gte'=>bucket[:start_date], '$lt'=>bucket[:end_date]}}).run.first[:objects].collect{|x| x.id}
					# puts "Nodes: #{n.length}, Ways: #{w.length}, Rels: #{r.length}"
					objs = n+w+r
					puts "Total objs: #{objs.length}"
					if objs.length > 0
						users[user[0].to_s] = {uid: user[0], user: user[1], objects: objs}
						if experienced_users.include? user[1]
							users[user[0].to_s]["status"] = "Experienced"
						else
							users[user[0].to_s]["status"] = "New"
						end
					end
				end
				# #In the bucket, have all the user objects:
				vals = users.values
				size = vals.length
				puts size
				size.times do |idx|
					((idx+1)..(size-1)).each do |jdx|
						intersect = (vals[idx][:objects] & vals[jdx][:objects]).length #Set intersection
						if intersect > 0
							user_1 = vals[idx][:user]
							user_2 = vals[jdx][:user]
							unless edges["#{user_1}-#{user_2}"].nil?
								edges["#{user_1}-#{user_2}"][:weight] += 1
							else
								edges["#{user_1}-#{user_2}"] = {source: user_1, target: user_2, weight: 1}
							end
						end
					end
				end
				usernames = users.values.collect{|x| { id: x[:user], size: Math.sqrt(x[:objects].length)} }
				this_file.write_network(nodes: usernames, edges: edges.values, options: {directed: false}, title: "Co-Editing Network: \n#{bucket[:start_date]} - #{bucket[:end_date]}")
			end
		end
	end
end
