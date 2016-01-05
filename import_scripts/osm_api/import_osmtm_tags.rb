#
# OSMTM Tags Import by Mikel Maron
#
#
class OSMTMTagsImport
		require 'net/http'
		require 'uri'
		require 'json'
	  require_relative '../../epic-osm'

	  attr_reader :base_url

	  def initialize(tag_search_term)
			  @base_url = "http://tasks.hotosm.org/projects.json?sort_by=priority&direction=asc&search=#{tag_search_term}"
	  end

    def hit_api
  		begin
				puts base_url
	  		uri = URI.parse(base_url)
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
          changeset_tag = DomainObject::ChangesetTags.new changeset_tag_obj
          changeset_tag.save!
        end

      end
			#
      # #lazily not implementing atomic_update as Class method
      # DomainObject::ChangesetTags.new( {} ).atomic_update

	  end

	end
