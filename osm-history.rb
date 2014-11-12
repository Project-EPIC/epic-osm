#
#
#
# THIS IS THE MAIN CONTROLLER.

#
$:.unshift File.dirname(__FILE__)

#Require the questions modules #These should be autoloaded, but we have to put this in the load path
require 'modules/questions/node_questions'
require 'modules/questions/way_questions'
require 'modules/questions/relation_questions'
require 'modules/questions/user_questions'
require 'modules/questions/changeset_questions'

#Require the rest of stuff here
require 'models/DomainObjects'
require 'models/DatabaseConnection'
require 'models/Query'

require 'yaml'

autoload :FileIO, 'modules/file_io'

#TODO: Things
class OSMHistory

	include Questions::Nodes
	include Questions::Ways

	attr_reader :aw_config

	def initialize(args)
		begin
			@aw_config = YAML.load_file(args[:analysis_window])
		rescue
			raise IOError.new("Can't load analysis window configuration file")
		end
		
		#Set Database Connection
		DatabaseConnection.new(database: aw_config['database'], host: aw_config['host'], port: aw_config['port'])
		
		analysis_window

		puts "Successfully initialized Analysis Window: #{aw_config['title']}"
	end

	def analysis_window
		@analysis_window ||= AnalysisWindow.new(time_frame: TimeFrame.new(start: aw_config['start_date'], end: aw_config['end_date']), bounding_box: nil)
	end

	def run_questions
		#Go through questions in the configuration file and run the appropriate algorithms to get answers
	
		puts number_of_nodes_added

		buildings_by_month
	end

	def write_json(args)
		FileIO::JSONExporter.new(name: args[:name])
	end
end