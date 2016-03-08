#TODO
# => Define our own bounding box for changesets (don't use the max/min)
# => We can make RICHER networks by stricter definitions

module Questions # :nodoc: all

	module Networks # :nodoc: all

		def overlapping_changesets(args)

			unit, step, directory, constraints = args['unit'], args['step'], args['files'], args['constraints'] || {}
			changeset_size = args['changeset_area'] || 100000000

			#make the directory
			FileUtils.mkpath(directory) unless Dir.exists? directory

			buckets = instance_eval "aw.changesets_x_#{unit}(step: #{step}, constraints: #{constraints})"
			ways    = instance_eval "aw.ways_x_#{unit}(step: #{step})"

			experienced_users = aw.experienced_contributors
			new_users         = aw.new_contributors

			unique_users = []
			buckets.each_with_index do |bucket, idx|
				this_file = 		 FileIO::JSONExporter.new(path: directory, name: "#{bucket[:start_date]}-#{bucket[:end_date]}.json")
				geojson_export = FileIO::JSONExporter.new(path: directory, name: "Ways_for_Overlapping_Changesets-#{bucket[:start_date]}-#{bucket[:end_date]}.geojson")
				puts "Running Bucket: #{bucket[:start_date]} - #{bucket[:end_date]}"

				changesets = []

				ways_in_changesets = {}
				changeset_comments = {}
				changeset_users = {}

				users = {}
				edges = {}

				puts "Found         #{bucket[:objects].size} changesets"

				changeset_objects = bucket[:objects].select{ |x| x.area <= changeset_size }

				puts "After filter: #{changeset_objects.size}"
			  changeset_objects.sort_by!{ |x| x.created_at }

				size = changeset_objects.count

				size.times do |i|
					#Grab this changeset info
					changeset_1 = changeset_objects[i]
					user_1 = changeset_1.user
					users[user_1] ||= {id: changeset_1.uid, user: user_1, weight: 1}
					#Always putting user_1 in the network.

					c1_ways = ways[idx][:objects].select{|b| b.changeset == changeset_1.id}

					#Now iterate over all the later changesets
					((i+1)..(size-1)).each do |j|

						changeset_2 = changeset_objects[j]
						user_2 = changeset_2.user

						#If they're not the same user
						unless user_1 == user_2
							#Always put user_2 in the network
							users[user_2] ||= {id: changeset_2.uid, user: user_2, weight: 1}

							#If the two changesets overlap, then add an edge from user_2 to user_1
							if changeset_1.bounding_box.intersects? changeset_2.bounding_box

								# This means that changeset 2 OVERLAPPED changeset 1
								unless edges["#{user_2}-#{user_1}"].nil?
									edges["#{user_2}-#{user_1}"][:weight] += 1
								else
									edges["#{user_2}-#{user_1}"] = {source: changeset_2.uid, target: changeset_1.uid, weight: 1}
								end


								c2_ways = ways[idx][:objects].select{|b| b.changeset == changeset_2.id}

								ways_in_changesets[changeset_1.id] ||= c1_ways
								ways_in_changesets[changeset_2.id] ||= c2_ways

								changeset_users[changeset_1.id] ||= user_1
								changeset_users[changeset_2.id] ||= user_2

								#Save the changeset comments
								changeset_comments[changeset_1.id] ||= changeset_1.comment
								changeset_comments[changeset_2.id] ||= changeset_2.comment
							end
						end
					end
				end
				puts "Found #{users.count} users"

				users.values.each do |node|
					if experienced_users.include? node[:id]
						node["status"] = "Experienced"
					else
						node["status"] = "New"
					end
				end

				clean_ways = []
				these_ways = FileIO::unpack_objects([ {:objects => ways_in_changesets.values.flatten} ])

				these_ways.first[:objects].each do |w|
					clean_ways << {"type"=>"Feature","properties"=>{
						"user" => w["user"],
						"c_set_user" => changeset_users[w["changeset"]],
						"date" => w["created_at"],
						"uid"  => w["uid"],
						"changeset" => w["changeset"],
						"version" => w["version"],
						"object_id" => w["id"],
						"comment" => changeset_comments[w["changeset"]]
						},"geometry"=>w["geometry"]}
				end
				geojson_export.write({type: "FeatureCollection", features: clean_ways})
				this_file.write_network(nodes: users.values, edges: edges.values, options: {directed: true}, title: "Overlapping Changeset Network: \n#{bucket[:start_date]} - #{bucket[:end_date]}")
				puts "================================================================"
			end
		end

		#
		#	An intersecting road are any two ways which are tagged with highway != null which share
		#	1 node.
		#
		def intersecting_roads(args)
			unit, step, directory, constraints = args['unit'], args['step'], args['files'], args['constraints'] || {}

			#make the directory
			FileUtils.mkpath(directory) unless Dir.exists? directory

			puts "aw.ways_x_#{unit}(step: #{step}, constraints: #{constraints})"

			puts "Getting ways"
			buckets = instance_eval "aw.ways_x_#{unit}(step: #{step}, constraints: #{constraints})"



			puts "Done, getting user stats"
			experienced_users = aw.experienced_contributors
			new_users         = aw.new_contributors

			buckets.each do |bucket|
				puts "#{bucket[:start_date]}, #{bucket[:end_date]}, #{bucket[:objects].count}"
			end

			buckets.each do |bucket|
				puts "Running bucket: #{bucket[:start_date]}"
				# this_file = make_file(filename="#{bucket[:start_date]}-#{bucket[:end_date]}", directory=directory)
				this_file = FileIO::JSONExporter.new(path: directory, name: "#{bucket[:start_date]}-#{bucket[:end_date]}.json")

				geojson_export = FileIO::JSONExporter.new(path: directory, name: "ActualWays-#{bucket[:start_date]}-#{bucket[:end_date]}.geojson")

				#http://stackoverflow.com/questions/5470725/how-to-group-by-count-in-array-without-using-loop
				# node_count_in_bucket = buckets.collect{|bucket| bucket[:objects].collect{|way| way.nodes}}.flatten.inject(Hash.new(0)){|h,e| h[e]+=1 ; h}

				nodes = {}
				edges = {}

				overlapping_ways = []
				way_count = bucket[:objects].count

				puts "Total Ways: #{way_count}"

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
								# puts "intersecting-road"
							end
						end
					end
					if (index%100).zero?
						puts "Processed #{index} of #{way_count}"
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

		#Deprecated # => Don't USE
		def overlapping_changesets_distinct_objects(args)

			unit, step, directory, constraints = args['unit'], args['step'], args['files'], args['constraints'] || {}
			changeset_size = args['changeset_area'] || 100000000

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
				changeset_comments = {}
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
							if (changeset_1.area < changeset_size) and (changeset_2.area < changeset_size)
								if changeset_1.bounding_box.intersects? changeset_2.bounding_box

									unless edges["#{user_1}-#{user_2}"].nil?
										edges["#{user_1}-#{user_2}"][:weight] += 1
										# edges["#{user_2}-#{user_1}"][:weight] += 1
									else
										edges["#{user_1}-#{user_2}"] = {source: user_1, target: user_2, weight: 1}
										# edges["#{user_2}-#{user_1}"] = {source: user_2, target: user_1, weight: 1}
									end
									# We have an overlapping changeset -- lets look at some of the objects???
									c1_ways = Way_Query.new(analysis_window: aw, constraints: {'changeset' => changeset_1.id, 'version' => 1}).run
									c2_ways = Way_Query.new(analysis_window: aw, constraints: {'changeset' => changeset_2.id, 'version' => 1}).run

									if (c1_ways.first[:objects].collect{|w| w.nodes} & c2_ways.first[:objects].collect{|w| w.nodes}).length == 0
										overlapping_edits << c1_ways.first[:objects] << c2_ways.first[:objects]

										#Save the changeset comments
										changeset_comments[changeset_1.id] ||= changeset_1.comment
										changeset_comments[changeset_2.id] ||= changeset_2.comment
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
				# puts these_ways
				these_ways.first[:objects].each do |w|
					clean_ways << {"type"=>"Feature","properties"=>{
						"user" => w["user"],
						"date" => w["created_at"],
						"uid"  => w["uid"],
						"version" => w["version"],
						"changeset" => w["changeset"],
						"comment" => changeset_comments[w["changeset"]],
						},"geometry"=>w["geometry"]}
					end
				this_geojson.write({type: "FeatureCollection", features: clean_ways})

				this_file.write_network(nodes: users.values, edges: edges.values, options: {directed: true}, title: "Overlapping Changeset Network: \n#{bucket[:start_date]} - #{bucket[:end_date]}")
			end
			puts "Found #{unique_users.uniq.count} users"
		end

		def co_editing_objects(args)
			unit, step, directory, constraints = args['unit'], args['step'], args['files'], args['constraints'] || {}

			#make the directory
			FileUtils.mkpath(directory) unless Dir.exists? directory

			puts "Running: aw.changesets_x_#{unit}(step: #{step}, constraints: #{constraints})"

			buckets = instance_eval "aw.changesets_x_#{unit}(step: #{step}, constraints: #{constraints})"

			# experienced_users = aw.experienced_contributors
			# new_users         = aw.new_contributors

			unique_users = []
			buckets.each do |bucket|
				this_file = FileIO::JSONExporter.new(path: directory, name: "#{bucket[:start_date]}-#{bucket[:end_date]}.json")

				users = []
				edges = {}

				#The users in this bucket
				these_users = bucket[:objects].collect{|cSet| cSet.uid}.uniq # these_users are the unique user ids
				puts bucket[:start_date], bucket[:end_date]
				puts "User Count: #{these_users.count}"
				puts "================================"
				these_users.each do |user|
					uid = user
					puts "user id: #{uid}"
					n = Node_Query.new(analysis_window: aw, constraints: {'uid'=>uid, :no_time_update =>true,
						:created_at=>{'$gte'=>bucket[:start_date], '$lt'=>bucket[:end_date]}}).run.first[:objects].collect{|x| 'n'+x.id}
					w = Way_Query.new(analysis_window: aw, constraints: {'uid'=>uid, :no_time_update =>true,
					  :created_at=>{'$gte'=>bucket[:start_date], '$lt'=>bucket[:end_date]}}).run.first[:objects].collect{|x| 'w'+x.id}
					r = Relation_Query.new(analysis_window: aw, constraints: {'uid'=>uid, :no_time_update =>true,
						:created_at=>{'$gte'=>bucket[:start_date], '$lt'=>bucket[:end_date]}}).run.first[:objects].collect{|x| 'r'+x.id}
					# puts "Nodes: #{n.length}, Ways: #{w.length}, Rels: #{r.length}"
					objs = n+w+r
					puts "Total objs: #{objs.length}"
					if objs.length > 0
						users <<  {id: uid.to_s, objects: objs}
					else
						puts "No objects here?" #Never happens (good!)
					end
				end
				#In the bucket, have all the user objects:
				size = users.length
				puts "Going through #{size} users"

				intersect_objects = []
				size.times do |idx|
					user_1 = users[idx][:id]
					((idx+1)..(size-1)).each do |jdx| #n^2
						intersect_objs = (users[idx][:objects] & users[jdx][:objects]) #Set intersection
						intersect_objects << intersect_objs
						intersect = intersect_objs.length
						if intersect > 0
							user_2 = users[jdx][:id]

							edges["#{user_1}-#{user_2}"] ||=  {source: user_1, target: user_2, weight: 0}
							edges["#{user_1}-#{user_2}"][:weight] += intersect
							# if intersect == 1
							# 	puts intersect_objs
							# end
						end
					end
				end
				# puts intersect_objects.flatten.uniq
				# puts edges.values
				usernames = users.collect{|x| { id: x[:id] } }
				this_file.write_network(nodes: usernames, edges: edges.values, options: {directed: false}, title: "Co-Editing Network: \n#{bucket[:start_date]} - #{bucket[:end_date]}")
			end
		end

		def overlapping_changesets_of_new_objects(args)

			unit, step, directory, constraints = args['unit'], args['step'], args['files'], args['constraints'] || {}
			changeset_size = args['changeset_area'] || 100000000

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
				changeset_comments = {}
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
							c1_geo = OSMGeo::extents_of_new_objects_in_changesets(changeset_1.id)
							c2_geo = OSMGeo::extents_of_new_objects_in_changesets(changeset_2.id)
							unless c1_geo.nil? or c2_geo.nil?
								if (c1_geo.area < changeset_size) and (c2_geo.area < changeset_size)

									if c1_geo.intersects? c2_geo

										unless edges["#{user_1}-#{user_2}"].nil?
											edges["#{user_1}-#{user_2}"][:weight] += 1
											# edges["#{user_2}-#{user_1}"][:weight] += 1
										else
											edges["#{user_1}-#{user_2}"] = {source: user_1, target: user_2, weight: 1}
											# edges["#{user_2}-#{user_1}"] = {source: user_2, target: user_1, weight: 1}
										end
										# We have an overlapping changeset -- lets look at some of the objects???
										c1_ways = Way_Query.new(analysis_window: aw, constraints: {'changeset' => changeset_1.id, 'version' => 1}).run
										c2_ways = Way_Query.new(analysis_window: aw, constraints: {'changeset' => changeset_2.id, 'version' => 1}).run
										if (c1_ways.first[:objects].collect{|w| w.nodes} & c2_ways.first[:objects].collect{|w| w.nodes}).length == 0
											overlapping_edits << c1_ways.first[:objects] << c2_ways.first[:objects]

											#Save the changeset comments
											changeset_comments[changeset_1.id] ||= changeset_1.comment
											changeset_comments[changeset_2.id] ||= changeset_2.comment
										end
										overlapping_edits.flatten!
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
				clean_ways = []
				these_ways = FileIO::unpack_objects([ {:objects => overlapping_edits} ])
				# puts these_ways
				these_ways.first[:objects].each do |w|
					clean_ways << {"type"=>"Feature","properties"=>{
						"user" => w["user"],
						"date" => w["created_at"],
						"uid"  => w["uid"],
						"version" => w["version"],
						"changeset" => w["changeset"],
						"comment" => changeset_comments[w["changeset"]]
						},"geometry"=>w["geometry"]}
					end
				this_geojson.write({type: "FeatureCollection", features: clean_ways})

				this_file.write_network(nodes: users.values, edges: edges.values, options: {directed: true}, title: "Overlapping Changeset Network: \n#{bucket[:start_date]} - #{bucket[:end_date]}")
			end
			puts "Found #{unique_users.uniq.count} users"
		end

		def tag_interactions(args)

			unit, step, directory, constraints = args['unit'], args['step'], args['files'], args['constraints'] || {}

			no_self_loops = true
			measure = :tags

			#make the directory
			FileUtils.mkpath(directory) unless Dir.exists? directory

			buckets    = instance_eval "aw.ways_x_#{unit}(step: #{step})"

			buckets.each_with_index do |bucket, idx|
				puts "Running Bucket: #{bucket[:start_date]} to #{bucket[:end_date]}"
				puts "Objects: #{bucket[:objects].count}"

				this_file = 		 FileIO::JSONExporter.new(path: directory, name: "way_edit_network_#{bucket[:start_date]}-#{bucket[:end_date]}.json")
				geojson_export = FileIO::JSONExporter.new(path: directory, name: "Ways_for_tag_interaction-#{bucket[:start_date]}-#{bucket[:end_date]}.geojson")

				nodes = {}
				edges = {}
				these_ways = {}

				bucket[:objects].each do |way|

					#Create the user and increment their size
					nodes[way.uid] ||= {id: way.uid, user: way.user, status: "blank", size: 0}
					nodes[way.uid][:size] += 1

					#Has it been documented before, if so, do the network-y stuff, otherwise, move on.
					if these_ways.has_key? way.id
						marked = false

						#If self-loops are allowed, then always ensure the edge is created...
						unless no_self_loops
							edges["#{way.uid}-#{these_ways[way.id][:uids].last}"] ||= {source: way.uid, target: these_ways[way.id][:uids].last, weight: 0}

						#If self-loops are not allowed, then check if the user is the same as the last time before checking to make the edge
						else
							if way.uid != these_ways[way.id][:uids].last
								edges["#{way.uid}-#{these_ways[way.id][:uids].last}"] ||= {source: way.uid, target: these_ways[way.id][:uids].last, weight: 0}
							end
						end

						#We've got a few different methods to determine what we want to count
						case measure
						when :tags
							if these_ways[way.id][:tags].last != way.tags
								edges["#{way.uid}-#{these_ways[way.id][:uids].last}"][:weight]+=1 unless (no_self_loops and these_ways[way.id][:uids].last == way.uid)
								marked = true unless (no_self_loops and these_ways[way.id][:uids].last == way.uid)
							end
						when :nodes
							if these_ways[way.id][:nodes].last.sort != way.nodes.sort
								edges["#{way.uid}-#{these_ways[way.id][:uids].last}"][:weight]+=1 unless (no_self_loops and these_ways[way.id][:uids].last == way.uid)
								marked = true unless (no_self_loops and these_ways[way.id][:uids].last == way.uid)
							end
						end

						these_ways[way.id][:geojsons] ||= []

						if marked
							#We need to make sure we pick up the previous geometry!

							these_ways[way.id][:geojsons] << {
								type: "Feature",
								properties: {
									object: way.id,
									user: way.user,
									uid: way.uid,
									time: way.created_at,
									tags: way.tags,
									version: way.version
								},
								geometry: way.geometry
							}
							these_ways[way.id][:geojsons] << these_ways[way.id][:geoms].last
						end

						#Now add this way's info to the count
						these_ways[way.id][:edit_count] += 1
						these_ways[way.id][:uids] << way.uid
						these_ways[way.id][:tags] << way.tags
						these_ways[way.id][:nodes] << way.nodes

					else #The way has not been documented before, so add it (edit_count is 0)
						these_ways[way.id] ||= {id: way.id, edit_count: 0, uids: [way.uid], tags: [way.tags], nodes: [way.nodes], geoms: [
							{
								type: "Feature",
								properties: {
									object: way.id,
									user: way.user,
									uid: way.uid,
									time: way.created_at,
									tags: way.tags,
									version: way.version
								},
								geometry: way.geometry
							}] }
					end
				end

				feats = these_ways.values.select{ |w| !w[:geojsons].nil? }.collect{|w| w[:geojsons]}.flatten.uniq

				geojson_export.write({type: "FeatureCollection", features: feats})
				this_file.write_network(nodes: nodes.values, edges: edges.values.select{|w| w[:weight] >= 1}, options: {directed: true}, title: "Co-Occuring Way Edits: \n#{bucket[:start_date]} - #{bucket[:end_date]}")
				puts "================================================================="
			end
		end
	end
end
