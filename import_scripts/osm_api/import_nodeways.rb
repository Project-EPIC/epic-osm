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
          DatabaseConnection.database["changesets"].update({:id => changeset_id}, {"$set" => {:complete => true}})
        end

        if (index%10).zero?
          print '.'
        elsif (index%101).zero?
          print index
        end
      rescue => e
        puts "Error on Changeset: #{changeset_id}, continuing"
        puts $!
      end

    end
  end

  def add_indexes
    DatabaseConnection.database['changesets'].ensure_index( id: 1 )
    DatabaseConnection.database['changesets'].ensure_index( user: 1 )
    DatabaseConnection.database['changesets'].ensure_index( geometry: "2dsphere")
  end

  def convert_osm_api_to_domain_object_hash(osm_api_hash)
    [:create, :modify].each do |action|
      if ! osm_api_hash[:osm_change][action].is_a? Array
        features = [ osm_api_hash[:osm_change][action] ]
      else
        features = osm_api_hash[:osm_change][action]
      end

      features.each do |feature_hash|
        if ! feature_hash.is_a? Hash
          return
        end
        if feature_hash.has_key?(:node)
          feature = feature_hash[:node]
        elsif feature_hash.has_key?(:way)
          feature = feature_hash[:way]
        else
          return
        end

        feature[:created_at] = Time.parse feature[:timestamp]
        if feature[:tag].is_a? Array
          feature[:tags] = feature[:tag].collect{|h| {h[:k]=>h[:v]}}
        elsif feature[:tag].nil?
          feature[:tags] = []
        else
          feature[:tags] = [ { feature[:tag][:k] => feature[:tag][:v] }]
        end
        feature.delete :tag

        if feature_hash.has_key?(:node)
          node_obj = Node.new feature
          node_obj.save!
        elsif feature_hash.has_key?(:way)
          feature[:nodes] = feature[:nd].map{ |n| n[:ref] }
          way_obj = Way.new feature
          get_missing_nodes(way_obj.get_missing_nodes())

          way_obj.save!
        end
      end
    end
  
  end

  def get_missing_nodes(nodes)
    if nodes.length() > 0
      missing_nodes = nodes_download_api.hit_api(nodes.join(','))
      if missing_nodes and missing_nodes.has_key?(:osm) and missing_nodes[:osm].has_key?(:node)
        if ! missing_nodes[:osm][:node].is_a? Array
          features = [ missing_nodes[:osm][:node] ]
        else
          features = missing_nodes[:osm][:node]
        end

        features.each do |node|
          node[:created_at] = Time.parse node[:timestamp]
          if node[:tag].is_a? Array
            node[:tags] = node[:tag].collect{|h| {h[:k]=>h[:v]}}
          elsif node[:tag].nil?
            node[:tags] = []
          else
            node[:tags] = [ { node[:tag][:k] => node[:tag][:v] }]
          end
          node.delete :tag

          node_obj = Node.new node
          node_obj.save!
        end
      end
    end
  end
end

