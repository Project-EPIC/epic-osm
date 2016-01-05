require "spec_helper"


describe Node_Query do

  before :all do
    @aw = AnalysisWindow.new
  end

  	it "Can count the total number of nodes edited in a given analysis window" do 
		puts "Number of Nodes Edited: #{@aw.node_edit_count}"
  	end


  	it "Can count the number of nodes added in a given analysis window" do 
		puts "Number of Nodes added: #{@aw.node_added_count}"
  	end


  	it "Can query nodes with monthly buckets" do
      @aw.nodes_x_month.each do |bucket|
  	    puts "#{bucket[:start_date]}, #{bucket[:end_date]}, #{bucket[:objects].count}"
  		end
  	end


  	xit "Can query nodes with daily buckets" do
  		puts "Number of daily buckets: #{@aw.nodes_x_day.count}"
  	end

    xit "Can get the latest version of distinct nodes" do 
      puts "Number of new distinct nodes: #{@aw.newest_nodes.count}"
    end

  	
end