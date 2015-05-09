class ChangesetImport

  require_relative 'osm_api'

  attr_reader :changeset_api, :success_log, :fail_log, :changeset_ids, :limit

  def initialize(limit=nil)
    @changeset_api = OSMAPI.new("http://api.openstreetmap.org/api/0.6/changeset/")
    @limit = limit
  end

  def distinct_changeset_ids
    @changeset_ids ||= get_distinct_changeset_ids
  end


  def get_distinct_changeset_ids
    changesets = []
    changesets = DatabaseConnection.database["nodes"].find.distinct("changeset")
    changesets += DatabaseConnection.database["ways"].find.distinct("changeset")
    changesets += DatabaseConnection.database["relations"].find.distinct("changeset")
    if limit.nil?
      return changesets.uniq!
    else
      return changesets.uniq!.first(limit)
    end
  end

  def import_changeset_objects
    distinct_changeset_count = distinct_changeset_ids.length
    puts "Importing #{distinct_changeset_count} changesets: "
    error_changesets = []
    distinct_changeset_ids.each_with_index do |changeset_id, index|
      begin
        this_changeset = changeset_api.hit_api(changeset_id)
        if this_changeset
          changeset_obj = DomainObject::Changeset.new convert_osm_api_to_domain_object_hash this_changeset
          changeset_obj.save!({pbf: true})
        end

        percent_done = ((index.to_f / distinct_changeset_count)*100).round
        if (percent_done)%2==0 and percent_done > 0 and percent_done < 100
          print "[#{(['*']*(percent_done/2)).join('')}#{(['.']*(50-percent_done/2)).join('')}] #{percent_done}%\r"
          $stdout.flush
        end
      rescue => e
        puts "X: #{changeset_id}"
        print e
        error_changesets << changeset_id
      end
    end
    if error_changesets.length > 0
      puts "\nError with #{error_changesets.length} Changesets.  IDS: #{error_changesets.join("\n")}"
    end
  end

  def add_indexes
    print "Adding Appropriate Indexes: id, uid, user, created_at, closed_at, geometry"
    DatabaseConnection.database['changesets'].indexes.create_many(
      [
				{ :key => { geometry:   '2dsphere'}},
				{ :key => { created_at: 1         }},
        { :key => { closed_at:  1         }},
				{ :key => { uid:        1         }},
				{ :key => { user:       1         }},
			])
  end

  def convert_osm_api_to_domain_object_hash(osm_api_hash)
    data = osm_api_hash[:osm][:changeset]

    data[:created_at] = Time.parse data[:created_at]
    data[:closed_at] = Time.parse data[:closed_at]

    if data[:tag].is_a? Array
      data[:tags] = data[:tag].collect{|h| {h[:k]=>h[:v]}}
    elsif data[:tag].nil?
      data[:tags] = []
      return data
    else
      data[:tags] = [ { data[:tag][:k] => data[:tag][:v] }]
    end
    data.delete :tag

    #Only have data[:tag], and it's an ARRAY! Look for a key of comment
    comment_index = data[:tags].index{|h| h.has_key? "comment" }

    unless comment_index.nil?
      data[:comment] = data[:tags].delete_at(comment_index)["comment"]
    else
      data[:comment] = ""
    end
    return data
  end

end
