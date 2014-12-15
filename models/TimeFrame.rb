# = Time Frame
#
# Timeframes are the temporal bounds of the analysis window.
class TimeFrame
	require 'time'

	attr_reader :start, :end, :active

	#If the time frame is active, then start and end dates are defined and functioning
	def active?
		active
	end

	def initialize(args=nil)
		if args.nil?
			@active = false
		else
			@start = validate_time(args[:start])
			@end   = validate_time(args[:end])
			@active = true
		end
	end

	def validate_time(time)
		if time.is_a? Time
			return time
		else
			return Time.parse(time)
		end
	end
end