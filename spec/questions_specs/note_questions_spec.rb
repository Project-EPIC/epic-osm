require "spec_helper"
require_relative '../../import_scripts/osm_api/import_notes'


describe Query do

	before :all do
    	@aw = AnalysisWindow.new
	end

	it "Can access the notes collection and count the number of notes" do 
		puts "Number of Notes: #{@aw.notes_count}"
	end
end