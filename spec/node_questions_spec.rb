require "spec_helper"

require_relative '../models/Query'


describe Query do

  	it "Can count the number of nodes edited in a given analysis window" do 

		this_analysis_window = AnalysisWindow.new

		puts "Number of Nodes Edited: #{this_analysis_window.node_edit_count}"

  	end

  	it "Can count the number of nodes added in a given analysis window" do 
  		
		this_analysis_window = AnalysisWindow.new

		puts "Number of Nodes added: #{this_analysis_window.node_added_count}"

  	end

end