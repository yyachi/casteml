require 'casteml'
require 'casteml/command'
require 'casteml/measurement_category'
class Casteml::Commands::ConvertCommand < Casteml::Command
	def usage
		"#{program_name} INFILE"
	end

	def arguments
	<<-EOS
    INFILE    Input file with extension (.pml .csv .tsv .isorg)
EOS
	end
    def initialize
		super 'convert', '    Convert (pml csv tsv isorg) to (pml csv tsv org isorg dataframe tex pdf)' # Summary:

		add_option('-f', '--format OUTFORMAT',
						'Output format (pml csv tsv org isorg dataframe tex pdf)') do |v, options|
			options[:output_format] = v.to_sym
		end

		add_option('-n', '--number-format FORMAT',
						'Number format (%.4g)') do |v, options|
			options[:number_format] = v
		end
		# MeasurementCategory.find_all
		category_names = Casteml::MeasurementCategory.record_pool.map{|category| "'" + category.name + "'"}
		add_option('-c', '--category CATEGORY',
						"Only pass measurement category of (#{category_names.join(', ')})") do |v, options|
			options[:with_category] = v
		end

		add_option('-t', '--transpose',
						'Transpose row and column on output format (csv tsv org isorg tex)') do |v, options|
			options[:transpose] = v
		end

		add_option('-a', '--average',
						'Output with average') do |v, options|
			options[:with_average] = v
		end

		add_option('-s', '--smash',
						'Only output average') do |v, options|
			options[:smash] = v
		end

		add_option('--[no-]unit [UNIT]',
						'Specify unit on output format (csv tsv org isorg)') do |v, options|
			options[:with_unit] = v
		end
		# add_option('-d', '--debug', 'Show debug information') do |v|
		# 	options[:debug] = v
		# end
	end

	def description
		<<-EOF
    Convert (pml csv tsv isorg)
         to (pml csv tsv isorg dataframe tex pdf).
    The converted datasets are wrote out to standard output.  Use
    redirect to save as file.

Format:
    pml:       The standard CASTEML file.
    csv:       Comma Separated Values (CSV) supported as input.
               Each stone and chem is on each row and col, respectively.
               You can have a second row dedicated for unit without rowname.
    tsv:       Tab Separated Values (TSV) supported as input.
               Same as csv but delimiter.
    isorg:     ORG format supported as input.
               Same as csv but delimiter.
    dataframe: Comma Separated Values (CSV) dedicated for R input,
               not for casteml input.  Similar to csv but column and
               row are flipped.  The first line is header that starts
               with `element'.  Each stone and chem is on
               each row and column, respectively.  Second column
               is dedicated for unit with colname `unit'.
   tex:        Text of table dedicated for LaTeX input.
   pdf:        PDF with table that is created based on output with '-f tex' option.
EOF
	end

	def example
	<<-EOS
    $ casteml convert ratree@150106.csv > ratree@150106.pml
    $ casteml convert -f tex -n %.5g ratree@150106.pml > ratree@150106.tex
    $ casteml convert -f csv --unit '%' ratree@150106.pml > ratree@150106.csv
    $ casteml convert -f csv --unit 'cg/g' ratree@150106.pml > ratree@150106.csv
    $ casteml convert -f csv --no-unit ratree@150106.pml > ratree@150106.csv

    R> dffile <- '20080616170000.dataframe'
    R> df0    <- t(read.csv(dffile,row.names=1,header=T,stringsAsFactors=F))
EOS
	end

	def see_also
	<<-EOS
    casteml join
    casteml split
    casteml/spec/casteml/formats/
    http://dream.misasa.okayama-u.ac.jp
EOS
	end




	def output(string)
		puts string
	end

	def execute
		original_options = options.clone
		options.delete(:build_args)
		args = options.delete(:args)
		raise OptionParser::InvalidArgument.new('specify FILE') if args.empty?
    	path = args.shift

    	string = Casteml.convert_file(path, options)
    	output(string)
    	#puts string
    	#xml = Casteml::Format::XmlFormat.from_array(data)
	end
end
