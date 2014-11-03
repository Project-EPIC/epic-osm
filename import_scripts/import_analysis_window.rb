require 'yaml'

#Require Import Scripts
require_relative 'osm_api/import_changesets'
require_relative 'osm_api/import_users'
require_relative 'osm_api/osm_api'
require_relative 'pbf_to_mongo'


def read_yaml_config(configuration_file)
	window_config = YAML.load_file(configuration_file)

	#TODO: Error Checking & Completeness, such as check for existin database and throw error
	
	return window_config
end