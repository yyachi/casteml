require 'casteml'
require 'casteml/command'
require 'casteml/measurement_category'
require 'erb'
class Casteml::Commands::PlotCommand < Casteml::Command
	attr_accessor :params	
	def initialize
		super 'plot', 'Plot data.'

	    @params = {
	    	:category => 'trace',
      		:template_file => File.join(Casteml::TEMPLATE_DIR, 'plot-trace.R.erb')
      	}


		#MeasurementCategory.find_all
		category_names = Casteml::MeasurementCategory.find_all.map{|category| "'" + category.name + "'"}
		add_option('-c', '--category CATEGORY',
						"Specify measurment category (#{category_names.join(', ')}) (default: #{@params[:category]})") do |v, options|
			options[:with_category] = v
		end

        add_option("-t", "--template-file path", "Specify template file path (default: #{@params[:template_file]})") do |v|
          options[:template_file] = v
        end 


		# add_option('-d', '--debug', 'Show debug information') do |v|
		# 	options[:debug] = v
		# end
	end

	def usage
		"#{program_name} CASTEMLFILE"
	end
	def arguments
		"CASTEMLFILE\t file to be plot (ex; session-all.csv, session-all.org)"
	end

	def description
		<<-EOF
EXAMPLE
    $ casteml download -R 20130528105235-594267 > download.pml
    $ casteml plot download.pml
    $ ls
    download.pml
    download.dataframe
    download.R
    download.pdf

SEE ALSO
    http://dream.misasa.okayama-u.ac.jp
    casteml download
    casteml convert

IMPLEMENTATION
    Copyright (c) 2015 ISEI, Okayama University
    Licensed under the same terms as Ruby

EOF
	end


	def execute
		original_options = options.clone
		options.delete(:build_args)
		args = options.delete(:args)
		params.merge!(options)

		raise OptionParser::InvalidArgument.new('specify FILE') if args.empty?
    	path = args.shift
		dir = File.dirname(path)
		base = File.basename(path,".*")
		dataframe_path = File.join(dir,base + '.dataframe')
		plotfile_path = File.join(dir,base + '.R')
		output_path = File.join(dir,base + '.pdf')
    	dataframe = Casteml.convert_file(path, {:output_format => :dataframe, :with_category => params[:category]})
		File.open(dataframe_path,'w') do |output|
			output.puts dataframe
	    end
        template = File.read(params[:template_file])
        regexp = nil
        regexp = params[:regexp] if params[:regexp]
        acq = "5f"
	    File.open(plotfile_path,"w") do |plot|
        	plot.puts ERB.new(template,nil,'-',"@output").result(binding)
        end
        Dir.chdir(dir){
        	Casteml.exec_command("R --vanilla --slave < #{File.basename(plotfile_path)}")
        }
    	#string = Casteml.plot_file(path, options)
	end
end
