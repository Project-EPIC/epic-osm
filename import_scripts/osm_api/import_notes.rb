class NoteImport
	  require_relative 'osm_api'
	  require_relative '../../epic-osm'

	  attr_reader :note_api, :bbox, :args, :success_log, :fail_log

	  def initialize(bbox,limit=nil)
	  	    @note_api = OSMAPI.new("http://api.openstreetmap.org/api/0.6/notes")
	  	    @limit = limit || 10
	  	    @args = "?bbox=" + bbox + "&limit=" + @limit.to_s
	  end

	  def import_note_objects
	  	results = note_api.hit_api(args)

	  	results[:osm][:note].each do |result|
	  		note_obj = DomainObject::Note.new convert_note_api_to_domain_object_hash result
	  		note_obj.save!
	  	end
	  end

	 def convert_note_api_to_domain_object_hash(data)
	 	data[:created_at] = Time.parse data[:date_created]
	 	data.delete :date_created
	 	return data
	 end
	end
