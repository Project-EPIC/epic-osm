require_relative '../osm_history_analysis'

#
# This script updates the 'object count' variable for changesets
#

country = 'haiti'

def upsert_to_mongo(collection, id, payload)
  collection.update(
    {"id" => id}, 
    {'$set' => payload}, 
    opts={:upsert=>true})
end

if __FILE__ == $0

	osm_driver = OSMHistoryAnalysis.new(:local)
	
	changesets = osm_driver.connect_to_mongo(db=country, coll="changesets")

	nodes = osm_driver.connect_to_mongo(db=country, coll="nodes")
	ways  = osm_driver.connect_to_mongo(db=country, coll="ways")
	relations = osm_driver.connect_to_mongo(db=country, coll="relations")

	sets = changesets.distinct("id").sort
	size = sets.count

	fail_log = LogFile.new("logs/processing_changesets", "failed")
	
	#Now iterate through changesets and query the collections:
	sets.each_with_index do |changeset, i|

		#Nodes
		begin
			node_count = nodes.find({"properties.changeset"=>changeset}).count()
			unless node_count.zero?
				upsert_to_mongo(changesets, changeset, {:node_count=>node_count, :nodes=>true})
			else
				upsert_to_mongo(changesets, changeset, {:nodes=>false})
			end
		rescue
			fail_log.log("Nodes: " + changeset.to_s)
			puts $!
		end
		
		if (i%101).zero?
			puts "Processed nodes: #{i} of #{size}"
		end

    	#Ways
		begin
			way_count = ways.find({"properties.changeset"=>changeset}).count()
			unless way_count.zero?
				upsert_to_mongo(changesets, changeset, {:way_count=>way_count, :ways=>true})
			else
				upsert_to_mongo(changesets, changeset, {:ways=>false})
			end
		rescue
			fail_log.log("Ways: " + changeset.to_s)
			puts $!
		end
		
		if (i%102).zero?
			puts "Processed ways: #{i} of #{size}"
		end

    	# #Relations
		begin
			relation_count = relations.find({"properties.changeset"=>changeset}).count()
			unless relation_count.zero?
				upsert_to_mongo(changesets, changeset, {:relation_count=>node_count, :relations=>true})
			else
				upsert_to_mongo(changesets, changeset, {:relations=>false})
			end
		rescue
			fail_log.log("Relations: " + changeset.to_s)
			puts $!
		end
		
		if (i%103).zero?
      		puts "Processed relations: #{i} of #{size}"
    	end
	end
end