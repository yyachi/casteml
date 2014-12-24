require 'casteml'
require 'casteml/command'
require 'casteml/user_interaction'

class Casteml::CommandManager
	include Casteml::UserInteraction

	attr_accessor :program_name
	BUILTIN_COMMANDS = [
						:join,
						:split,
						:upload,
						:convert,
						:help,
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
			opts.banner = "casteml: a utility for CASTEML"
			opts.define_head "usage: csteml [options] [subcommand [options]]"
			opts.separator ""
			# opts.separator "Commands:"
			# opts.separator ""
			opts.separator "Examples:"
			opts.separator "  casteml join session-1.pml session-2.pml ... session-n.pml"
			opts.separator "  casteml split session-all.pml"
			opts.separator ""
			opts.separator "Options:"


			opts.on_tail("-?", "--help", "Show this message") do |v|
				@options[:help] = v
			end

			opts.on_tail("-v", "--[no-]verbose", "Run verbosely") do |v|
				@options[:verbose] = v
			end

			opts.on_tail("-V", "--version", "Show version") do |v|
				@options[:version] = v
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

	def show_version
		say Casteml::VERSION
	end


	def process_args(args, build_args=nil)
		opts.order!(args)
		
		if options[:help] then
			show_help
			exit
		elsif options[:version] then
			show_version
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
		say "ERROR: #{ex}. See '#{program_name} --help'."
	rescue Casteml::CommandLineError => ex
		say "ERROR: #{ex}. See '#{program_name} --help'."
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