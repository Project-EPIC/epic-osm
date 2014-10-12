#
#
#
#
#

module OSMongoable

	module OSMObject
		def to_mongo(hash)
			hash[:id] 		  ||= id.to_s
			hash[:user_id]    ||= user_id.to_s
			hash[:user_name]  ||= user_name
			hash[:created_at] ||= created_at
			hash[:tags]       ||= tags
			hash[:version]    ||= version
		end
	end
	
	module Node

		def to_mongo
			hash={}
			hash[:lat] ||= lat
			hash[:lon] ||= lon
			hash[:geometry] ||= geojson_geometry
			super(hash)
			hash
		end

		def geojson_geometry
			{type: "Point", coordinates: [lon,lat]}
		end

		def save!
			DB['nodes'].insert( self.to_mongo )
		end

	end



	module Way
		def to_mongo
			hash = {}
			hash[:nodes] = nodes.collect{|node| node.to_s}
			super(hash)
			hash
		end

		def save!
			DB['ways'].insert( self.to_mongo )
		end
	end


	module Relation
		def to_mongo
			hash = {}
			hash[:nodes] = nodes.collect{|node| node.to_s}
			hash[:ways]  = ways #TODO: Clean this up so it casts to string .collect{|w| w[:id] = id.to_s }
			super(hash)
			hash
		end

		def save!
			DB['relations'].insert( self.to_mongo )
		end
	end


	module User


	end


	module Changeset



	end
end