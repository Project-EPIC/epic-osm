require 'spec_helper'


describe OSMPBF do

	#Open the PBF file
	before :all do
		MongoMapper.database = 'osm_test'
		@conn = OSMPBF.new
		@conn.open_parser("./spec/import/test_files/terre-haute.osm.pbf")

		puts @conn.file_stats
	end

	it "Can create node objects from the PBF" do
		@conn.parse_to_collection(object_type="nodes", lim=1000)
	end

	it "Can create Relation objects from the PBF" do
		@conn.parse_to_collection(object_type="relations", lim=1000)
	end

	it "Can create way objects from the PBF" do
		@conn.parse_to_collection(object_type="ways", lim=1000)
	end

end