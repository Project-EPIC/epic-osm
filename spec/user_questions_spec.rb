require "spec_helper"

require_relative '../models/Query'


describe Query do

	before :each do
		nil #Should we set a databse connection here -- either :nil or :not
	end

  	it "Can find users who edited in an analysis window and also created their account during that time" do 
  		time_frame = TimeFrame.new( start: Time.new(2010,1,12), end: Time.new(2010,2,12) )
		bounding_box = BoundingBox.new nil

		this_analysis_window = AnalysisWindow.new(time_frame: time_frame, bounding_box: bounding_box)

		num = this_analysis_window.new_contributors

		puts "Number of new contributors: #{this_analysis_window.new_contributors}"
	end
end