
module FileIO

	#Main File Exporter (Should be VERY simple)
	class JSONExporter

		def initialize(args)
			puts args
		end
	end


	#Write a 'gml' file for network analytics
	class GMLAuthor

		attr_reader :nodes, :edges, :file, :directed, :id, :label, :comment

		def initialize(args)
			@filename= args[:filename] || Time.new.to_s + '.gml'
			@nodes = []
			@edges = []

			@id = args[:id]
			@label = args[:label]
			@comment = args[:comment]

			if args[:directed]
				@directed = 1
			else
				@directed = 0
			end

			@file = File.open(args[:filename], 'wb')
		end

		def write
			header
			write_nodes
			write_edges
			footer
		end

		def header
			file.write %Q{graph [\n} 
			file.write %Q{\tdirected #{directed}\n}
			if id
				file.write %Q{\tid #{id}\n}
			end
			if label
				file.write %Q{\tlabel #{label}\n}
			end
			if comment
				file.write %Q{\tcomment #{comment}\n}
			end
		end

		def footer
			file.write %Q{]}
			file.close
		end

		def add_node(node)
			unless nodes.include? node
				@nodes << node
			end
		end


		def add_edge(edge)
			unless edges.include? edge
				@edges << edge
			end
		end

		def write_nodes
			nodes.each do |node|
				file.write %Q{\tnode [\n} 
				file.write %Q{\t\tid "#{node.delete :id}"\n}
				node.keys.each do |key|
					file.write %Q{\t\t#{key} }
					if node[key].is_a? String
						file.write %Q{"#{node[key]}"\n}
					else
						file.write %Q{#{node[key]}\n}
					end
				end
				file.write %Q{\t]\n}
			end
		end

		def write_edges
			edges.each do |edge|
				file.write %Q{\tedge [\n}
				file.write %Q{\t\tsource "#{edge.delete :source}"\n}
				file.write %Q{\t\ttarget "#{edge.delete :target}"\n}
				edge.keys.each do |key|
					file.write %Q{\t\t#{key} }
					if edge[key].is_a? String
						file.write %Q{"#{edge[key]}"\n}
					else
						file.write %Q{#{edge[key]}\n}
					end
				end
				file.write %Q{\t]\n}
			end
		end
	end
end