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
                before do
                    puts cmd.show_help
                end
				it "shows help and exit" do
					expect(cmd).to receive(:show_help)
					expect{ cmd.run args }.to exit_with_code(0)
				end
			end

			context "with -V", :current => true do
				let(:args){ ['-V'] }
				before do
					puts cmd.show_version
				end
				it "shows version and exit" do
					expect(cmd).to receive(:show_version)
					expect{ cmd.run args }.to exit_with_code(0)
				end
			end
	

			context "with -R", :current => true do
				let(:args){ ['-R'] }
				before do
					puts cmd.show_version
				end
				it "shows version and exit" do
					expect(cmd).to receive(:refresh_cache)
					expect{ cmd.run args }.to exit_with_code(0)
				end
			end

			context "with registered command" do
				let(:command){ double(command_name).as_null_object }
				let(:args){ [command_name] }
				context "split" do
					let(:command_name){ 'split'}
					it "load_and_instantiate a command class" do
						expect(cmd).to receive(:load_and_instantiate).with(command_name.to_sym).and_return(command)	
						cmd.run args
					end
				end

				context "join" do
					let(:command_name){ 'join'}
					it "load_and_instantiate a command class" do
						expect(cmd).to receive(:load_and_instantiate).with(command_name.to_sym).and_return(command)	
						cmd.run args
					end
				end

				context "upload" do
					let(:command_name){ 'upload'}
					it "load_and_instantiate a command class" do
						expect(cmd).to receive(:load_and_instantiate).with(command_name.to_sym).and_return(command)	
						cmd.run args
					end
				end

				context "convert" do
					let(:command_name){ 'convert' }
					it "load_and_instantiate a command class" do
						expect(cmd).to receive(:load_and_instantiate).with(command_name.to_sym).and_return(command)	
						cmd.run args
					end
				end

				context "download" do
					let(:command_name){ 'download' }
					it "load_and_instantiate a command class" do
						expect(cmd).to receive(:load_and_instantiate).with(command_name.to_sym).and_return(command)	
						cmd.run args
					end
				end

				context "spots" do
					let(:command_name){ 'spots' }
					it "load_and_instantiate a command class" do
						expect(cmd).to receive(:load_and_instantiate).with(command_name.to_sym).and_return(command)	
						cmd.run args
					end
				end

				context "plot" do
					let(:command_name){ 'plot' }
					it "load_and_instantiate a command class" do
						expect(cmd).to receive(:load_and_instantiate).with(command_name.to_sym).and_return(command)	
						cmd.run args
					end
				end

			end


			context "with unknown command" do
				let(:command){ double(command_name).as_null_object }
				let(:command_name){ 'hoge'}
				let(:args){ [command_name] }
				it "shows error message" do
					expect(cmd).to receive(:alert_error).with("Unknown command #{command_name}. See 'casteml --help'.")					
					cmd.run args
				end
			end
	
			after(:each) do
				CommandManager.clear_instance
			end
		end

		describe ".load_and_instantiate" do
			subject{ cmd.send(:load_and_instantiate, command_name)}
			let(:cmd){ CommandManager.instance}

			context "download" do
				let(:command_name){ :download }
				it { expect(subject).to be_an_instance_of(Casteml::Commands::DownloadCommand) }
			end

			context "split" do
				let(:command_name){ :split }
				it { expect(subject).to be_an_instance_of(Casteml::Commands::SplitCommand) }
			end

			context "join" do
				let(:command_name){ :join }
				it { expect(subject).to be_an_instance_of(Casteml::Commands::JoinCommand) }
			end

			context "upload" do
				let(:command_name){ :upload }
				it { expect(subject).to be_an_instance_of(Casteml::Commands::UploadCommand) }
			end

			context "convert" do
				let(:command_name){ :convert }
				it { expect(subject).to be_an_instance_of(Casteml::Commands::ConvertCommand) }
			end

			context "spots" do
				let(:command_name){ :spots }
				it { expect(subject).to be_an_instance_of(Casteml::Commands::SpotsCommand) }
			end

			after(:each) do
				CommandManager.clear_instance				
			end			
		end
	end
end
