require 'casteml/command'
require 'casteml/formats/xml_format'
class Casteml::Commands::JoinCommand < Casteml::Command
	def usage
		"#{program_name} FILE0 FILE1 [FILE2 ...]"
	end

	def arguments
	<<-EOS
    FILE0, FILE1    pmlfiles to be joined (ex. session1.pml ... sessionN.pml)
EOS
	end

	def initialize
		super 'join', '    Join several pmlfiles to a single pmlfile' # Summary:

		add_option('-o', '--outfile OUTPUTFILE',
						'Specify output filename') do |v, options|
			options[:outfile] = v
		end
	end

	def description
    <<-EOF
    Join several pmlfiles to a single pmlfile.  Certain command such
    for `casteml plot' can only accept a single pmlfile (including
    many datesets).  Use this program to merge the pmlfiles.
EOF
	end

	def example
	<<-EOS
    $ casteml join JB1.pml stone2.pml JB3.pml > session.pml
    $ casteml join JB1.pml stone2.pml JB3.pml -o session.pml
EOS
	end

	def see_also
	<<-EOS
    casteml split
    casteml download
    http://dream.misasa.okayama-u.ac.jp
    https://github.com/misasa/casteml/blob/master/lib/casteml/commands/join_command.rb
EOS
	end



	def execute
		original_options = options.clone
		args = options.delete(:args)
		raise OptionParser::InvalidArgument.new('specify PMLFILES') if args.empty?

    	path = Casteml::Formats::XmlFormat.join_files(args)

		pml = File.read(path)
		if options[:outfile]
	        File.open(options[:outfile],'w') do |output|
	        	output.puts pml
	        end
		else
			say pml
 		end
	end
end
