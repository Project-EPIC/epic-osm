#
#
# Spec Helper -- mocks a database
#
#
require 'mongo'

def build_database

	require_relative '../models/DomainObjects'

	conn = Mongo::MongoClient.new('epic-analytics.cs.colorado.edu',27018)
	db = conn['haiti']
	
	nodes = db['nodes'].find({},{limit:100})
	ways = db['ways'].find({},{limit:100})
	relations = db['relations'].find({},{limit:100})
	users = db['users'].find({},{limit:100})
	changesets = db['changesets'].find({},{limit:100})
	
	database = {nodes: [], ways: [], relations: [], changesets: [], users: [], notes: []}

	nodes.each do |osm_object|
		database[:nodes] << Node.new( id: osm_object["id"], lat: osm_object["properties.lat"],
			lon: osm_object["properties.lon"], changeset: osm_object["properties.changeset"], 
			user_id: osm_object["properties.uid"], user_name: osm_object["properties.user"],
			tags: osm_object["properties.tags"], created_at: osm_object["date"] )
	end

	ways.each do |osm_object|
		database[:ways] << Way.new(id: osm_object["id"], changeset: osm_object["properties.changeset"], 
			user_id: osm_object["properties.uid"], user_name: osm_object["properties.user"],
			tags: osm_object["properties.tags"], created_at: osm_object["date"],
			nodes: osm_object["properties.refs"])
	end

	relations.each do |osm_object|
		database[:ways] << Relation.new(id: osm_object["id"], changeset: osm_object["properties.changeset"], 
			user_id: osm_object["properties.uid"], user_name: osm_object["properties.user"],
			tags: osm_object["properties.tags"], created_at: osm_object["date"],
			nodes: osm_object["properties.members.nodes"],
			ways:  osm_object["properties.members.ways"])
	end

	changesets.each do |osm_object|
		database[:changesets] << Changeset.new(id: osm_object["id"], 
			user_id: osm_object["uid"], user_name: osm_object["user"],
			tags: osm_object["tags"], created_at: osm_object["created_at"],
			open: osm_object["open"], closed_at: osm_object["closed_at"])
	end

	users.each do |osm_object|
		database[:users] << User.new( id: osm_object["uid"].to_i, 
			user_name: osm_object["name"],
			join_date: osm_object["joiningdate"])
	end

	return database
end


if __FILE__ == $0
	build_database
end