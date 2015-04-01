module Questions # :nodoc: all

	module Notes
	    #Total notes 
	    def total_notes
	  		{'Total Notes' => aw.notes_count }
	  	end
	  	#Total Geographic Info 
	    def total_geo
	  		{'Total Notes' => aw.notes_geo}
	  	end
	end
end