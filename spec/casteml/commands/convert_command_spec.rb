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
					expect(cmd).to receive(:alert_error).with("invalid argument: specify FILE. See 'casteml convert --help'.")
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

			context "with tsv" do
				let(:path){ 'tmp/mytable.tsv'}
				let(:data){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:args){ [path]}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
				end

				it "calls Casteml.convert_file with path" do
					expect(Casteml).to receive(:convert_file).with(path, {}).and_return('pml')					
					cmd.invoke_with_build_args args, build_args
				end
			end

			context "with pml" do
				let(:path){ 'tmp/mytable.pml'}
				let(:data){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:args){ [path]}

				it "calls Casteml.convert_file with path" do
					expect(Casteml).to receive(:convert_file).with(path, {}).and_return('csv')	
					cmd.invoke_with_build_args args, build_args
				end
			end

			context "with output_format tex without number_format" do
				subject{ cmd.invoke_with_build_args args, build_args }
				let(:path){ 'tmp/mytable.tsv'}
				let(:instance){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:args){ ['-f', 'tex', path]}
				let(:data){ double('data').as_null_object }
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
					allow(Casteml).to receive(:decode_file).with(path).and_return(data)
				end

				it "calls Casteml.decode_file with path" do
					expect(Casteml).to receive(:convert_file).with(path, :output_format => :tex).and_return('tex')
					subject
				end

				it "calls Casteml.encode with options" do
					expect(Casteml).to receive(:encode).with(data, :output_format => :tex, :number_format => "%.4g").and_return('tex')
					subject
				end

				it "calls Casteml::Formats::TexFormat.to_string with options" do
					expect(Casteml::Formats::TexFormat).to receive(:to_string).with(data, :number_format => "%.4g").and_return('tex')
					subject
				end


			end

			context "with output_format tex with number_format '%.3f'" do
				subject{ cmd.invoke_with_build_args args, build_args }
				let(:path){ 'tmp/mytable.tsv'}
				let(:instance){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:args){ ['-f', 'tex', '-n','%.3f',path]}
				let(:data){ double('data').as_null_object }
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
					allow(Casteml).to receive(:decode_file).with(path).and_return(data)
				end

				it "calls Casteml.decode_file with path" do
					expect(Casteml).to receive(:convert_file).with(path, :output_format => :tex, :number_format => "%.3f").and_return('tex')
					subject
				end

				it "calls Casteml.encode with options" do
					expect(Casteml).to receive(:encode).with(data, :output_format => :tex, :number_format => "%.3f").and_return('tex')
					subject
				end

				it "calls Casteml::Formats::TexFormat.to_string with options" do
					expect(Casteml::Formats::TexFormat).to receive(:to_string).with(data, :number_format => "%.3f").and_return('tex')
					subject
				end


			end

			context "with format csv" do
				let(:path){ 'tmp/mytable.tsv'}
				let(:instance){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:args){ ['-f', 'csv', path]}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
				end

				it "calls Casteml.decode_file with path" do
					#expect(Casteml).to receive(:convert_file).with(path, :format => :tex).and_return(instance)
					cmd.invoke_with_build_args args, build_args
				end
			end

			context "with format tsv" do
				let(:path){ 'tmp/mytable.tsv'}
				let(:instance){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:args){ ['-f', 'tsv', path]}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
				end

				it "calls Casteml.decode_file with path" do
					#expect(Casteml).to receive(:convert_file).with(path, :format => :tex).and_return(instance)
					cmd.invoke_with_build_args args, build_args
				end
			end

			context "with format org", :current => true do
				let(:path){ 'tmp/mytable1.pml'}
				#let(:path){ '~/orochi-devel/gems/casteml/spec/fixtures/files/mydata@1.pml'}
				let(:instance){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:args){ ['-f', 'org', path, '-d']}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
				#	puts path
				end

				it "calls Casteml.decode_file with path" do
					#expect(Casteml).to receive(:convert_file).with(path, :format => :tex).and_return(instance)
					cmd.invoke_with_build_args args, build_args
				end
			end

			context "with format isorg" do
				let(:path){ 'tmp/mytable.tsv'}
				let(:instance){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:args){ ['-f', 'isorg', path]}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
				end

				it "calls Casteml.decode_file with path" do
					#expect(Casteml).to receive(:convert_file).with(path, :format => :tex).and_return(instance)
					cmd.invoke_with_build_args args, build_args
				end
			end

			context "with format pdf" do
				let(:path){ 'tmp/mytable.tsv'}
				let(:instance){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:args){ ['-f', 'pdf', path]}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
				end

				it "calls Casteml.decode_file with path" do
					#expect(Casteml).to receive(:convert_file).with(path, :format => :tex).and_return(instance)
					cmd.invoke_with_build_args args, build_args
				end
			end

			context "with format dataframe" do
				let(:path){ 'tmp/mytable.tsv'}
				let(:instance){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:args){ ['-f', 'dataframe', path]}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
				end

				it "calls Casteml.decode_file with path" do
					#expect(Casteml).to receive(:convert_file).with(path, :format => :tex).and_return(instance)
					cmd.invoke_with_build_args args, build_args
				end
			end

		end		
	end
end
