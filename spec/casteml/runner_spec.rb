require 'spec_helper'
require 'casteml/runner'
module Casteml
	describe Runner do
		describe "#run" do
			let(:args){ ['arg1', 'arg2', '-h'] }
			it { 
				expect(Casteml::CommandManager.instance).to receive(:run).with(args) 
				Runner.new.run args
			}
		end
	end
end
