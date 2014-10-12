require "spec_helper"

require_relative '../models/Query'


describe Query do

	before :each do
		nil #Should we set a databse connection here -- either :nil or :not
	end

  	it "Can Query the Nodes collection for a specific analyis window" do 
  		time_frame = TimeFrame.new( start: Time.new(2011,1,1), end: Time.new(2011,10,1) )
		bounding_box = BoundingBox.new nil

		this_analysis_window = AnalysisWindow.new(time_frame: time_frame, bounding_box: bounding_box)

		this_query = Node_Query.new(analysis_window: this_analysis_window)

		node_bucket = this_query.run

		puts node_bucket.count

		puts node_bucket.items.first.inspect
  	end

end