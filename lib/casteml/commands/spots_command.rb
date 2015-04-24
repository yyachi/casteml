require 'casteml'
require 'casteml/command'
require 'casteml/formats/xml_format'
require 'casteml/tex_helper'
require 'erb'
#require 'casteml/tex_helper/over_pic'
class Casteml::Commands::SpotsCommand < Casteml::Command
	attr_accessor :params
	include Casteml::TexHelper
	def initialize
		super 'spots', 'Store pml spots info in tex file'

	    @params = {
	    	:image_width => 0.49, 
	    	:scale_ab_rel_to_image_width => [10,10], 
	    	:scale_iso_range_min_max => [-20,20],
      		:template_file => File.join(Casteml::TEMPLATE_DIR, 'spots.tex.erb')
      	}
        add_option("-o", "--output path", "Specify output filename (default: casteml-file.tex)") do |v|
          options[:output_file] = v
        end 

        add_option("-p", "--picture path", "Specify picture file (default: casteml-file)") do |v|
          options[:picture_file] = v
        end 
        add_option("-w", "--image-width NUM", "Specify image width (default: #{@params[:image_width]})") do |v|
          options[:image_width] = v
        end 
        add_option("-t", "--template-file path", "Specify template file path (default: #{@params[:template_file]})") do |v|
          options[:template_file] = v
        end 
        add_option("-a", "--scale-ab-rel-to-image-width NUM,NUM", Array, "Specify scale abundance relative to image width (default: #{@params[:scale_ab_rel_to_image_width].join(',')})") do |v|
          if v.length != 2
			raise OptionParser::InvalidArgument.new("incorrect number of arguments for scale-ab-rel-to-image-width")
          end
          v.map!{|vv| vv.to_f}
          options[:scale_ab_rel_to_image_width] = v
        end

        add_option("-i", "--scale-iso-range-min-max NUM,NUM", Array, "Specify scale isotope range (default: #{params[:scale_iso_range_min_max].join(',')})") do |v|
          if v.length != 2
            raise OptionParser::InvalidArgument.new("incorrect number of arguments for scale-iso-range-min-max")
          end
          v.map!{|vv| vv.to_f}
          options[:scale_iso_range_min_max] = v
        end

	end

	def usage
		 "#{program_name} inputfile [abundance isotope]"
	end


	def description
		<<-EOS
    Store pml spots info in tex file.  To describe your spots, create
    a pml file with spots info by using Matlab-script spots.m as of
    April 3 (2014).  Creation of tex file of spots with number or
    isocircle is shown below EXAMPLE.

Example:
    matlab> spots   # => input spots on an image file
    $ ls
    tt_bcg12@4032.pml
    $ casteml spots tt_bcg12@4032.pml
    $ ls
    tt_bcg12@4032.pml tt_bcg12@4032.tex

    ### for isocircle insertion ###
    $ casteml convert tt_bcg12@4032.pml -f csv > tt_bcg12@4032.csv
    $ ls
    tt_bcg12@4032.pml  tt_bcg12@4032.csv
    # => edit the csv file to add two columns with label Li and d7Li in Excel
    $ casteml convert tt_bcg12@4032.csv -f pml > tt_bcg12@4032.pml
    $ ls
    tt_bcg12@4032.pml  tt_bcg12@4032.csv
    $ casteml spots tt_bcg12@4032.pml Li d7Li -a 2.1,10 -i -30,+30
    $ ls
    tt_bcg12@4032.pml  tt_bcg12@4032.csv  tt_bcg12@4032.tex

See Also:
    spots.m
    http://dream.misasa.okayama-u.ac.jp

Implementation:
    Orochi, version 9
    Copyright (C) 2015 Okayama University
    License GPLv3+: GNU GPL version 3 or later

EOS
	end

	def execute
		original_options = options.clone
		options.delete(:build_args)
		argv = options.delete(:args)
		params.merge!(options)

		commandline = program_name
		case argv.size
		when 1
			flag_ab = false
			flag_iso = false
			casteml_file = argv.shift
			commandline += " #{casteml_file}"
			commandline += " --picture #{params[:picture_file]}" if params[:picture_file]
			commandline += " --output #{params[:output_file]}" if params[:output_file]
		when 2
			flag_ab = false
			flag_iso = true
			casteml_file = argv.shift
			iso_item = argv.shift  
			commandline += " #{casteml_file} #{iso_item}"
			commandline += " --picture #{params[:picture_file]}" if params[:picture_file]
			commandline += " --output #{params[:output_file]}" if params[:output_file]
			commandline += " --scale-ab-rel-to-image-width #{params[:scale_ab_rel_to_image_width].join(',')}"
			commandline += " --scale-iso-range-min-max #{params[:scale_iso_range_min_max].join(',')}"  
		when 3
			flag_ab = true
			flag_iso = true
			casteml_file = argv.shift
			ab_item = argv.shift
			iso_item = argv.shift  
			commandline += " #{casteml_file} #{ab_item} #{iso_item}"
			commandline += " --picture #{params[:picture_file]}" if params[:picture_file]
			commandline += " --output #{params[:output_file]}" if params[:output_file]
			commandline += " --scale-ab-rel-to-image-width #{params[:scale_ab_rel_to_image_width].join(',')}"
			commandline += " --scale-iso-range-min-max #{params[:scale_iso_range_min_max].join(',')}"  
		else
			raise OptionParser::InvalidArgument.new('specify PMLFILE')
		end

		commandline += " --image-width #{params[:image_width]}"
		path = File.dirname(casteml_file)
		base = File.basename(casteml_file,".*")
		picture = base      
		fileout = File.join(path,base + '.tex')

		if params[:picture_file]
			picture = params[:picture_file]
			params[:output_file] = File.join(path,File.basename(picture,".*") + ".tex") unless params[:output_file]
		end

		fileout = params[:output_file] if params[:output_file]

#      begin
        @output_file = File.open(fileout, 'w')
        template = File.read(params[:template_file])
 #       Casteml::ItemMeasured.config_file = params[:file_config]
        acquisitions = []
 
        #if is_pml?(casteml_file)
        acquisitions << Casteml.decode_file(casteml_file).map{|attrib| Casteml::Acquisition.new(attrib)}
#       # elsif is_csv_file?(casteml_file)
        #else
        #  acquisitions << Casteml::Acquisition.from_template(File.open(casteml_file))        
        #end
        acquisitions = acquisitions.flatten
        return unless acquisitions.size > 0

        # codes = Casteml::Acquisition.get_item_measureds(acquisitions).map{ |code| code }
        # Casteml::ItemMeasured.setup_data(codes)

        acquisitions.each do |acq|
          (class << acq; self; end).class_eval do
            if flag_ab
              define_method(:abundance) do
                send(:value_of, ab_item)
              end
            end
            if flag_iso
              define_method(:isotope) do
                send(:value_of, iso_item)
              end
            end
          end
        end
        imagewidth = params[:image_width].to_f
        ref_ab = params[:scale_ab_rel_to_image_width][0].to_f
        ref_relwidth = params[:scale_ab_rel_to_image_width][1].to_f
        iso_range_min = params[:scale_iso_range_min_max][0].to_f
        iso_range_max = params[:scale_iso_range_min_max][1].to_f
        # ref_width = imagewidth * ref_relwidth
        ref_width = ref_relwidth # overpic is relative anyway 2014-09-12
        puts "#{fileout} writing..."
        @output_file.puts ERB.new(template,nil,'-',"@output").result(binding)
  #    rescue => ex
  #      puts "#{ex.class}: #{ex.message}"
  #      exit
  #    end
	end

    def overpic_tag(picture, option = "width=0.99\\textwidth")
      builder =  Casteml::TexHelper::OverPic.new
      @output << "\\begin{overpic}"
      @output << "[" + option + "]"
      @output << "{" + picture  + "}"
      @output << "\n"
      yield(builder)
      @output << "\\end{overpic}\n"
    end


end
