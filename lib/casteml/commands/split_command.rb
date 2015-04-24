require 'casteml/command'
require 'casteml/formats/xml_format'
class Casteml::Commands::SplitCommand < Casteml::Command
	def initialize
		super 'split', 'Split a single pmlfile into multiple pmlfiles'

	end

	def usage
		"#{program_name} PMLFILE"
	end
	def arguments
		"    pmlfile to be splited (ex; session-all.pml)"
	end

	def description
		<<-EOF
    Split a single pmlfile into multiple pmlfiles

Example:
    $ casteml split session.pml
    $ ls
    stone-1.pml stone-2.pml JB3-1.pml JB3-2.pml

See Also:
    casteml join
    casteml convert
    http://dream.misasa.okayama-u.ac.jp

Implementation:
    Copyright (c) 2015 ISEI, Okayama University
    Licensed under the same terms as Ruby

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
