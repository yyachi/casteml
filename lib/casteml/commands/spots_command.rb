require 'casteml'
require 'casteml/command'
require 'casteml/formats/xml_format'
require 'casteml/tex_helper'
require 'erb'
#require 'casteml/tex_helper/over_pic'
class Casteml::Commands::SpotsCommand < Casteml::Command
	attr_accessor :params
	include Casteml::TexHelper

	def usage
		 "#{program_name} PMLFILE ABUNDANCE ISOTOPE"
	end

	def arguments
	<<-EOS
    PMLFILE      A member of CASTEML family that can be either pmlfile, isorgfile, or csvfile
    ABUNDANCE    Name of column with element abundance that determine dimension of isocircle
    ISOTOPE      Name of column with isotope abundance that detremine angle of thread
EOS
	end

    def initialize
		super 'spots', '    Export spots info in pmlfile to texfile' # Summary:

	    @params = {
	    	:image_width => 0.49,
	    	:scale_ab_rel_to_image_width => [10,10],
	    	:scale_iso_range_min_max => [-20,20],
      		:template_file => File.join(Casteml::TEMPLATE_DIR, 'spots.tex.erb')
      	}
        add_option("-o", "--output path", "Output filename (default: inputfile.tex)") do |v|
          options[:output_file] = v
        end

        add_option("-p", "--picture path", "Picture file (default: inputfile)") do |v|
          options[:picture_file] = v
        end
        add_option("-w", "--image-width NUM", "Image width (default: #{@params[:image_width]})") do |v|
          options[:image_width] = v
        end
        add_option("-t", "--template-file path", "Template file path (default: #{@params[:template_file]})") do |v|
          options[:template_file] = v
        end
        add_option("-a", "--scale-ab-rel-to-image-width NUM1,NUM2", Array, "Circle scale: Element abundance NUM1 in ug/g (ppm) unit will be expressed by a circle with width NUM2 in percent relative to an image (default: #{@params[:scale_ab_rel_to_image_width].join(',')})") do |v|
          if v.length != 2
			raise OptionParser::InvalidArgument.new("incorrect number of arguments for scale-ab-rel-to-image-width")
          end
          v.map!{|vv| vv.to_f}
          options[:scale_ab_rel_to_image_width] = v
        end

        add_option("-i", "--scale-iso-range-min-max NUM,NUM", Array, "Scale isotope range (default: #{params[:scale_iso_range_min_max].join(',')})") do |v|
          if v.length != 2
            raise OptionParser::InvalidArgument.new("incorrect number of arguments for scale-iso-range-min-max")
          end
          v.map!{|vv| vv.to_f}
          options[:scale_iso_range_min_max] = v
        end
	end

	def description
	<<-EOS
    Process pmlfile (created by Matlab-script `spots.m') and generate
    texfile with spots and isocircles.

    Arguments ABUNDANCE and ISOTOPE correspond to name of columns for
    element abundance and isotope abundance to draw a isocircle.

    The isocircle (formerly known as isoclock) consists of two threads
    that are arrow and tick.  Angle of arrow corresponds to isotope
    ratio defined by option `--scale-iso-range-min-max'.  Angle of
    tick corresponds to sub-integer.  Tick at 3, 6, 9, and 12 o'clock
    corresponds to xx.25, xx.50, xx.75, and xx.00.

    Note this program can take ISORG file, which is a member of CASTEML
    family.  As of October 3, 2019, ISORG file should not include columns
    with name `attachment_file_path', `x_vs', and `y_vs'.
EOS
	end

	def example
	<<-EOS
    ### demonstration for spot ###
    $ ls
    tt_bcg12@4032.jpg
    matlab>> spots   % => input spots on an imagefile
    $ ls
    tt_bcg12@4032.jpg  tt_bcg12@4032.tex  tt_bcg12@4032.pml~
    $ rm tt_bcg12@4032.tex; mv tt_bcg12@4032.pml~ tt_bcg12@4032.pml
    $ ls
    tt_bcg12@4032.jpg  tt_bcg12@4032.pml
    $ casteml spots tt_bcg12@4032.pml
    ./tt_bcg12@4032.tex writing...
    $ ls
    tt_bcg12@4032.jpg  tt_bcg12@4032.pml  tt_bcg12@4032.tex

    ### demonstration for isocircle ###
    $ ls
    tt_bcg12@4032.jpg
    matlab>> spots   % => input spots on an imagefile
    $ ls
    tt_bcg12@4032.jpg  tt_bcg12@4032.tex  tt_bcg12@4032.pml~
    $ rm tt_bcg12@4032.tex tt_bcg12@4032.pml~
    $ vi tt_bcg12@4032.isorg # => add columns with label `Li' and `d7Li'
    ...
    $ ls
    tt_bcg12@4032.jpg  tt_bcg12@4032.isorg
    $ casteml spots tt_bcg12@4032.isorg Li d7Li -a 2.1,10 -i -30,+30
    $ ls
    tt_bcg12@4032.jpg  tt_bcg12@4032.isorg  tt_bcg12@4032.tex
EOS
	end

	def see_also
	<<-EOS
    spots.m
    casteml convert
    http://dream.misasa.okayama-u.ac.jp
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
