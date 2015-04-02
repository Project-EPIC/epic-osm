require "spec_helper"
require "osm-history"
require "modules/questions/questions"


describe QuestionAsker do

	before :all do
		o = OSMHistory.new(analysis_window: 'spec/test_config_file.yml')
    @aw = o.analysis_window
    @q  = QuestionAsker.new(analysis_window: @aw)
  end

  xit "Can count the ways" do
    puts @q.number_of_ways_edited
  end

  xit "Can count the buildings" do
		puts @q.number_of_buildings_edited
  end

	it "Can compute the area of buildings" do
		@q.size_of_buildings
	end

end
