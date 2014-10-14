require "spec_helper"

require_relative '../models/Query'


describe Query do

  	it "Can Query the Nodes collection for a specific analyis window" do 
  		time_frame = TimeFrame.new( start: Time.new(2011,1,1), end: Time.new(2011,10,1) )

		this_analysis_window = AnalysisWindow.new(time_frame: time_frame)

		this_query = Node_Query.new(analysis_window: this_analysis_window)

		node_bucket = this_query.run

		puts node_bucket.count

		puts node_bucket.first.inspect
  	end

end