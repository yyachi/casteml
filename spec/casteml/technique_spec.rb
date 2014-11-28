require 'spec_helper'
require 'casteml/technique'
module Casteml
	describe Technique do
		describe ".find_by_name" do
			subject { Technique.find_or_create_by_name(name) }

			let(:name){ 'tech-2' }
			let(:records){ [tech1, tech2, tech3] }
			let(:tech1){ double('tech-1', :id => 1, :name => 'tech-1').as_null_object }
			let(:tech2){ double('tech-2', :id => 2, :name => 'tech-2').as_null_object }
			let(:tech3){ double('tech-3', :id => 3, :name => 'tech-3').as_null_object }
			context "with empty record_pool" do
				before do
					Technique.record_pool = []
				end

				it { 
					expect(MedusaRestClient::Technique).to receive(:find).with(:all).and_return(records) 
					subject
				}
			end

			context "with non-empty record_pool" do
				before do
					Technique.record_pool = records
				end

				it { 
					expect(MedusaRestClient::Technique).not_to receive(:find).with(:all) 
					subject
				}
			end

			context "without match record and answer yes" do
				let(:name){ 'new-tech' }
				let(:new_obj){ double('new_obj', :id => 100, :name => name)}
				before do
					Technique.record_pool = records
				end
				it {
					expect(Technique).to receive(:ask_yes_no).with("<Technique: new-tech> does not exist. Are you sure you want to create it?").and_return(true)
					expect(MedusaRestClient::Technique).to receive(:create).with(:name => name).and_return(new_obj)
					expect(subject).to be_eql(new_obj)
				}
			end

			context "without match record and answer no" do
				let(:name){ 'new-tech' }
				before do
					Technique.record_pool = records
				end
				it {
					expect(Technique).to receive(:ask_yes_no).with("<Technique: new-tech> does not exist. Are you sure you want to create it?").and_return(nil)
					expect(MedusaRestClient::Technique).not_to receive(:create).with(:name => name)
					expect{ subject }.to raise_error
				}
			end


		end
	end
end