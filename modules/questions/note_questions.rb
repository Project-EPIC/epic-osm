module Questions # :nodoc: all

	module Notes
	    #Total notes 
	    def total_notes
	  		{'Total Notes' => aw.notes_count }
	  	end
	  	#All Notes In Geojson Format 
	    def notes_geojson
	    	{ 'type' => 'FeatureCollection', 
	    	  'features' => aw.notes_geo 
	    	}
	  	end
	end
end