require 'pbf_parser'

class OSMPBF
	include DomainObject
	require 'date'

	attr_reader :parser, :missing_nodes, :n_count, :w_count, :r_count, :file, :nodes, :ways, :end_date, :start_date, :use_start_date

	def initialize(args={})

		@end_date = args[:end_date] || Time.now
		@start_date = args[:start_date]
		@use_start_date = args[:not_complete]
		@missing_nodes		= 0
		@empty_lines 		= 0
		@empty_geometries 	= 0

		@n_count = 0
		@w_count = 0
		@r_count = 0

		@nodes = {}
		@ways  = {}


		puts "---------------------------------------"

		if use_start_date
			puts "Only importing data after #{start_date}"
		end

		puts "Parsing data up to #{end_date}"
		puts "---------------------------------------"
	end


	#Initialize the pbf parser from the file
	def open_parser(this_file)
		@file = this_file
		@parser = PbfParser.new(file)
	end

	#If the function @parser.seek(0) worked, this would be prettier...
	def reset_parser
		@parser = nil
		@parser = PbfParser.new(file)
	end

	#Get stats on the PBF file.
	def file_stats
		test_parser = PbfParser.new(file)
		unless test_parser.nodes.empty?
			@n_count+= test_parser.nodes.size
		end
		unless test_parser.ways.empty?
			@w_count+= test_parser.ways.size
		end
		unless test_parser.relations.empty?
			@r_count+= test_parser.relations.size
		end
		while test_parser.next
			unless test_parser.nodes.empty?
				@n_count+= test_parser.nodes.size
			end
			unless test_parser.ways.empty?
				@w_count+= test_parser.ways.size
			end
			unless test_parser.relations.empty?
				@r_count+= test_parser.relations.size
			end
		end
		puts "============================================================="
		puts "Nodes: #{n_count}, Ways: #{w_count}, Relations: #{r_count}\n"
		puts "=============================================================\n"
	end

	#Convert the Timestmap to an instance of Time
	def timestamp_to_date(timestamp)
		Time.at(timestamp/1000).utc #This is a time instance, it should go straight ot ruby
	end

	def add_node(node)
		node[:created_at] = timestamp_to_date(node[:timestamp])

		this_node = Node.new(node)
		this_node.save!
	end

	def add_way(way)
		way[:created_at] = timestamp_to_date(way[:timestamp])
		way[:nodes] = way[:refs]
		way.delete :refs

		this_way = Way.new(way)
		this_way.save!
	end

	def add_relation(relation)
		relation[:created_at] = timestamp_to_date(relation[:timestamp])
		relation[:nodes] = relation[:members][:nodes].collect{|n| n[:id].to_s}
		relation[:ways]  = relation[:members][:ways].collect{|w| w[:id].to_s}

		relation.delete :members

		this_rel = Relation.new(relation)
		this_rel.save!
	end


	def parse_to_collection(object_type, lim=nil)
		start_time = Time.now
    	puts "Started #{object_type} import at: #{start_time}"
    	puts "-----------------------------------------------\n"
		reset_parser #Reset the parser because 'seek' does not work

		@missing_nodes = 0
		index = 0
		add_func = method("add_#{object_type[0..-2]}")
		count = eval("@#{object_type[0]}_count")
		time_then = Time.now()

		while true
			unless parser.send(object_type).nil?
				if lim
					to_parse = parser.send(object_type).first(lim)
				else
					to_parse = parser.send(object_type)
				end
				to_parse.each do |obj|
					this_date = timestamp_to_date(obj[:timestamp])

					#Check if we're using start date
					next if (use_start_date) and (this_date < start_date)

					if (this_date < end_date)
						begin
							add_func.call(obj)
							index += 1
						rescue => e
							puts $!
							puts e.backtrace
						end
					end
					if index%5000==0
						time = Time.now()
						current_rate = (5000/(time - time_then))
						time_then = time
						avg_rate = index/(time - start_time)
						print "Processed #{index} #{object_type} at Avg: #{'%d' % avg_rate} Current: #{'%d' % current_rate} #{object_type}/second. \r"
						$stdout.flush
					end
				end
			end
			unless parser.next
				#We need to force the bulk insert to write.
				eval "DatabaseConnection.bulk_#{object_type}.execute()"
				break
			end
		end

		puts "\nAdding the appropriate indexes: id, changeset, created_at, geometry\n"
		puts "=======================================================\n\n"
		begin
			DatabaseConnection.database[object_type].indexes.create_many(
			[
				{ :key => { geometry:   '2dsphere'}},
				{ :key => { created_at: 1         }},
				{ :key => { uid:        1         }},
				{ :key => { user:       1         }},
			])
		rescue => e
			puts "Error creating index"
			p $!
		end
	end

	def read_pbf_to_mongo(lim=nil, types=[:nodes, :ways, :relations])
		if types.include? :nodes
			puts "\nImporting Nodes"
			parse_to_collection('nodes', lim=lim)
		end

		if types.include? :ways
			puts "\nImporting Ways"
			parse_to_collection('ways', lim=lim)
			puts "Missing node count: #{@missing_nodes}"
			puts "Empty way count: #{@empty_lines}"
		end

		if types.include? :relations
			puts "\nImporting Relations"
			parse_to_collection('relations', lim=lim)
			puts "Missing node count: #{@missing_nodes}"
			puts "Empty way count: #{@empty_lines}"
			puts "Empty Geometries: #{@empty_geometries}"
		end

	end
end
