require "spec_helper"

require_relative '../models/Query'


describe Query do

  	it "Can find users who edited in an analysis window and also created their account during that time" do 
		this_analysis_window = AnalysisWindow.new

		puts "Number of new contributors: #{this_analysis_window.new_contributors}"
	end
end