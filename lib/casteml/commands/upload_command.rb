require 'casteml/command'
class Casteml::Commands::UploadCommand < Casteml::Command
	def initialize
		super 'upload', 'Upload a pmlfile to Medusa 9'

	end

	def usage
		"#{program_name} pmlfile"
	end
	def arguments
		"    pmlfile to be uploaded"
	end

	def description
	<<-EOF

    Upload pmlfile to Medusa.  Users are encoraged to call this
    program through `orochi-upload'.

    You may want to correlate pmlfile to certain stone.  To do so
    stone-ID should be specified in pmlfile since `#{program_name}' does
    not take stone-ID as an option.

    CASTEML stores spot location as relative coordinate of an image.
    Origin of a coordinate is center of an image.  A spot coordinate
    is normalized by the longest side.  As a consequence, the longest
    side ranges from -50 to 50.

    This utility `#{program_name}' uploads datasets, imagefile
    `my-spots-picture.jpg', and coordinates.  If there is Affine
    matrix file `my-spots-picture.affine' (xy-on-image to vs space),
    it also uploads it.

Example:
    $ casteml join JB1.pml stone2.pml JB3.pml > session.pml
    $ casteml upload session.pml

See Also:
    casteml join
    casteml mv
    orochi-upload
    http://dream.misasa.okayama-u.ac.jp

Implementation:
    Copyright (c) 2015-2016, ISEI, Okayama University
    Licensed under the same terms as Ruby

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
