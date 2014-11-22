require 'spec_helper'
require 'casteml/command_manager'
module Casteml
	describe CommandManager do
		describe "#run" do
			let(:cmd){ CommandManager.instance}
			context "with empty args" do
				let(:args){ [] }
				it "shows help and exit" do
					expect(cmd).to receive(:show_help)
					expect{ cmd.run args }.to exit_with_code(0)
				end
			end

			context "with -h" do
				let(:args){ ['-h'] }
				it "shows help and exit" do
					expect(cmd).to receive(:show_help)
					expect{ cmd.run args }.to exit_with_code(0)
				end
			end

			context "with -V" do
				let(:args){ ['-V'] }
				it "shows version and exit" do
					expect(cmd).to receive(:show_version)
					expect{ cmd.run args }.to exit_with_code(0)
				end
			end
	
			context "with registered command" do
				let(:command){ double(command_name).as_null_object }
				let(:command_name){ 'split'}
				let(:args){ [command_name] }
				it "load_and_instantiate a command class" do
					expect(cmd).to receive(:load_and_instantiate).with(command_name.to_sym).and_return(command)
					
					cmd.run args
				end
			end

			context "with unknown command" do
				let(:command){ double(command_name).as_null_object }
				let(:command_name){ 'hoge'}
				let(:args){ [command_name] }
				it "shows error message" do
					expect(cmd).to receive(:say).with("ERROR: Unknown command #{command_name}. See 'casteml --help'.")					
					cmd.run args
				end
			end
	
			after(:each) do
				CommandManager.clear_instance
			end
		end
	end
end
