require 'casteml/command'
require 'casteml/formats/xml_format'
class Casteml::Commands::SplitCommand < Casteml::Command
	def initialize
		super 'split', 'Split one multi-pmlfile into multiple pmlfiles'

	end

	def usage
		"#{program_name} pmlfile"
	end
	def arguments
		"    pmlfile to be splited (ex. session-all.pml)"
	end

	def description
	<<-EOF
    Split one multi-pmlfile into multiple pmlfiles.  This is useful
    when you download datasets of a whole family but want to separete
    it into several files.

Example:
    $ casteml split session-all.pml
    $ ls
    stone-1.pml JB3-1.pml JB3-2.pml

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
