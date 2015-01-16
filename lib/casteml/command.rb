require 'optparse'
require 'casteml/user_interaction'
class Casteml::Command
	include Casteml::UserInteraction

	attr_reader :command
	attr_reader :options
	attr_accessor :defaults
	attr_accessor :program_name
	attr_accessor :summary

	def self.common_options
		@common_options ||= []
	end

	def self.add_common_option(*args, &handler)
		Casteml::Command.common_options << [args, handler]
	end

	def initialize(command, summary=nil, defaults={})
		@command = command
		@summary = summary
		@program_name = "casteml #{command}"
		@defaults = defaults
		@options = defaults.dup
		@option_groups = Hash.new { |h,k| h[k] = []}
		@parser = nil
		@when_invoked = nil
	end

	def usage
		program_name
	end

	def arguments
		""
	end

	def defaults_str
		""
	end

	def description
		nil
	end

	def show_help
		parser.program_name = usage
		say parser
	end

	def invoke_with_build_args(args, build_args)
		handle_options args
		options[:build_args] = build_args
		if options[:help] then
			show_help
		else
			execute
		end		
	rescue => ex
		raise if options[:debug]
			say "ERROR: #{ex}. See '#{program_name} --help'."
	end

	def handle_options(args)
		@options = @defaults
		parser.parse!(args)
		@options[:args] = args
	end

	def add_option(*opts, &handler)
		group_name = Symbol === opts.first ? opts.shift : :options

		@option_groups[group_name] << [opts, handler]
	end

	def remove_option(name)
		@option_groups.each do |_, option_list|
			option_list.rejct! { |args,_| args.any? { |x| x =~ /^#{name}/ }}
		end
	end

	def execute
		raise "generic command has no action"
	end

	private

	def add_parser_description
		return unless description

		formatted = description.split("\n\n").map do |chunk|
			wrap chunk, 80 - 4
		end.join "\n"
		@parser.separator nil
		@parser.separator " Description:"
		formatted.split("\n").each do |line|
			@parser.separator " #{line.rstrip}"
		end	
	end

	def add_parser_run_info title, content
		return if content.empty?
		@parser.separator nil
		@parser.separator " #{title}:"
		content.split(/\n/).each do |line|
			@parser.separator " #{line}"
		end
	end

	def add_parser_summary # :nodoc:
		return unless @summary
		@parser.separator nil
		@parser.separator " Summary:"
		wrap(@summary, 80 - 4).split("\n").each do |line|
			@parser.separator " #{line.strip}"
		end
	end

	def wrap(text, width) # :doc:
		text.gsub(/(.{1,#{width}})( +|$\n?)|(.{1,#{width}})/, "\\1\\3\n")
	end

	def add_parser_options
		@parser.separator nil

		regular_options = @option_groups.delete :options
		configure_options "", regular_options

		@option_groups.sort_by { |n,_| n.to_s }.each do |group_name, option_list|
			@parser.separator nil
			configure_options group_name, option_list
		end
	end

	def parser
		create_option_parser if @parser.nil?
		@parser
	end

	def create_option_parser
		@parser = OptionParser.new
		add_parser_options

		@parser.separator nil
		configure_options "Common", Casteml::Command.common_options

		add_parser_run_info "Arguments", arguments
		add_parser_summary
		add_parser_description
		add_parser_run_info "Defaults", defaults_str

	end

	def configure_options(header, option_list)
		return if option_list.nil? or option_list.empty?

		header = header.to_s.empty? ? '' : "#{header} "
		@parser.separator " #{header}Options:"
		option_list.each do |args, handler|
			args.select{ |arg| arg =~ /^-/ }
			@parser.on(*args) do |value|
				handler.call(value, @options)
			end

			@parser.separator ''
		end
	end

	add_common_option('-h', '--help', 'Get help on this command') do |value, options|
		options[:help] = true
	end

	add_common_option('-d', '--debug', 'Show debug information') do |value, options|
		options[:debug] = true
	end


# add_common_option('-v', '--[no-]verbose','Set the verbose level of output') do |value, options|
# # Set us to "really verbose" so the progress meter works
# if Casteml.configuration.verbose and value then
# Casteml.configuration.verbose = true
# else
# Casteml.configuration.verbose = value
# end
# end

# add_common_option('-q', '--quiet', 'Silence commands') do |value, options|
# Casteml.configuration.verbose = false
# end	
end

module Casteml::Commands
end