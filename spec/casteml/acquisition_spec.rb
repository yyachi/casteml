require 'spec_helper'
require 'casteml/acquisition'
module Casteml
	describe Acquisition do
		let(:session){ 'deleteme-1' }
		let(:analyst){ 'Yusuke Yachi' }
		let(:description){ 'Hello casteml'}

		describe ".initialize" do
			subject{ Acquisition.new(attrib) }
			context "with old type attrib" do
				let(:attrib){ {:session => session, :description => description, :analyst => analyst } }			
				it { expect(subject).to be_an_instance_of(Acquisition) }
				it { expect(subject.session).to be_eql(session) }
				it { expect(subject.description).to be_eql(description) }
				it { expect(subject.analyst).to be_eql(analyst) }
				it { expect(subject.name).to be_eql(session)}
			end

			context "with new type attrib" do
			 	let(:attrib){ {:name => session, :description => description, :operator => analyst } }			
			 	it { expect(subject).to be_an_instance_of(Acquisition) }
			 	it { expect(subject.session).to be_eql(session) }
			 	it { expect(subject.description).to be_eql(description) }
			 	it { expect(subject.analyst).to be_eql(analyst) }
			end

		end

		describe ".name" do
			let(:obj){ Acquisition.new() }
			let(:name){ 'deleteme-1' }
			before do
				obj.name = name
			end
			it {
				expect(obj.name).to be_eql(name)
				expect(obj.session).to be_eql(name)
			}
		end

		describe "#abundances" do
			subject{ obj.abundances }
			let(:obj){ Acquisition.new(attrib) }
			context "without abundances" do
				let(:attrib){ {:session => session, :analyst => analyst, :description => description} }
				it { expect(subject).to be_empty }				
			end

			context "with abundances" do
				let(:attrib){ {:session => 'deleteme-1', :instrument => nil, :abundances => [{:nickname => 'Li'}] } }
				it { expect(subject).not_to be_empty }				
			end


		end

		describe "#stone_id" do
			subject{ obj.stone_id }
			let(:obj){ Acquisition.new(attrib) }
			let(:stone_obj){ double(sample_uid, :id => stone_id, :global_id => sample_uid, :name => sample_name).as_null_object }
			let(:sample_uid){ '000000-1' }
			let(:sample_name){ 'sample-1' }
			let(:stone_id){ 300 }

			context "without sample" do			
				let(:attrib){ {:session => session, :analyst => analyst, :description => description} }
				it { expect(subject).to be_nil }
			end
			context "with sample_uid" do
				let(:attrib){ {:session => session, :analyst => analyst, :description => description, :sample_uid => sample_uid } }				
				before do
					obj
					allow(Stone).to receive(:find_by_global_id).with(sample_uid).and_return(stone_obj)
				end
				it "should call Stone.find_by_global_id with sample_uid" do 
					expect(Stone).to receive(:find_by_global_id).with(sample_uid).and_return(stone_obj) 
					subject
				end
				it { expect(subject).to be_eql(stone_id) }
			end

			context "with sample_name" do
				let(:attrib){ {:session => session, :analyst => analyst, :description => description, :sample_name => sample_name } }
				before do
					obj
					allow(Stone).to receive(:find_or_create_by_name).with(sample_name).and_return(stone_obj)
				end
				it "should call Stone.find_or_create_by_name with sample_name" do 
					expect(Stone).to receive(:find_or_create_by_name).with(sample_name).and_return(stone_obj) 
					subject
				end
				it { expect(subject).to be_eql(stone_id) }

			end
		end

		describe "#technique_id" do
			subject{ obj.technique_id }
			let(:obj){ Acquisition.new(attrib) }
			let(:technique_obj){ double(technique, :id => technique_id, :name => technique).as_null_object }
			let(:attrib){ {:session => session, :analyst => analyst, :description => description, :technique => technique } }
			let(:technique){ 'EPMA' }
			let(:technique_id){ 100 }

			context "without technique" do			
				let(:attrib){ {:session => session, :analyst => analyst, :description => description} }
				it { expect(subject).to be_nil }
			end

			context "with tequnique" do
				before do
					obj
					allow(Technique).to receive(:find_or_create_by_name).with(technique).and_return(technique_obj)
				end
				it "should call Technique.find_or_create_by_name with sample_name" do 
					expect(Technique).to receive(:find_or_create_by_name).with(technique).and_return(technique_obj)
					subject
				end
				it { expect(subject).to be_eql(technique_id) }
			end
		end

		describe "#device_id" do
			subject{ obj.device_id }
			let(:obj){ Acquisition.new(attrib) }
			let(:device_obj){ double(device, :id => device_id, :name => device).as_null_object }
			let(:device){ 'JXA-8800' }
			let(:device_id){ 120 }
			context "without device" do			
				let(:attrib){ {:session => session, :analyst => analyst, :description => description} }
				it { expect(subject).to be_nil }
			end

			context "with device" do

				let(:attrib){ {
					:session => session, 
					:analyst => analyst, 
					:description => description, 
					:device => device
				} }		
				before do
					obj
					allow(Device).to receive(:find_or_create_by_name).with(device).and_return(device_obj)
				end
				it "should call Device.find_or_create_by_name with device" do
					expect(Device).to receive(:find_or_create_by_name).with(device).and_return(device_obj)
					subject
				end
				it { expect(subject).to be_eql(device_id) }
			end

		end

		describe "#remote_obj", :current => true do
			subject { obj.remote_obj }
			let(:obj){ Acquisition.new(attrib) }
			let(:attrib){ {:global_id => '000-001', :session => 'hello'} }
			let(:global_id){ '000-001' }
			let(:robj){ double('robj', :global_id => global_id, :class => obj.class.remote_class ) }
			context "with global_id" do
				it {
					expect(MedusaRestClient::Record).to receive(:find).with(global_id).and_return(robj)
					subject
				}
			end
			context "with uid" do
				let(:attrib){ {:uid => '000-001', :session => 'hello'} }				
				it {
					expect(MedusaRestClient::Record).to receive(:find).with(global_id).and_return(robj)
					subject
				}
			end
			context "with id" do
				let(:attrib){ {:id => id, :session => 'hello'} }				
				let(:id){ 100 }
				it {
					expect(obj.class.remote_class).to receive(:find).with(id).and_return(robj)
					subject
				}
			end
			context "without any id" do
				let(:attrib){ {:session => 'hello'} }				
				let(:id){ 100 }
				let(:remote_hash){ {:session => 'world'} }
				before do
					allow(obj).to receive(:to_remote_hash).and_return(remote_hash)
				end
				it {
					expect(obj.class.remote_class).to receive(:new).with(remote_hash).and_return(robj)
					subject
				}
			end




		end


		describe "#save_spot", :current => true do
			subject { obj.save_spot }
			let(:obj){ Acquisition.new() }
			let(:robj){ double('robj', :id => 100, :global_id => '090') }
			let(:spot){ double('spot') }

			before do
				allow(obj).to receive(:remote_obj).and_return(robj)
				allow(obj).to receive(:spot).and_return(spot)
				allow(spot).to receive(:target_uid=)
				allow(spot).to receive(:save_remote)
			end
			it "call spot.target_uid = robj.global_id" do
				expect(spot).to receive(:target_uid=).with(robj.global_id)
				subject
			end
			it "call spot.save_remote" do
				expect(spot).to receive(:save_remote)
				subject
			end
		end

		describe "#save_abundances" do
			subject{ obj.save_abundances }
			let(:obj){ Acquisition.new(attrib) }
			let(:attrib){ {:session => 'deleteme-1' } }
			let(:abundances){ [ab1] }
			let(:ab1){ double('ab1', :nickname => 'SiO2', :data => 11.5)}
			let(:robj){ double('robj', :id => 110, :name => session) }
			let(:rchemobj){ double('rchem', :measurement_item_id => 4, :value => 11.5).as_null_object }
			let(:chem1){ double('chem1', :measurement_item_id => 1, :value => 11.5).as_null_object }
			let(:chem2){ double('chem2', :measurement_item_id => 2, :value => 11.5).as_null_object }
			let(:chem3){ double('chem3', :measurement_item_id => 3, :value => 11.5).as_null_object }
			let(:existing){ double('rchem', :measurement_item_id => 1, :value => 11.5).as_null_object }

			before do
				allow(ab1).to receive(:analysis_id=)
				allow(ab1).to receive(:to_remote_hash).and_return({})
				allow(ab1).to receive(:remote_obj).and_return(rchemobj)
				allow(robj).to receive(:chemistries).and_return([chem1, chem2, chem3])
				allow(obj).to receive(:abundances).and_return(abundances)
				allow(obj).to receive(:remote_obj).and_return(robj)
			end
			context "with non-existing chemistries" do
				before do
					allow(ab1).to receive(:measurement_item_id).and_return(5)
				end
				it {
					expect(rchemobj).to receive(:save)
					subject
				}
			end

			context "with existing chemistries" do
				before do
					allow(ab1).to receive(:measurement_item_id).and_return(1)
				end
				it {
					expect(chem1).to receive(:update_attributes)
					subject
				}
			end
		end

		describe "#save_remote" do
			subject{ obj.save_remote }
			let(:obj){ Acquisition.new(attrib) }
			let(:attrib){ {:session => session, :analyst => analyst, :description => description} }
			let(:remote_hash){ double('hash') }
			let(:robj){ double('robj', :name => session, :description => description, :operator => analyst, :device_id => nil, :technique_id => nil) }
			context "without any id" do
				before do
					obj
					allow(robj).to receive(:new?).and_return(true)
					allow(obj).to receive(:remote_obj).and_return(robj)
				end
				it "calls remote_obj.save" do
					expect(robj).to receive(:save).and_return(true)
					subject
				end
			end

			context "with existing remote_obj", :current => true do
				let(:rattrib){ double('attrib') }
				let(:rhash){ double('rhash') }
				before do
					obj
					allow(robj).to receive(:new?).and_return(false)

					allow(obj).to receive(:remote_obj).and_return(robj)
					allow(obj).to receive(:to_remote_hash).and_return(rhash)
					allow(robj).to receive(:save).and_return(true)
					allow(rattrib).to receive(:update)					
					allow(robj).to receive(:attributes).and_return(rattrib)
				end
				it "calls remote_obj.attributes.update with remote_hash" do
					expect(robj).to receive(:attributes).and_return(rattrib)
					expect(rattrib).to receive(:update).with(rhash).and_return(true)
					subject
				end
				it "calls remote_obj.save" do
					expect(robj).to receive(:save).and_return(true)
					subject
				end

			end

			context "with abundances" do
				let(:attrib){ {:session => 'deleteme-1', :abundances => abundances } }
				let(:abundances){ [ab1, ab2] }
				let(:ab1){ {:nickname => 'SiO2', :data => '12.5', :unit => 'cg/g'}}
				let(:ab2){ {:nickname => 'Li', :data => '0.12', :unit => 'ug/g'}}
				before do
					obj
					allow(robj).to receive(:new?).and_return(true)		
					allow(obj).to receive(:remote_obj).and_return(robj)
				end
				context "with save => true" do
					before do
						allow(robj).to receive(:save).and_return(true)
					end
					it "calls save_abundances" do
						expect(obj).to receive(:save_abundances)
						subject
					end
				end
				context "with save => false" do
					before do
						allow(robj).to receive(:save).and_return(false)
					end
					it "not calls save_abundances" do
						expect(obj).not_to receive(:save_abundances)
						subject
					end
				end

			end

			context "with spot" do
				let(:spot){ double('spot') }
				before do
					obj
					allow(obj).to receive(:spot).and_return(spot)
					allow(robj).to receive(:new?).and_return(true)		
					allow(obj).to receive(:remote_obj).and_return(robj)
				end
				context "with save => true" do
					before do
						allow(robj).to receive(:save).and_return(true)
					end
					it "calls save_spot" do
						expect(obj).to receive(:save_spot)
						subject
					end
				end
				context "with save => false" do
					before do
						allow(robj).to receive(:save).and_return(false)
					end
					it "not calls save_spot" do
						expect(obj).not_to receive(:save_spot)
						subject
					end
				end

			end
		end

		describe "#to_remote_hash" do
			subject{ obj.to_remote_hash }
			let(:obj){ Acquisition.new(attrib) }
			let(:attrib){ {:session => session, :description => description, :analyst => analyst} }
			before do
				obj
			end
			it { expect(subject).to be_an_instance_of(Hash) }
			it { expect(subject).to include(:name => session)}
			it { expect(subject).to include(:description => description)}
			it { expect(subject).to include(:operator => analyst)}

			context "with sample_uid" do
				let(:attrib){ {:session => session, :analyst => analyst, :description => description, :sample_uid => sample_uid } }				
				let(:stone_obj){ double(sample_uid, :id => stone_id).as_null_object }
				let(:sample_uid){ '000000-1' }
				let(:stone_id){ 300 }
				before do
					obj
					allow(Stone).to receive(:find_by_global_id).with(sample_uid).and_return(stone_obj)
				end
				it {
					expect(subject).to include(:stone_id => stone_id)
				}			
			end

			context "with sample_name" do
				let(:stone_obj){ double(sample_name, :id => stone_id).as_null_object }
				let(:attrib){ {:session => session, :analyst => analyst, :description => description, :sample_name => sample_name } }
				let(:sample_name){ 'sample-1' }
				let(:stone_id){ 300 }
				before do
					obj
					allow(Stone).to receive(:find_or_create_by_name).with(sample_name).and_return(stone_obj)
				end
				it {
					expect(subject).to include(:stone_id => stone_id)
				}			
			end

			context "with tequnique" do
				let(:technique_obj){ double(technique, :id => technique_id, :name => technique).as_null_object }
				let(:attrib){ {:session => session, :analyst => analyst, :description => description, :technique => technique } }
				let(:technique){ 'EPMA' }
				let(:technique_id){ 100 }
				before do
					obj
					allow(Technique).to receive(:find_or_create_by_name).with(technique).and_return(technique_obj)
				end
				it {
					expect(subject).to include(:technique_id => technique_id)
				}
			end
			context "with device" do
				let(:device_obj){ double(device, :id => device_id, :name => device).as_null_object }
				let(:attrib){ {
					:session => session, 
					:analyst => analyst, 
					:description => description, 
					:device => device
					} }		
				let(:device){ 'JXA-8800' }
				let(:device_id){ 120 }
				before do
					obj
					allow(Device).to receive(:find_or_create_by_name).with(device).and_return(device_obj)
				end
				it {
					expect(subject).to include(:device_id => device_id)
				}
			end

		end
	end
end
