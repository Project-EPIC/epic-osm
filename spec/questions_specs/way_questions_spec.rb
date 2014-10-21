require "spec_helper"


describe Way_Query do

  	before :each do
      @aw = AnalysisWindow.new #()
    end

    it "Can count the ways" do
      puts "Ways edited: #{@aw.way_edit_count}"
    end

    it "Can count the buildings" do
      puts "Buildings edited #{@aw.ways_x_all(constraints: {"tags.building" => "yes"}).count}"
    end

    it "Can find tagged buildings by month" do
      @aw.ways_x_monthly(constraints: {"tags.building" => "yes"}).each do |bucket|
        puts "#{bucket[:start_date]}, #{bucket[:end_date]}, #{bucket[:objects].count}"
      end
    end
end