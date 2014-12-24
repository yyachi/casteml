require 'spec_helper'
require 'casteml/commands/convert_command'
module Casteml::Commands
	describe ConvertCommand do
		let(:cmd_class){ ConvertCommand }
		before(:each) do
			setup_empty_dir('tmp')
		end

		describe "#show_help", :show_help => true do
			let(:cmd){ cmd_class.new }
			it {
				puts "===================================="
				expect{ cmd.show_help }.not_to raise_error
				puts "===================================="
			}
		end

		describe "#invoke_with_build_args" do
			let(:cmd){ cmd_class.new }
			let(:build_args){ [] }
			context "without args" do
				let(:args){ [] }
				it "shows error message" do
					expect(cmd).to receive(:say).with("ERROR: invalid argument: specify FILE. See 'casteml convert --help'.")
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
				let(:path){ 'tmp/mytable.csv'}
				let(:instance){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:args){ [path]}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
				end

				it "calls Casteml.decode_file with path" do
#					expect(Casteml).to receive(:convert_file).with(path).and_return(instance)
					cmd.invoke_with_build_args args, build_args
				end

			end

		end		
	end
end
