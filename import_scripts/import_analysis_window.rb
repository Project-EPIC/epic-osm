# This does all of the heavy lifting for Cutting and Importing new data

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

	attr_reader :config, :global_config
	def initialize(args = {})

		begin
			@config = YAML.load_file(args[:config])
		rescue
			raise IOError.new("Error loading the configuration file: #{args[:config]}")
		end

		begin
			@global_config = YAML.load_file('config.yml')
			puts global_config
		rescue
			raise IOError.new("Error loading global configuration file")
		end
	end

	#Calls the Singleton Database Connection for the specific database
	def connect_to_database
		#Open Database Connection
		puts "Connecting to: #{config['database']} Mongo Database"
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

	#Runs a system shell script to call the osm-history-splitter
	def run_osm_history_splitter
		unless config['soft-cut']
			system "#{global_config['osm-history-splitter']} --hardcut #{config['pbf_file']} import_scripts/temp.config"
		else
			system "#{global_config['osm-history-splitter']} --softcut #{config['pbf_file']} import_scripts/temp.config"
		end
	end

	def run_mongo_import
		connect_to_database
		conn = OSMPBF.new(end_date: config[:end_date])
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
		puts "Importing #{changeset_import.distinct_changeset_ids.length} changesets"
		changeset_import.import_changeset_objects
	end

	def user_import
		user_import = UserImport.new
		puts "Importing user data for #{user_import.distinct_uids.length} users"
		user_import.import_user_objects
	end
end