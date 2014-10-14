require 'spec_helper'

require_relative '../../import_scripts/osm_api/import_changesets'

describe ChangesetImport do
	before :each do
		@changeset_import = ChangesetImport.new
	end

	it "can get all distinct changesets in db" do 
		puts @changeset_import.distinct_changeset_ids.length
	end

	it "Can import changesets" do 
		@changeset_import.import_changeset_objects
	end
end