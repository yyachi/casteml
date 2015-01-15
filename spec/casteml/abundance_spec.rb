require 'spec_helper'
require 'casteml/abundance'
require 'alchemist'
module Casteml
	describe Abundance do
		let(:attrib){ {:nickname => nickname, :data => data, :unit => unit, :error => error, :label => label, :info => info } }	
		let(:nickname){ 'SiO2' }
		let(:data){ '34.53' }
		let(:unit){ 'cg/g' }
		let(:error){ '0.21' }
		let(:label){ 'label'}
		let(:info){ 'info'}

		describe ".precision", :current => true do
			subject { Abundance.precision(data, error) }
			let(:data){ 12.3456789 }
			context "with error 0.03" do
				let(:error){ 0.03 }
				it { expect(subject).to be_eql(4) }
			end

			context "with error 0.3" do
				let(:error){ 0.3 }
				it { expect(subject).to be_eql(3) }
			end

			context "with error 3" do
				let(:error){ 3 }
				it { expect(subject).to be_eql(2) }
			end

			context "with error 30" do
				let(:error){ 30 }
				it { expect(subject).to be_eql(1) }
			end

			context "with error 300" do
				let(:error){ 300 }
				it { expect(subject).to be_eql(1) }
			end

			context "with error 3000" do
				let(:error){ 3000 }
				it { expect(subject).to be_eql(1) }
			end


		end

		describe ".initialize" do
			subject{ Abundance.new(attrib) }
			context "with new type attrib" do
				let(:attrib){ {:nickname => nickname, :value => data, :unit => unit, :uncertainty => error, :label => label, :info => info } }			
				let(:data){ "12.3456" }
				let(:error){ "0.02" }
				let(:unit){ "cg/g" }
				it { expect(subject).to be_an_instance_of(Abundance) }
				it { expect(subject.nickname).to be_eql(nickname) }
				it { expect(subject.data).to be_eql(data) }
				it { expect(subject.data_in_parts).to be_eql(data.to_f/100) }				
				it { expect(subject.error).to be_eql(error) }
				it { expect(subject.error_in_parts).to be_eql(error.to_f/100) }								
				it { expect(subject.precision).to be_eql(4) }				
				it { expect(subject.unit).to be_eql(unit)}
				it { expect(subject.label).to be_eql(label)}
				it { expect(subject.info).to be_eql(info)}				
			end

			context "with error and unit" do
				let(:attrib){ {:nickname => nickname, :data => data, :unit => unit, :error => error, :label => label, :info => info } }			
				let(:data){ "12.3456" }
				let(:error){ "0.02" }
				let(:unit){ "cg/g" }
				it { expect(subject).to be_an_instance_of(Abundance) }
				it { expect(subject.nickname).to be_eql(nickname) }
				it { expect(subject.data).to be_eql(data) }
				it { expect(subject.data_in_parts).to be_eql(data.to_f/100) }				
				it { expect(subject.error).to be_eql(error) }
				it { expect(subject.error_in_parts).to be_eql(error.to_f/100) }								
				it { expect(subject.precision).to be_eql(4) }				
				it { expect(subject.unit).to be_eql(unit)}
				it { expect(subject.label).to be_eql(label)}
				it { expect(subject.info).to be_eql(info)}				
			end

			context "without unit" do
				let(:attrib){ {:nickname => nickname, :data => data, :error => error, :label => label, :info => info } }			
				let(:data){ "12.3456" }
				let(:error){ "0.02" }
				it { expect(subject).to be_an_instance_of(Abundance) }
				it { expect(subject.nickname).to be_eql(nickname) }
				it { expect(subject.data).to be_eql(data) }
				it { expect(subject.data_in_parts).to be_eql(data.to_f) }				
				it { expect(subject.error).to be_eql(error) }
				it { expect(subject.error_in_parts).to be_eql(error.to_f) }								
				it { expect(subject.precision).to be_eql(4) }				
				it { expect(subject.unit).to be_eql(:parts)}
				it { expect(subject.label).to be_eql(label)}
				it { expect(subject.info).to be_eql(info)}				
			end

			context "without error", :current => true do
				let(:attrib){ {:nickname => nickname, :data => data, :unit => unit, :label => label, :info => info } }			
				let(:data){ "33.3" }
				let(:unit){ "cg/g" }
				before do
					puts data
					puts subject.data_in_parts
				end
				it { expect(subject).to be_an_instance_of(Abundance) }
				it { expect(subject.nickname).to be_eql(nickname) }
				it { expect(subject.data).to be_eql(data) }
				it { expect(subject.data_in_parts.to_s).to be_eql("0.333") }				
				it { expect(subject.precision).to be_nil }				
				it { expect(subject.unit).to be_eql(unit)}
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

		describe "#unit_id" do
			subject{ obj.unit_id }
			let(:obj){ Abundance.new(attrib) }

			context "without unit" do
				let(:attrib){ {:nickname => nickname, :data => data, :error => error, :label => label, :info => info } }
				let(:unit_obj){ double('robj', :id => 1, :name => 'parts', :conversion => 1, :html => "", :text => "" ).as_null_object}
				before do
					allow(Unit).to receive(:find_by_name_or_text).with("parts").and_return(unit_obj)
				end

				it { expect(subject).to be_eql(unit_obj.id) }	
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

		describe "#remote_obj" do
			subject { obj.remote_obj }
			let(:obj){ Abundance.new(attrib) }
			before do
				obj
				allow(obj).to receive(:to_remote_hash).and_return({})
			end
			it { expect(subject).to be_an_instance_of(MedusaRestClient::Chemistry) }
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
