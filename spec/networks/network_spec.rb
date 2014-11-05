#
# Network Spec for quick visualization using Ubigraph, ensure the ubigraph server is running
#
#

require 'spec_helper'
require 'rubigraph'
require_relative '../../modules/osm_network'

describe Network do

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

	it "Can make a network connecting users who edited the same node" do 
		users = {}

		@dw.nodes_x_all.first[:objects].group_by{|node| node.id}.each do |id, ways|

			puts id, ways.length
			
			#At this point, we have groups of ways.
			ways.sort_by!{ |way| way.version}

			previous_user = users[ways.first.user]

			users[previous_user] ||= Rubigraph::Vertex.new

			unless ways.length == 1
				ways.each do |version_of_way|

					#Make a vertex (if it doesn't already exist for the user that's part of this way)
					if version_of_way.user != previous_user
						users[version_of_way.user] ||= Rubigraph::Vertex.new
						Rubigraph::Edge.new( users[previous_user], users[version_of_way.user] )
					end
					previous_user = version_of_way.user
				end
			end
		end
	end
end