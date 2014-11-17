# THIS IS THE MAIN CONTROLLER.

#This adds the current directory to the loadpath
$:.unshift File.dirname(__FILE__)

#Require the questions modules # => These could be autoloaded?
require 'modules/questions/node_questions'
require 'modules/questions/way_questions'
require 'modules/questions/relation_questions'
require 'modules/questions/user_questions'
require 'modules/questions/changeset_questions'
require 'modules/questions/network_questions'

#This is what's required to make it all work
require 'models/DomainObjects'
require 'models/DatabaseConnection'
require 'models/Query'

#Standard ruby Libraries we need?
require 'yaml'

#Autoload FileIO as needed
autoload :FileIO, 'modules/file_io'

#TODO: Things
class OSMHistory

	include Questions::Nodes
	include Questions::Ways
	include Questions::Network

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
		# Go through questions in the configuration file and run the appropriate algorithms to get answers
	
		# puts number_of_nodes_added

		# nodes_by_2_months

  		analysis_window.ways_x_month(step: 3).each do |bucket|
  			puts "#{bucket[:start_date]} - #{bucket[:end_date]} : #{bucket[:objects].count}"
  		end

		#Do all the way questions:
		#Questions::Ways.instance_methods.each do |method|
			#print method.to_s + ': '; eval "#{method}"
		#end
	end

	def run_network_functions
  		network_info = aw_config['temporal_network']
		temp = TemporalAnalysis.new(aw: analysis_window, step: network_info['step'], unit: network_info['unit'], directory: network_info['files'])
		temp.run_overlapping_changesets
	end

	def write_json(args)
		FileIO::JSONExporter.new(name: args[:name]) 
	end
end