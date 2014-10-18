require "spec_helper"

require_relative '../models/AnalysisWindow'

describe AnalysisWindow do

  	it "Properly finds the bounds for the timeframe" do 
  		this_window = AnalysisWindow.new

  		puts this_window.time_frame.inspect

  	end

end