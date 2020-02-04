require 'casteml/command'
require 'casteml'
require 'casteml/formats/xml_format'
class Casteml::Commands::DownloadCommand < Casteml::Command
	def usage
		"#{program_name} [options] ID0 [ID1 ...]"
	end

	def arguments
	<<-EOS
    ID0   ID of a record in Medusa
EOS
	end

    def initialize
	  super 'download', '    Download pmlfile from Medusa' # Summary:

	  add_option('-f', '--format OUTFORMAT',
				 'Output format (pml, csv, tsv, org, isorg, tex, pdf, dataframe)') do |v, options|
		options[:output_format] = v.to_sym
	  end

	  add_option('-r', '--descendant',
				 'Analyses with descendants of a stone') do |v|
		options[:recursive] = :self_and_descendants
	  end

	  add_option('-R', '--family',
				 'Analyses with a whole family of a stone') do |v|
		options[:recursive] = :families
	  end

	  add_option('-n', '--number-format NUMFORMAT',
				 'Number format (%.4g)') do |v, options|
		options[:number_format] = v
	  end
	end

	def description
    <<-EOS
    Download pmlfile from Medusa.  Specify ID as argument.  This
    returns pmlfiles linked to corresponding record.  Default output
    is toward to the standard output.  Redirect to certain file.

    This accepts both stone-ID, box-ID, session-ID (also referred as
    analysis-ID), bib-ID, table-ID, and image-ID.  For image-ID,
    analyses linked via spot record are returned.  For bib-ID,
    analyses directly linked to the bib record are returned.  Only for
    stone-ID and box-ID, recursive download is available.  Unless
    stone-ID or box-ID is specified, recursive option is ignored.
    Note that option '--Recursive' with box-ID takes huge amount of
    time.

    This command accept more than one ID.  Note that you can also
    obtain a multi-pmlfile for a whole family.  If you need a
    multi-pmlfile, (1) download simultaneously or (2) separately then
    join them by a command `casteml join'.

    You may want to plot the multi-pmlfile by a command `casteml
    plot'.
EOS
	end

	def example
	<<-EOS
    $ casteml download 20130528105235-594267
    ...
    $ casteml download -r 20130528105235-594267 > download.pml
    $ casteml convert download.pml -f csv > data-from-casteml.csv
    ...
    $ casteml download 20110205103129-336-399 20110203174950-308-353 > c.pml
    ...
    $ casteml download 20110205103129-336-399 > a.pml
    $ casteml download 20110203174950-308-353 > b.pml
    $ casteml join a.pml b.pml > c.pml
    ...
    $ casteml plot c.pml
    ...
    $ casteml download 20160226174711-288407 > mosaic_ok11mc.pml
    $ casteml convert mosaic_ok11mc.pml -f org > mosaic_ok11mc.isorg
EOS
	end

	def see_also
	<<-EOS
    casteml convert
    casteml join
    casteml plot
    http://dream.misasa.okayama-u.ac.jp
    https://github.com/misasa/casteml/blob/master/lib/casteml/commands/download_command.rb
EOS
	end




    def output(string)
        puts string
    end

	def execute
		original_options = options.clone
		options.delete(:build_args)
		args = options.delete(:args)
		raise OptionParser::InvalidArgument.new('specify stone-ID or analysis-ID') if args.empty?
		#id = args.shift
		options_download = {}
        paths = []
        jpath = nil
        joined = nil
        strings = []
        castemls = []
        while(id = args.shift) do
		  options_download[:recursive] = options[:recursive] if options[:recursive]
          casteml = Casteml.get(id, options_download)
          castemls << casteml
          # castemls = [casteml]
          # castemls.unshift joined if joined
          # joined = Casteml::Formats::XmlFormat.join_strings(castemls)
        end
        string = Casteml::Formats::XmlFormat.join_strings(castemls)

    	if options[:output_format]
	    	string = Casteml.encode(Casteml::Formats::XmlFormat.decode_string(string), options)
    	end
        output(string)
	end

end
