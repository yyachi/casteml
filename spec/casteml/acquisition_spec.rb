require 'spec_helper'
require 'casteml/acquisition'
module Casteml
	describe Acquisition do
		describe ".initialize" do
			subject{ Acquisition.new(attrib) }
			let(:attrib){ {:session => session} }
			let(:session){ 'deleteme-1' }
			it { expect(subject).to be_an_instance_of(Acquisition) }
			it { expect(subject.session).to be_eql(session) }
		end

		describe "#save_remote" do
			let(:obj){ Acquisition.new(attrib) }
			let(:attrib){ {:session => session} }
			let(:session){ 'deleteme-1' }
			before do
				obj
			end
			it {
				expect(MedusaRestClient::Analysis).to receive(:new).once
				obj.save_remote
			}
		end

		describe "#remote_attributes" do
			subject{ obj.remote_attributes }
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
