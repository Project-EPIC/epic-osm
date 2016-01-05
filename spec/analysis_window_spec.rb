require "spec_helper"

require_relative '../models/AnalysisWindow'

describe AnalysisWindow do

  	it "Properly finds the bounds for the timeframe" do 
  		this_window = AnalysisWindow.new
  		expect this_window.time_frame.active? == true
  	end

  	it "Can handle monthly buckets" do
  		this_window = AnalysisWindow.new
  		this_window.time_frame.inspect
  		expect this_window.build_buckets(:monthly).count > 1
  	end

  	it "Can handle daily buckets" do
  		this_window = AnalysisWindow.new
  		this_window.time_frame.inspect
  		expect this_window.build_buckets(:daily).count > 24
  	end

  	it "Can handle hourly buckets" do
  		this_window = AnalysisWindow.new
  		this_window.time_frame.inspect
  		expect this_window.build_buckets(:hourly).count > 28*24
  	end

  	it "Can handle yearly buckets" do
  		this_window = AnalysisWindow.new
  		this_window.time_frame.inspect
  		puts this_window.build_buckets(:yearly)
  	end

    it "Can handle a missing method call to simplify our life" do 

      this_window = AnalysisWindow.new
      
      puts this_window.all_changesets

    end

end