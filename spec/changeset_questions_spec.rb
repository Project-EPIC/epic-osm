require "spec_helper"

require_relative '../models/Query'


describe Query do

	before :each do
		nil #Should we set a databse connection here -- either :nil or :not
	end

  	it "Can count the distinct number of changesets for a given analysis window" do 
  		
  		time_frame = TimeFrame.new( start: Time.new(2010,1,12), end: Time.new(2010,2,12) )
		bounding_box = BoundingBox.new nil

		this_analysis_window = AnalysisWindow.new(time_frame: time_frame, bounding_box: bounding_box)

		puts "Number of Changesets: #{this_analysis_window.changeset_count}"

  	end

  	it "Can count the distinct users in changesets for a given analysis window" do 
  		
  		time_frame = TimeFrame.new( start: Time.new(2010,1,12), end: Time.new(2010,2,12) )
		bounding_box = BoundingBox.new nil

		this_analysis_window = AnalysisWindow.new(time_frame: time_frame, bounding_box: bounding_box)

		puts "Number of Distinct Users: #{this_analysis_window.distinct_users_in_changesets.length}"
  	end

  	it "Can count the number of changesets per day" do 
  		time_frame = TimeFrame.new( start: Time.new(2010,1,12), end: Time.new(2010,2,12) )
		bounding_box = BoundingBox.new nil

		this_analysis_window = AnalysisWindow.new(time_frame: time_frame, bounding_box: bounding_box)

		per_day = this_analysis_window.changesets_per_day

		puts "Day : Number of Changesets"
		per_day.each do |k,v|
			puts "#{k}:  #{v.length}"
		end
	end

	it "Can count the number of users per day" do 
  		time_frame = TimeFrame.new( start: Time.new(2010,1,12), end: Time.new(2010,2,12) )
		bounding_box = BoundingBox.new nil

		this_analysis_window = AnalysisWindow.new(time_frame: time_frame, bounding_box: bounding_box)

		per_day = this_analysis_window.users_per_day
		
		puts "Day : Number of Users"
		per_day.each do |k,v|
			puts "#{k}:  #{v.length}"
		end
	end
end