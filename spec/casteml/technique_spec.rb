require 'spec_helper'
require 'casteml/technique'
module Casteml
	describe Technique do
		describe ".record_pool" do
			subject { Technique.record_pool }
			let(:name){ 'deleteme-1' }
			before do
				Technique.record_pool = []
			end
			it {
				expect(MedusaRestClient::Technique).to receive(:find).with(:all)
				subject
			}
		end
	end
end