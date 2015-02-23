require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start
RSpec.configure do |config|
end

RSpec::Matchers.define :exit_with_code do |code|
	supports_block_expectations
	actual = nil
	match do |block|
		begin
			block.call
		rescue SystemExit => ex
			actual = ex.status
		end
		actual && actual == code
	end

	failure_message_when_negated do |block|
		"expected block not to call exit(#{code})"
	end

	failure_message do |block|
		"expected block to call exit(#{code}) but exit" + (actual.nil? ? " not called" : "(#{actual}) was called")
	end

	description do
		"expected block to call exit(#{code})"
	end

end

def texcompile(string, path = 'tmp/deleteme.tex')
	puts "compiling..."
	#string = "Hello World"
	# string = Casteml::Formats::TexFormat.document do |doc|
	# 	doc.puts string
	# end

	puts string
	#puts Casteml.compile_tex(string)
	#puts string
	dir = File.dirname(path)
	FileUtils.mkdir_p(dir) unless File.directory?(dir)
	File.open(path, "w") do |f|
		f.puts string
	end
	system("cd #{dir} && pdflatex #{File.basename(path)}")
end

def deleteall(delthem)
	if FileTest.directory?(delthem) then
		Dir.foreach( delthem ) do |file|
			next if /^\.+$/ =~ file
			deleteall(delthem.sub(/\/+$/,"") + "/" + file)
		end
		#p "#{delthem} deleting..."		
		Dir.rmdir(delthem) rescue ""
	else
		#p "#{delthem} deleting..."
		File.delete(delthem)
	end
end

def setup_empty_dir(dirname)
	deleteall(dirname) if File.directory?(dirname)
	FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
end

def setup_file(destfile)
	src_dir = File.expand_path('../fixtures/files',__FILE__)
	filename = File.basename(destfile)
	dest_dir = File.dirname(destfile)
	dest = File.join(dest_dir, filename)
	src = File.join(src_dir, filename)
	FileUtils.mkdir_p(dest_dir) unless File.directory?(dest_dir)
	FileUtils.copy(src, dest)
end
