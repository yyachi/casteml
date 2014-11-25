require 'casteml/command'
class Casteml::Commands::UploadCommand < Casteml::Command
	def initialize
		super 'upload', 'Upload pml-file'

	end

	def usage
		"#{program_name} PMLFILE"
	end
	def arguments
		"PMLFILE\t pmlfile to be uploaded"
	end

	def description
		<<-EOF
The upload command allows you to upload pmlfile.

Examples:
	$ casteml upload session-all.pml
EOF
	end

	def execute
		original_options = options.clone
		args = options.delete(:args)
		raise OptionParser::InvalidArgument.new('specify PMLFILE') if args.empty?

    	pml_path = args.shift
    	data = Casteml.decode_file(pml_path)
    	Casteml.save_remote(data)
	end

end
