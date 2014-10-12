require_relative '../osm_history_analysis'

#
# This script adds the "dw" variable to a user signifying they had a changeset that occured in the DW
#

country = 'phil'

def upsert_to_mongo(collection, id, payload)
  collection.update(
    {"id" => id}, 
    {'$set' => payload}, 
    opts={:upsert=>true})
end

if __FILE__ == $0

	osm_driver = OSMHistoryAnalysis.new(:local)
	changesets = osm_driver.connect_to_mongo(db=country, coll="changesets")
	users      = osm_driver.connect_to_mongo(db=country, coll="users")

	res = changesets.distinct("uid", {
			:created_at => {'$gt' => osm_driver.dates[country.to_sym][:event],
							'$lt' => osm_driver.dates[country.to_sym][:dw_end]
						   },
		})
	res.each do |uid|
		begin
			puts uid
			user = users.find({:id=>uid}).first
			user['dw'] = true
			upsert_to_mongo(users, uid, user)
		rescue => e
			p $!
			p e.backtrace
		end
	end

end