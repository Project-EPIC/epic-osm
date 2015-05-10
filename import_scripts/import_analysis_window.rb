# This does all of the heavy lifting for Cutting and Importing new data

require 'yaml'

#Require Import Scripts
require_relative 'osm_api/import_changesets'
require_relative 'osm_api/import_nodeways'
require_relative 'osm_api/import_users'
require_relative 'osm_api/import_notes'
require_relative 'osm_api/osm_api'
require_relative 'osm_api/import_osmtm_tags'
require_relative 'pbf_to_mongo'

#Require Domain Objects
require_relative '../models/DomainObjects'
require_relative '../models/AnalysisWindow'
require_relative '../models/Persistence'
require_relative '../models/Query'

class AnalysisWindowImport

	include DomainObject

	attr_reader :config, :global_config, :time_frame
	def initialize(args = {})

		begin
			@config = YAML.load_file(args[:config])
			end_date = config['end_date'] || Time.now
			@time_frame = TimeFrame.new(start_date: config['start_date'], end_date: end_date)
		rescue => e
			puts $!
			raise IOError.new("Error loading the configuration file: #{args[:config]}")
		end

		begin
			@global_config = YAML.load_file('config.yml')
		rescue => e
			puts e
			raise IOError.new("Error loading global configuration file")
		end
		connect_to_database
	end

	#Calls the Singleton Database Connection for the specific database
	def connect_to_database
		#Open Database Connection
		puts "Connecting to: #{config['database']} Mongo Database\n"
		DatabaseConnection.new(database: config['database'], mongo_only: config['mongo_only'], mem_only: config['mem_only'])
	end

	def write_configuration_file
		# * the destination path and filename. The file-extension used specifies the generated file format (.osm, .osh, .osm.bz2, .osh.bz2, .osm.pbf, .osh.pbf)
		# * the type of extract (BBOX or POLY)
		# * the extract specification
		# * for BBOX: boundaries of the bbox, eg. -180,-90,180,90 for the whole world
		# * for OSM:  path to an .osm file from which all closed ways are taken as outlines of a MultiPolygon. Relations are not taken into account, so holes are not possible.
		# * for POLY: path to the .poly file

		File.open('import_scripts/temp.config', 'wb') do |file|
			if config['poly']
				file.write("import_scripts/temp.osm.pbf  POLY #{config['poly']}")
			else
				file.write("import_scripts/temp.osm.pbf  BBOX #{config['bbox']}")
			end
		end
	end

	#Runs a system shell script to call the osm-history-splitter
	def run_epic_osm_splitter
		begin
			unless config['soft-cut']
				system "#{global_config['osm-history-splitter']} --hardcut #{config['pbf_file']} import_scripts/temp.config"
			else
				system "#{global_config['osm-history-splitter']} --softcut #{config['pbf_file']} import_scripts/temp.config"
			end
		rescue
			raise Error.new("OSM History Splitter Failed")
			puts $!
		end
	end

	def run_mongo_import
		conn = OSMPBF.new(end_date: time_frame.end_date, start_date: time_frame.start_date, not_complete: config['not_complete'])
		if config['pbf_file_final']
			conn.open_parser(config['pbf_file_final'])
		else
			conn.open_parser("import_scripts/temp.osm.pbf")
		end
		# puts conn.file_stats

		#Import Nodes, Ways, Relations
		conn.parse_to_collection(object_type="nodes", lim=nil)

		conn.parse_to_collection(object_type="ways", lim=nil)

		conn.parse_to_collection(object_type="relations", lim=nil)
	end

	def changeset_import
		changeset_import = ChangesetImport.new
		changeset_import.import_changeset_objects
		changeset_import.add_indexes
	end

	def nodeways_import
		nodeways_import = NodeWaysImport.new
		nodeways_import.import_nodeways_objects
    	#puts nodeways_import.new_changeset_ids
	end

	def user_import
		user_import = UserImport.new
		user_import.import_user_objects
		user_import.add_indexes
	end


	#Runs a system shell script to call osm-meta-util
  def run_live_replication_import
    begin
      if config['changeset_tags_collection']
        tags_arg = "--tags_collection changeset_tags "
      else
        tags_arg = "\"" + config['changeset_tags'] + "\""
      end
				string = "#{global_config['osm-meta-util']} --db " + config['database'] + " " + tags_arg + " &"
        puts "Executing: #{string}"
				system string
    rescue
			puts $!
    	raise StandardError.new("osm-meta-util failed")
    end
  end

	def osmtm_tags_import
    osmtm_tags_import = OSMTMTagsImport.new(config['tag_search_term'])
    osmtm_tags_import.import_osmtm_tags
  end

	def note_import
		note_import = NoteImport.new(@config['bbox'])
		puts "Importing note data"
		note_import.import_note_objects
	end
end
