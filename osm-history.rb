#
#
#
# THIS IS THE MAIN CONTROLLER.

#Require modules here

#Require the rest of stuff here
require_relative 'models/DomainObjects'
require_relative 'models/DatabaseConnection'
require_relative 'models/Query'

require 'yaml'

#TODO: Things
class OSMHistory

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
	end

	def write_json(args)
		nil
	end
end