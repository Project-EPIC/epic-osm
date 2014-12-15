class OSMAPI

	attr_reader :parser
	def initialize(baseurl)
		require 'net/http'
		require 'uri'
		require 'nokogiri'
		require 'json'
		require 'nori'

		@base_url = baseurl

		@parser = Nori.new(:convert_tags_to => lambda { |tag| tag.gsub('@','').snakecase.to_sym } )
	end


	def hit_api(arg)
		begin
			uri = URI.parse(@base_url + arg.to_s)
			response = Net::HTTP.get(uri)
			return parser.parse(response)
		rescue
			puts "Unsuccessful for: #{uri}"
			puts $!
			return false
		end
	end
end

class LogFile # :nodoc: all
	require 'fileutils'
	def initialize(dir, filename)
		@lines = 0
		@filepath = "#{dir}/#{filename}_#{Time.now.to_s}.txt"
		FileUtils.mkdir_p(dir) unless File.exists?(dir)
		@openfile = File.open(@filepath, "wb")
	end

	def log(line)
		@lines +=1
		@openfile.write(line.to_s+"\n")
	end

	def close
		@openfile.close
		if @lines.zero?
			FileUtils.remove(@filepath)
		end
	end
end