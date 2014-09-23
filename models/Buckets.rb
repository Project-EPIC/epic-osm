#
#
#
#
#

class Bucket # => work on this?

	def initialize(args)
		# => Do things
		post_initialize(args)
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
	attr_reader :items

	def initialize(args)
		@items = args[:items].sort{|object| object.created_at}
	end
end


class Nodes < OSMObjects

end

class Ways < OSMObjects

end

class Relations < OSMObjects

end

class Changesets < OSMObjects

end

class Users < OSMObjects


	def latest(num)

	end
end

class Notes < OSMObjects

end