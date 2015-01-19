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
					expect(cmd).to receive(:say).with("ERROR: invalid argument: specify stone-ID or analysis-ID. See 'casteml download --help'.")
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

			context "with id" do
				let(:id){ '0000-0001'}
				let(:args){ [id]}
				let(:path){ "spec/fixtures/files/my-great.pml" }
				before do
					allow(Casteml).to receive(:download).with(id, {}).and_return(path)
				end
				it "calls download with id" do
					expect(Casteml).to receive(:download).with(id, {}).and_return(path)
					cmd.invoke_with_build_args args, build_args
				end
				context "with -f csv" do
					let(:args){ [id, '-f', 'csv']}
					it "calls download with id" do
						expect(Casteml).to receive(:convert_file).with(path, {:output_format => :csv})
						cmd.invoke_with_build_args args, build_args
					end

				end
			end

		end		

	end
end