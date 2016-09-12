require 'casteml'
require 'casteml/command'
require 'casteml/measurement_category'
require 'erb'
class Casteml::Commands::PlotCommand < Casteml::Command
	attr_accessor :params

	def usage
		"#{program_name} PMLFILE"
	end
	def arguments
	<<-EOS
    PMLFILE    A member of CASTEML file that can be either pmlfile, csvfile, or isorgfile
EOS
	end

	def initialize
		super 'plot', '    Create diagram for certein category from pmlfile using R' # Summary:

	    @params = {
#	    	:category => 'trace',
#      		:template_file => File.join(Casteml::TEMPLATE_DIR, 'plot-trace.R.erb')
      	}

		#MeasurementCategory.find_all
		category_names = Casteml::MeasurementCategory.record_pool.map{|category| "'" + category.name + "'"}
		add_option('-c', '--category CATEGORY',
						"Select template CATEGORY.R.erb and extract datasets defined in CATEGORY (#{category_names.join(', ')})") do |v, options|
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

	def description
	<<-EOF
    Create diagram for certein category from pmlfile using R.  Specify
    pmlfile as argument.  Multiple stones can be plotted at the same
    time.  Download pmlfiles for stones, and merge them into single
    multi-pmlfile by command `casteml join' in advance.  The pmlfile
    can be csvfile or isorgfile.

    This program extracts certain datasets from pmlfile, and plots
    them using template.  With option `--category CATEGORY1', datasets
    defined in CATEGORY1 on Medusa, are passed and template
    `CATEGORY1.R.erb' will be chosen.  Without option, a category
    `default' is selected.

    To add a new `CATEGORY1', create set of elements `CATEGORY1' in
    Medusa and place template `CATEGORY1.R.erb' in certain place.  As
    of May 13 (2015), the R-script should be in
    ~/orochi-devel/casteml/template/plot/.

    Do not forget to include path to R.exe such for 'c:/Program
    Files/R/R-3.2.5/bin/x64/' in %PATH%.  To modify the plot, revise
    newly generated R-script then run vanilla R.
EOF
	end

	def example
	<<-EOS
    $ casteml download -R 20130528105235-594267 > cbk.pml
    $ casteml plot cbk.pml
    $ ls
    cbk.pml cbk.dataframe cbk.R cbk.pdf
    $ vi cbk.R
    ...
    $ R --vanilla --slave < cbk.R

    $ casteml download -R 20130528105235-594267 > cbk.pml
    $ casteml plot cbk.pml --category trace
    $ ls
    cbk.pml cbk_trace.dataframe cbk_trace.R cbk_trace.pdf

    $ casteml download -R 20130528105235-594267 > cbk.pml
    $ casteml plot cbk.pml --category oxygen
    $ ls
    cbk.pml cbk_oxygen.dataframe cbk_oxygen.R cbk_oxygen.pdf
EOS
	end

	def see_also
	<<-EOS
    casteml download
    casteml join
    http://dream.misasa.okayama-u.ac.jp
    http://dream.misasa.okayama-u.ac.jp/documentation/CastemlPlot/report.pdf
EOS
	end

	def default_template(category)
        if category
    	   File.join(Casteml::TEMPLATE_DIR, "plot", "#{category}.R.erb")
        else
           File.join(Casteml::TEMPLATE_DIR, "plot", "default.R.erb")
        end
	end

    def output_dataframe(dataframe_path, dataframe)
        File.open(dataframe_path,'w') do |output|
            output.puts dataframe
        end
    end

    def output_plotfile(path, content)
        File.open(path,"w") do |plot|
            plot.puts content
        end
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
        if params[:category]
            base += "_#{params[:category]}"
        end
		dataframe_path = File.join(dir,base + ".dataframe")
		plotfile_path = File.join(dir,base + ".R")
		output_path = File.join(dir,base + ".pdf")
    	dataframe = Casteml.convert_file(path, {:output_format => :dataframe, :with_category => params[:category]})
        output_dataframe(dataframe_path, dataframe)
		# File.open(dataframe_path,'w') do |output|
		# 	output.puts dataframe
	 #    end
        #template = File.read(params[:template_file])
        template = read_template(params[:template_file])
        regexp = nil
        regexp = params[:regexp] if params[:regexp]
        acq = "5f"
        output_plotfile(plotfile_path, ERB.new(template,nil,'-',"@output").result(binding))
	    # File.open(plotfile_path,"w") do |plot|
     #    	plot.puts ERB.new(template,nil,'-',"@output").result(binding)
     #    end
        Dir.chdir(dir){
        	Casteml.exec_command("R --vanilla --slave < #{File.basename(plotfile_path)}")
        }
    	#string = Casteml.plot_file(path, options)
	end
end
