
require 'spec_helper'

require_relative '../../io_plugins/network_exporter'

describe FileIO do

	before :each do 
		@dw = AnalysisWindow.new
	end

	it "Can write a GraphML file from the data" do

		file = GMLAuthor.new(filename: 'changesets_per_month.gml', directed: 1, id: 1, comment: "Changesets Per Month", label: "Testing")

		users = {}
		edges = {}

		@dw.changesets_x_monthly.each do |bucket|

			puts "#{bucket[:start_date]} - #{bucket[:end_date]}"

	
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
		end

		users.values.each do |node|
			file.add_node(node)
		end

		edges.values.each do |edge|
			file.add_edge(edge)
		end

		file.write
	end
end