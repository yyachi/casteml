require 'spec_helper'
require 'casteml/commands/download_command'
module Casteml::Commands
	describe DownloadCommand do
		before(:each) do
			setup_empty_dir('tmp')
		end
		let(:cmd){ DownloadCommand.new }
		describe "#show_help", :show_help => true do
			it {
				puts "===================================="
				expect{ cmd.show_help }.not_to raise_error
				puts "===================================="
			}

		end

		describe "#invoke_with_build_args" do
			let(:build_args){ [] }
			context "without args" do
				let(:args){ [] }
				it "shows error message" do
					expect(cmd).to receive(:alert_error).with("invalid argument: specify stone-ID or analysis-ID. See 'casteml download --help'.")
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

            context "with ids" do
              subject { cmd.invoke_with_build_args args, build_args }
			  let(:id_1){ '0000-0001'}
			  let(:id_2){ '0000-0002'}
  			  let(:xml){ "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><acquisition><session>hi</session></acquisition>" }
              
				let(:args){ [id_1, id_2]}

				it "calls download with id" do
				  expect(Casteml).to receive(:get).with(id_1, {}).and_return(xml)
				  expect(Casteml).to receive(:get).with(id_2, {}).and_return(xml)
				  expect(cmd).to receive(:output)
				  subject
				end
            end

            context "with many ids" do
            	subject { cmd.invoke_with_build_args args, build_args }
			  	let(:id_1){ '0000-0001'}
			  	let(:num_ids){ 1000 }
				let(:xmls){

				}              
			  	let(:args){ Array.new(num_ids, id_1).concat(['-R']) }
			  	before do
			  		@xmls = []
			  		num_ids.times do |id|
			  			no = id + 1
			  			@xmls << "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><acquisition><session>#{no}</session></acquisition>"
			  		end
			  	end
			  	it "output casteml to stdout" do
			  		expect(Casteml).to receive(:get).with(id_1, {:recursive => :families}).exactly(num_ids).and_return(*@xmls)
			  		#expect(Casteml).to receive(:get).with(id_2, {}).and_return(xml)
			  		expect(cmd).to receive(:output).with(Regexp.new('<acquisitions>'))
			  		subject
			  	end
            end
            
			context "with id" do
            	subject { cmd.invoke_with_build_args args, build_args }
				let(:id){ '0000-0001'}
				let(:args){ [id]}
				let(:xml){ "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><acquisition><session>#{id}</session></acquisition>" }
				let(:path){ "spec/fixtures/files/my-great.pml" }
				before do
					allow(Casteml).to receive(:get).with(id, {}).and_return(xml)
				end
				it "calls download with id" do
					expect(Casteml).to receive(:get).with(id, {}).and_return(xml)
					expect(cmd).to receive(:output)
					#cmd.invoke_with_build_args args, build_args
					subject
				end
				context "with -f csv" do
					let(:args){ [id, '-f', 'csv']}
					it "calls download with id" do
						expect(Casteml).to receive(:get).with(id, {}).and_return(xml)
						expect(cmd).to receive(:output).with(Regexp.new("session"))
						subject
						#cmd.invoke_with_build_args args, build_args
					end

				end

				# context "with -f tex" do
				# 	let(:args){ [id, '-f', 'tex']}
				# 	it "calls download with id" do
				# 		expect(Casteml).to receive(:get).with(id, {}).and_return(xml)
				# 		expect(cmd).to receive(:output).with(Regexp.new("session"))
				# 		subject
				# 		#cmd.invoke_with_build_args args, build_args
				# 	end
				# end

				context "with -r" do
					let(:args){ [id, '-r']}
					it "calls download with id" do
						expect(Casteml).to receive(:get).with(id, {:recursive => :self_and_descendants}).and_return(xml)
						expect(cmd).to receive(:output).with(Regexp.new("session"))
						cmd.invoke_with_build_args args, build_args
					end
				end


				context "with -R" do
					let(:args){ [id, '-R']}
					it "calls download with id" do
						expect(Casteml).to receive(:get).with(id, {:recursive => :families}).and_return(xml)
						expect(cmd).to receive(:output).with(Regexp.new("session"))						
						cmd.invoke_with_build_args args, build_args
					end
				end

				context "with -R and -f" do
					let(:args){ [id, '-R', '-f', 'org']}
					it "calls download with id" do
						expect(Casteml).to receive(:get).with(id, {:recursive => :families}).and_return(xml)
						#cmd.invoke_with_build_args args, build_args
						expect(cmd).to receive(:output).with(Regexp.new("|session|"))
						subject
					end
				end

			end

		end		

	end
end
