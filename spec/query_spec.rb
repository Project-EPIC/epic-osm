require "spec_helper"
require_relative '../models/Query'


describe Query do
	
	before :all do
		@db = build_database
	end

  	it "Can return a bucket of Changesets and count them" do 
  		time_frame = TimeFrame.new( start: Time.new(2008 ,1,1), end: Time.new(2013,1,1) )
		bounding_box = nil #Stubbed for now

		this_analysis_window = AnalysisWindow.new(time_frame: time_frame, bounding_box: bounding_box)

		this_query = Query.new(analysis_window: this_analysis_window, type: :changesets)

		results = this_query.run(db: @db)

		puts results.count

  	end

end