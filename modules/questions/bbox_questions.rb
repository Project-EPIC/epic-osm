module Questions

  #BBox Questions
  class Bbox < QuestionsRunner

  	#Bounding Box Geometry
  	def bbox_geometry
  		{'Bounding Box' => aw.bounding_box.inspect }
  	end
  end
end