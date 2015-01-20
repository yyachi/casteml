require 'spec_helper'
require 'casteml/tex_helper'
module Casteml
	describe TexHelper do
		let(:klass){ Class.new.include(TexHelper) }
		let(:obj){ klass.new }
		describe "#tiny" do
			subject{ obj.tiny(content) }
			let(:content){ "Hello World"}
			it {
				expect(subject).to be_eql("\\tiny{#{content}}")
			}
		end
		describe "OverPic" do
			# subject{ obj.overpic_tag(picture, option) }
			# let(:picture){ "picture.jpg"}
			# let(:option){ "width=0.99\\textwidth" }
			before do
				p Casteml::TexHelper::OverPic.new
			end
			it {
				expect(nil).to be_nil			
			}
		end

	end
end