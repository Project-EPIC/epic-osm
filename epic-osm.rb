#Add the current directory to the load path to cleanup installs
$:.unshift File.dirname(__FILE__)

#This is what's required to make it all work
require 'models/DomainObjects'
require 'models/Persistence'
require 'models/Query'
require 'models/AnalysisWindow'

#Load the Questions Module, which autoloads all of the questions
require 'modules/questions/questions.rb'

#Standard ruby Libraries we need?
require 'yaml'
require 'descriptive_statistics/safe'

#Autoload FileIO as needed
autoload :FileIO, 'modules/file_io'

#=Main Controller for EPIC-OSM
#
#
class EpicOSM

	attr_reader :aw_config

	def initialize(args)
		begin
			@aw_config = YAML.load_file(args[:analysis_window])
		rescue
			raise IOError.new("Can't load analysis window configuration file")
		end

		#Set Database Connection
		DatabaseConnection.new(database: aw_config['database'], host: aw_config['host'], port: aw_config['port'])

		puts "Successfully initialized Analysis Window: #{aw_config['title']}"
	end

	def analysis_window
		@analysis_window ||= AnalysisWindow.new(
						time_frame: TimeFrame.new(start_date: aw_config['start_date'], end_date: aw_config['end_date']),
						bounding_box: BoundingBox.new(bbox: aw_config['bbox']),
						min_area: aw_config['min_area'],
						max_area: aw_config['max_area'],
						changeset_tags: aw_config['changeset_tags']
		)
	end

	def question_asker
		@question_asker ||= QuestionAsker.new(analysis_window: analysis_window)
	end


	def run_node_questions
		unless aw_config['Node Questions'].nil?
			aw_config['Node Questions'].each do |node_q|
				write_json( data: question_asker.run(node_q), name: "#{node_q}.json")
			end
		end
	end

	def run_way_questions
		unless aw_config['Way Questions'].nil?
			aw_config['Way Questions'].each do |node_q|
				write_json( data: question_asker.run(node_q), name: "#{node_q}.json")
			end
		end
	end

	def run_changeset_questions
		unless aw_config['Changeset Questions'].nil?
			aw_config['Changeset Questions'].each do |changeset_q|
				write_json( data: question_asker.run(changeset_q), name: "#{changeset_q}.json")
			end
		end
	end

	def run_bbox_questions
		unless aw_config['Bbox Questions'].nil?
			aw_config['Bbox Questions'].each do |bbox_q|
				write_json( data: question_asker.run(bbox_q), name: "#{bbox_q}.json")
			end
		end
	end

	def run_user_questions
		unless aw_config['User Questions'].nil?
			aw_config['User Questions'].each do |user_q|
				write_json( data: question_asker.run(user_q), name: "#{user_q}.json")
			end
		end
	end

	def run_multi_user_questions
		unless aw_config['Multi User Quesions'].nil?
			aw_config['Multi User Questions'].each do |user_q|
				puts user_q
				question_asker.run(user_q).each do |name, data|
					write_json( data: data, name: "#{user_q}/#{name}.json")
				end
			end
		end
	end

	def run_network_functions
		network_info = aw_config['temporal_network']
			temp = Questions::Networks::TemporalAnalysis.new(aw: analysis_window, step: network_info['step'], unit: network_info['unit'], directory: network_info['files'])
			temp.run_overlapping_changesets
	end

	def run_note_questions
		unless aw_config['Note Questions'].nil?
			aw_config['Note Questions'].each do |note_q|
				write_json( data: question_asker.run(note_q), name: "#{note_q}.json")
			end
		end
	end

	def write_json(args)
		out_file = FileIO::JSONExporter.new(name: args[:name], data: args[:data], path: aw_config['write_directory']+'/json')
		unless out_file.data.nil?
			out_file.write
		end
	end
end
