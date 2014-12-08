#This Rakefile defines tasks for setting up Analysis Windows

#The import_analysis_window script does all the heavy lifting
require_relative 'import_scripts/import_analysis_window'

require_relative 'osm-history'

#This function will ensure that we create the proper analysis window
def window

	#TODO Make this more robust to handle multiple configuration files
	unless ARGV[1].nil?
		@this_window ||= AnalysisWindowImport.new(config: ARGV[1]) #Pass the configuration in
	else
		raise ArgumentError.new("A valid configuration file must be defined")
	end

	return @this_window
end

def osmhistory
	unless ARGV[1].nil?
		@osm_history ||= OSMHistory.new( analysis_window: ARGV[1]) #Pass the configuration in
	else
		raise ArgumentError.new("A valid configuration file must be defined")
	end

	return @osm_history
end

desc "Given a valid configuration file, Cut and Import all of the data"
task :new do
	Rake::Task['cleanup'].invoke
	Rake::Task['cut'].invoke
	Rake::Task['import:pbf'].invoke
	Rake::Task['import:changesets'].invoke
	Rake::Task['import:users'].invoke
end

desc "Write appropriate configuration file and cut the file to create temp.osm.pbf file"
task :cut do
	puts "Writing Configuration File for Cut"
	window.write_configuration_file
	puts "Running osm history splitter"
	window.run_osm_history_splitter
end

desc "Import Scripts"
namespace :import do

	desc "Import PBF File (Nodes, Ways, Relations)"
	task :pbf do
		window.run_mongo_import
	end

	desc "Import Changesets"
	task :changesets do
		window.changeset_import
	end

	desc "Import Users"
	task :users do
		window.user_import
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

desc "Network Writers"
task :network do 
	osmhistory = OSMHistory.new(analysis_window: ARGV[1])
	osmhistory.run_network_functions #This will need to be pulled out eventually...
end


namespace :questions do

	desc "Run Node Questions"
	task :nodes do
		osmhistory.run_node_questions
	end

	desc "Run Way Questions"
	task :ways do
		osmhistory.run_way_questions
	end

	desc "Run Relation Questions"
	task :relations do
		osmhistory.run_relation_questions
	end

	desc "Run Changeset Questions"
	task :changesets do
		osmhistory.run_changeset_questions
	end

	desc "Run User Questions"
	task :ways do
		osmhistory.run_user_questions
	end
end

#Builds Jekyll sites based on analysis windows
namespace :jekyll do
	desc "Builds Jekyll Site"
	task :test do

	end
	task :config do
		dir = window.config['write_directory']
		File.open("jekyll/config.yml", 'w') { |file| 
		window.config.each do |key, value| 
			file.write("#{key} : #{value} \n") 
			puts "#{key} : #{value}"
		end
		file.write("data_source : ../#{dir}/json")
		}
	end
	task :build do
		dir = window.config['write_directory']
		system("jekyll build --source jekyll --destination #{dir}")
	end
end









