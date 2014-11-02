require "spec_helper"

describe OSMGeo::Changeset do

  	before :each do
      @aw = AnalysisWindow.new #()
    end

    it "Can get all changesets and turn them into polygons" do
    	@aw.changesets_x_all.first[:objects].each do |changeset|
    		puts changeset.bounding_box
    	end
    end

    it "Can get all changesets and calculate their geographic areas" do
    	@aw.changesets_x_all.first[:objects].each do |changeset|
    		puts "#{changeset.id}: #{changeset.area}"
    	end
    end

  
end