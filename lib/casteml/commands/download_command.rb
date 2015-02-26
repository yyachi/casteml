require 'casteml/command'
require 'casteml'
require 'casteml/formats/xml_format'
class Casteml::Commands::DownloadCommand < Casteml::Command
	def initialize
		super 'download', 'Download casteml file from Medusa 9.  Prepare STONE-ID/ANALYSIS-ID with other tools.'

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
		"#{program_name} [options] <STONE-ID/ANALYSIS-ID>"
	end

	def description
		<<-EOS
EXAMPLE
    $ casteml download 20110518194205-602-801
    $
    $ orochi-ls 20110518194205-602-801 -R --id > demo_casteml_download.sh
    $ vi demo_casteml_download.sh
    $ sh demo_casteml_download.sh

SEE ALSO
    orochi-ls
    http://dream.misasa.okayama-u.ac.jp

IMPLEMENTATION
    Orochi, version 9
    Copyright (C) 2015 Okayama University
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
    	string = File.read(path)
    	if options[:output_format]
	    	string = Casteml.encode(Casteml::Formats::XmlFormat.decode_string(string), options)
    	end
    	say string
	end

end
