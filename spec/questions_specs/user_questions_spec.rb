require "spec_helper"

describe Query do

	before :all do
		@this_analysis_window = this_analysis_window = AnalysisWindow.new
	end

	it "Can access the user's collection and get their join dates" do 
		puts "Number of Users: #{@this_analysis_window.all_users_data.count}"
	end

  	it "Can find users who edited in an analysis window and also created their account during that time" do 
		puts "New contributors: #{@this_analysis_window.new_contributors}"
	end

	it "Can count the number of users editing each year" do 
		@this_analysis_window.users_editing_per_year.each do |year, users|
			puts "Year: #{year.year}: #{users}"
		end
	end

	it "Can count the number of users editing each month" do 
		@this_analysis_window.users_editing_per_month.each do |time, users|
			puts "Year-Month: #{time.year}-#{time.month}: #{users}"
		end
	end


	it "Can count top contributors" do 
		top_contributors = @this_analysis_window.top_contributors_by_changesets

		top_contributors.each do |k,v|
			puts "#{k} --> #{v.length}"
		end

	end
end