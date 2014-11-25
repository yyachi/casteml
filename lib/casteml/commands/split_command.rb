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
The split command allows you to split single pmlfile and create multiple pmlfiles.

Examples:
	$ casteml split session-all.pml
	$ ls
	session-all.pml session-1.pml session-2.pml session-3.pml
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
