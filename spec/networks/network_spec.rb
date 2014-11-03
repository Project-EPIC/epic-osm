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
	end

	it "Can make  new network with test nodes" do
		v1  = Rubigraph::Vertex.new
		v2  = Rubigraph::Vertex.new
		e12 = Rubigraph::Edge.new(v1, v2)
	end
end