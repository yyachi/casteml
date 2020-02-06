require 'casteml'
require 'casteml/command'
require 'casteml/user_interaction'

class Casteml::CommandManager
	include Casteml::UserInteraction

	attr_accessor :program_name
	BUILTIN_COMMANDS = [
						:download,
						:join,
						:split,
						:upload,
						:convert,
						:spots,
						:plot,
						# :help,
	]
	def self.instance
		@command_manager ||= new
	end

	def self.clear_instance
		@command_manager = nil
	end

	def instance
		self
	end

	def initialize
		@commands = {}
		@options = {}
		@program_name = "casteml"
		BUILTIN_COMMANDS.each do |name|
			register_command name
		end
	end

	def register_command(command, obj=false)
		@commands[command] = obj
	end

	def command_names
		@commands.keys.collect {|key| key.to_s}.sort
	end

	def run(args, build_args=nil)
		process_args(args, build_args)
	end

	def parse_options

	end

	def options
		@options || {}
	end

	def opts
		@opts ||= OptionParser.new do |opts|
			opts.banner = "Casteml is a suite of comprehensive utilities for CASTEML.  This is
a basic help message containing pointers to more information.

"
			opts.define_head "Usage:
    casteml --help
    casteml [options...]
    casteml command [arguments...] [options...]"
			opts.separator ""
			opts.separator "Command:"
            opts.separator "    #{BUILTIN_COMMANDS.join('
    ')}"
			opts.separator ""
			opts.separator "Further help:"
            opts.separator "    casteml #{BUILTIN_COMMANDS.join(' --help
    casteml ')} --help"
			# opts.separator "    casteml command --help"
			opts.separator ""
			opts.separator "Description:"
			opts.separator "    casteml download - Download pmlfile from Medusa"
			opts.separator "    casteml join - Join several pmlfiles to a single pmlfile"
			opts.separator "    casteml split - Split one multi-pmlfile into multiple pmlfiles"
			opts.separator "    casteml upload - Upload a pmlfile to Medusa"
			opts.separator "    casteml convert - Convert (pml csv tsv isorg) to (pml csv tsv isorg dflame tex pdf)"
			opts.separator "    casteml spots - Export spots info in pmlfile to texfile"
			opts.separator "    casteml plot - Create diagram for certein category from pmlfile using R"
			opts.separator ""
			opts.separator "See also:"
			opts.separator "    http://dream.misasa.okayama-u.ac.jp"
			opts.separator "    https://github.com/misasa/casteml/blob/master/lib/casteml/command_manager.rb"
			opts.separator ""
			opts.separator "Examples:"
			opts.separator "    casteml join --help"
			opts.separator "    casteml join session-1.pml session-2.pml session-3.pml"
			opts.separator "    casteml split session-all.pml"
			opts.separator "    casteml spots --help"
			opts.separator "    casteml spots liso_pig_nwa2376.isorg Li d7Li -a 1.0,4.0 -i -16,8"
			opts.separator "    casteml casteml convert -f tex my_rat_ree.pml >  my_rat_ree.tex"
			opts.separator ""
			opts.separator "Option:"

			opts.on_tail("-?", "--help", "Show this message") do |v|
				@options[:help] = v
			end

			opts.on_tail("-v", "--[no-]verbose", "Run verbosely") do |v|
				@options[:verbose] = v
			end

			#opts.on_tail("-d", "--[no-]debug", "Show debug info") do |v|
			#	@options[:debug] = v
			#end

			opts.on_tail("-V", "--version", "Show version") do |v|
				@options[:version] = v
			end

			opts.on_tail("-R", "--refresh", "Refresh cache files") do |v|
				@options[:refresh] = v
			end

		end
	end

	def usage
		"casteml"
	end

	def show_help
		opts.program_name = usage
		say opts
	end

    def refresh_cache
#    	say "remote_dump refreshing..."
		klasses = [Casteml::Unit, Casteml::MeasurementItem, Casteml::MeasurementCategory]
	    klasses.each do |klass|
      		dump_path = klass.dump_path
#        	say "#{dump_path} is removing..."
        	FileUtils.rm(dump_path) if File.exist?(dump_path)
	    	say "#{dump_path} is generating..."
    		klass.dump_all
      	end
    end

    def refresh_abundance_unit_file
      	say "#{Casteml::ABUNDANCE_UNIT_FILE} is generating..."
    	Casteml::Unit.refresh_abundance_unit_file
    end

	def show_version
		say "version: #{Casteml::VERSION}"
		say <<EOF
configuration:
  alchemist: #{Casteml::ABUNDANCE_UNIT_FILE}
  cache files:
   #{Casteml::Unit.dump_path}
   #{Casteml::MeasurementItem.dump_path}
   #{Casteml::MeasurementCategory.dump_path}

To update configuration, revise at Medusa and issue `casteml --refresh' locally.
When still conversion does not work as expected, re-install gem `alchemist'.
EOF
	end

	def process_args(args, build_args=nil)
		opts.order!(args)

		if options[:help] then
			show_help
			exit
		elsif options[:version] then
			show_version
			exit
		elsif options[:refresh] then
			refresh_cache
			refresh_abundance_unit_file
			exit
		elsif args.empty?
			show_help
			exit
		else
			cmd_name = args.shift.downcase
		end
		cmd = find_command cmd_name
		cmd.invoke_with_build_args args, build_args
	rescue OptionParser::InvalidOption => ex
		alert_error "#{ex}. See '#{program_name} --help'."
	rescue Casteml::CommandLineError => ex
		alert_error "#{ex}. See '#{program_name} --help'."
	end

	def [](command_name)
		command_name = command_name.intern
		return nil if @commands[command_name].nil?
		@commands[command_name] ||= load_and_instantiate(command_name)
	end

	def find_command(cmd_name)
		#len = cmd_name.length
		#found = command_names.select{ |name| cmd_name == name[0, len] }
		exact = command_names.find{ |name| name == cmd_name }
		raise Casteml::CommandLineError, "Unknown command #{cmd_name}" unless exact
		self[exact]
	end

	private
	def load_and_instantiate(command_name)
		command_name = command_name.to_s
		const_name = command_name.capitalize.gsub(/_(.)/) { $1.upcase } << "Command"
		require "casteml/commands/#{command_name}_command"
		Casteml::Commands.const_get(const_name).new
	end
end
