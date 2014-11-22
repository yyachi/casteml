require 'casteml/command_manager'

module Casteml
	class Runner
		def initialize(options = {})
			@command_manager_class = options[:command_manager] || CommandManager	
		end
		def run(args)
			cmd = @command_manager_class.instance
			cmd.run args
		end
	end
end
