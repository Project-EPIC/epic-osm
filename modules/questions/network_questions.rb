#
#
# Network Questions

module Questions
module Network

	class TemporalAnalysis

		attr_reader :unit, :step, :directory, :buckets, :aw

		def initialize(args)
			@unit, @step, @directory, @aw = args[:unit], args[:step], args[:directory], args[:aw]

			#make the directory
			Dir.mkdir(directory) unless Dir.exists? directory
		
			@buckets = instance_eval "aw.changesets_x_#{unit}(step: #{step})"
		end

		def run_overlapping_changesets
			buckets.each do |bucket|
				this_file = make_file(filename="#{bucket[:start_date]}-#{bucket[:end_date]}")

				users = {}
				edges = {}

				size = bucket[:objects].count

				size.times do |i|
					((i+1)..(size-1)).each do |j|
						changeset_1 = bucket[:objects][i]
						changeset_2 = bucket[:objects][j]

						user_1 = bucket[:objects][i].user
						user_2 = bucket[:objects][j].user

						unless user_1 == user_2
							if (changeset_1.area < 100000000) and (changeset_2.area < 100000000)
								if changeset_1.bounding_box.intersects? changeset_2.bounding_box
									
									users[user_1] ||= {id: user_1}
									users[user_2] ||= {id: user_2}
		
									unless edges["#{user_1}-#{user_2}"].nil?
										edges["#{user_1}-#{user_2}"][:weight] += 1
									else
										edges["#{user_1}-#{user_2}"] = {source: user_1, target: user_2, weight: 1}
									end
									puts "#{user_1} - #{user_2}"
								end
							end
						end
					end
				end
				users.values.each do |node|
					this_file.add_node(node)
				end

				edges.values.each do |edge|
					this_file.add_edge(edge)
				end
				this_file.write
			end
		end

		def make_file(filename, comment="", label="")
			return FileIO::GMLAuthor.new(filename: "#{directory}/#{filename}.gml", directed: 1, id: 1, comment: comment, label: label)
		end

	end
end
end