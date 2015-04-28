class OSMTMTagsImport
		require 'net/http'
		require 'uri'
		require 'json'
	  require_relative '../../osm-history'

	  attr_reader :base_url

	  def initialize()
	      @base_url = "http://0.0.0.0:6543/projects.json"
	  end

    def hit_api
  		begin
	  		uri = URI.parse(@base_url)
	  		response = Net::HTTP.get(uri)
	  		return JSON.parse(response)
	  	rescue
	  		puts "Unsuccessful for: #{uri}"
	  		puts $!
	  		return false
	  	end
    end

	  def import_osmtm_tags
	  	results = hit_api()

      results['features'].each_with_index do |feature,index|
        changeset_tag_obj = {}

        changeset_tags = feature['properties']['changeset_comment'].split(' ')
        #get unique identifying changeset tag
        changeset_tags.each do |tag|
          tag.sub!(/,$/, '')
          if /^\#hotosm-.*?-\d*$/.match(tag)
            changeset_tag_obj[:tag] = tag
          end
        end

        if changeset_tag_obj[:tag]
          changeset_tag_obj[:name] = feature['properties']['name']
          changeset_tag = ChangesetTags.new changeset_tag_obj
          changeset_tag.save!
        end

      end
      
      #lazily not implementing atomic_update as Class method
      ChangesetTags.new( {} ).atomic_update

	  end

	end
