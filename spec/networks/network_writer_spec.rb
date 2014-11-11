
require 'spec_helper'

require_relative '../../modules/osm_network'

describe Network do

	before :each do 
		@dw = AnalysisWindow.new
	end

	it "Can write a GraphML file from the data" do

		file = Network::GMLAuthor.new(filename: 'test.gml', directed: 1, id: 4, comment: "comment", label: "blah")

		nodes = [{id: 1, label: "Jennings", age: 25},{id: 2, label: "Marina"},{id: 3, label: "Robert"}]
		edges = [{source: 1, target: 3, weight: 3}, {source: 1, target: 2, color: 'red'}, {source: 2, target: 3}]

		nodes.each do |node|
			file.add_node(node)
		end

		edges.each do |edge|
			file.add_edge(edge)
		end

		file.write

		# @dw.changesets_x_monthly.each do |bucket|

		# 	puts "#{bucket[:start_date]} - #{bucket[:end_date]}"

		# 	users = {}
		# 	edges = {}
		# 	size = bucket[:objects].count

		# 	size.times do |i|
		# 		((i+1)..(size-1)).each do |j|
		# 			changeset_1 = bucket[:objects][i]
		# 			changeset_2 = bucket[:objects][j]

		# 			user_1 = bucket[:objects][i].user
		# 			user_2 = bucket[:objects][j].user

		# 			unless user_1 == user_2
		# 				if (changeset_1.area < 100000000) and (changeset_2.area < 100000000)
		# 					if changeset_1.bounding_box.intersects? changeset_2.bounding_box
								
		# 						users[user_1] ||= Rubigraph::Vertex.new	

		# 						users[user_2] ||= Rubigraph::Vertex.new	

		# 						#Add labels to the network
		# 						users[user_1].label = user_1
		# 						users[user_2].label = user_2
	
		# 						unless edges["#{user_1}-#{user_2}"].nil?
		# 							edges["#{user_1}-#{user_2}"][:width] += 1
		# 							edges["#{user_1}-#{user_2}"][:edge].width = edges["#{user_1}-#{user_2}"][:width]
		# 						else
		# 							edges["#{user_1}-#{user_2}"] = {edge: Rubigraph::Edge.new(users[user_1], users[user_2]), width: 1}
		# 						end
		# 						puts "#{user_1} - #{user_2}"
		# 						users[user_1].shape = 'sphere'
		# 						users[user_2].shape = 'sphere'
		# 						users[user_1].color = '#003366'
		# 						users[user_2].color = '#003366'

		# 						sleep(4)
		# 					end
		# 				end
		# 			end
		# 		end
		# 	end
		# 	Rubigraph.clear
		# 	users = {}
		# 	edges={}
		# end
	end
end