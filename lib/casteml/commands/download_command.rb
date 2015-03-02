require 'casteml/command'
require 'casteml'
require 'casteml/formats/xml_format'
class Casteml::Commands::DownloadCommand < Casteml::Command
	def initialize
		super 'download', 'Download casteml file from Medusa 9.'

		add_option('-f', '--format OUTPUTFORMAT',
						'Specify output format (pml, csv, tsv, org, isorg, tex, pdf)') do |v, options|
			options[:output_format] = v.to_sym
		end

		add_option('-r', '--recursive', 
						'Have analyses with descendants of a stone') do |v|
			options[:recursive] = :self_and_descendants
		end

		add_option('-R', '--Recursive', 
						'Have analyses with a whole family of a stone') do |v|
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
    $ casteml download -r 20130528105235-594267 > download.pml
    $ casteml convert download.pml -f csv > data-from-casteml.csv    

SEE ALSO
    casteml convert
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
