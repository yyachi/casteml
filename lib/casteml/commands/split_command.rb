require 'casteml/command'
require 'casteml/formats/xml_format'
class Casteml::Commands::SplitCommand < Casteml::Command
	def initialize
		super 'split', '    Split one multi-pmlfile into multiple pmlfiles' # Summary:
	end

	def usage
		"#{program_name} PMLFILE"
	end
	def arguments
	<<-EOS
    PMLFILE    pmlfile to be splited (ex. session-all.pml)
EOS
	end

	def description
	<<-EOF
    Split one multi-pmlfile into multiple pmlfiles.  This is useful
    when you download datasets of a whole family but want to separete
    it into several files.
EOF
	end

	def example
	<<-EOS
    $ casteml split session-all.pml
    $ ls
    stone-1.pml JB3-1.pml JB3-2.pml
EOS
	end

	def see_also
	<<-EOS
    casteml join
    casteml convert
    http://dream.misasa.okayama-u.ac.jp
    https://github.com/misasa/casteml/blob/master/lib/casteml/commands/split_command.rb
EOS
	end

	def execute
		original_options = options.clone
		args = options.delete(:args)
		raise OptionParser::InvalidArgument.new('specify PMLFILE') if args.empty?

    	pml_path = args.shift
    	Casteml::Formats::XmlFormat.split_file(pml_path)

	end
end
