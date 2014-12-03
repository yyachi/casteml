require 'spec_helper'
require 'casteml/remote_interaction'

module Casteml


	describe RemoteInteraction do
		let(:klass){ Class.new.extend(RemoteInteraction) }
		let(:ui) { StreamUI.new(in_stream, out_stream, err_stream, true) }
		let(:in_stream){ double('in_stream').as_null_object }
		let(:out_stream){ double('out_stream').as_null_object }
		let(:err_stream){ double('err_stream').as_null_object }
		let(:remote_class){ double('Remote').as_null_object }
		before do
#			DefaultUserInteraction.ui = ui
			klass.set_remote_class(remote_class)
		end

		it {
			expect(remote_class).to receive(:find).with(:all).and_return([])
			klass.get_records
		}
		describe ".find_by_global_id", :current => true do
			subject { klass.find_by_global_id(global_id) }
			let(:global_id){ '000-001' }
			let(:remote_obj){ double('remote_obj', :class => remote_class, :global_id => global_id).as_null_object }
			it {
				expect(MedusaRestClient::Record).to receive(:find).with(global_id).and_return(remote_obj)
				expect(subject).to be_eql(remote_obj)
			}

			context "with other class's global_id" do
				let(:remote_obj){ double('remote_obj', :class => double('Example').as_null_object, :global_id => global_id).as_null_object }
				before do
					allow(MedusaRestClient::Record).to receive(:find).with(global_id).and_return(remote_obj)
				end			
				it {
					expect{ subject }.to raise_error
				}

			end

			context "with global_id does not exist" do
				let(:error){ ActiveResource::ResourceNotFound.new('error') }
				before do
					allow(MedusaRestClient::Record).to receive(:find).with(global_id).and_raise(error)
				end			
				it {
					expect{ subject }.to raise_error
				}
			end
		end

		describe ".find_or_create_by_name" do
			subject { klass.find_or_create_by_name(name) }

			let(:name){ 'tech-2' }
			let(:records){ [tech1, tech2, tech3] }
			let(:tech1){ double('tech-1', :id => 1, :name => 'tech-1').as_null_object }
			let(:tech2){ double('tech-2', :id => 2, :name => 'tech-2').as_null_object }
			let(:tech3){ double('tech-3', :id => 3, :name => 'tech-3').as_null_object }
			context "with empty record_pool" do
				before do
					klass.record_pool = []
				end

				it { 
					expect(remote_class).to receive(:find).with(:all).and_return(records) 
					subject
				}
			end

			context "with non-empty record_pool" do
				before do
					klass.record_pool = records
				end

				it { 
					expect(remote_class).not_to receive(:find).with(:all) 
					subject
				}
			end

			context "without match record and answer yes" do
				let(:name){ 'new-tech' }
				let(:new_obj){ double('new_obj', :id => 100, :name => name)}
				let(:message){ "<#{remote_class}: #{name}> does not exist. Are you sure you want to create it?" }
				before do
					klass.record_pool = records
				end
				it {
					expect(klass).to receive(:ask_yes_no).with(message, true).and_return(true)
					expect(remote_class).to receive(:create).with(:name => name).and_return(new_obj)
					expect(subject).to be_eql(new_obj)
				}
			end

			context "without match record and answer no" do
				let(:name){ 'new-tech' }
				let(:message){ "<#{remote_class}: #{name}> does not exist. Are you sure you want to create it?" }				
				before do
					klass.record_pool = records
				end
				it {
					expect(klass).to receive(:ask_yes_no).with(message, true).and_return(false)
					expect(remote_class).not_to receive(:create).with(:name => name)
					expect{ subject }.to raise_error
				}
			end



		end

		describe "instance" do

			let(:klass1) do
				Class.new do
					extend Casteml::RemoteInteraction
					set_remote_class MedusaRestClient::Stone
					attr_accessor :name, :data
					attr_remote :nickname, :value
					alias_attribute :nickname, :name
					alias_attribute :value, :data

					def nickname
						name
					end

				end
			end
			let(:obj1){ klass1.new({:name => 'test'} ) }

			let(:klass2) do
				Class.new do
					extend Casteml::RemoteInteraction
					set_remote_class MedusaRestClient::Analysis
					attr_accessor :name, :value
					attr_remote :name, :value
					#set_remote_attributes [:name, :value]

				end
			end
			let(:obj2){ klass2.new({:name => 'test', :value => 34.5} ) }

			it { expect(obj1).to be_an_instance_of(klass1)}
			it { expect(obj1.to_remote_hash).to be_an_instance_of(Hash) }
			describe "#to_remote_hash" do
				subject{ obj.to_remote_hash }
				let(:obj){ klass1.new(attrib) }
				let(:attrib){ {:name => name} }
				let(:name){ 'test' }
				before do
					obj
				end
				it { expect(subject).to be_an_instance_of(Hash) }
				it { expect(subject).to include(:nickname => name)}
			end		
			describe "#save_remote", :current => true do
				subject{ obj.save_remote }
				let(:obj){ klass1.new(attrib) }
				let(:attrib){ {:name => name} }
				let(:name){ 'test' }
				it { 
					expect(MedusaRestClient::Stone).to receive(:new).with({:nickname => name, :value => nil})
					subject
				}

			end
		end

	end
end