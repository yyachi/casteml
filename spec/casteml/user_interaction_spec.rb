require 'spec_helper'
require 'casteml/user_interaction'
module Casteml


	describe UserInteraction do
		let(:klass){ Object.new.extend(UserInteraction) }
		let(:ui) { StreamUI.new(in_stream, out_stream, err_stream, true) }
		let(:in_stream){ double('in_stream').as_null_object }
		let(:out_stream){ double('out_stream').as_null_object }
		let(:err_stream){ double('err_stream').as_null_object }
		before do
			DefaultUserInteraction.ui = ui
		end

		context "ask_yes_no with default" do
			subject{ klass.ask_yes_no message, default }
			let(:message){ 'Are you sure?' }
			let(:answer){ 'yes' }
			context "true" do
				let(:default){ true }
				before do
					allow(in_stream).to receive(:gets).and_return(answer)
				end

				it { 
					expect(out_stream).to receive(:print).with(message + ' [Yn] ') 
					subject
				}
			end

			context "false" do
				let(:default){ false }
				before do
					allow(in_stream).to receive(:gets).and_return(answer)
				end

				it { 
					expect(out_stream).to receive(:print).with(message + ' [yN] ') 
					subject
				}
			end

		end

		context "ask_yes_no without default" do
			subject { klass.ask_yes_no message }
			let(:message){ 'Are you sure?' }
			let(:answer){ 'yes' }
			before do
				allow(out_stream).to receive(:print)
				allow(in_stream).to receive(:gets).and_return(answer)
			end
			it { 
				expect(out_stream).to receive(:print).with(message + ' [yn] ') 
				subject
			}
			it { 
				expect(in_stream).to receive(:gets).and_return(answer) 
				subject
			}
			context "answer yes" do
				let(:answer){ 'yes' }
				before do
					allow(in_stream).to receive(:gets).and_return(answer)
				end
				it { 
					expect(subject).to be_truthy
				}
			end

			context "answer no" do
				let(:answer){ 'no' }
				before do
					allow(in_stream).to receive(:gets).and_return(answer)
				end
				it { 
					expect(subject).to be_falsy
				}
			end
		end

		after do
			DefaultUserInteraction.ui = ConsoleUI.new
		end
	end
end
