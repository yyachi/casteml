require 'casteml'
require 'casteml/command'
require 'casteml/measurement_category'
require 'erb'
class Casteml::Commands::PlotCommand < Casteml::Command
	attr_accessor :params	
	def initialize
		super 'plot', 'Generate a spider diagram from a pmlfile using R.'

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
		"#{program_name} pmlfile"
	end
	def arguments
		"    multi-pmlfile (or csv, isorg)"
	end

	def description
	<<-EOF
    Create a spider diagram from a pmlfile.  Specify pmlfile as
    argument.  Multiple stones can be plotted at the same time.
    Download pmlfiles for stones, and merge them into a single
    multiple pmlfile by command `casteml join' in advance.

    To modify the plot, revise corresponding R file then run vanilla
    R.

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

See Also:
    casteml download
    casteml join
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
