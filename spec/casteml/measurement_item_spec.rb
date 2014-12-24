require 'spec_helper'
require 'casteml/measurement_item'
module Casteml
	describe MeasurementItem do
		let(:klass){ MeasurementItem }
		let(:ui) { StreamUI.new(in_stream, out_stream, err_stream, true) }
		let(:in_stream){ double('in_stream').as_null_object }
		let(:out_stream){ double('out_stream').as_null_object }
		let(:err_stream){ double('err_stream').as_null_object }
		let(:remote_class){ MedusaRestClient::MeasurementItem }

		before do
			#DefaultUserInteraction.ui = ui
			#klass.set_remote_class(remote_class)
		end


		describe ".record_pool" do
			subject { klass.record_pool }
			let(:name){ 'deleteme-1' }
			before do
				klass.record_pool = []
			end
			it {
				expect(remote_class).not_to receive(:find).with(:all)
				subject
			}
		end


		describe ".find_or_create_by_name" do
			subject { klass.find_or_create_by_name(name) }

			let(:name){ 'Elem-2' }
			let(:records){ [item1, item2, item3] }
			let(:item1){ double('item-1', :id => 1, :nickname => 'Elem-1').as_null_object }
			let(:item2){ double('item-2', :id => 2, :nickname => 'Elem-2').as_null_object }
			let(:item3){ double('item-3', :id => 3, :nickname => 'Elem-3').as_null_object }
			context "with empty record_pool" do
				before do
					klass.record_pool = []
					allow(remote_class).to receive(:find_by_nickname).and_return(item2)
				end

				it { 
					expect(remote_class).to receive(:find_by_nickname).with(name).and_return(item2) 
					subject
				}
	
			end

			context "with non-empty record_pool" do
				before do
					klass.record_pool = records
				end

				it { 
					expect(remote_class).not_to receive(:find).with(:all) 
					subject
				}
			end

			context "without match record and answer yes" do
				let(:name){ 'SiO2' }
				let(:new_obj){ double('new_obj', :id => 100, :nickname => name)}
				let(:message){ "<#{remote_class}: #{name}> does not exist. Are you sure you want to create it?" }
				before do
					klass.record_pool = records
					allow(remote_class).to receive(:find_by_nickname).with(name).and_return(nil)
				end
				it {
					expect(klass).to receive(:ask_yes_no).with(message, true).and_return(true)
					expect(remote_class).to receive(:create).with(:nickname => name).and_return(new_obj)
					expect(subject).to be_eql(new_obj)
				}
			end

			context "without match record and answer no" do
				let(:name){ 'new-tech' }
				let(:message){ "<#{remote_class}: #{name}> does not exist. Are you sure you want to create it?" }				
				before do
					klass.record_pool = records
					allow(remote_class).to receive(:find_by_nickname).with(name).and_return(nil)					
				end
				it {
					expect(klass).to receive(:ask_yes_no).with(message, true).and_return(false)
					expect(remote_class).not_to receive(:create)
					expect{ subject }.to raise_error
				}
			end



		end


	end
end