require "spec_helper"

describe OSMGeo::Node do

  	before :each do
      @aw = AnalysisWindow.new #()
    end

    it "Can get a bucket of nodes and treat them as rgeo points" do
    	@aw.nodes_x_all.first[:objects][0..100].each do |node|
    		puts node.point
    	end
    end
    
end