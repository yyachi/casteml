require "casteml/version"
require 'casteml/exceptions'
require 'casteml/acquisition'
require 'casteml/formats/xml_format'
module Casteml
  # Your code goes here...
  def self.decode_file(path)
  	Formats::XmlFormat.decode_file(path)
  end


  def self.save_remote(data)
  	case data
  	when Array
  		data.each do |attrib|
  			Acquisition.new(attrib).save_remote
  		end
  	when Hash
  		Acquisition.new(data).save_remote
  	end
  end
end

