require 'casteml/command'
require 'casteml/formats/xml_format'
class Casteml::Commands::JoinCommand < Casteml::Command
	def initialize
		super 'join', 'Join multiple pml-files'

		add_option('-o', '--outfile OUTPUTFILE',
						'Specify output filename') do |v, options|
			options[:outfile] = v
		end

	end

	def usage
		"#{program_name} PMLFILES"
	end
	def arguments
		"PMLFILES\t pmlfiles to be joined (ex; session-1.pml session-2.pml ... session-n.pml)"
	end

	def description
		<<-EOF
NAME
    #{File.basename($0, '.*')} -  Create a multi PML from single PMLs.

SYNOPSIS
    #{File.basename($0, '.*')} [options] file0 [file1 ...] > file-product
    #{File.basename($0, '.*')} [options] file0 [file1 ...] -o file-product

DESCRIPTION
    Create a multi PML from single PMLs
    The join command allows you to join multiple pmlfiles and create single pmlfile.

EXAMPLE
	$ casteml join session-1.pml session-2.pml session-3.pml session-n.pml > session-all.pml
	$ casteml join session-1.pml session-2.pml session-3.pml -o session-all.pml

SEE ALSO
    http://dream.misasa.okayama-u.ac.jp
    split

IMPLEMENTATION
    Copyright (c) 2012 ISEI, Okayama University
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
