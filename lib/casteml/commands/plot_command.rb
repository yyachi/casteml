require 'casteml'
require 'casteml/command'
require 'casteml/measurement_category'
require 'erb'
class Casteml::Commands::PlotCommand < Casteml::Command
	attr_accessor :params	
	def initialize
		super 'plot', 'Create diagram for certein category from pmlfile using R'

	    @params = {
	    	:category => 'trace',
#      		:template_file => File.join(Casteml::TEMPLATE_DIR, 'plot-trace.R.erb')
      	}

		#MeasurementCategory.find_all
		category_names = Casteml::MeasurementCategory.find_all.map{|category| "'" + category.name + "'"}
		add_option('-c', '--category CATEGORY',
						"From pmlfile, extract only datasets of (#{category_names.join(', ')}) (default: #{@params[:category]})") do |v, options|
			options[:category] = v
		end

        # add_option("-t", "--template-file TEMPLATE_PATH", "Specify template file path (default: #{default_template(@params[:category])})") do |v|
        add_option("-t", "--template-file template.R.erb", "Specify template R-script for local development") do |v|
          options[:template_file] = v
        end 

		# add_option('-d', '--debug', 'Show debug information') do |v|
		# 	options[:debug] = v
		# end
	end

	def usage
		"#{program_name} pmlfile"
	end
	def arguments
		"    pmlfile (or csv, isorg)"
	end

	def description
	<<-EOF
    Create diagram for certein category from pmlfile using R.  Specify
    pmlfile as argument.  Multiple stones can be plotted at the same
    time.  Download pmlfiles for stones, and merge them into single
    multi-pmlfile by command `casteml join' in advance.

    This program extracts certain datasets from pmlfile, and plots
    them using template R-script.  With option `--category', datasets
    of CATEGORY, which is defined on Medusa, are passed and template
    R-script `plot-CATEGORY.R.erb' will be used.  Without option,
    CATEGORY of `trace' is selected.

    To add a new `CATEGORY1', create set of elements `CATEGORY1' in
    Medusa and template R-script `plot-CATEGORY1.R.erb' in certain
    place.  As of May 8 (2015), the R-script should be in
    orochi-devel/casteml/template/.

    To modify the plot, revise newly generated R-script then run
    vanilla R.

Example:
    $ casteml download -R 20130528105235-594267 > cbkstones.pml
    $ casteml plot cbkstones.pml
    $ ls
    cbkstones.pml
    cbkstones.dataframe
    cbkstones.R
    cbkstones.pdf
    $ vi cbkstones.R
    ...
    $ R --vanilla --slave < cbkstones.R

    $ casteml download -R 20130528105235-594267 > datasets.pml
    $ casteml plot datasets.pml --category oxygen
    $ ls
    datasets.pml
    datasets.dataframe
    datasets.R
    datasets.pdf

See Also:
    casteml download
    casteml join
    http://dream.misasa.okayama-u.ac.jp

Implementation:
    Copyright (c) 2015 ISEI, Okayama University
    Licensed under the same terms as Ruby

EOF
	end

	def default_template(category)
    	File.join(Casteml::TEMPLATE_DIR, "plot-#{category}.R.erb")
	end

	def read_template(path)
		raise "Colud not find #{path}. Specify TEMPLATE_PATH" unless File.exists?(path)
		File.read(path)
	end

	def execute
		original_options = options.clone
		options.delete(:build_args)
		args = options.delete(:args)
		params.merge!(options)
		params[:template_file] = default_template(params[:category]) unless params[:template_file]
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
        #template = File.read(params[:template_file])
        template = read_template(params[:template_file])
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
