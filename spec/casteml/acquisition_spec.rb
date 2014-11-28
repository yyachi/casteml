require 'spec_helper'
require 'casteml/acquisition'
module Casteml
	describe Acquisition do
		describe ".initialize" do
			subject{ Acquisition.new(attrib) }
			let(:session){ 'deleteme-1' }
			let(:analyst){ 'Yusuke Yachi' }
			let(:description){ 'Hello casteml'}
			context "with old type attrib" do
				let(:attrib){ {:session => session, :description => description, :analyst => analyst } }			
				it { expect(subject).to be_an_instance_of(Acquisition) }
				it { expect(subject.session).to be_eql(session) }
				it { expect(subject.description).to be_eql(description) }
				it { expect(subject.analyst).to be_eql(analyst) }
				it { expect(subject.name).to be_eql(session)}
			end

			context "with new type attrib" do
			 	let(:attrib){ {:name => session, :description => description, :operator => analyst } }			
			 	it { expect(subject).to be_an_instance_of(Acquisition) }
			 	it { expect(subject.session).to be_eql(session) }
			 	it { expect(subject.description).to be_eql(description) }
			 	it { expect(subject.analyst).to be_eql(analyst) }
			end

		end

		describe ".name" do
			let(:obj){ Acquisition.new() }
			let(:name){ 'deleteme-1' }
			before do
				obj.name = name
			end
			it {
				expect(obj.name).to be_eql(name)
				expect(obj.session).to be_eql(name)
			}
		end

		describe "with tequnique" do
			let(:obj){ Acquisition.new(attrib) }
			let(:technique_obj){ double(technique, :id => technique_id, :name => technique).as_null_object }
			let(:attrib){ {:session => session, :analyst => analyst, :description => description, :technique => technique } }
			let(:session){ 'deleteme-1' }
			let(:description){ 'hello' }
			let(:analyst){ 'Yusuke Yachi'}
			let(:technique){ 'EPMA' }
			let(:technique_id){ 100 }
			before do
				obj
				allow(Technique).to receive(:find_or_create_by_name).with(technique).and_return(technique_obj)
			end
			it {
				expect(MedusaRestClient::Analysis).to receive(:new).with({:name => session, :description => description, :operator => analyst, :technique_id => technique_id }).once
				obj.save_remote
			}
		end

		describe "#save_remote" do
			let(:obj){ Acquisition.new(attrib) }
			let(:attrib){ {:session => session, :analyst => analyst, :description => description} }
			let(:session){ 'deleteme-1' }
			let(:description){ 'hello' }
			let(:analyst){ 'Yusuke Yachi'}
			before do
				obj
			end
			it {
				expect(MedusaRestClient::Analysis).to receive(:new).with({:name => session, :description => description, :operator => analyst, :technique_id => nil}).once
				obj.save_remote
			}
		end

		describe "#to_remote_hash", :current => true do
			subject{ obj.to_remote_hash }
			let(:obj){ Acquisition.new(attrib) }
			let(:attrib){ {:session => session, :description => description, :analyst => analyst} }
			let(:session){ 'deleteme-1' }
			let(:description){ 'Hello World'}
			let(:analyst){ 'YY' }
			before do
				obj
			end
			it { expect(subject).to be_an_instance_of(Hash) }
			it { expect(subject).to include(:name => session)}
			it { expect(subject).to include(:description => description)}
			it { expect(subject).to include(:operator => analyst)}


		end
	end
end
