require 'spec_helper'
require 'casteml/runner'
module Casteml
	describe Runner do
		describe "#run" do
			subject {Runner.new.run args}
			let(:args){ ['arg1', 'arg2', '-h'] }
			it { 
				expect(Casteml::CommandManager.instance).to receive(:run).with(args) 
				subject
			}

			context "without args" do
				let(:args){ [] }
				it { 
#					expect(Casteml::CommandManager.instance).to receive(:run).with(args) 
					expect{subject}.to raise_error
				}

			end

			context "with invalid args" do
				let(:args){ ['convert', 'arg2'] }
				it { 
#					expect(Casteml::CommandManager.instance).to receive(:run).with(args) 
					expect{subject}.to raise_error
				}

			end

		end
	end
end
