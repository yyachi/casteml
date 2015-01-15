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
    Upload a pmlfile to Medusa 9.  Users are encoraged to call this
    program through `orochi-upload'.

    CASTEML stores spot location as relative coordinate of an image.  
    Origin of a coordinate is center of an image.
    A spot coordinate is normalized by the longest side.
    As a consequence, the longest side ranges from $-50$ to $50$.
     
    A utility #{program_name} tries to upload data-sets, image file
    my-spot-region.jpg, and coordinate.  If there is Affine
    matrix file my-spot-region.affine (xy-on-image to vs space),
    it also uploads the Affine matrix at the same time.

EXAMPLE
	$ casteml join JB3-1.pml stone-1.pml stone-2.pml JB3-2.pml > session.pml
	$ casteml upload session.pml

SEE ALSO
    http://dream.misasa.okayama-u.ac.jp
    join
    orochi-upload

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
