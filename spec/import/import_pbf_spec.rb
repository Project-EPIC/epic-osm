require 'spec_helper'

require_relative '../../import_scripts/pbf_to_mongo'

describe OSMPBF do

	#Open the PBF file
	before :all do
		@conn = OSMPBF.new(end_date: Time.new(2009,1,1))
		@conn.open_parser("./spec/import/test_files/managua.osm.pbf")

		puts @conn.file_stats
	end

	it "Can create node objects from the PBF" do
		@conn.parse_to_collection(object_type="nodes", lim=nil)
	end

	xit "Can create Relation objects from the PBF" do
		@conn.parse_to_collection(object_type="relations", lim=nil)
	end

	it "Can create way objects from the PBF" do
		@conn.parse_to_collection(object_type="ways", lim=nil)
	end

end