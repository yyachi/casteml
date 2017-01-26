require "casteml/version"
require 'casteml/exceptions'
require 'tempfile'
#require 'medusa_rest_client'

#require 'casteml/acquisition'
#require 'casteml/formats/xml_format'
#require 'casteml/formats/csv_format'
#require 'casteml/formats/tex_format'
autoload(:MedusaRestClient, 'medusa_rest_client.rb')

module Enumerable
  def mean
    self.sum/self.length.to_f
  end

  def sample_variance
    m = self.mean
    sum = self.inject(0){|accum, i| accum +(i-m)**2 }
    sum/(self.length - 1).to_f
  end

  def standard_deviation
    return Math.sqrt(self.sample_variance)
  end
end

module Casteml
  autoload(:Acquisition, 'casteml/acquisition.rb')
  module Casteml::Formats
    autoload(:XmlFormat, 'casteml/formats/xml_format.rb')
    autoload(:CsvFormat, 'casteml/formats/csv_format.rb')
    autoload(:TexFormat, 'casteml/formats/tex_format.rb')
  end
  autoload(:Unit, 'casteml/unit.rb')
  autoload(:MeasurementItem, 'casteml/measurement_item.rb')
  autoload(:MeasurementCategory, 'casteml/measurement_category.rb')

  # Your code goes here
  #REMOTE_DUMP_DIR = 'remote_dump'
  LIB_DIR = File.dirname File.expand_path(__FILE__)
  GEM_DIR = File.dirname LIB_DIR
  TEMPLATE_DIR = File.join(GEM_DIR,'template')
  CONFIG_DIR = File.join(GEM_DIR,'config')
  ABUNDANCE_UNIT_FILE = File.join(CONFIG_DIR, "alchemist", "abundance.yml")

  def self.integer_string?(str)
    Integer(str)
    true
  rescue ArgumentError
    false
  end

  def self.float_string?(str)
    Float(str)
    true
  rescue ArgumentError
    false
  end

  def self.convert_file(path, options = {})
    #opts[:type] = opts.delete(:format)
    opts = {}
    if options[:with_average]
      opts[:with_average] = options[:with_average]
    end
    if options[:smash]
      opts[:smash] = options[:smash]
    end

    if options[:transpose]
      opts[:transpose] = options[:transpose]
    end
    opts[:output_format] = options[:output_format]

    if options.has_key?(:with_unit)
      if options[:with_unit]
        opts[:with_unit] = options[:with_unit]
      else
        opts[:with_unit] = 'parts'
      end
    end

    if options[:unit_separate]
      opts[:unit_separate] = options[:unit_separate]
    end


    unless opts[:output_format]
      opts[:output_format] = Casteml.is_pml?(path) ? :csv : :pml
    end

    if opts[:output_format] == :tex
      opts[:number_format] = options[:number_format] || "%.4g"
    end


    category_name = options.delete(:with_category)
    if category_name
      category = MeasurementCategory.find_by_name(category_name)
      raise "no category |#{category_name}|" unless category
      if category.unit_name
        unit = Unit.find_by_name(category.unit_name)
        opts.merge!(:with_unit => (unit && unit.text ? unit.text : category.unit_name))
      end
      opts.merge!(:with_nicknames => category.nicknames) if category && category.nicknames
    end
    string = encode(decode_file(path), opts)
  end

  def self.average(data, opts = {})
    hash_avg = Hash.new
    hash_avg[:session] = sprintf("average", data.size)
    # fmt = opts[:number_format] || '%.4g'
    # units_for_display = {:centi => 'c', :mili => 'm', :micro => 'u', :nano => 'n', :pico => 'p'}
    # fmt_opts = {:format => "$%n%u$", :units => units_for_display }
    acqs = []
    data.each do |hash|
      acqs << Casteml::Acquisition.new(hash)
    end
    nicknames = []
    acqs.each do |acq|
      nicknames.concat(acq.abundances.map(&:nickname))
      nicknames.uniq!
    end

    array_of_arrays = []

    #array_of_arrays << ["session"].concat(acqs.map{|acq| Casteml::Formats::TexFormat.escape(acq.session) })

    nicknames.each do |nickname|
      average = Hash.new
      average[:nickname] = nickname
      values = []
      acqs.each do |acq|
        ab = acq.abundance_of(nickname)
        value = ab.data_in_parts if ab && ab.data 
        #error = ab.error_in_parts if ab && ab.error 
        #text = value ? '$' + sprintf(fmt, value) + '$' : '---'
        if value
          values << value      
        end
      end
      average[:data] = values.mean
#      average[:unit] = Casteml::Formats::TexFormat.number_to_unit(values.mean)
      average[:error] = values.standard_deviation if values.size > 1
      average[:info] = values.size
      hash_avg[:abundances] ||= []
      hash_avg[:abundances] << average
    end
    hash_avg
  end


  def self.encode(data, opts = {})
    if opts[:with_average]
      avg = self.average(data)
      data << avg
    end

    if opts[:smash]
      data = [self.average(data)]
    end
    type = opts.delete(:output_format) || :pml
    case type
    when :pml, :xml
      string = Formats::XmlFormat.to_string(data, opts)
    when :csv
      string = Formats::CsvFormat.to_string(data, opts)
    when :tsv
      string = Formats::CsvFormat.to_string(data, opts.merge(:col_sep => "\t"))
    when :dataframe
      string = Formats::CsvFormat.to_string(data, opts.merge(:without_error => false, :omit_null => true, :unit_separate => true, :omit_description => true))
      string = Formats::CsvFormat.transpose(string)
      string.gsub!(/\s\(.*\)/,"")
      string.sub!(/session/,"element")
      string.sub!(/name/,"element")
      string.sub!(/element,\"\"/,"element,unit")
      string.sub!(/description.*\n/,"")      
      string.gsub!(/spot\_global\_id.*\n/,"")
      #string.sub!(/spot\_attachment\_file\_global\_id.*\n/,"")
      string.sub!(/spot\_attachment\_file\_global\_id/,"image\_id")
      #string.sub!(/spot\_attachment\_file\_path.*\n/,"")
      string.gsub!(/spot\_attachment\_file\_path/,"image\_path")
      string.gsub!(/spot\_x\_image/,"x\_image")      
      string.gsub!(/spot\_y\_image/,"y\_image")      
      string.gsub!(/spot\_x\_overpic.*\n/,"")      
      string.gsub!(/spot\_y\_overpic.*\n/,"")  
      string.gsub!(/spot\_x\_vs/,"x\_vs")      
      string.gsub!(/spot\_y\_vs/,"y\_vs")                
#      string.gsub!(/sample\_global\_id.*\n/,"")
      string.gsub!(/sample\_global\_id/,"sample\_id")      
      string.gsub!(/^global\_id.*\n/,"")
#      string.gsub!(/^global\_id/,"analysis\_id")
      string.gsub!(/device.*\n/,"")
      string.gsub!(/instrument.*\n/,"")
      string.gsub!(/analyst.*\n/,"")
      string.gsub!(/bib-ID.*\n/,"")
      string.gsub!(/stone-ID.*\n/,"")
      string.gsub!(/technique.*\n/,"")
      string.gsub!(/operator.*\n/,"")
      string.gsub!(/sample_name.*\n/,"")
      string.gsub!(/sample_description.*\n/,"")
      #puts string


    when :org, :isorg, :isoorg
      string = Formats::CsvFormat.to_string(data, opts.merge(:col_sep => "|")).gsub(/^/,"|").gsub(/\n/,"|\n")
      lines = string.split("\n")
      lines.insert(1,"|-")
      lines.unshift "#+TBLNAME: casteml"
      string = lines.join("\n")
    when :tex
      string = Formats::TexFormat.to_string(data, opts)
    when :pdf
      source = Formats::TexFormat.document do |doc|
        doc.puts Formats::TexFormat.to_string(data, opts)
      end
      string = compile_tex(source)
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

  def self.compile_tex(tex, opts = {})
      fp = Tempfile.open(["casteml-", ".tex"])
      path = fp.path
      fp.puts tex
      fp.close(false)
      basename = File.basename(path, ".tex")
      dirname = File.dirname(path)
      pdfname = basename + ".pdf"
      string = ""
      FileUtils.cd(dirname) {|dir|
        system("pdflatex #{basename}.tex > pdflatex-out")
        string = File.read(pdfname) if File.exist?(pdfname)
      }
      string
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

  def self.get(id, opts = {})
    #require 'medusa_rest_client'
    #path = MedusaRestClient::Record.casteml_path(id)
    path = MedusaRestClient::Record.element_path(id)
    dirname = File.dirname(path)
    basename = File.basename(path, ".*")
    ext = File.extname(path)
    path = "#{dirname}/#{basename}"
    recursive = opts.delete(:recursive)
    path += "/#{recursive}" if recursive
    path += ".pml"
    MedusaRestClient::Record.download_one(:from => path, :params => opts)
  end

  def self.download(id, opts = {})
    pml = get(id, opts)
    fp = Tempfile.open(["downloaded-", ".pml"])
    path = fp.path
    fp.puts pml
    fp.close(false)
    path    
  end

  def self.exec_command(command)
    exec(command)
  end

  def self.decode_file(path)
    case File.extname(path)
    when ".pml"
  	 Formats::XmlFormat.decode_file(path)
    when ".csv", ".tsv"
      Formats::CsvFormat.decode_file(path)
    when ".org", ".isorg"
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

