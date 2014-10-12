require 'net/http'
require 'json'
require 'pp'


class InvalidAPIError < StandardError
end

class OSMAPIHitter
	#Returns the hash payload of the input URI w.r.t API symbol.
	def self.hit_API (uris)
		puts "[START]: Hitting The OSM API for the requested URIs...."

		#Use Enumerator for lazy yielding.
		Enumerator.new do |yielder|
			i = 1
			uris.each do |api, uri_str|
				puts "[INFO]: Hitting URI: #{uri_str} (#{i} of #{uris.size})"

				case api
				when :notes
					uri = URI(uri_str)
					payload = Net::HTTP.get(uri)
				else
					raise InvalidAPIError, "[ERROR]: Invalid API specified. Choose: [:notes, ...]"
				end

				i += 1
				yielder.yield JSON.load(payload)
			end
		end
	end
end