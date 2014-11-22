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