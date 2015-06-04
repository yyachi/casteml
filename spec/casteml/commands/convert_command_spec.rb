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
			subject { cmd.invoke_with_build_args args, build_args }
			let(:cmd){ cmd_class.new }
			let(:build_args){ [] }
			context "without args" do
				let(:args){ [] }
				it "shows error message" do
					expect(cmd).to receive(:alert_error).with("invalid argument: specify FILE. See 'casteml convert --help'.")
					#cmd.invoke_with_build_args args, build_args
					expect { subject }.to raise_error
				end
			end

			context "with -h" do
				let(:args){ ['-h'] }
				it "shows help" do
					expect(cmd).to receive(:show_help)
					cmd.invoke_with_build_args args, build_args
				end
			end

			context "without --unit" do
				subject{ cmd.invoke_with_build_args args, build_args }
				let(:path){ 'tmp/mytable.tsv'}
				let(:data){ double('data').as_null_object }
				let(:args){ [path, '-f', 'csv']}
				it {
					expect(Casteml).to receive(:convert_file).with(path, {:output_format => :csv})				
					subject
				}
			end

			context "with --no-unit", :current => true do
				subject{ cmd.invoke_with_build_args args, build_args }
				let(:path){ 'tmp/mytable.tsv'}
				let(:data){ double('data').as_null_object }
				let(:args){ [path, '-f', 'csv', '--no-unit']}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
				end
				it {
					expect(Casteml).to receive(:convert_file).with(path, {:output_format => :csv, :with_unit => false})				
					subject
				}
				it {
					expect(cmd).to receive(:output).with(/Hf176zHf177,Hf176zHf177/)
					subject
				}
			end

			context "with unit '%'", :current => true do
				subject{ cmd.invoke_with_build_args args, build_args }
				let(:path){ 'tmp/mytable.tsv'}
				let(:data){ double('data').as_null_object }
				let(:args){ [path, '-f', 'csv', '--unit', '%']}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
				end
				it {
					expect(Casteml).to receive(:convert_file).with(path, {:output_format => :csv, :with_unit => '%'})				
					subject
				}
				it {
					expect(cmd).to receive(:output).with(/Hf176zHf177 \(%\),Hf176zHf177/)
					subject
				}

			end

			context "with --with-average" do
				subject{ cmd.invoke_with_build_args args, build_args }
				let(:path){ 'tmp/mytable.tsv'}
				#let(:data){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:data){ double('data').as_null_object }
				let(:args){ [path, '--average']}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
				end
				it {
					expect(Casteml).to receive(:decode_file).with(path).and_return(data)				
					expect(Casteml).to receive(:encode).with(data, {:output_format => :pml, :with_average => true})
					subject
				}
			end

			context "with --smash" do
				subject{ cmd.invoke_with_build_args args, build_args }
				let(:path){ 'tmp/mytable.tsv'}
				#let(:data){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:data){ double('data').as_null_object }
				let(:args){ [path, '--smash']}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
				end
				it {
					expect(Casteml).to receive(:decode_file).with(path).and_return(data)				
					expect(Casteml).to receive(:encode).with(data, {:output_format => :pml, :smash => true})
					subject
				}
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
					expect(cmd).to receive(:output)
					subject
					#cmd.invoke_with_build_args args, build_args
				end
			end


			context "with pml" do
				let(:path){ 'tmp/mytable.pml'}
				let(:data){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:args){ [path]}

				it "calls Casteml.convert_file with path" do
					expect(Casteml).to receive(:convert_file).with(path, {}).and_return('csv')	
					expect(cmd).to receive(:output)
					subject
					#cmd.invoke_with_build_args args, build_args
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
					allow(cmd).to receive(:output)
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
					allow(cmd).to receive(:output)

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
				let(:data){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:args){ ['-f', 'csv', path]}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
				end

				it "output normal csv" do
					expect(cmd).to receive(:output).with(Regexp.new("instrument,analyst,session"))
					subject
				end
				context "with -t" do
					let(:args){ ['-t', '-f', 'csv', path]}
					it "call Casteml.convert_file with transpose option" do
						expect(Casteml).to receive(:decode_file).with(path).and_return(data)
						expect(Casteml).to receive(:encode).with(data, :output_format => :csv, :transpose => true).and_return('csv')
						expect(cmd).to receive(:output).with('csv')
						subject
					end
					it "output transposed csv" do
						expect(cmd).to receive(:output).with(Regexp.new("instrument,MAT 262"))
						subject
					end
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

				it "output normal tsv" do
					expect(cmd).to receive(:output).with(Regexp.new("instrument\tanalyst\tsession"))
					subject
				end

				context "with -t" do
					let(:args){ ['-t', '-f', 'tsv', path]}
					it "output transposed tsv" do
						expect(cmd).to receive(:output).with(Regexp.new("instrument\tMAT 262"))
						subject
					end
				end

			end


			context "with format org" do
				let(:path){ 'tmp/mytable.tsv'}
				#let(:path){ '~/orochi-devel/gems/casteml/spec/fixtures/files/mydata@1.pml'}
				let(:instance){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:args){ ['-f', 'org', path, '-d']}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
				end

				it "output normal org" do
					expect(cmd).to receive(:output).with(Regexp.new('instrument\|analyst\|session\|'))					
					subject
				end


				context "with -t" do
					let(:args){ ['-t', '-f', 'org', path]}
					it "output transposed org" do
						expect(cmd).to receive(:output).with(Regexp.new('instrument\|MAT 262'))
						subject
					end
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
					#cmd.invoke_with_build_args args, build_args
					expect(cmd).to receive(:output).with(Regexp.new("|session|"))
					subject
				end
			end

			context "with format tex" do
				let(:path){ 'tmp/mytable.tsv'}
				let(:instance){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:args){ ['-f', 'tex', path]}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
				end

				it "output normal tex" do
					expect(cmd).to receive(:output).with(Regexp.new('session & \\\\ion\[176\]{Hf}'))
					subject
				end

				context "with -t" do
					let(:args){ ['-t', '-f', 'tex', path]}
					it "output transposed tex" do
						expect(cmd).to receive(:output).with(Regexp.new('session \& I1841'))
						subject
					end
				end

			end

			context "with format pdf" do
				let(:path){ 'tmp/mytable.tsv'}
				let(:args){ ['-f', 'pdf', path]}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
				end

				it "output PDF" do
					#expect(Casteml).to receive(:convert_file).with(path, :format => :tex).and_return(instance)
					#cmd.invoke_with_build_args args, build_args
					expect(cmd).to receive(:output)
					subject
				end
			end

			context "with format dataframe" do
				let(:path){ 'tmp/20130704180915-127898.pml'}
				#let(:instance){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:data_array){ double(:data) }				
				let(:args){ ['-f', 'dataframe', '-c', 'trace', path]}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
					allow(cmd).to receive(:output)
					#allow(Casteml).to receive(:decode_file).with(path).and_return(instance)
				end

				it "calls Casteml.convert_file with path and options" do
					expect(Casteml).to receive(:convert_file).with(path, :output_format => :dataframe, :with_category => "trace")
					cmd.invoke_with_build_args args, build_args
				end

				it "calls Casteml.encode with array and options" do
					expect(Casteml).to receive(:decode_file).with(path).and_return(data_array)
					expect(Casteml).to receive(:encode).with(data_array ,:output_format => :dataframe, :with_unit => "ug/g", :with_nicknames => Casteml::MeasurementCategory.find_by_name("trace").nicknames)
					cmd.invoke_with_build_args args, build_args
				end

				it "calls Casteml::Formats::CsvFormat.encode with array and options" do
#					expect(Casteml::Formats::CsvFormat).to receive(:to_string).with(instance, :omit_null => true, :without_error => true, :without_spot => true, :with_unit => "ug/g", :with_nicknames => Casteml::MeasurementCategory.find_by_name("trace").nicknames).and_return("element")
					expect(cmd).to receive(:output).with(Regexp.new("\nEr"))
					cmd.invoke_with_build_args args, build_args
				end

			end

			context "with category trace" do
				let(:path){ 'tmp/20130704180915-127898.pml'}
				#let(:instance){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
				let(:args){ ['-c', 'trace', path]}
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
				end

				it "calls Casteml.decode_file with path" do
					#expect(Casteml).to receive(:convert_file).with(path, :format => :tex).and_return(instance)
					#cmd.invoke_with_build_args args, build_args
					expect(cmd).to receive(:output).with(Regexp.new("global_id,"))
					subject
				end
			end

		end		
	end
end
