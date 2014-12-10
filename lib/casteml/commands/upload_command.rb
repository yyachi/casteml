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
NAME
    #{program_name} -  Upload a pmlfile to Medusa 9.

SYNOPSIS
    #{program_name} [options] file

DESCRIPTION
    Upload a pmlfile to Medusa 9.

NOTE
    This command will be incorporated into orochi-upload soon.
    Execute via orochi-upload as "$ orochi-upload session.pml".

EXAMPLE
	$ casteml join JB3-1.pml stone-1.pml stone-2.pml JB3-2.pml > session.pml
	$ casteml upload session.pml

SEE ALSO
    orochi-upload
    join
    http://dream.misasa.okayama-u.ac.jp

IMPLEMENTATION
    Copyright (c) 2014 ISEI, Okayama University
    Licensed under the same terms as Ruby

OPTIONS
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
