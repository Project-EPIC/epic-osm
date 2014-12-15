require_relative '../osm-history'

describe OSMHistory do 

	before :all do 
		@osmhistory = OSMHistory.new(analysis_window: 'analysis_windows/nicaragua_sample.yml')
	end

	it "Successfully created itself" do 
		expect @osmhistory != nil
	end

	it "Parsed time correctly" do
		expect @osmhistory.analysis_window.time_frame.start_date.is_a? Time
	end

	it "can run a simple question" do 
		@osmhistory.run_questions
	end

	it "Can open a JSON Writer" do 
		@osmhistory.write_json(name: "test")
	end


end