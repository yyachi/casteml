require 'spec_helper'
require 'casteml/tex_helper/over_pic'
module Casteml
	module TexHelper
		describe OverPic do
			let(:overpic){ OverPic.new }

			before(:each) do
			end
			describe "#tiny" do
				subject{ overpic.tiny(content) }
				let(:content){ "hello world" }
				it { expect(subject).to be_eql("\\tiny{#{content}}")}
			end
			describe "#put_isoclock" do
				subject{ overpic.put_isoclock(x_image, y_image, isotope) }
				let(:x_image){ 10.2 }
				let(:y_image){ 22.3 }
				let(:isotope){ -2.3 }
				before(:each) do
					puts subject
				end

				it "put something" do
					expect(subject).to be_an_instance_of(String)
				end
			end
		end
	end
end