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

		describe "#default_template" do
			subject { cmd.default_template(category) }
			let(:cmd){ cmd_class.new }
			let(:category){ 'trance' }
			it {
				expect(subject).to eql(File.join(Casteml::TEMPLATE_DIR, "plot/#{category}.R.erb"))
			}
		end

		describe "#invoke_with_build_args" do
			let(:cmd){ cmd_class.new }
			let(:build_args){ [] }
			context "without args" do
				let(:args){ [] }
				it "shows error message" do
					expect(cmd).to receive(:alert_error).with("invalid argument: specify FILE. See 'casteml plot --help'.")
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

			context "without options" do
				subject { cmd.invoke_with_build_args args, build_args }

				let(:path){ 'tmp/20130528105235-594267-R.pml'}
				let(:plotfile){ File.basename(path,".*") + '.R'}
				let(:instance){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:args){ [path]}
				let(:erb){ double(:erb) }
				let(:template){ double(:template)} 
				let(:output){ double(:output) }

				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
					allow(Casteml).to receive(:exec_command)
				end

				it "execute R" do
					expect(Casteml).to receive(:exec_command).with("R --vanilla --slave < #{plotfile}")
					subject
				end

				it "select template for default" do
					expect(cmd).to receive(:default_template).with(nil).and_return(File.join(Casteml::TEMPLATE_DIR, "plot/default.R.erb"))
					subject
				end

				it "select dataframe name without category" do
					expect(cmd).to receive(:output_dataframe).with(File.join(File.dirname(path), File.basename(path, '.*') + ".dataframe"), /element/)
					subject
				end

				it "generate plotfile" do
					expect(cmd).to receive(:read_template).and_return(template)
					expect(erb).to receive(:result).and_return(output)
					expect(ERB).to receive(:new).with(template, nil, "-", "@output").and_return(erb)
					expect(cmd).to receive(:output_plotfile).with(File.join(File.dirname(path), File.basename(path, '.*') + ".R"), output)
#					expect(cmd).to receive(:output_plotfile).with(File.join(File.dirname(path), File.basename(path, '.*') + "_trace.R"), Regexp.new("input = \\\"#{File.basename(path, '.*') + '_trace.dataframe'}\\\"\noutput = \\\"#{File.basename(path, '.*') + '_trace.pdf'}\\\"\n"))
					subject
				end
			end

			context "with -c" do
				subject { cmd.invoke_with_build_args args, build_args }
				let(:path){ 'tmp/20130528105235-594267-R.pml'}
				let(:plotfile){ File.join( File.dirname(path), File.basename(path,".*") + "_#{category}.R" )}
				let(:args){ [path, '-c', category]}
				let(:category){ 'trace'} 
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
					allow(Casteml).to receive(:exec_command)
					#allow(Casteml).to receive(:convert_file)
				end

				it "call convert" do
					expect(Casteml).to receive(:convert_file).with(path, {:output_format => :dataframe, :with_category => category})
					subject
				end


				context "isotope-dev" do
					it "select template for category" do
						expect(cmd).to receive(:default_template).with(category).and_return(File.join(Casteml::TEMPLATE_DIR, "plot/#{category}.R.erb"))
						expect(Casteml).not_to receive(:exec_command)
						expect{ subject }.to raise_error
					end

				end

				context "oxygen" do
					let(:category){ 'oxygen' }
					let(:erb){ double(:erb) }
					let(:template){ double(:template)} 
					let(:output){ double(:output) }
					it "select template for category" do
						expect(cmd).to receive(:default_template).with(category).and_return(File.join(Casteml::TEMPLATE_DIR, "plot/#{category}.R.erb"))
						subject
					end

					it "select dataframe name with category" do
						expect(cmd).to receive(:output_dataframe).with(File.join(File.dirname(path), File.basename(path, '.*') + "_#{category}.dataframe"), /element/)
						subject
					end

					it "generate plotfile" do
						expect(cmd).to receive(:read_template).and_return(template)
						expect(erb).to receive(:result).and_return(output)
						expect(ERB).to receive(:new).with(template, nil, "-", "@output").and_return(erb)
#						expect(cmd).to receive(:output_plotfile).with(File.join(File.dirname(path), File.basename(path, '.*') + "_#{category}.R"), Regexp.new("input = \\\"#{File.basename(path, '.*') + "_#{category}.dataframe"}\\\"\r\noutput = \\\"#{File.basename(path, '.*') + "_#{category}.pdf"}\\\"\r\n"))
						expect(cmd).to receive(:output_plotfile).with(File.join(File.dirname(path), File.basename(path, '.*') + "_#{category}.R"), output)
						subject
					end

					it "generate plotfile include input and output path" do
						subject
						expect(File.exists?(plotfile)).to be_truthy
						plot = File.open(plotfile).read
						#expect(plot).to match(Regexp.new("input = \"#{File.basename(path, '.*') + "_#{category}.dataframe"}\""))
						#expect(plot).to match(Regexp.new("output = \\\"#{File.basename(path, '.*') + "_#{category}.pdf"}\\\""))						
					end

					it "execute command with template" do
						expect(Casteml).to receive(:exec_command).with("R --vanilla --slave < #{File.basename(plotfile)}")
						subject
					end


				end

				context "brabra" do
					let(:category){ 'brabra' }
					it "select template for category" do
						expect(cmd).to receive(:default_template).with(category).and_return(File.join(Casteml::TEMPLATE_DIR, "plot/#{category}.R.erb"))
						expect(Casteml).not_to receive(:exec_command)
						expect{ subject }.to raise_error
					end
				end


			end
		end
	end
end