require 'spec_helper'
require 'casteml/unit'
module Casteml
	describe Unit do
		let(:klass){ Unit }
		let(:ui) { StreamUI.new(in_stream, out_stream, err_stream, true) }
		let(:in_stream){ double('in_stream').as_null_object }
		let(:out_stream){ double('out_stream').as_null_object }
		let(:err_stream){ double('err_stream').as_null_object }
		let(:remote_class){ MedusaRestClient::Unit }

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
				expect(remote_class).to receive(:find).with(:all)
				subject
			}
		end

		describe ".find_by_name_or_text", :current => true do
			subject { klass.find_by_name_or_text(name_or_text) }
			let(:name_or_text){ name }
			let(:name){ 'centi_gram_per_gram' }
			let(:text){ 'cg/g'}
			let(:records){ [robj_1, robj_2, robj_3] }
			let(:robj_1){ double('robj', :id => 1, :name => 'parts', :conversion => 1, :html => "", :text => "" ).as_null_object }
			let(:robj_2){ double('robj', :id => 1, :name => 'centi_gram_per_gram', :conversion => 100, :html => "cg/g", :text => "cg/g" ).as_null_object}
			let(:robj_3){ double('robj', :id => 1, :name => 'micro_gram_per_gram', :conversion => 1000000, :html => "\u0026micro;g/g", :text => "ug/g" ).as_null_object}


			before do
				klass.record_pool = []
				allow(remote_class).to receive(:find).with(:all).and_return(records)
			end

			it {
				expect(remote_class).to receive(:find).with(:all)
				subject
			}

			context "with existing name" do
				it { subject.to be_eql(robj_2) }
			end

			context "with existing text" do
				let(:name_or_text){ text }
				it { 
					expect(klass).to receive(:find_by_text).with(name_or_text)
					subject
				}
				it { subject.to be_eql(robj_2) }
			end

			context "with non-existing name_or_text" do
				let(:name_or_text){ "unk" }
				it { expect(subject).to be_nil }
			end

		end
	end
end