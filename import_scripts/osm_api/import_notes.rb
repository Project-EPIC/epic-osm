class NoteImport
	  require_relative 'osm_api'
	  require_relative '../../osm-history'


	  attr_reader :note_api, :bbox, :args, :success_log, :fail_log

	  def initialize(bbox, limit=nil)
	  	    @note_api = OSMAPI.new("http://api.openstreetmap.org/api/0.6/notes")
	  	    @args = "?bbox=" + bbox
	  	    #TODO: Logs	
	  	    @limit = limit
	  end

	  def import_note_objects
	  	results = note_api.hit_api(args)

	  	results[:osm][:note].each do |result|
	  		note_obj = Note.new result #convert_note_api_to_domain_object_hash(result)
	  		note_obj.save!
	  	end
	  end

	  def convert_note_api_to_domain_object_hash(note_api_hash)
	  	data = note_api_hash
	  	## do stuff
	  	return data
	  end
	end