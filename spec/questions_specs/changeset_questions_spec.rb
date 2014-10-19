require "spec_helper"


describe Changeset_Query do

  	it "Can count the distinct number of changesets for a given analysis window" do 
		this_analysis_window = AnalysisWindow.new
		puts "Number of Changesets: #{this_analysis_window.changeset_count}"

  	end

  	it "Can count the distinct users in changesets for a given analysis window" do 
		this_analysis_window = AnalysisWindow.new
		puts "Number of Distinct Users: #{this_analysis_window.distinct_users_in_changesets.length}"
  	end

  	it "Can count the number of changesets per Month" do 
		this_analysis_window = AnalysisWindow.new

		per_month = this_analysis_window.changesets_per_month

		puts "Month : Number of Changesets"
		per_month.each do |bucket|
			puts "#{bucket[:start_date].year}-#{bucket[:start_date].mon}:  #{bucket[:objects].length}"
		end
	end
end