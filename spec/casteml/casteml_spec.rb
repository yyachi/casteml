require 'spec_helper'
require 'casteml'
module Casteml
	describe ".decode_file" do
		context "with pmlfile" do
			let(:path){'tmp/my-great.pml'}
			it {
				expect(Casteml::Formats::XmlFormat).to receive(:decode_file).with(path)
				Casteml.decode_file(path)
			}
		end
	end

	describe ".save_remote" do
		let(:hash_1){ {:session => 'deleteme-1'} }
		let(:hash_2){ {:session => 'deleteme-2'} }
		let(:instance_1){ double('instance-1').as_null_object }
		let(:instance_2){ double('instance-2').as_null_object }

		before do
			allow(Acquisition).to receive(:new).with(hash_1).and_return(instance_1)
			allow(Acquisition).to receive(:new).with(hash_2).and_return(instance_2)	
		end

		context "with array_of_hash" do
			let(:data){ [hash_1, hash_2] }	

			it {
				expect(Acquisition).to receive(:new).twice
				expect(instance_1).to receive(:save_remote)
				expect(instance_2).to receive(:save_remote)				
				Casteml.save_remote(data)
			}


		end

		context "with hash" do
			let(:data){ hash_1 }	

			it {
				expect(Acquisition).to receive(:new).once
				expect(instance_1).to receive(:save_remote)
				Casteml.save_remote(data)
			}
		end

	end
end
