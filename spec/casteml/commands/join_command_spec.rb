require 'spec_helper'
require 'casteml/commands/join_command'
module Casteml::Commands
	describe JoinCommand do
		before(:each) do
			setup_empty_dir('tmp')
		end

		describe "#show_help", :show_help => true do
			let(:cmd){ JoinCommand.new }
			it {
				puts "===================================="
				expect{ cmd.show_help }.not_to raise_error
				puts "===================================="
			}


		end

		describe "#invoke_with_build_args" do
			let(:cmd){ JoinCommand.new }
			let(:build_args){ [] }
			context "without args" do
				let(:args){ [] }
				it "shows error message" do
					expect(cmd).to receive(:alert_error).with("invalid argument: specify PMLFILES. See 'casteml join --help'.")
					expect { cmd.invoke_with_build_args args, build_args }.to raise_error
				end
			end

			context "with -h" do
				let(:args){ ['-h'] }
				it "shows help" do
					expect(cmd).to receive(:show_help)
					cmd.invoke_with_build_args args, build_args
				end
			end

			context "with paths" do
				let(:paths){ ['path1',  'path2'] }
				let(:path){ 'tmp/my-great.pml' }
				let(:pml){ File.read(path)}
				before do
					setup_file(path)
					pml
				end
				context "without -o" do
					let(:args){ [*paths]}
					it "calls join_files with paths and outputs to stdout" do
						expect(Casteml::Formats::XmlFormat).to receive(:join_files).with(paths).and_return(path)
						expect(cmd).to receive(:say).with(pml)
						cmd.invoke_with_build_args args, build_args
					end
				end

				context "with -o outpath" do
					let(:outfile_io){ double('fileio').as_null_object }
					let(:outpath){ 'tmp/output.pml' }
					let(:args){ [*paths, '-o', outpath]}
					it "calls join_files with paths and outputs to outpath" do
						expect(Casteml::Formats::XmlFormat).to receive(:join_files).with(paths).and_return(path)
						expect(File).to receive(:open).with(outpath, 'w').and_yield(outfile_io)
						expect(outfile_io).to receive(:puts).with(pml)
						cmd.invoke_with_build_args args, build_args
					end

					it "duplicate file contents" do
						expect(Casteml::Formats::XmlFormat).to receive(:join_files).with(paths).and_return(path)
						cmd.invoke_with_build_args args, build_args
						expect(File.read(outpath)).to be_eql(pml)
					end
				end

				context "with --outfile outpath" do
					let(:outfile_io){ double('fileio').as_null_object }
					let(:outpath){ 'tmp/output.pml' }
					let(:args){ [*paths, '--outfile', outpath]}
					it "calls join_files with paths and outputs to outpath" do
						expect(Casteml::Formats::XmlFormat).to receive(:join_files).with(paths).and_return(path)
						expect(File).to receive(:open).with(outpath, 'w').and_yield(outfile_io)
						expect(outfile_io).to receive(:puts).with(pml)
						cmd.invoke_with_build_args args, build_args
					end

					it "duplicate file contents" do
						expect(Casteml::Formats::XmlFormat).to receive(:join_files).with(paths).and_return(path)
						cmd.invoke_with_build_args args, build_args
						expect(File.read(outpath)).to be_eql(pml)
					end
				end

			end

		end

	end
end
