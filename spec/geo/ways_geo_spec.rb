require "spec_helper"

describe OSMGeo::Way do

  	before :each do
      @aw = AnalysisWindow.new #()
    end

    it "Can get all the ways and turn them into linestrings and calculate their length" do
    	successful = 0
        failed     = 0
        @aw.ways_x_all.first[:objects].each do |way|
    		begin
                print '.'
                way.line_string(@aw.nodes_x_all.first[:objects])
                successful += 1
            rescue
                failed += 1
            end
    	end

        puts "Successful: #{successful}"
        puts "Failed: #{failed}"
    end
  
end