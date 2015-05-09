require 'mongo'

#First, open BSON Ordered Hash and rewrite the keys to symbols to interface
# better with our model
module BSON  #:nodoc:
	class OrderedHash
		#=Turn Strings to Symbols
		#
		#
		def from_mongo
			self.keys.each do |key|
				self[key.to_sym] = self[key]
				self.delete key
			end
			return self
		end
	end
end

# = Creating the EPIC OSM <=> Mongo Link
#
#
module OSMongoable

	#Nodes, Ways, Relations share these features
	module OSMObject # :nodoc:
		def to_mongo(hash)
			hash[:id] 		  ||= id.to_s
			hash[:uid]		  ||= uid.to_s
			hash[:user]       ||= user
			hash[:created_at] ||= created_at
			hash[:tags]       ||= tags
			hash[:geometry]   ||= geojson_geometry

			hash.delete :geometry if hash[:geometry].nil?
		end

		def save!
			DatabaseConnection.insert(self)
		end
	end

	module Node # :nodoc: all
		def to_mongo
			hash={}
			hash[:lat] ||= lat
			hash[:lon] ||= lon
			hash[:version]   ||= version
			hash[:changeset] ||= changeset.to_s
			super(hash)
			hash
		end

		def get_geojson_geometry
			@geometry ||= {type: "Point", coordinates: [lon,lat]}
		end
	end

	module Way # :nodoc: all
		def to_mongo
			hash = {}
			hash[:nodes] 	  ||= nodes
			hash[:changeset]  ||= changeset.to_s
			hash[:version]    ||= version
			super(hash)
			hash[:missing_nodes] = missing_nodes unless missing_nodes.empty?
			hash
		end

		def get_geojson_geometry
			return nil if nodes.nil?
			return nil if nodes.empty?

			missing_nodes = []
			coords = []

			#Iterate over this way's nodes
			nodes.each do |node_id| #The id of the node needed
				mem_nodes = DatabaseConnection.persistent_nodes(node_id)

				if mem_nodes.nil?	#Look for this node in memory
					missing_nodes << node_id     #Add it to missing and skip
					next
				else
					if mem_nodes.length == 1 #If there is only one, use it
						this_node = DomainObject::Node.new(mem_nodes.first)
						coords << [this_node.lon, this_node.lat]
					else
						mem_nodes = mem_nodes.collect{|n| DomainObject::Node.new(n)}
						mem_nodes.sort! { |a,b| a.changeset <=> b.changeset }
						this_node = mem_nodes.select{|node| node.changeset.to_i <= changeset.to_i}
						unless this_node.empty?
							coords << [this_node.last.lon, this_node.last.lat]
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
	end


	module Relation # :nodoc: all
		def to_mongo
			hash = {}
			hash[:version]    ||= version
			hash[:changeset]  ||= changeset.to_s
			hash[:nodes] 	  ||= nodes
			hash[:ways]       ||= ways
			super(hash)
			hash[:missing_nodes] = missing_nodes unless missing_nodes.empty?
			hash[:missing_ways]  = missing_ways  unless missing_ways.empty?
			hash
		end

		def get_geojson_geometry
			geometries = []
			@missing_nodes = []
			@missing_ways  = []

			unless nodes.nil? or nodes.empty?
				nodes.each do |node_id|

					mem_nodes = DatabaseConnection.persistent_nodes(node_id)

					if mem_nodes.nil?	#Look for this node in memory
						@missing_nodes << node_id    	#Add it to missing and skip
						next
					elsif mem_nodes.length == 1 #If there is only one, use it
						geometries << DomainObject::Node.new(mem_nodes.first).geometry

					else
						mem_nodes = mem_nodes.collect{|n| DomainObject::Node.new(n)}
						mem_nodes.sort! { |a,b| a.changeset <=> b.changeset }
						this_node = mem_nodes.select{|node| node.changeset.to_i <= changeset}
						unless this_node.empty?
							geometries << this_node.last.geometry
						else
							@missing_nodes << node_id
						end
					end
				end
			end

			unless ways.nil? or ways.empty?
				ways.each do |way_id|

					mem_ways = DatabaseConnection.persistent_ways(way_id)

					if mem_ways.nil?	#Look for this way in memory
						@missing_ways << way_id    	#Add it to missing and skip
						next
					elsif mem_ways.length == 1 #If there is only one, use it
						this_way = DomainObject::Way.new(mem_ways.first)
						geometries << this_way.geometry unless this_way.geometry.nil?
					else
						mem_ways = mem_ways.collect{|w| DomainObject::Way.new(w)}
						mem_ways.sort! { |a,b| a.changeset <=> b.changeset }
						this_way = mem_ways.select{|way| way.changeset.to_i <= changeset}
						unless this_way.empty?
							geometries << this_way.last.geometry unless this_way.last.geometry.nil?
						else
							@missing_ways << way_id
						end
					end
				end
			end

			geometries.compact!

			unless geometries.empty?
				return {type: "GeometryCollection", geometries: geometries}
			else
				return nil
			end
		end
	end


	module User # :nodoc: all
		def to_mongo
			hash = {}
			hash[:uid]  = uid.to_s
			hash[:user] = user #TODO: Clean this up so it casts to string .collect{|w| w[:id] = id.to_s }
			hash[:account_created] = account_created
			hash
		end

		def save!
			DatabaseConnection.database['users'].insert_one( self.to_mongo )
		end
	end

	module Note # :nodoc: all
		def to_mongo
			hash = {}
			hash[:id] 		  	||= id.to_s
			hash[:url] 		 	||= url
			hash[:created_at]	||= created_at
			hash[:status] 		||= status
			hash[:lon] 		 	||= lon
			hash[:lat] 		 	||= lat
			hash[:comments] 	||= comments
			hash
		end

		def save!
			DatabaseConnection.database['notes'].insert_one( self.to_mongo )
		end
	end


	module Changeset # :nodoc: all

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

		def get_geojson_geometry
			#Check if it's valid
			if min_lon < -180 or max_lon > 180 or min_lat < -90 or max_lat > 90
				return nil
			#Check if it's just a point
			elsif ( (min_lon - max_lon).abs < 0.000000001) or ( (min_lat - max_lat).abs < 0.000000001)
				return {type: "Point", coordinates: [min_lon, max_lat]}
			else
				return {type: "Polygon",
						coordinates: [[	[min_lon, min_lat],
										[min_lon, max_lat],
										[max_lon, max_lat],
										[max_lon, min_lat],
										[min_lon, min_lat] ]] }
			end
		end

		def save!(args={})
			obj = self.to_mongo.merge(args)
  		DatabaseConnection.database['changesets'].insert_one( obj )
  	end
	end

	module ChangesetTags # :nodoc: all
  	def to_mongo
    	hash = {}
      hash[:tag]  = tag
      hash[:name] = name
      hash[:status] = 0 # new documents are flagged, for atomicity of update
      hash
    end

    def save!
			to_upsert = self.to_mongo
      DatabaseConnection.database['changeset_tags'].update( {tag: to_upsert[:tag]}, to_upsert, {upsert: true})
    end

    def atomic_update
      DatabaseConnection.database['changeset_tags'].update({},{:$inc => {:status => 1}}, {:$isolated =>  1, :multi => true})
      DatabaseConnection.database['changeset_tags'].remove({:status => {:$gt => 1}})
    end
  end

end
