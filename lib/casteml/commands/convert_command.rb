require 'casteml'
require 'casteml/command'
require 'casteml/measurement_category'
class Casteml::Commands::ConvertCommand < Casteml::Command
	def initialize
		super 'convert', 'Convert (pml csv tsv isorg) to (pml isorg csv tsv org dataframe tex pdf)'

		add_option('-f', '--format OUTFORMAT',
						'Output format (pml csvx tsvx isorg csv tsv org dataframe tex pdf)') do |v, options|
			options[:output_format] = v.to_sym
		end

		add_option('-n', '--number-format FORMAT',
						'Number format (%.4g)') do |v, options|
			options[:number_format] = v
		end
		#MeasurementCategory.find_all
		category_names = Casteml::MeasurementCategory.find_all.map{|category| "'" + category.name + "'"}
		add_option('-c', '--category CATEGORY',
						"Only pass measurement category of (#{category_names.join(', ')})") do |v, options|
			options[:with_category] = v
		end

		# add_option('-d', '--debug', 'Show debug information') do |v|
		# 	options[:debug] = v
		# end
	end

	def usage
		"#{program_name} infile"
	end
	def arguments
		"infile(.pml .csv .tsv .isorg)"
	end

	def description
		<<-EOF
    Convert (pml csv tsv isorg)
         to (pml csv tsv isorg org dataframe tex pdf).
    The converted datasets are wrote out to standard output.  Use
    redirect to save as file.

Format:
    csv:       Comma Separated Values (CSV) supported as input.
               Each stone will be on each column.
    tsv:       Tab Separated Values (TSV) supported as input.
               Same as csv but delimiter.
    isorg:     ORG format supported as input.  Same as csvx but
               delimiter.
    dataframe: Comma Separated Values (CSV) dedicated for R input,
               not for casteml input.  Similar to csv but colum and
               row are flipped, and with single line header starts
               with `element'.  Each stone will be on each row.

Example:
    $ casteml convert my_rat_ree@150106.csv > my_rat_ree@150106.pml
    $ ls
    my_rat_ree@150106.pml
    $ casteml split my_rat_ree@150106.pml

    $ casteml convert -f tex -n %.5g my_rat_ree@150106.pml > my_rat_ree@150106.tex
    $ pdflatex my_rat_ree@150106.tex

See Also:
    casteml join
    casteml split
    casteml/spec/casteml/formats/
    http://dream.misasa.okayama-u.ac.jp

Implementation:
    Copyright (c) 2015 ISEI, Okayama University
    Licensed under the same terms as Ruby

EOF
	end

	def execute
		original_options = options.clone
		options.delete(:build_args)
		args = options.delete(:args)
		raise OptionParser::InvalidArgument.new('specify FILE') if args.empty?
    	path = args.shift

    	string = Casteml.convert_file(path, options)
    	puts string
    	#xml = Casteml::Format::XmlFormat.from_array(data)
	end
end
