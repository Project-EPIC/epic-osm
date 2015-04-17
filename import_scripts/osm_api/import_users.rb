class UserImport

  require_relative 'osm_api'

  attr_reader :user_api, :success_log, :fail_log, :uids

  def initialize(limit=nil)
    @user_api = OSMAPI.new("http://api.openstreetmap.org/api/0.6/user/")

    #Open Log files
    # @success_log = LogFile.new("logs/users","successful")
    # @fail_log    = LogFile.new("logs/users","failed")

    @limit = limit
  end

  def distinct_uids
    @uids ||= get_distinct_uids
  end


  def get_distinct_uids
    uids = []
    uids = DatabaseConnection.database["nodes"].distinct("uid")
    uids += DatabaseConnection.database["ways"].distinct("uid")
    uids += DatabaseConnection.database["relations"].distinct("uid")
    uids += DatabaseConnection.database["changesets"].distinct("uid")
    if @limit.nil? 
      return uids.uniq!
    else 
      return uids.uniq!.first(@limit)
    end
  end

  def import_user_objects
    total_user_count = distinct_uids.length
    error_ids = []
    print "\n======================================\n"
    print "Importing #{total_user_count} Users: \n"
    distinct_uids.each_with_index do |user_id, index|
      #check if user exists first (Shouldn't happen...)
      user_count =  DatabaseConnection.database["users"].find({"uid" =>  user_id}).count()
      if user_count > 0
        next
      end
        
      begin
        this_user = user_api.hit_api(user_id)

        user_obj = DomainObject::User.new convert_osm_api_to_domain_object_hash this_user
        user_obj.save!
      rescue => e
        error_ids << user_id
        next
      end

      percent_done = ((index.to_f / total_user_count)*50).round
      if (percent_done)%2==0 and percent_done > 0 and percent_done < 50
        print "[#{(['*']*percent_done).join('')}#{(['.']*(50-percent_done)).join('')}] #{percent_done*2}%\r"
        $stdout.flush
      end
    end
    if error_ids.length > 0
      puts "\nError with #{error_ids.length} users.  IDS: #{error_ids.join("\n")}"
    end
  end

  def add_indexes
    print "Adding Appropriate Indexes: uid, user, account_created"
    DatabaseConnection.database['users'].ensure_index( uid: 1 )
    DatabaseConnection.database['users'].ensure_index( user: 1 )
    DatabaseConnection.database['users'].ensure_index( account_created: 1)
  end

  def convert_osm_api_to_domain_object_hash(osm_api_hash)
    data = osm_api_hash[:osm][:user]
    data[:user] = data[:display_name]
    data[:uid]  = data[:id]
    data[:account_created] = Time.parse data[:account_created]

    data.delete :display_name
    data.delete :id

    return data
  end

end
