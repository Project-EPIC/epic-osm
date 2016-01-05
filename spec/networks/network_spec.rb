#
# Network Spec for quick visualization using Ubigraph, ensure the ubigraph server is running
#
#

require 'spec_helper'
require 'rubigraph'

describe 'nothing' do

	before :each do
		Rubigraph.init
		Rubigraph.clear

		@dw = AnalysisWindow.new
	end

	xit "Make a network showing who created which ways (bipartite)." do
		
		users = {}
		way_nodes  = {}

		@dw.ways_x_all.first[:objects].group_by{|way| way.id}.each do |id, ways|
			way_nodes[id] ||= Rubigraph::Vertex.new
			way_nodes[id].color = "#003366"
			ways.each do |version_of_way|
				users[version_of_way.user] ||= Rubigraph::Vertex.new
				users[version_of_way.user].shape = 'sphere'
				Rubigraph::Edge.new(users[version_of_way.user], way_nodes[id])
			end
		end
	end

	xit "Can make a network connecting users who edited the same node" do 
		users = {}

		@dw.changesets_x_hourly.each do |bucket|

			puts "#{bucket[:start_date]} - #{bucket[:end_date]}"

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
								
								users[user_1] ||= Rubigraph::Vertex.new	

								users[user_2] ||= Rubigraph::Vertex.new	

								#Add labels to the network
								users[user_1].label = user_1
								users[user_2].label = user_2
	
								unless edges["#{user_1}-#{user_2}"].nil?
									edges["#{user_1}-#{user_2}"][:width] += 1
									edges["#{user_1}-#{user_2}"][:edge].width = edges["#{user_1}-#{user_2}"][:width]
								else
									edges["#{user_1}-#{user_2}"] = {edge: Rubigraph::Edge.new(users[user_1], users[user_2]), width: 1}
								end
								puts "#{user_1} - #{user_2}"
								users[user_1].shape = 'sphere'
								users[user_2].shape = 'sphere'
								users[user_1].color = '#003366'
								users[user_2].color = '#003366'

								sleep(4)
							end
						end
					end
				end
			end
			Rubigraph.clear
			users = {}
			edges={}
		end
	end


end