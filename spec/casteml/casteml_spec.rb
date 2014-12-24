require 'spec_helper'
require 'casteml'
module Casteml
	describe ".convert_file" do
		context "with csvfile", :current => true do
			let(:path){'tmp/mytable.csv'}
			let(:data){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
#			before(:each) do
#				setup_empty_dir('tmp')
#				setup_file(path)
#			end

			it {
				expect(Casteml::Formats::CsvFormat).to receive(:decode_file).with(path).and_return(data)
				Casteml.convert_file(path)
			}
		end

	end

	describe ".encode", :current => true do
		let(:data){ [{:session => 'session-1',:sample_name => 'stone-1'},{:session => 'session-2',:sample_name => 'stone-2'}] }
		context "without opts" do
			it {
				expect(Formats::XmlFormat).to receive(:to_string).with(data, {})
				Casteml.encode(data)
			}
		end

		context "with type = :csv" do
			let(:opts){ {:type => :csv}}
			it {
				expect(Formats::CsvFormat).to receive(:to_string).with(data, {})
				Casteml.encode(data, opts)
			}
		end

	end

	describe ".decode_file" do
		context "with pmlfile" do
			let(:path){'tmp/my-great.pml'}
			it {
				expect(Casteml::Formats::XmlFormat).to receive(:decode_file).with(path)
				Casteml.decode_file(path)
			}
		end

		context "with csvfile" do
			let(:path){'tmp/my-great.csv'}
			it {
				expect(Casteml::Formats::CsvFormat).to receive(:decode_file).with(path)
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
