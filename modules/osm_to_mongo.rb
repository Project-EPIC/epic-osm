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
			hash[:geometry]   ||= geojson_geometry

			hash.delete :geometry if hash[:geometry].nil?
		end

		def geojson_geometry
			nil
		end

		def mem_save
			nil
		end
	end
	
	module Node
		def to_mongo
			hash={}
			hash[:lat] ||= lat
			hash[:lon] ||= lon
			hash[:version]   ||= version
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

		def mem_save
			DatabaseConnection.write_memory_node(self)
		end
	end



	module Way
		def to_mongo
			hash = {}
			hash[:nodes] = nodes.collect{|node| node.to_s}
			hash[:changeset]  ||= changeset.to_s
			hash[:version]    ||= version
			super(hash)
			hash[:missing_nodes] = missing_nodes unless missing_nodes.empty?
			hash
		end

		def geojson_geometry
			return nil if nodes.nil?
			return nil if nodes.empty?

			mem_nodes = DatabaseConnection.memory_nodes

			missing_nodes = []
			coords = []
			
			#Iterate over this way's nodes
			nodes.each do |node_id| #The id of the node needed
				if mem_nodes[node_id].nil?	#Look for this node in memory
					missing_nodes << node_id     #Add it to missing and skip
					next
				else
					if mem_nodes[node_id].length == 1 #If there is only one, use it
						coords << [mem_nodes[node_id].first.lon, mem_nodes[node_id].first.lat]
					else
						this_node = mem_nodes[node_id].select{|node| node.changeset == changeset}
						unless this_node.empty?
							coords << [this_node.first.lon, this_node.first.lat]
						else
							missing_nodes << node_id
						end
					end
				end
			end

			@missing_nodes = missing_nodes
			
			case coords.length
			when 0 
				return nil
			when 1 
				return {"type" => "Point", "coordinates" => coords.first}
			else
				return {"type" => "LineString", "coordinates" => coords}
			end
		end

		def save!
			DatabaseConnection.database['ways'].insert( self.to_mongo )
		end

		def mem_save
			DatabaseConnection.write_memory_way(self)
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

		#TODO: Initialize a mem_save function as well as a get_geometry function which will be a 
			#  collection of geometries (GeometryCollection) for the associated nodes & stuff
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