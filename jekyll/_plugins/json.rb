#https://gist.github.com/joelverhagen/1850654
require "rubygems"
require "json"

module JsonFilter
  def json(input)
    input.to_json
  end
  
  Liquid::Template.register_filter self
end
