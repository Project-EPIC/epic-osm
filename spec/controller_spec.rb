require_relative '../osm-history'

describe EpicOSM do 

	before :all do 
		@EpicOSM = EpicOSM.new(analysis_window: 'analysis_windows/nicaragua_sample.yml')
	end

	it "Successfully created itself" do 
		expect @EpicOSM != nil
	end

	it "Parsed time correctly" do
		expect @EpicOSM.analysis_window.time_frame.start_date.is_a? Time
	end

	it "can run a simple question" do 
		@EpicOSM.run_questions
	end

	it "Can open a JSON Writer" do 
		@EpicOSM.write_json(name: "test")
	end


end