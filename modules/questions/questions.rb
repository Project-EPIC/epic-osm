#=Questions Module
#
#
module Questions

	#Abstract Questions Runner Class
	class QuestionsRunner
		attr_reader :aw

		def initialize(args)
			@aw = args[:analysis_window]
		end

		#Default run command for all questions, first looks at analysis window
		#then moves up to questions module to answer the question
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
	end
end