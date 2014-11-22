class Casteml::Exception < RuntimeError
	attr_accessor :source_exception
end

class Casteml::CommandLineError < Casteml::Exception; end
