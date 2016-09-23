require 'casteml/command'
class Casteml::Commands::UploadCommand < Casteml::Command
	def initialize
		super 'upload', '    Upload a pmlfile to Medusa 9' # Summary:
	end

	def usage
		"#{program_name} PMLFILE"
	end

	def arguments
	<<-EOS
    PMLFILE    A pmlfile to be uploaded
EOS
	end

	def description
	<<-EOF
    Upload pmlfile to Medusa.  See `casteml convert --help' for data
    format.  Note that these also is program to upload files named
    `orochi-upload'.

    This program `#{program_name}' creates sessions (also referred as
    analyses) that unite chemical datasets.  You want to correlate
    each session to a stone.  To do so stone-ID should be specified in
    pmlfile since `#{program_name}' does not take stone-ID as an
    option.

    This program `#{program_name}' stores location (also referred as
    spot) of an session (also referred as analysis) as relative
    coordinate of an imagefile.  Origin of a coordinate is center of
    an image.  A spot coordinate is normalized by the longest side.
    As a consequence, the longest side ranges from -50 to 50.  Use a
    Matlab script `spot.m' to create pmlfile with spots, and follow
    instrution provided by `spots.m'.

    This program `#{program_name}' uploads datasets, coordinates, and
    imagefile `my-spots-picture.jpg'.  If there is Affine matrix file
    `my-spots-picture.affine' (xy-on-image to vs space), it also
    uploads it.  Use `spots.m' to create pmlfile with spots.
EOF
	end

	def example
	<<-EOS
    $ casteml join JB1.pml stone2.pml JB3.pml > session.pml
    $ casteml upload session.pml

    matlab>> spots
    ...
    $ ls
    my-spots-picture.jpg  my-spots-picture.pml
    $ casteml upload my-spots-picture.pml
EOS
	end

	def see_also
	<<-EOS
    orochi-upload
    casteml convert --help
    casteml join
    http://dream.misasa.okayama-u.ac.jp
    spots.m
EOS
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
