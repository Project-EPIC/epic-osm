require_relative 'import_scripts/pbf_to_mongo'
require_relative 'import_scripts/import_analysis_window'

desc "Create New Analysis Window"
task :new do
	puts "Step 1: Reading Configuration File"

	this_window = AnalysisWindowImport.new(config: 'analysis_windows/nicaragua_sample.yml')

	#Reads a config file which was passed in, or by default runs all imports (maybe we need a safety)
	this_window.write_configuration_file

	# Step 2: Runs OSM History Cutting tool to build temp.pbf file for import
	#this_window.run_osm_history_splitter
	
	# Step 3: Runs osm-history2 import scripts on temp OSM.pbf file with flags for
	# 		  dates which are too early or too late

	#this_window.run_mongo_import

	# Step 3.5 Clean PBF Files
	#this_window.remove_temp_files

	# Step 4: Ensures changeset & user API calls are made for the collection

	#this_window.changeset_import

	this_window.user_import

	# this_window.user_import
	# Step 5: Build Static Site (Jekyll new)

	# Step 6: Email user and tell them their analysis window is up and running:
end


#Tasks to flesh out: (Helper tasks)
# desc "Create a new instance of the import window"
# task :initialize_window do 
# 	@this_window = AnalysisWindowImport.new(config: 'analysis_windows/nicaragua_sample.yml')
# end

# desc "Import users (make sure to drop User collection first)"
# namespace :import

# 	task :users
# 	@this_window.import_users
# end
