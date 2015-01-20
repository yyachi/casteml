require 'spec_helper'
require 'casteml/commands/upload_command'
module Casteml::Commands
	describe UploadCommand do
		before(:each) do
			setup_empty_dir('tmp')
		end

		describe "#show_help", :show_help => true do
			let(:cmd){ UploadCommand.new }
			it {
				puts "===================================="
				expect{ cmd.show_help }.not_to raise_error
				puts "===================================="
			}
		end

		describe "#invoke_with_build_args" do
			let(:cmd){ UploadCommand.new }
			let(:build_args){ [] }
			context "without args" do
				let(:args){ [] }
				it "shows error message" do
					expect(cmd).to receive(:alert_error).with("invalid argument: specify PMLFILE. See 'casteml upload --help'.")
					cmd.invoke_with_build_args args, build_args
				end
			end

			context "with -h" do
				let(:args){ ['-h'] }
				it "shows help" do
					expect(cmd).to receive(:show_help)
					cmd.invoke_with_build_args args, build_args
				end
			end

			context "with path" do
				let(:paths){ ['path1',  'path2'] }
				let(:instance){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:path){ 'tmp/my-great.pml'}
				let(:args){ [path]}
				before do
					allow(Casteml).to receive(:decode_file).with(path).and_return(instance)
					allow(Casteml).to receive(:save_remote).with(instance)
				end
				it "calls decode_file with path" do
					expect(Casteml).to receive(:decode_file).with(path).and_return(instance)
					cmd.invoke_with_build_args args, build_args
				end

				it "calls save_remote with instance" do
					expect(Casteml).to receive(:save_remote).with(instance)
					cmd.invoke_with_build_args args, build_args
				end
			end

		end		
	end
end
