require_relative 'import_scripts/pbf_to_mongo'
require_relative 'import_scripts/import_analysis_window'

#This function will ensure that we create the proper analysis window
def window
	unless ARGV[1].nil?
		@this_window ||= AnalysisWindowImport.new(config: ARGV[1]) #Pass the configuration in
	else
		raise StandardError.new("Need a valid Configuration File")
	end

	return @this_window
end

desc "Given a valid configuration file, cut and import all of the data"
task :new do
	Rake::Task['cut'].invoke
	Rake::Task['import:pbf'].invoke
	Rake::Task['import:changesets'].invoke
	Rake::Task['import:users'].invoke
end

desc "Write appropriate configuration file and cut the file to create temp.osm.pbf file"
task :cut do
	window.write_configuration_file
	window.run_osm_history_splitter
end

desc "Import Scripts"
namespace :import do

	desc "Import PBF File (Nodes, Ways, Relations)"
	task :pbf do
		puts window.run_mongo_import
	end

	desc "Import Changesets"
	task :changesets do
		puts window.changeset_import
	end

	desc "Import Users"
	task :users do
		puts window.user_import
	end
end

desc "Clean up all temp files"
task :cleanup do
	if File.exists? "import_scripts/temp.config"
		File.delete "import_scripts/temp.config"
	end
	if File.exists? "import_scripts/temp.osm.pbf"
		File.delete "import_scripts/temp.osm.pbf"
	end
end