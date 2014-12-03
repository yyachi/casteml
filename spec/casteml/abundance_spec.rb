require 'spec_helper'
require 'casteml/abundance'
module Casteml
	describe Abundance do
		let(:attrib){ {:nickname => nickname, :data => data, :unit => unit, :error => error, :label => label, :info => info } }	
		let(:nickname){ 'SiO2' }
		let(:data){ '34.5' }
		let(:unit){ 'cg/g' }
		let(:error){ '12.5' }
		let(:label){ 'label'}
		let(:info){ 'info'}


		describe ".initialize" do
			subject{ Abundance.new(attrib) }
			context "with attrib" do
				let(:attrib){ {:nickname => nickname, :data => data, :unit => unit, :error => error, :label => label, :info => info } }			
				it { expect(subject).to be_an_instance_of(Abundance) }
				it { expect(subject.nickname).to be_eql(nickname) }
				it { expect(subject.data).to be_eql(data) }
				it { expect(subject.error).to be_eql(error) }
				it { expect(subject.label).to be_eql(label)}
				it { expect(subject.info).to be_eql(info)}				
			end


		end
		describe "#measurement_item_id" do
			subject{ obj.measurement_item_id }
			let(:obj){ Abundance.new(attrib) }
			let(:attrib){ {:nickname => nickname, :data => data, :unit => unit, :error => error, :label => label, :info => info } }			

			let(:measurement_item_obj){ double('measurement_item', :id => measurement_item_id, :name => nickname).as_null_object }

			let(:nickname){ 'SiO2' }
			let(:measurement_item_id){ 100 }

			context "without nickname" do			
				let(:attrib){ {:data => data, :unit => unit, :error => error, :label => label, :info => info } }			
				it { expect(subject).to be_nil }
			end

			context "with nickname" do
				before do
					obj
					allow(MeasurementItem).to receive(:find_or_create_by_name).with(nickname).and_return(measurement_item_obj)
				end
				it "should call MeasurementItem.find_or_create_by_name with nickname" do 
					expect(MeasurementItem).to receive(:find_or_create_by_name).with(nickname).and_return(measurement_item_obj)
					subject
				end
				it { expect(subject).to be_eql(measurement_item_id) }
			end
		end

		describe "#unit_id", :current => true do
			subject{ obj.unit_id }
			let(:obj){ Abundance.new(attrib) }

			context "without unit" do
				let(:attrib){ {:nickname => nickname, :data => data, :error => error, :label => label, :info => info } }
				it { expect(subject).to be_nil }	
			end

			context "with valid unit" do
				let(:attrib){ {:nickname => nickname, :data => data, :unit => unit, :error => error, :label => label, :info => info } }
				let(:unit){ "cg/g" }
				let(:unit_obj){ double('robj', :id => 1, :name => 'centi_gram_per_gram', :conversion => 100, :html => "cg/g", :text => "cg/g" ).as_null_object}
				before do
					allow(Unit).to receive(:find_by_name_or_text).with(unit).and_return(unit_obj)
				end
				it { expect(subject).to be_eql(unit_obj.id) }	
			end

			context "with non-exsiting unit" do
				let(:attrib){ {:nickname => nickname, :data => data, :unit => unit, :error => error, :label => label, :info => info } }
				let(:unit){ "--" }
				#let(:unit_obj){ double('robj', :id => 1, :name => 'centi_gram_per_gram', :conversion => 100, :html => "cg/g", :text => "cg/g" ).as_null_object}
				before do
					allow(Unit).to receive(:find_by_name_or_text).with(unit).and_return(nil)
				end
				it { expect{ subject }.to raise_error }
			end

		end


		describe "#to_remote_hash" do
			subject{ obj.to_remote_hash }
			let(:obj){ Abundance.new(attrib) }
			let(:unit_obj){ double('robj', :id => 1, :name => 'centi_gram_per_gram', :conversion => 100, :html => "cg/g", :text => unit ).as_null_object}
			let(:measurement_item_obj){ double('measurement_item', :id => 2, :name => nickname).as_null_object }

			before do
				obj
				allow(MeasurementItem).to receive(:find_or_create_by_name).with(nickname).and_return(measurement_item_obj)
				allow(Unit).to receive(:find_by_name_or_text).with(unit).and_return(unit_obj)
			end
			it { expect(subject).to be_an_instance_of(Hash) }
			it { expect(subject).to include(:info => info)}
			it { expect(subject).to include(:label => label)}
			it { expect(subject).to include(:value => data)}
			it { expect(subject).to include(:unit_id => unit_obj.id)}
			it { expect(subject).to include(:measurement_item_id => measurement_item_obj.id)}
		end		

		describe "#save_remote" do
			subject{ obj.save_remote }
			let(:obj){ Abundance.new(attrib) }
			let(:remote_hash){ {:value => 12.3} }
			before do
				obj
				allow(obj).to receive(:to_remote_hash).and_return(remote_hash)
			end
			it {
				expect(MedusaRestClient::Chemistry).to receive(:new).with(remote_hash)
				subject
			}
		end

	end
end
