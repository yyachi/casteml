require "casteml/version"
require 'casteml/exceptions'
require 'casteml/acquisition'
require 'casteml/formats/xml_format'
require 'casteml/formats/csv_format'
module Casteml
  # Your code goes here...
  def self.convert_file(path)
    string = encode(decode_file(path))
  end


  def self.encode(data, opts = {})
    type = opts.delete(:type) || :pml
    case type
    when :pml
      string = Formats::XmlFormat.to_string(data, opts)
    when :csv
      string = Formats::CsvFormat.to_string(data, opts)      
    else
      raise "not implemented"
    end
    string
    # doc = Formats::XmlFormat.from_array(data)
    # fp = StringIO.new
    # Formats::XmlFormat.write(doc, fp)
    # fp.close
    # fp.string
  end

  def self.decode_file(path)
    case File.extname(path)
    when ".pml"
  	 Formats::XmlFormat.decode_file(path)
    when ".csv"
      Formats::CsvFormat.decode_file(path)
    else
      raise "not implemented"
    end
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

