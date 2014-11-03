#
#
#
#
#
#
require_relative 'import_scripts/pbf_to_mongo'
require_relative 'import_scripts/import_analysis_window'


desc "Create New Analysis Window"
task :new do
	puts "Step 1: Reading Configuration File"

	analysis_window_arg = read_yaml_config('analysis_windows/costa_rica_2010.yml')
	#Reads a config file which was passed in, or by default runs all imports (maybe we need a safety)

	# Step 2: Runs OSM History Cutting tool to build temp OSM.pbf file for import
	
	# Step 3: Runs osm-history2 import scripts on temp OSM.pbf file with flags for
	# 		  	dates which are too early or too late

	# Step 4: Ensures changeset & user API calls are made for the collection

	# Step 5: Build Static Site (Jekyll new)

	# Step 6: Email user and tell them their analysis window is up and running:
end
