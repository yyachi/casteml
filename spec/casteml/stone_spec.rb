require 'spec_helper'
require 'casteml/stone'
module Casteml
	describe Stone do
		let(:ui) { StreamUI.new(in_stream, out_stream, err_stream, true) }
		let(:in_stream){ double('in_stream').as_null_object }
		let(:out_stream){ double('out_stream').as_null_object }
		let(:err_stream){ double('err_stream').as_null_object }

		describe ".record_pool" do
			subject { Stone.record_pool }
			let(:name){ 'deleteme-1' }
			before do
				Stone.record_pool = []
			end
			it {
				expect(MedusaRestClient::Stone).not_to receive(:find).with(:all)
				subject
			}
		end

		describe ".find_by_global_id" do
			subject { Stone.find_by_global_id(global_id) }
			let(:remote_obj){ double('remote', :class => MedusaRestClient::Stone).as_null_object }
			let(:global_id){ '000-001' }
			before do
				allow(MedusaRestClient::Record).to receive(:find).with(global_id).and_return(remote_obj)
			end
			it {
				expect(subject).to be_eql(remote_obj)
			}
		end

		describe ".find_or_create_by_name" do
			subject { Stone.find_or_create_by_name(name) }
			let(:name){ 'stone-2' }
			let(:stone_1){ double('stone-1', :name => 'stone-1', :global_id => '000-001').as_null_object }
			let(:stone_2){ double('stone-2', :name => 'stone-2', :global_id => '000-002').as_null_object }
			let(:stone_3){ double('stone-3', :name => 'stone-3', :global_id => '000-003').as_null_object }

			let(:records){ [] }
			before do
				DefaultUserInteraction.ui = ui
				Stone.record_pool = records
				allow(in_stream).to receive(:gets).and_return("yes")
			end

			context "with local objects" do
				let(:records){ [stone_1, stone_2, stone_3] }

				it {
					expect(subject).to be_eql(stone_2)
				}

			end

			context "no remote objects" do
				let(:message){ "<MedusaRestClient::Stone: #{name}> does not exist. Are you sure you want to create it?" }
				let(:answer){ true }
				before do
					allow(MedusaRestClient::Stone).to receive(:find_by_name).with(name).and_return([])
					allow(ui).to receive(:ask_yes_no).with(message, true).and_return(true)
					allow(MedusaRestClient::Stone).to receive(:create).with({:name => name}).and_return(stone_2)
				end

				it { 
					expect(MedusaRestClient::Stone).to receive(:find_by_name).with(name).and_return([])
					subject
				}

				context "positive answer" do
					let(:answer){ true }
					it "create remote object" do
						expect(MedusaRestClient::Stone).to receive(:create).with({:name => name}).and_return(stone_2)
						subject
					end
				end

				context "negative answer" do
					let(:answer){ false }
					it "raise_error and not create remote object" do
						expect(MedusaRestClient::Stone).not_to receive(:create).with({:name => name})
						expect{ subject }.to raise_error
					end
				end
			end

			context "some remote objects" do
				let(:records){ [stone_1, stone_2, stone_3] }
				let(:message){ "select one" }
				let(:new_obj){ double(name).as_null_object }
				let(:select){ 1 }
				before do
					Stone.record_pool = []
					allow(MedusaRestClient::Stone).to receive(:find_by_name).with(name).and_return(records)
					allow(in_stream).to receive(:gets).and_return('1')
				end
				context "choose remote object" do
					it {
						expect(ui).to receive(:choose_from_list).with(message, records.map{|robj| "#{robj.name} <ID: #{robj.global_id}>"}.push("create new one")).and_return(select)
						expect(subject).to be_eql(records[select])
					}
				end
				context "choose create new one" do
					it {
						expect(ui).to receive(:choose_from_list).with(message, records.map{|robj| "#{robj.name} <ID: #{robj.global_id}>"}.push("create new one")).and_return(records.size)
						expect(MedusaRestClient::Stone).to receive(:create).with({:name => name}).and_return(new_obj)
						expect(subject).to be_eql(new_obj)
					}
				end

			end

			

			after do
				DefaultUserInteraction.ui = ConsoleUI.new
			end
		end
	end
end