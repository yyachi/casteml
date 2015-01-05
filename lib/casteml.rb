require "casteml/version"
require 'casteml/exceptions'
require 'casteml/acquisition'
require 'casteml/formats/xml_format'
require 'casteml/formats/csv_format'
require 'casteml/formats/tex_format'
module Casteml
  # Your code goes here...
  def self.convert_file(path, opts = {})
    #opts[:type] = opts.delete(:format)
    string = encode(decode_file(path), opts)
  end


  def self.encode(data, opts = {})
    type = opts.delete(:output_format) || :pml
    case type
    when :pml
      string = Formats::XmlFormat.to_string(data, opts)
    when :csv
      string = Formats::CsvFormat.to_string(data, opts)
    when :tsv
      string = Formats::CsvFormat.to_string(data, opts.merge(:col_sep => "\t"))
    when :tex
      string = Formats::TexFormat.to_string(data, opts)      
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

  def self.file_type(path)
    ext = File.extname(path)
    ext.sub(/./,"").to_sym
  end

  def self.is_file_type?(path, type)
    file_type(path) == type
  end

  def self.is_pml?(path)
    is_file_type?(path, :pml)
  end

  def self.is_csv?(path)
    is_file_type?(path, :csv)
  end

  def self.is_tsv?(path)
    is_file_type?(path, :tsv)
  end

  def self.is_tex?(path)
    is_file_type?(path, :tex)
  end


  def self.decode_file(path)
    case File.extname(path)
    when ".pml"
  	 Formats::XmlFormat.decode_file(path)
    when ".csv", ".tsv"
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

