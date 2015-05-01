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
				subject { cmd.invoke_with_build_args args, build_args }

				let(:path){ 'tmp/20130528105235-594267-R.pml'}
				let(:plotfile){ File.basename(path,".*") + '.R'}
				let(:instance){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:args){ [path]}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
					allow(Casteml).to receive(:exec_command)
				end

				it "execute R" do
					expect(Casteml).to receive(:exec_command).with("R --vanilla --slave < #{plotfile}")
					subject
				end

				it "select template for trace" do
					expect(cmd).to receive(:default_template).with('trace').and_return(File.join(Casteml::TEMPLATE_DIR, "plot-trace.R.erb"))
					subject
				end
			end

			context "with -c" do
				subject { cmd.invoke_with_build_args args, build_args }
				let(:path){ 'tmp/20130528105235-594267-R.pml'}
				let(:plotfile){ File.basename(path,".*") + '.R'}
				let(:category){ 'isotope-dev'} 
				let(:args){ [path, '-c', category]}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
					allow(Casteml).to receive(:exec_command)
					allow(Casteml).to receive(:convert_file)
					#allow(cmd).to receive(:read_template).and_return("Hello")
				end

				it "call convert" do
					expect(Casteml).to receive(:convert_file).with(path, {:output_format => :dataframe, :with_category => category})
					subject
				end

				it "select template for category" do
					expect(cmd).to receive(:default_template).with(category).and_return(File.join(Casteml::TEMPLATE_DIR, "plot-#{category}.R.erb"))
					subject
				end

				it "execute command with template" do
					expect(Casteml).to receive(:exec_command).with("R --vanilla --slave < #{plotfile}")
					subject
				end
			end
		end
	end
end