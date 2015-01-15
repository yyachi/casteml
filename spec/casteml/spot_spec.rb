require 'spec_helper'
require 'casteml/spot'
module Casteml
	describe Spot do
		let(:global_id){ '0000-0034'}
		let(:image_uid){ '000-001' }
		let(:image_path){ 'tmp/example.jpg'}
		let(:x_image){ '12.3' }
		let(:y_image){ '23.4' }
		describe ".initialize" do
			subject{ Spot.new(attrib) }
			context "with attrib" do
				let(:attrib){ {:image_uid => image_uid, :image_path => image_path, :x_image => x_image, :y_image => y_image } }			
				it { expect(subject).to be_an_instance_of(Spot) }
				it { expect(subject.image_uid).to be_eql(image_uid) }
				it { expect(subject.image_path).to be_eql(image_path) }				
				it { expect(subject.x_image).to be_eql(x_image) }
				it { expect(subject.y_image).to be_eql(y_image) }
			end
			context "with attrib" do
				let(:attrib){ {:global_id => global_id, 
					:attachment_file_global_id => image_uid, :image_path => image_path, :x_image => x_image, :y_image => y_image } }			
				it { expect(subject).to be_an_instance_of(Spot) }
				it { expect(subject.global_id).to be_eql(global_id) }
				it { expect(subject.attachment_file_global_id).to be_eql(image_uid) }
				it { expect(subject.image_path).to be_eql(image_path) }				
				it { expect(subject.x_image).to be_eql(x_image) }
				it { expect(subject.y_image).to be_eql(y_image) }
			end

		end

		describe "#spot_x", :current => true do
			subject{ obj.spot_x }
			let(:attrib){ {:x_image => x_image }}
			let(:obj){ Spot.new(attrib) }
			let(:ref_image){ double('ref_image', :length => length, :width => width, :height => height)}
			let(:length){ width }
			let(:width){ 4000 }
			let(:height){ 3000 }

			before do
				allow(obj).to receive(:ref_image).and_return(ref_image)
			end

			context "x_image => -50.0" do
				let(:x_image){ -50.0 }
				it {
					expect(subject).to be_eql(0)
				}		
			end



			context "x_image => 0.0" do
				let(:x_image){ 0 }
				it {
					expect(subject).to be_eql(width/2)
				}		
			end

			context "x_image => 10.0" do
				let(:x_image){ 10 }
				it {
					expect(subject).to be_eql(width/2 + length/10 )
				}		
			end


			context "x_image => 50.0" do
				let(:x_image){ 50.0 }
				it {
					expect(subject).to be_eql(width)
				}		
			end

		end

		describe "#spot_y", :current => true do
			subject{ obj.spot_y }
			let(:attrib){ {:y_image => y_image }}
			let(:obj){ Spot.new(attrib) }
			let(:ref_image){ double('ref_image', :length => length, :width => width, :height => height)}
			let(:length){ width }
			let(:width){ 4000 }
			let(:height){ 3000 }

			before do
				allow(obj).to receive(:ref_image).and_return(ref_image)
			end

			context "y_image => 37.5" do
				let(:y_image){ 37.5 }
				it {
					expect(subject).to be_eql(0)
				}		
			end

			context "y_image => 10.0" do
				let(:y_image){ 10.0 }
				it {
					expect(subject).to be_eql(height/2 - length/10)
				}		
			end


			context "y_image => 0.0" do
				let(:y_image){ 0 }
				it {
					expect(subject).to be_eql(height/2)
				}		
			end


			context "y_image => -37.5" do
				let(:y_image){ -37.5 }
				it {
					expect(subject).to be_eql(height)
				}		
			end

		end

		describe "#attachment_file_id" do
			subject{ obj.attachment_file_id }
			let(:obj){ Spot.new() }
			let(:ref_image){ double('ref_images', :class => MedusaRestClient::AttachmentFile, :id => 1212) }
			context "without ref_image" do
				before do
					obj.ref_image = nil
				end
				it { expect(subject).to be_nil }
			end
			context "with ref_image" do
				before do
					obj.ref_image = ref_image
				end
				it { expect(subject).to be_eql(ref_image.id) }
			end


		end

		describe "#ref_image" do
			subject{ obj.ref_image }
			let(:obj){ Spot.new }
			let(:ref_image){ double('ref_images', :class => MedusaRestClient::AttachmentFile) }
			context "without image" do
				it { expect(subject).to be_nil }
			end

			context "with image_uid" do
				before do
					obj.image_uid = image_uid
					allow(MedusaRestClient::Record).to receive(:find).with(image_uid).and_return(ref_image)					
				end
				it { expect(subject).to be_eql(ref_image) }
			end

			context "with image_path" do
				before do
					obj.image_path = image_path
					allow(MedusaRestClient::AttachmentFile).to receive(:find_or_create_by_file).with(image_path).and_return(ref_image)					
				end
				it { expect(subject).to be_eql(ref_image) }
			end
		end

		describe "#save_remote" do
			subject{ obj.save_remote }
			let(:obj){ Spot.new() }
			let(:robj){ double('robj').as_null_object }
			let(:remote_attributes){ double('remote_attributes')}
			let(:remote_hash){ double('remote_hash')}
			let(:ref_image){ double('ref_image') }
			let(:remote_spots){ double('remote_spots')}
			context "non-existing spot" do
				before do
					allow(obj).to receive(:remote_obj).and_return(robj)
					allow(obj).to receive(:ref_image).and_return(ref_image)
					allow(robj).to receive(:new?).and_return(true)
					allow(ref_image).to receive(:spots).and_return(remote_spots)
				end
				it {
					expect(remote_spots).to receive(:<<).with(robj)
					subject
				}
			end

			context "existing spot" do
				before do
					allow(obj).to receive(:remote_obj).and_return(robj)
					allow(obj).to receive(:ref_image).and_return(ref_image)
					allow(obj).to receive(:to_remote_hash).and_return(remote_hash)
					allow(robj).to receive(:new?).and_return(false)
					allow(robj).to receive(:attributes).and_return(remote_attributes)
				end
				it {
					expect(remote_attributes).to receive(:update).with(remote_hash)
					subject
				}

			end
		end

		describe "#to_remote_hash" do
			subject { obj.to_remote_hash }
			let(:obj){ Spot.new(attrib) }
			let(:attachment_file_id){ 1000 }
			let(:target_uid){ '010-0001'}
			context "with valid attributes" do
				let(:attrib){ {:image_uid => image_uid, :x_image => x_image, :y_image => y_image} }
				let(:ref_image){ double('ref_image', :length => length, :width => width, :height => height)}
				let(:length){ width }
				let(:width){ 4000 }
				let(:height){ 3000 }
				before do
					allow(obj).to receive(:ref_image).and_return(ref_image)
					obj.target_uid = target_uid
					allow(obj).to receive(:attachment_file_id).and_return(attachment_file_id)
				end
				it {
					expect(subject).to include(:target_uid => target_uid)
				}

				# it {
				# 	expect(subject).to include(:attachment_file_id => attachment_file_id)
				# }
				it {
					expect(subject).to include(:spot_x)
				}
				it {
					expect(subject).to include(:spot_y)
				}
				it {
					expect(subject).to include(:name => nil)
				}
				it {
					expect(subject).to include(:description => nil)
				}

			end
		end

	end
end
