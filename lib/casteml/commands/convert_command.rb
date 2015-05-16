require 'casteml'
require 'casteml/command'
require 'casteml/measurement_category'
class Casteml::Commands::ConvertCommand < Casteml::Command
	def initialize
		super 'convert', 'Convert from/to pml, csv, tsv, org, isorg, tex, pdf, and dataframe'

		add_option('-f', '--format OUTFORMAT',
						'Output format (pml, csv, tsv, org, isorg, tex, pdf, dataframe)') do |v, options|
			options[:output_format] = v.to_sym
		end

		add_option('-n', '--number-format FORMAT',
						'Number format (%.4g)') do |v, options|
			options[:number_format] = v
		end
		#MeasurementCategory.find_all
		category_names = Casteml::MeasurementCategory.find_all.map{|category| "'" + category.name + "'"}
		add_option('-c', '--category CATEGORY',
						"Only pass measurement category of(#{category_names.join(', ')})") do |v, options|
			options[:with_category] = v
		end

		# add_option('-d', '--debug', 'Show debug information') do |v|
		# 	options[:debug] = v
		# end
	end

	def usage
		"#{program_name} file0"
	end
	def arguments
		"    file0                Input file with extention (pml, csv, tsv, org, isorg)"
	end

	def description
		<<-EOF
    Convert from/to pml, csv, tsv, org, isorg, tex, pdf, and
    dataframe.  The converted datasets are wrote out to standard
    output.  Use redirect to save as file.

Example:
    $ casteml convert my_rat_ree@150106.csv > my_rat_ree@150106.pml
    $ ls
    my_rat_ree@150106.pml
    $ casteml split my_rat_ree@150106.pml

    $ casteml convert -f tex -n %.5g  my_rat_ree@150106.pml > my_rat_ree@150106.tex
    $ pdflatex my_rat_ree@150106.tex

See Also:
    casteml join
    casteml split
    http://dream.misasa.okayama-u.ac.jp

Implementation:
    Copyright (c) 2015 ISEI, Okayama University
    Licensed under the same terms as Ruby

EOF
	end

	def execute
		original_options = options.clone
		options.delete(:build_args)
		args = options.delete(:args)
		raise OptionParser::InvalidArgument.new('specify FILE') if args.empty?
    	path = args.shift

    	string = Casteml.convert_file(path, options)
    	puts string
    	#xml = Casteml::Format::XmlFormat.from_array(data)
	end
end
