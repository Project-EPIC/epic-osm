#
# Module to interface our Domain Objects with Mongo
#
#
#

require 'mongo'

class BSON::OrderedHash
	def from_mongo
		self.keys.each do |key|
			self[key.to_sym] = self[key]
			self.delete key
		end
		return self
	end
end

module OSMongoable
	
	module OSMObject
		def to_mongo(hash)
			hash[:id] 		  ||= id.to_s
			hash[:uid]		  ||= uid.to_s
			hash[:user]       ||= user
			hash[:created_at] ||= created_at
			hash[:tags]       ||= tags
		end

	end
	
	module Node
		def to_mongo
			hash={}
			hash[:lat] ||= lat
			hash[:lon] ||= lon
			hash[:version]   ||= version
			hash[:geometry]  ||= geojson_geometry
			hash[:changeset] ||= changeset.to_s
			super(hash)
			hash
		end

		def geojson_geometry
			{type: "Point", coordinates: [lon,lat]}
		end

		def save!
			DatabaseConnection.database['nodes'].insert( self.to_mongo )
		end

	end



	module Way
		def to_mongo
			hash = {}
			hash[:nodes] = nodes.collect{|node| node.to_s}
			hash[:changeset]  ||= changeset.to_s
			hash[:version]    ||= version
			super(hash)
			hash
		end

		def save!
			DatabaseConnection.database['ways'].insert( self.to_mongo )
		end
	end


	module Relation
		def to_mongo
			hash = {}
			hash[:version]    ||= version
			hash[:changeset]  ||= changeset.to_s
			hash[:nodes] = nodes.collect{|node| node.to_s}
			hash[:ways]  = ways #TODO: Clean this up so it casts to string .collect{|w| w[:id] = id.to_s }
			super(hash)
			hash
		end

		def save!
			DatabaseConnection.database['relations'].insert( self.to_mongo )
		end
	end


	module User
		def to_mongo
			hash = {}
			hash[:uid]  = uid.to_s
			hash[:user] = user #TODO: Clean this up so it casts to string .collect{|w| w[:id] = id.to_s }
			hash[:account_created] = account_created
			hash
		end

		def save!
			DatabaseConnection.database['users'].insert( self.to_mongo )
		end
	end


	module Changeset

		def to_mongo
			hash = {}
			hash[:comment]   ||= comment
			hash[:closed_at] ||= closed_at
			hash[:open]		 ||= open
			hash[:min_lat]   ||= min_lat
			hash[:max_lat]   ||= max_lat
			hash[:min_lon]   ||= min_lon
			hash[:max_lon]   ||= max_lon
			super(hash)
			hash
		end

		def save!
  			DatabaseConnection.database['changesets'].insert( self.to_mongo )
  		end
  	end
end