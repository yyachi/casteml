require 'spec_helper'
require 'casteml/measurement_category'
module Casteml
	describe MeasurementCategory do
		let(:klass){ MeasurementCategory }
		let(:ui) { StreamUI.new(in_stream, out_stream, err_stream, true) }
		let(:in_stream){ double('in_stream').as_null_object }
		let(:out_stream){ double('out_stream').as_null_object }
		let(:err_stream){ double('err_stream').as_null_object }
		let(:remote_class){ MedusaRestClient::MeasurementCategory }

		before do
			#DefaultUserInteraction.ui = ui
			#klass.set_remote_class(remote_class)
		end

		describe ".dump_path" do
			subject { klass.dump_path }
			it {
				expect(subject).to be_present
			}
		end

		describe ".record_pool" do
			subject { klass.record_pool }
			it {
				expect(subject).to be_present
			}
		end

		describe "#nicknames" do
			let(:obj){klass.find_by_name('trace')}
			before do
			end
			it {
				expect(obj.nicknames).to be_present
			}
		end


		describe ".record_pool" do
			subject { klass.record_pool }
			let(:name){ 'deleteme-1' }
			before do
				klass.record_pool = []
			end
			#it { expect(subject).not_to be_empty }
			context "with dumpfile" do
				it {
					expect(remote_class).not_to receive(:find).with(:all)
					expect(klass).to receive(:load_from_dump)
					subject
				}
			end
			context "without dumpfile" do
				before do
					klass.record_pool = []
					#FileUtils.rm(klass.dump_path) if File.exist?(klass.dump_path)
					allow(File).to receive(:exist?).with(klass.dump_path).and_return(false)
				end
				it {
					expect(klass).to receive(:dump_all)
					expect(klass).to receive(:load_from_dump)					
					subject
				}

			end
		end
	end
end