require 'spec_helper'
require 'casteml/device'
module Casteml
	describe Device do

		describe ".record_pool" do
			subject { Device.record_pool }
			let(:name){ 'deleteme-1' }
			before do
				Device.record_pool = []
			end
			it {
				expect(MedusaRestClient::Device).to receive(:find).with(:all)
				subject
			}
		end

	end
end