#This Rakefile defines tasks for setting up Analysis Windows

#The import_analysis_window script does all the heavy lifting
require_relative 'import_scripts/import_analysis_window'
require_relative 'epic-osm'
require_relative 'modules/realtime'

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

def epicosm
	unless ARGV[1].nil?
		@epic_osm ||= EpicOSM.new( analysis_window: ARGV[1]) #Pass the configuration in
	else
		raise ArgumentError.new("A valid configuration file must be defined")
	end

	return @epic_osm
end

desc "Given a valid configuration file, Cut and Import all of the data"
task :new do
	Rake::Task['cleanup'].invoke
	Rake::Task['cut'].invoke
	Rake::Task['import:pbf'].invoke
	Rake::Task['import:changesets'].invoke
	Rake::Task['import:users'].invoke
	Rake::Task['import:notes'].invoke
end

desc "Write appropriate configuration file and cut the file to create temp.osm.pbf file"
task :cut do
	puts "Writing Configuration File for Cut"
	window.write_configuration_file
	puts "Running osm history splitter"
	window.run_epic_osm_splitter
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

	desc "Import NodeWays"
	task :nodeways do
		window.nodeways_import
	end

	desc "Import Users"
	task :users do
		window.user_import
	end

	desc "Import OSMTM Tags"
  task :osmtm_tags do
    window.osmtm_tags_import
  end

	desc "Import Realtime"
	task :realtime do
		window.run_live_replication_import
	end

	desc "Import Notes"
	task :notes do
		window.note_import
	end
end

desc "Indexes"
namespace :index do
	desc "Rebuild Changeset Indexes"
	task :changesets do
		window
		ChangesetImport.new.add_indexes
	end

	desc "Rebuild User Indexes"
	task :users do
		window
		UserImport.new.add_indexes
	end
end

desc "Realtime"
task :realtime do
	Realtime::updateYAML(ARGV[1])
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
	epicosm = EpicOSM.new(analysis_window: ARGV[1])
	epicosm.run_network_functions #This will need to be pulled out eventually...
end


namespace :questions do
	desc "Run all questions defined in the analysis window"
	task :all do
	Rake::Task['questions:nodes'].invoke
	Rake::Task['questions:ways'].invoke
	# Rake::Task['questions:relations'].invoke
	Rake::Task['questions:changesets'].invoke
	Rake::Task['questions:users'].invoke
	Rake::Task['questions:multi_users'].invoke
	Rake::Task['questions:bbox'].invoke
	Rake::Task['questions:notes'].invoke
	end

	desc "Run Node Questions"
	task :nodes do
		epicosm.run_node_questions
	end

	desc "Run Way Questions"
	task :ways do
		epicosm.run_way_questions
	end

	# desc "Run Relation Questions"
	task :relations do
		# This doesn't exist yet
		epicosm.run_relation_questions
	end

	desc "Run Changeset Questions"
	task :changesets do
		epicosm.run_changeset_questions
	end

	desc "Run User Questions"
	task :users do
		epicosm.run_user_questions
	end

	desc "Run Multi-User Questions"
	task :multi_users do
		epicosm.run_multi_user_questions
	end

	desc "Run BBox Questions"
	task :bbox do
		epicosm.run_bbox_questions
	end

	desc "Run Notes Questions"
	task :notes do
		epicosm.run_note_questions
	end
end
