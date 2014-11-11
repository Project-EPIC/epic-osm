require_relative '../osm-history'

describe OSMHistory do 

	before :each do 
		@osmhistory = OSMHistory.new(analysis_window: 'analysis_windows/nic_test.yml')
	end

	it "Successfully created itself" do 
		expect @osmhistory != nil
	end

	it "Parsed the timeframe properly" do 
		puts @osmhistory.analysis_window.time_frame.inspect
	end


end