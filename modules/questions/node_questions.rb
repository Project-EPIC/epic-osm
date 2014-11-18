module Questions

	class Nodes
		attr_reader :aw

		def initialize(args)
			@aw = args[:analysis_window]
		end

		def run(command)
			print "Running Function: #{command}..."
			
			begin
				data = FileIO::unpack_objects( instance_eval ("aw.#{command}") )
				
				print "Success: Analysis Window\n"
				
				if data.is_a? Hash or data.is_a? Array
					return data
				else
					return {command.to_s => data}
				end
			rescue
				begin 
					print "Up to QM..."
					x = instance_eval(command)
					print "Success\n"
					return x
				rescue
					print "FUNCTION NOT FOUND -- SKIPPING\n"
				end
			end
		end

    	def total_nodes_edited
			return {'Total Nodes Edited' => aw.node_edit_count }
		end

		def number_of_nodes_added
     		aw.node_added_count
  		end
	 end
  	
end