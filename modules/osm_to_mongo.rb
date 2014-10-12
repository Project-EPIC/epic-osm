#
#
#
#
#

module OSMongoable

	#Does this function live here? Where should it be?
	def save!
			#Node_collection.insert(self.to_mongo)
	end


	module Node

		def to_mongo
			
		end

		def save!
			DB['nodes'].insert( self.to_mongo )
		end

	end



	module Way


	end


	module Relation



	end


	module User


	end


	module Changeset



	end
end