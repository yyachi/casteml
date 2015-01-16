require 'casteml/command'
class Casteml::Commands::DownloadCommand < Casteml::Command
	def initialize
		super 'download', 'Download pml-file'

		add_option('-f', '--format OUTPUTFORMAT',
						'Specify output format (pml, csv, tsv, org, isorg, tex, pdf)') do |v, options|
			options[:output_format] = v.to_sym
		end

		add_option('-n', '--number-format NUMBERFORMAT',
						'Specify number format (%.4g)') do |v, options|
			options[:number_format] = v
		end		
	end

	def usage
		"#{program_name} [options] <STONE-/ANALYSIS-ID>"
	end

	def description
		<<-EOS
NAME
    #{program_name} -    Download pml file from Medusa

SYNOPSIS
    #{program_name} [options] <STONE-/ANALYSIS-ID>

OPTIONS
    -f, --format        OUTPUTFORMAT: {pml, csv, tsv, org, isorg, tex, pdf}
    -h, --help          Get help on this command
    Below is only available when OUTPUTFORMAT is tex
    -n, --number-format NUMBERFORMAT: {%.4g}

DESCRIPTION
    Download pml file from Medusa.

EXAMPLE
    casteml download 20110518194205-602-801
SEE ALSO
    http://dream.misasa.okayama-u.ac.jp

IMPLEMENTATION
    Orochi, version 9
    Copyright (C) 2014 Okayama University
    License GPLv3+: GNU GPL version 3 or later

EOS
	end

	def execute
		original_options = options.clone
		options.delete(:build_args)
		args = options.delete(:args)
		raise OptionParser::InvalidArgument.new('specify stone-ID or analysis-ID') if args.empty?
		id = args.shift
    	#pml = Casteml.get(id, options)
    	opts = {}
    	path = Casteml.download(id, opts)
    	if options[:output_format]
	    	string = Casteml.convert_file(path, options)
    	else
    		string = File.read(path)
    	end
    	say string
	end

end