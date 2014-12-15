module Questions

  #BBox Questions
  class Bbox < QuestionsRunner

  	#Bounding Box Geometry
  	def bbox_geometry
  		{'Bounding Box' => aw.bounding_box.geometry }
  	end

  	def bbox_geojson_geometry
  		{'GeoJSON Bounding Box' => aw.bounding_box.geojson_geometry }
  	end
  end
end