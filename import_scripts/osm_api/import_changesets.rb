#Create either a point or a polygon depending on the reported points
def process_bbox(this_changeset)
  ll = [ this_changeset["min_lon"].to_f, this_changeset["min_lat"].to_f ]

  if this_changeset["min_lat"] == this_changeset["max_lat"]
    if this_changeset["min_lon"] == this_changeset["max_lon"]
      type="Point"
      coords = ll
    end
  else
    lr = [ this_changeset["max_lon"].to_f, this_changeset["min_lat"].to_f ]
    ur = [ this_changeset["max_lon"].to_f, this_changeset["max_lat"].to_f ]
    ul = [ this_changeset["min_lon"].to_f, this_changeset["max_lat"].to_f ]

    type= "Polygon"
    coords = [ [ll, ul, ur, lr, ll] ]
  end
  return { :type=>type, :coordinates=>coords}
end

def upsert_to_mongo(collection, id, payload)
  collection.update(
    {"id" => id}, 
    {'$set' => payload}, 
    opts={:upsert=>true})
end



if __FILE__ == $0
  require 'json'
  require 'optparse'
  require 'pp'
  require_relative '../osm_history_analysis'
  options = OpenStruct.new
  opts = OptionParser.new do |opts|
    opts.banner = "Usage: ruby import_changesets.rb -d DATABASE -c COLLECTION  [-l LIMIT]\n\tIterate over a collection and hit the API for the changeset information."
    opts.separator "\nSpecific options:"

    opts.on("-d", "--database Database Name",
            "Name of Database (Haiti, Philippines)"){|v| options.db = v }
    opts.on("-c", "--Collection Name",
            "Type of OSM object (nodes, ways, relations)"){|v| options.coll = v }
    opts.on("-l", "--limit [LIMIT]",
            "[Optional] Limit of objects to parse"){|v| options.limit = v.to_i }
    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end
  opts.parse!(ARGV)
  unless options.db and options.coll
    puts opts
    exit
  end


#########################################################################
########################  RUNTIME  ######################################
#########################################################################

  #Connect to Mongo
  osm_driver = OSMHistoryAnalysis.new(:local)
  object_collection = osm_driver.connect_to_mongo(db=options.db, coll=options.coll)
  changesets = osm_driver.connect_to_mongo(db=options.db, coll="changesets")

  #Connect to API
  changeset_api = OSMAPI.new("http://api.openstreetmap.org/api/0.6/changeset/")

  #Open Log files
  success_log = LogFile.new("logs/changesets","successful")
  fail_log    = LogFile.new("logs/changesets","failed")

  distinct_changesets = object_collection.distinct("properties.changeset").collect{|x| x.to_i}.sort #Sort for safety, again
  if options.limit
    distinct_changesets = distinct_changesets.first(options.limit)
  end

  size = distinct_changesets.count()

  puts "Processing #{size} changesets"

  distinct_changesets.each_with_index do |changeset, i|
    
    begin
      looking_for_it = changesets.find({"id"=>changeset})

      #Look for this changeset in the changeset collection.
      unless looking_for_it.has_next?
        this_changeset = changeset_api.hit_api(changeset)

        #Standardize the attributes:
        this_changeset["id_str"] = this_changeset["id"]
        this_changeset["id"]     = this_changeset["id"].to_i
        
        #Now process dates:
        this_changeset["created_at"] = osm_driver.parse_date(this_changeset["created_at"])
        this_changeset["closed_at"] = osm_driver.parse_date(this_changeset["closed_at"])

        #Now process the box:
        this_changeset["geometry"] = process_bbox this_changeset
      else
        this_changeset = looking_for_it.first
      end

      #Tell it what type of objects we're running it for
      this_changeset[options.coll] = true

      upsert_to_mongo(changesets, changeset, this_changeset)

      success_log.log(changeset)
    rescue
      fail_log.log(changeset)
      puts $!
    end
    if (i%10).zero?
      puts "Processed #{i} of #{size}"
    end
  end

  success_log.close 
  fail_log.close 
end
