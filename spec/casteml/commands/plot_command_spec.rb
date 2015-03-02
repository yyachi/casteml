require 'spec_helper'
require 'casteml/commands/plot_command'
module Casteml::Commands
	describe PlotCommand do
		let(:cmd_class){ PlotCommand }
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
					expect(cmd).to receive(:alert_error).with("invalid argument: specify FILE. See 'casteml plot --help'.")
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

			context "without options" do
				let(:path){ 'tmp/20130528105235-594267-r.pml'}
				let(:plotfile){ File.basename(path,".*") + '.R'}
				let(:instance){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:args){ [path]}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
				end

				it "does something" do
					expect(Casteml).to receive(:exec_command).with("R --vanilla --slave < #{plotfile}")
					#expect(Casteml).to receive(:convert_file).with(path, :format => :tex).and_return(instance)
					cmd.invoke_with_build_args args, build_args
				end
			end			
		end
	end
end