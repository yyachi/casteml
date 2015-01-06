require 'casteml'
require 'casteml/command'
class Casteml::Commands::ConvertCommand < Casteml::Command
	def initialize
		super 'convert', 'Convert pmlfile to datafile with different format.'

		add_option('-f', '--format OUTPUTFORMAT',
						'Specify output format (pml, csv, tsv, tex)') do |v, options|
			options[:output_format] = v.to_sym
		end

		add_option('-n', '--number-format NUMBERFORMAT',
						'Specify number format (%.4g)') do |v, options|
			options[:number_format] = v
		end

	end

	def usage
		"#{program_name} FILE"
	end
	def arguments
		"FILE\t file to be converted (ex; session-all.csv)"
	end

	def description
		<<-EOF
NAME
    #{program_name} -   Convert a {pml, csv, tsv} file in different format.

SYNOPSIS
    #{program_name} [options] filein

OPTIONS
    -f, --format        OUTPUTFORMAT: {pml, csv, tsv, tex}
    -h, --help          Get help on this command
    Below is only available when OUTPUTFORMAT is tex
    -n, --number-format NUMBERFORMAT: {%.4g}

DESCRIPTION
    Convert a {pml, csv, tsv} file in different format.

EXAMPLE
    $ casteml convert  MY_RAT_REEONLY@150106.csv >  MY_RAT_REEONLY@150106.pml
    $ ls
    MY_RAT_REEONLY@150106.pml

    $ casteml convert -f tex -n %.5g  MY_RAT_REEONLY@150106.pml >  MY_RAT_REEONLY@150106.tex
    $ pdflatex MY_RAT_REEONLY@150106.pml.tex

    $ casteml split MY_RAT_REEONLY@150106.pml

SEE ALSO
    http://dream.misasa.okayama-u.ac.jp
    casteml join
    casteml split

IMPLEMENTATION
    Copyright (c) 2014 ISEI, Okayama University
    Licensed under the same terms as Ruby

EOF
	end


	def execute
		original_options = options.clone
		options.delete(:build_args)
		args = options.delete(:args)
		raise OptionParser::InvalidArgument.new('specify FILE') if args.empty?
    	path = args.shift

		unless options[:output_format]
			options[:output_format] = Casteml.is_pml?(path) ? :csv : :pml
		end

		if options[:output_format] == :tex
			options[:number_format] = "%.4g" unless options[:number_format]
		end

    	string = Casteml.convert_file(path, options)
    	puts string
    	#xml = Casteml::Format::XmlFormat.from_array(data)
	end
end
