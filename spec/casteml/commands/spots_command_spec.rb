require 'spec_helper'
require 'casteml/commands/spots_command'
module Casteml::Commands
	describe SpotsCommand do
		let(:cmd){ SpotsCommand.new }

		before(:each) do
			setup_empty_dir('tmp')
		end

		describe "#show_help", :show_help => true do
			it {
				puts "===================================="
				expect{ cmd.show_help }.not_to raise_error
				puts "===================================="
			}
		end

		describe "#invoke_with_build_args" do
			subject{cmd.invoke_with_build_args args, build_args}
			let(:build_args){ [] }
			context "without args" do
				let(:args){ [] }
				it "shows error message" do
					expect(cmd).to receive(:alert_error).with("invalid argument: specify PMLFILE. See 'casteml spots --help'.")
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

			context "with path" do
				let(:pmlfile){ 'tmp/ys_pl_bytownite_c.pml'}
				let(:args){ [pmlfile]}
				before do
					setup_file(pmlfile)
				end
				it "not raise error" do
					cmd.invoke_with_build_args args, build_args
				end
				context "and --picture picture_path" do
					let(:picture_path){ 'temp/deleteme.jpg' }
					let(:args){ [pmlfile, '--picture', picture_path]}
					it "not raise error" do
						expect{subject}.not_to raise_error
					end
				end
				context "and abundance" do
					let(:args){ [pmlfile, abundance, "-d"] }
					let(:abundance){ "Li" }
					it "not raise error" do
						expect{subject}.not_to raise_error
					end

				end

				context "and abundance and isotope", :current => true do
					let(:args){ [pmlfile, abundance, isotope, "-d"] }
					let(:abundance){ "Li" }
					let(:isotope){ "d7Li"}
					it "not raise error" do
						expect{subject}.not_to raise_error
					end
					context "and --scale-ab-rel-to-image-with 5,5" do
						let(:args){ [pmlfile, abundance, isotope, "--scale-ab-rel-to-image-width", "5,5"] }
						it "not raise error" do
							expect{subject}.not_to raise_error
						end
					end

					context "and --scale-ab-rel-to-image-with 5" do
						let(:args){ [pmlfile, abundance, isotope, "--scale-ab-rel-to-image-width", "5"] }
						it "raise error" do
							expect(cmd).to receive(:alert_error).with("invalid argument: --scale-ab-rel-to-image-width incorrect number of arguments for scale-ab-rel-to-image-width. See 'casteml spots --help'.")
							expect {subject}.to raise_error
						end
					end

					context "and --scale-iso-range-min-max -5,5" do
						let(:args){ [pmlfile, abundance, isotope, "--scale-iso-range-min-max", "-5,5"] }
						it "not raise error" do
							expect{subject}.not_to raise_error
						end
					end

					context "and --scale-iso-range-min-max -5" do
						let(:args){ [pmlfile, abundance, isotope, "--scale-iso-range-min-max", "-5"] }
						it "not raise error" do
							expect(cmd).to receive(:alert_error).with("invalid argument: --scale-iso-range-min-max incorrect number of arguments for scale-iso-range-min-max. See 'casteml spots --help'.")
							expect{ subject }.to raise_error
						end
					end

				end

			end

		end		


	end
end