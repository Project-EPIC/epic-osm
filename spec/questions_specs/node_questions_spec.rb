require "spec_helper"


describe Node_Query do

  	xit "Can count the total number of nodes edited in a given analysis window" do 
		this_analysis_window = AnalysisWindow.new
		puts "Number of Nodes Edited: #{this_analysis_window.node_edit_count}"
  	end


  	xit "Can count the number of nodes added in a given analysis window" do 
		this_analysis_window = AnalysisWindow.new
		puts "Number of Nodes added: #{this_analysis_window.node_added_count}"
  	end


  	it "Can query nodes with monthly buckets" do
  		this_window = AnalysisWindow.new
  		
      this_window.nodes_x_monthly.each do |bucket|
  	    puts "#{bucket[:start_date]}, #{bucket[:end_date]}, #{bucket[:objects].count}"
  		end
  	end


  	xit "Can query nodes with daily buckets" do
  		this_window = AnalysisWindow.new
  		puts "Number of daily buckets: #{this_window.nodes_x_daily.count}"
  	end

  	
end