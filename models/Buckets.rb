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

	attr_reader :items

	def initialize(args)
		@items = args[:items].sort{|object| object.created_at}
	end
end


class Nodes < OSMObjects

end

class Ways < OSMBObjects

end

class Relations < OSMBObjects

end

class Changesets < OSMBObjects

end

class Users < OSMBObjects


	def latest(num)

	end
end

class Notes < OSMBObjects

end