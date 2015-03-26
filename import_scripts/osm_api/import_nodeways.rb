class NodeWaysImport

  require_relative 'osm_api'

  attr_reader :changeset_download_api, :nodes_download_api, :success_log, :fail_log, :changeset_ids

  def initialize(limit=nil)
    @changeset_download_api = OSMAPI.new("http://www.openstreetmap.org/api/0.6/changeset/")
    @nodes_download_api = OSMAPI.new("http://www.openstreetmap.org/api/0.6/nodes?nodes=")
  
#http://www.openstreetmap.org/api/0.6/changeset/29682572/download
#http://www.openstreetmap.org/api/0.6/nodes?nodes=3145564995,3145564994
    # #Open Log files
    # @success_log = LogFile.new("logs/changesets","successful")
    # @fail_log    = LogFile.new("logs/changesets","failed")

    @limit = limit
  end

  def new_changeset_ids
    @changeset_ids ||= get_new_changeset_ids
  end


  def get_new_changeset_ids
    changesets = []
    selector = {:complete => { '$ne' => true }}
	  opts= {:fields => {'_id' => 0, 'id' => 1 }}
    changesets = DatabaseConnection.database["changesets"].find(selector, opts).map { |changeset| changeset['id'] }
    return changesets
    if @limit.nil? 
      return changesets.uniq!
    else 
      return changesets.uniq!.first(@limit)
    end
  end

  def import_nodeways_objects
    # get changesets that haven't been downloaded
    new_changeset_ids.each_with_index do |changeset_id, index|

      begin
        this_changeset = changeset_download_api.hit_api(changeset_id + "/download")
        if this_changeset
          convert_osm_api_to_domain_object_hash this_changeset
#          changeset_obj = Changeset.new convert_osm_api_to_domain_object_hash this_changeset
#          changeset_obj.save!
        end

        if (index%10).zero?
          print '.'
        elsif (index%101).zero?
          print index
        end
      #rescue => e
      #  puts "Error on Changeset: #{changeset_id}, continuing"
      #  puts $!
      end

    end
  end

  def add_indexes
    DatabaseConnection.database['changesets'].ensure_index( id: 1 )
    DatabaseConnection.database['changesets'].ensure_index( user: 1 )
    DatabaseConnection.database['changesets'].ensure_index( geometry: "2dsphere")
  end

  def convert_osm_api_to_domain_object_hash(osm_api_hash)
    osm_api_hash.first[1].each do |change|
      if change[0] == :create or change[0] == :modify
        change[1].each do |c|
          if c.has_key?(:node)
            d = c[:node]
          elsif c.has_key?(:way)
            d = c[:way]
          else
            next
          end
          
          d[:created_at] = Time.parse d[:timestamp]
          if d[:tag].is_a? Array
            d[:tags] = d[:tag].collect{|h| {h[:k]=>h[:v]}}
          elsif d[:tag].nil?
            d[:tags] = []
          else
            d[:tags] = [ { d[:tag][:k] => d[:tag][:v] }]
          end
          d.delete :tag

          if c.has_key?(:node)
            node_obj = Node.new d
            node_obj.save!
          elsif d.has_key?(:way)
            puts d[:nd].values
            way_obj = Way.new d
            way_obj.save!
          end
        end
      end
    end
    return        
    data = osm_api_hash[:osm][:changeset]

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

