require 'casteml/command'
require 'casteml/formats/xml_format'
class Casteml::Commands::JoinCommand < Casteml::Command
	def initialize
		super 'join', 'Join several pmlfiles to a single pmlfile'

		add_option('-o', '--outfile OUTPUTFILE',
						'Specify output filename') do |v, options|
			options[:outfile] = v
		end
	end

	def usage
		"#{program_name} file0 file1 [file2 ...] > outfile"
	end
	def arguments
		"pmlfiles to be joined (ex. session1.pml session2.pml ... sessionN.pml)"
	end

	def description
    <<-EOF
    Join several pmlfiles to a single pmlfile.  Certain command such
    for `casteml plot' can only accept a single pmlfile (including
    many datesets).  Use this program to merge the pmlfiles.

EXAMPLE
	$ casteml join JB3-1.pml stone-1.pml stone-2.pml JB3-2.pml > session.pml
	$ casteml join JB3-1.pml stone-1.pml stone-2.pml JB3-2.pml -o session.pml

SEE ALSO
    casteml split
    casteml download
    http://dream.misasa.okayama-u.ac.jp

IMPLEMENTATION
    Copyright (c) 2015 ISEI, Okayama University
    Licensed under the same terms as Ruby

OPTIONS
EOF
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
