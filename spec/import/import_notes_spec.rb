require 'spec_helper'

require_relative '../../import_scripts/osm_api/import_notes'

describe NoteImport do
	before :all do 
		@osmhistory = OSMHistory.new(analysis_window: 'analysis_windows/nicaragua_sample.yml')
	end

	before :each do
		@note_import = NoteImport.new(@osmhistory.aw_config['bbox'])
	end

	it "Can import notes" do 
		@note_import.import_note_objects
	end
end