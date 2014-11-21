require 'pbf_parser'

class OSMPBF
	require 'date'

	attr_reader :parser, :missing_nodes, :n_count, :w_count, :r_count, :file, :nodes, :ways, :end_date, :memory_only

	def initialize(args={})

		@end_date = args[:end_date] || Time.now
		@missing_nodes		= 0
		@empty_lines 		= 0
		@empty_geometries 	= 0

		@n_count = 0
		@w_count = 0
		@r_count = 0

		@nodes = {}
		@ways  = {}

		@memory_only = args[:memory_only] || false

		puts "---------------------------------------"
		puts "Only parsing data up to #{end_date}"
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
		puts "Nodes: #{n_count}, Ways: #{w_count}, Relations: #{r_count}"
	end

	#Convert the Timestmap to an instance of Time
	def timestamp_to_date(timestamp)
		Time.at(timestamp/1000).utc #This is a time instance, it should go straight ot ruby
	end

	def add_node(node)
		node[:created_at] = timestamp_to_date(node[:timestamp])
		this_node = Node.new(node)

		this_node.save! unless memory_only #Save to Database
		this_node.mem_save  #Save to Memory
	end


	def add_way(way)
		way[:created_at] = timestamp_to_date(way[:timestamp])
		way[:nodes] = way[:refs]
		way.delete :refs
		
		this_way = Way.new(way)

		
		this_way.save! unless memory_only #Save to Database
		this_way.mem_save   #Save to Memory
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

		while parser.next
			unless parser.send(object_type).nil?
				if lim
					to_parse = parser.send(object_type).first(lim)
				else
					to_parse = parser.send(object_type)
				end
				to_parse.each do |obj|
					unless timestamp_to_date(obj[:timestamp]) > end_date
						begin
							add_func.call(obj)
							index += 1
						rescue => e
							puts $!
							puts e.backtrace
							begin
								type["tags"].each do |k,v|
									k.gsub!('.','_')
								end
								add_func.call(obj)
							rescue
								next
							end
						end
					end
					if index%5000==0
						puts "Processed #{index} of #{count} #{object_type}"
						if index%1000==0
        			rate = index/(Time.now() - start_time) #Tweets processed / seconds elapsed
        			mins = (count-index) / rate / 60         #minutes left = tweets left * seconds/tweet / 60
        			hours = mins / 60
        			puts "Status: #{'%.2f' % rate} #{object_type}/Second. #{'%.2f' % mins} minutes left or #{'%.2f' % hours} hours."
						end
					end
				end
			end
		end

		puts "Adding the appropriate indexes: id, changeset, geometry\n"
		puts "=======================================================\n\n"
		begin
			DatabaseConnection.database[object_type.to_sym].ensure_index( id: 1 )
			DatabaseConnection.database[object_type.to_sym].ensure_index( changeset: 1 )
			DatabaseConnection.database[object_type.to_sym].ensure_index( geometry: "2dsphere")
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