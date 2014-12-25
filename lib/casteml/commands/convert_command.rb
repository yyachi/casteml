require 'casteml'
require 'casteml/command'
class Casteml::Commands::ConvertCommand < Casteml::Command
	def initialize
		super 'convert', 'Convert a file into pml-file'

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
    	string = Casteml.convert_file(path)
    	puts string
    	#xml = Casteml::Format::XmlFormat.from_array(data)
	end
end
