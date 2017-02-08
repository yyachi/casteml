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
						'Output format (pml csv tsv org isorg dataframe dflame tex pdf)') do |v, options|
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

    add_option('-p', '--place',
            'Output with place') do |v, options|
      options[:with_place] = v
    end


    # add_option('-e', '--error',
    #         'Output with error') do |v, options|
    #   options[:with_error] = v
    # end
		# add_option('-d', '--debug', 'Show debug information') do |v|
		# 	options[:debug] = v
		# end
	end

	def description
		<<-EOF
    Convert (pml csv tsv isorg)
         to (pml csv tsv isorg dataframe tex pdf).
    The converted datasets are written out to standard output.  Use
    redirect to save as file.

    See how pmlfile with analysis looks like by following command.
    $ casteml download 20081202172326.hkitagawa > 20081202172326.pml
    $ casteml convert 20081202172326.pml | head
    $ open http://database.misasa.okayama-u.ac.jp/stone/bibs/8.pml

    See how pmlfile with analysis and spot looks like by following command.
    $ casteml download 20160923194512-900008 > 20160923194512-900008.pml
    $ casteml convert 20160923194512-900008.pml | head
    $ open http://database.misasa.okayama-u.ac.jp/stone/attachment_files/48326.pml

    This program relays on gem-package alchemist.  As of February
    2017, the alchemist cannot handle wt%.  Use % or cg/g instead.

Format:
    pml:       The standard CASTEML file.
    csv:       Comma Separated Values (CSV) supported as input.
               Each stone and chem is on each row and column, respectively.

               A column of chem can be accompanied by a column of
               error of the chem.  Name of the column should be with
               `_error' (ie, `SiO2_error' for `SiO2').

               A column of chem can be accompanied by unit.  Unit of
               the column should be specified in parenthesis following
               the name of chem (ie, `SiO2 (wt%)' instead of `SiO2').
               See `text' column of list in
               `http://medusa-uri/app/units'.  Instead, you can use
               the dedicated second row (or line) for unit.  LABEL of
               row (or line) SHOULD BE EMPTY.

               You can completely flip row and column.
    tsv:       Tab Separated Values (TSV) supported as input.
               Same as csv but delimiter.
    isorg:     ORG format supported as input.
               Same as csv but delimiter.
    dataframe: Comma Separated Values (CSV) dedicated for R input, not
               for casteml input.  Similar to CSV but column and row
               are flipped.  The first line is header that starts with
               `element'.  Each stone and chem is on each column and
               row, respectively but the second column is dedicated for
               unit with colname `unit'.
   tex:        Text of table dedicated for LaTeX input.  Define label used for
               convertion at `http://medusa-uri/app/measurement_items'.  You have
               to clear local cache by `casteml --refresh'.
   pdf:        PDF with table that is created based on output with '-f tex' option.
EOF
	end

	def example
	<<-EOS
    $ casteml download 20081202172326.hkitagawa > 20081202172326.pml
    $ casteml convert 20081202172326.pml > 20081202172326.csv
    $ casteml convert -f csv --unit '%' 20081202172326.pml > 20081202172326.csv
    $ casteml convert -f csv --unit 'cg/g' 20081202172326.pml > 20081202172326.csv
    $ casteml convert -f csv --no-unit 20081202172326.pml > 20081202172326.csv
    $ casteml convert -f tex -n %.5g 20081202172326.pml > 20081202172326.tex
    $ casteml convert -f dataframe 20081202172326.pml > 20081202172326.dataframe

    R> dffile <- '20081202172326.dataframe'
    R> df0    <- read.csv(dffile,row.names=1,header=T,stringsAsFactors=F)
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
