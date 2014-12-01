require 'casteml/command'
require 'casteml/formats/xml_format'
class Casteml::Commands::SplitCommand < Casteml::Command
	def initialize
		super 'split', 'Split single pml-file'

	end

	def usage
		"#{program_name} PMLFILE"
	end
	def arguments
		"PMLFILE\t pmlfile to be splited (ex; session-all.pml)"
	end

	def description
		<<-EOF
NAME
    #{File.basename($0, '.*')} -   Create single PMLs from a multi PML.

SYNOPSIS
    #{File.basename($0, '.*')} [options] file

DESCRIPTION
    Create single PMLs from a multi PML.
    The split command allows you to split single pmlfile and create multiple pmlfiles.

EXAMPLE
	$ casteml split session-all.pml
	$ ls
	session-all.pml session-1.pml session-2.pml session-3.pml

SEE ALSO
    http://dream.misasa.okayama-u.ac.jp
    join

IMPLEMENTATION
    Copyright (c) 2012 ISEI, Okayama University
    Licensed under the same terms as Ruby

OPTIONS
EOF
	end


	def execute
		original_options = options.clone
		args = options.delete(:args)
		raise OptionParser::InvalidArgument.new('specify PMLFILE') if args.empty?

    	pml_path = args.shift
    	Casteml::Formats::XmlFormat.split_file(pml_path)

	end
end
