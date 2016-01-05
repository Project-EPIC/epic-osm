#
# Network Spec for quick visualization using Ubigraph, ensure the ubigraph server is running
#
#

require 'spec_helper'
require 'rubigraph'

describe 'Overlapping Changeset Network' do

	before :each do
		Rubigraph.init
		Rubigraph.clear

		#Philippines
		@dw = AnalysisWindow.new(time_frame: TimeFrame.new(start: Time.new(2013,11,8), end: Time.new(2013,12,10)))

		#Haiti
		#@dw = AnalysisWindow.new(time_frame: TimeFrame.new(start: Time.new(2010,1,13), end: Time.new(2010,1,14)))
	end

	it "Can make a network connecting users who edited overlapping changesets" do 
		
		@dw.changesets_x_hour.each do |bucket|

			puts "#{bucket[:start_date]} - #{bucket[:end_date]} : #{bucket[:objects].count}"

			users = {}
			edges = {}
			size = bucket[:objects].count

			size.times do |i|
				((i+1)..(size-1)).each do |j|
					changeset_1 = bucket[:objects][i]
					changeset_2 = bucket[:objects][j]

					user_1 = bucket[:objects][i].user
					user_2 = bucket[:objects][j].user

					users[user_1] ||= Rubigraph::Vertex.new	
					users[user_2] ||= Rubigraph::Vertex.new	


					#Add labels to the network
					users[user_1].label = user_1
					users[user_2].label = user_2

					unless user_1 == user_2
						if (changeset_1.area < 100000000) and (changeset_2.area < 100000000)
							if changeset_1.bounding_box.intersects? changeset_2.bounding_box
	
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