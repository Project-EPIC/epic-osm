# = Questions Runner
#
# There are two ways to ask questions.  Using the run('question as a string') command
# is the safety net.  For more ruby-ish methods, you can also call each method directly

Dir[File.dirname(__FILE__)+'/*.rb'].each { |file|
	require file
}

class QuestionAsker # :nodoc: all

	include Questions::Nodes
	include Questions::Ways
	include Questions::Relations
	include Questions::Users
	include Questions::Changesets
	include Questions::Networks
	include Questions::Bbox
	include Questions::Notes

	attr_reader :aw

	def initialize(args)
		@aw = args[:analysis_window]
	end

	# Check question syntax before sending it up the chain
	def method_missing(m, *args, &block)
		begin
			pieces = m.to_s.split(/\_/)

			#If the question is of the format users_editing_(per|by|x)_[timeframe]
			if pieces[0]+pieces[1] == 'usersediting'
				instance_eval "user_time_frame(pieces[3],#{args.join(',')})"
			else
				#Ultimately send it to the Analysis Window if it wasn't found here
				instance_eval "aw.#{m}(#{args.join(',')})"
			end
		rescue => e
			puts $!
			puts e.backtrace
			super(args)
		end
	end


	#Default run command for all questions, first looks at analysis window
	#then moves up to questions module to answer the question

	#This command is used to have more control and error handling.
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
			rescue => e
				print "FUNCTION NOT FOUND -- SKIPPING\n"
				puts $!
				# puts e.backtrace
			end
		end
	end

	def run_network_questions(question)
		instance_eval "#{question.keys.first}(#{question.values.first})"
	end

	def run_advanced_changeset_questions(question)
		instance_eval "#{question.keys.first}(#{question.values.first})"
	end
end
