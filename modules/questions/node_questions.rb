module Questions

	module Nodes

		def number_of_nodes_edited
			analysis_window.node_edit_count
		end

  	it "Can count the number of nodes added in a given analysis window" do 
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

    xit "Can get the latest version of distinct nodes" do 
      this_window = AnalysisWindow.new
      puts "Number of new distinct nodes: #{this_window.newest_nodes.count}"
    end

  	
end