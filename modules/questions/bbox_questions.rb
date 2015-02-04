module Questions # :nodoc: all

  #BBox Questions
  module Bbox

  	#Bounding Box Geometry
  	def bbox_geometry
  		{'Bounding Box' => aw.bounding_box.geometry }
  	end

  	#Returns the geometry of the bounding box as valid geojson
  	def bbox_geojson_geometry
  		aw.bounding_box.geojson_geometry
  	end
  end
end