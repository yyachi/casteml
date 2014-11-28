begin
	require 'io/console'
rescue LoadError
end

class Casteml::StreamUI
end

class Casteml::ConsoleUI < Casteml::StreamUI
end

module Casteml::DefaultUserInteraction
	@ui = nil
	def self.ui
		@ui ||= Casteml::ConsoleUI.new
	end

	def self.ui=(new_ui)
		@ui = new_ui
	end

	def self.use_ui(new_ui)
		old_ui = @ui
		@ui = new_ui
		yield
	ensure
		@ui = old_ui
	end

	def ui
		Casteml::DefaultUserInteraction.ui
	end

	def ui=(new_ui)
		Casteml::DefaultUserInteraction.use_ui(new_ui, &block)
	end	
end

module Casteml::UserInteraction
	include Casteml::DefaultUserInteraction

	##
	# Displays an alert +statement+. Asks a +question+ if given.
	def alert statement, question = nil
		ui.alert statement, question
	end
	##
	# Displays an error +statement+ to the error output location. Asks a
	# +question+ if given.
	def alert_error statement, question = nil
		ui.alert_error statement, question
	end
	##
	# Displays a warning +statement+ to the warning output location. Asks a
	# +question+ if given.
	def alert_warning statement, question = nil
		ui.alert_warning statement, question
	end
	##
	# Asks a +question+ and returns the answer.
	def ask question
		ui.ask question
	end
	##
	# Asks for a password with a +prompt+
	def ask_for_password prompt
		ui.ask_for_password prompt
	end
	##
	# Asks a yes or no +question+. Returns true for yes, false for no.
	def ask_yes_no question, default = nil
		ui.ask_yes_no question, default
	end
	##
	# Asks the user to answer +question+ with an answer from the given +list+.
	def choose_from_list question, list
		ui.choose_from_list question, list
	end
	##
	# Displays the given +statement+ on the standard output (or equivalent).
	def say statement = ''
		ui.say statement
	end
	##
	# Terminates the RubyGems process with the given +exit_code+
	def terminate_interaction exit_code = 0
		ui.terminate_interaction exit_code
	end
	##
	# Calls +say+ with +msg+ or the results of the block if really_verbose
	# is true.
	def verbose msg = nil
		say(msg || yield) if Casteml.configuration.really_verbose
	end

end


class Casteml::StreamUI
	# The input stream
	attr_reader :ins
	##
	# The output stream
	attr_reader :outs
	##
	# The error stream
	attr_reader :errs
	##
	# Creates a new StreamUI wrapping +in_stream+ for user input, +out_stream+
	# for standard output, +err_stream+ for error output. If +usetty+ is true
	# then special operations (like asking for passwords) will use the TTY
	# commands to disable character echo.
	def initialize(in_stream, out_stream, err_stream=STDERR, usetty=true)
		@ins = in_stream
		@outs = out_stream
		@errs = err_stream
		@usetty = usetty
	end
	##
 	##
	# Returns true if TTY methods should be used on this StreamUI.
	def tty?
		if RUBY_VERSION < '1.9.3' and RUBY_PLATFORM =~ /mingw|mswin/ then
			@usetty
		else
			@usetty && @ins.tty?
		end
	end
	##
	# Prints a formatted backtrace to the errors stream if backtraces are
	# enabled.
	def backtrace exception
		return unless Gem.configuration.backtrace
		@errs.puts "\t#{exception.backtrace.join "\n\t"}"
	end
	##
	# Choose from a list of options. +question+ is a prompt displayed above
	# the list. +list+ is a list of option strings. Returns the pair
	# [option_name, option_index].
	def choose_from_list(question, list)
		@outs.puts question
		list.each_with_index do |item, index|
			@outs.puts " #{index+1}. #{item}"
		end
		@outs.print "> "
		@outs.flush
		result = @ins.gets
		return nil, nil unless result
		result = result.strip.to_i - 1
		return list[result], result
	end
	##
	# Ask a question. Returns a true for yes, false for no. If not connected
	# to a tty, raises an exception if default is nil, otherwise returns
	# default.
	def ask_yes_no(question, default=nil)
		unless tty? then
		if default.nil? then
		raise Gem::OperationNotSupportedError,
		"Not connected to a tty and no default specified"
		else
		return default
		end
		end
		default_answer = case default
		when nil
		'yn'
		when true
		'Yn'
		else
		'yN'
		end
		result = nil
		while result.nil? do
		result = case ask "#{question} [#{default_answer}]"
		when /^y/i then true
		when /^n/i then false
		when /^$/ then default
		else nil
		end
		end
		return result
	end
	##
	# Ask a question. Returns an answer if connected to a tty, nil otherwise.
	def ask(question)
		return nil if not tty?
		@outs.print(question + " ")
		@outs.flush
		result = @ins.gets
		result.chomp! if result
		result
	end
##
# Ask for a password. Does not echo response to terminal.
def ask_for_password(question)
return nil if not tty?
@outs.print(question, " ")
@outs.flush
password = _gets_noecho
@outs.puts
password.chomp! if password
password
end
if IO.method_defined?(:noecho) then
def _gets_noecho
@ins.noecho {@ins.gets}
end
elsif Gem.win_platform?
def _gets_noecho
require "Win32API"
password = ''
while char = Win32API.new("crtdll", "_getch", [ ], "L").Call do
break if char == 10 || char == 13 # received carriage return or newline
if char == 127 || char == 8 # backspace and delete
password.slice!(-1, 1)
else
password << char.chr
end
end
password
end
else
def _gets_noecho
system "stty -echo"
begin
@ins.gets
ensure
system "stty echo"
end
end
end
##	
	# Display a statement.
	def say(statement="")
		@outs.puts statement
	end
end

class Casteml::ConsoleUI < Casteml::StreamUI
	def initialize
		super STDIN, STDOUT, STDERR, true
	end
end