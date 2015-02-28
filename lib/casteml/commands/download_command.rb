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

		add_option('-r', '--recursive', 
						'Output descendants analyses together') do |v|
			options[:recursive] = :descendants
		end

		add_option('-R', '--Recursive', 
						'Output families analyses together') do |v|
			options[:recursive] = :families
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
    $ mkdir chunk_CBK-1
    $ cd chunk_CBK-1
    $ casteml download -r descendants 20130528105235-594267 > data-from-casteml.pml
    $ casteml convert data-from-casteml.pml -f csv > data-from-casteml.csv    
    #$ for i in `orochi-ls --id -R 20130528105235-594267`; do casteml download $i > $i.pml; done
    #$ casteml join *.pml > data-from-casteml.pml
    #$ casteml convert data-from-casteml.pml -f csv > data-from-casteml.csv

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
		options_download = {}
		options_download[:recursive] = options[:recursive] if options[:recursive]
    	path = Casteml.download(id, options_download)
    	string = File.read(path)
    	if options[:output_format]
	    	string = Casteml.encode(Casteml::Formats::XmlFormat.decode_string(string), options)
    	end
    	say string
	end

end
