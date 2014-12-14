#Add the current directory to the load path to cleanup installs
$:.unshift File.dirname(__FILE__)

#This is what's required to make it all work
require 'models/DomainObjects'
require 'models/Persistence'
require 'models/Query'

#Load the Questions Base Module
require 'modules/questions/questions.rb'

#Load Individual Questions Modules
require 'modules/questions/node_questions'
require 'modules/questions/way_questions'
require 'modules/questions/relation_questions'
require 'modules/questions/user_questions'
require 'modules/questions/changeset_questions'
require 'modules/questions/network_questions'
require 'modules/questions/bbox_questions'


#TODO: Load custom questions modules as desired....

#Standard ruby Libraries we need?
require 'yaml'
require 'descriptive_statistics/safe'

#Autoload FileIO as needed
autoload :FileIO, 'modules/file_io'

#=Main Controller for OSM History
#
#
class OSMHistory

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
		@analysis_window ||= AnalysisWindow.new( time_frame: TimeFrame.new(start: aw_config['start_date'], end: aw_config['end_date']), 
												 bounding_box: nil, 
												 min_area: aw_config['min_area'], 
												 max_area: aw_config['max_area']
		)
	end


	def run_node_questions
		node_questions = Questions::Nodes.new(analysis_window: analysis_window)

		aw_config['Node Questions'].each do |node_q|
			write_json( data: node_questions.run(node_q), name: "#{node_q}.json")
		end
	end


	def run_changeset_questions
		changeset_questions = Questions::Changeset.new(analysis_window: analysis_window)

		aw_config['Changeset Questions'].each do |changeset_q|
			write_json( data: changeset_questions.run(changeset_q), name: "#{changeset_q}.json")
		end
	end

	def run_bbox_questions
		bbox_questions = Questions::Bbox.new(analysis_window: analysis_window)

		aw_config['Bbox Questions'].each do |bbox_q|
			write_json( data: bbox_questions.run(bbox_q), name: "#{bbox_q}.json")
		end
	end

	def run_user_questions
		user_questions = Questions::Users.new(analysis_window: analysis_window)

		aw_config['User Questions'].each do |user_q|
			write_json( data: user_questions.run(user_q), name: "#{user_q}.json")
		end
	end

	def run_network_functions
  		network_info = aw_config['temporal_network']
		temp = TemporalAnalysis.new(aw: analysis_window, step: network_info['step'], unit: network_info['unit'], directory: network_info['files'])
		temp.run_overlapping_changesets
	end

	def write_json(args)
		out_file = FileIO::JSONExporter.new(name: args[:name], data: args[:data], path: aw_config['write_directory']+'/json') 
		unless out_file.data.nil? 
			out_file.write
		end
	end
end