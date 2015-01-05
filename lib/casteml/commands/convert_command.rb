require 'casteml'
require 'casteml/command'
class Casteml::Commands::ConvertCommand < Casteml::Command
	def initialize
		super 'convert', 'Convert pmlfile to datafile with different format.'

		add_option('-f', '--format OUTPUTFORMAT',
						'Specify output format (pml, csv, tsv, tex)') do |v, options|
			options[:format] = v
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
    #{program_name} -   Convert pmlfile to datafile with different format.

SYNOPSIS
    #{program_name} [options] filein

OPTIONS
    -f, --format OUTPUTFORMAT: {pml, csv, tsv, tex}

DESCRIPTION
    Convert pmlfile to datafile with different format.  #{program_name} accepts {pml, csv, tsv}.

EXAMPLE
    $ casteml convert session.csv > session.pml
    $ ls
    session.pml
    $ casteml split session.pml

    $ casteml convert -f tex session.csv > session.tex
    $ pdflatex session.tex

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
		args = options.delete(:args)
		raise OptionParser::InvalidArgument.new('specify FILE') if args.empty?
    	path = args.shift
		oformat = options.delete(:format)
		unless oformat
			oformat = Casteml.is_pml?(path) ? :csv : :pml
		end
    	string = Casteml.convert_file(path, :format => oformat.to_sym)
    	puts string
    	#xml = Casteml::Format::XmlFormat.from_array(data)
	end
end
