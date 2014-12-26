require 'casteml'
require 'casteml/command'
class Casteml::Commands::ConvertCommand < Casteml::Command
	def initialize
		super 'convert', 'Convert a file into pml-file'

		add_option('-f', '--format OUTPUTFORMAT',
						'Specify output format (pml, csv, tex)') do |v, options|
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
    #{program_name} -   Convert between data files including pmlfile.

SYNOPSIS
    #{program_name} [options] file

DESCRIPTION
    Convert between data files including pmlfile.

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

OPTIONS
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
