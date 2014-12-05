require 'spec_helper'
require 'casteml/commands/split_command'
module Casteml::Commands
	describe SplitCommand do
		before(:each) do
			setup_empty_dir('tmp')
		end

		describe "#show_help", :show_help => true do
			let(:cmd){ SplitCommand.new }
			it {
				puts "===================================="
				expect{ cmd.show_help }.not_to raise_error
				puts "===================================="
			}
		end

		describe "#invoke_with_build_args" do
			let(:cmd){ SplitCommand.new }
			let(:build_args){ [] }
			context "without args" do
				let(:args){ [] }
				it "shows error message" do
					expect(cmd).to receive(:say).with("ERROR: invalid argument: specify PMLFILE. See 'casteml split --help'.")
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
				let(:path){ 'tmp/my-great.pml'}
				let(:args){ [path]}
				it "calls split_file with path" do
					expect(Casteml::Formats::XmlFormat).to receive(:split_file).with(path).and_return(paths)
					cmd.invoke_with_build_args args, build_args
				end

			end

		end		
	end
end
