require "spec_helper"


describe Changeset_Query do
	before :each do 
		@this_analysis_window = AnalysisWindow.new
	end


  	it "Can count the distinct number of changesets for a given analysis window" do 
		puts "Number of Changesets: #{@this_analysis_window.changeset_count}"

  	end

  	it "Can count the distinct users in changesets for a given analysis window" do 
		puts "Number of Distinct Users: #{@this_analysis_window.distinct_users_in_changesets.length}"
  	end


  	it "Can count the number of changesets per Month" do 
		per_month = @this_analysis_window.changesets_x_monthly

		puts "Month : Number of Changesets"
		per_month.each do |bucket|
			puts "#{bucket[:start_date].year}-#{bucket[:start_date].mon}:  #{bucket[:objects].length}"
		end
	end
end