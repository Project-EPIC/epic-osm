#
#
#
#
#

class Bucket # => work on this?
	require_relative 'DomainObjects'

	attr_reader :items

	def initialize(args)
		# => Do things
		@items = args[:items]
		post_initialize(args)
	end

	def post_initialize(args)
		nil
	end

	def count
		items.count
	end

	def summary_stats
		nil
	end

end

class OSMObjects < Bucket
	# => Does this need to be aware of DomainObjects?
end


class Nodes < OSMObjects

end

class Ways < OSMObjects

end

class Relations < OSMObjects

end

class Changesets < OSMObjects

end

class Users < Bucket

end

class Notes < Bucket

end