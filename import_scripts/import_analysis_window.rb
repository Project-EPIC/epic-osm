require 'yaml'

#Require Import Scripts
require_relative 'osm_api/import_changesets'
require_relative 'osm_api/import_users'
require_relative 'osm_api/osm_api'
require_relative 'pbf_to_mongo'

#Require Database Connection
require_relative '../models/DatabaseConnection'

#Require Domain Objects
require_relative '../models/DomainObjects'
require_relative '../models/DatabaseConnection'
require_relative '../models/Query'


class AnalysisWindowImport

	attr_reader :config_file, :config, :options_file

	def initialize(args = {})
		@config_file = args[:config]

		begin
			@config = YAML.load_file(config_file)
		rescue
			raise StandardError.new("Error loading the configuration YAML file.")
		end

		post_initialize
	end

	def post_initialize
		#Open Database Connection
		puts "Connecting to: #{config['database']}"
		DatabaseConnection.new(database: config['database'])
	end

	def write_configuration_file

		# * the destination path and filename. The file-extension used specifies the generated file format (.osm, .osh, .osm.bz2, .osh.bz2, .osm.pbf, .osh.pbf)
		# * the type of extract (BBOX or POLY)
		# * the extract specification
		# * for BBOX: boundaries of the bbox, eg. -180,-90,180,90 for the whole world
		# * for OSM:  path to an .osm file from which all closed ways are taken as outlines of a MultiPolygon. Relations are not taken into account, so holes are not possible.
		# * for POLY: path to the .poly file

		File.open('import_scripts/temp.config', 'wb') do |file|
			file.write("import_scripts/temp.osm.pbf  BBOX #{config['bbox']}")
		end
	end


	def run_osm_history_splitter
		exec "~/Applications/osm-history-splitter/osm-history-splitter --hardcut #{config['pbf_file']} import_scripts/temp.config"
	end

	def run_mongo_import
		conn = OSMPBF.new
		conn.open_parser("import_scripts/temp.osm.pbf")
		puts conn.file_stats
	
		#Import Nodes, Ways, Relations
		conn.parse_to_collection(object_type="nodes", lim=nil)

		#TODO: Build Node Indexes so Ways can get their geometries
		conn.parse_to_collection(object_type="ways", lim=nil)

		#TODO: Build Node, Way Indexes so Relations can get their members
		conn.parse_to_collection(object_type="relations", lim=nil)
	end

	def changeset_import
		changeset_import = ChangesetImport.new
		puts "Importing #{changeset_import.distinct_changeset_ids.length} changsets"
		changeset_import.import_changeset_objects
	end

	def user_import
		user_import = UserImport.new
		puts "Importing user data for #{user_import.distinct_uids.length} users"
		user_import.import_user_objects
	end

	# Delete temporary files
	def remove_temp_files
		if File.exists? 'import_scripts/temp.config'
			File.delete 'import_scripts/temp.config'
		end
		if File.exists? 'import_scripts/temp.pbf'
			File.delete 'import_scripts/temp.pbf'
		end
	end

end