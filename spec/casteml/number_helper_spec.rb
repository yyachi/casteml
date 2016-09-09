require 'casteml/number_helper'
module Casteml
	describe NumberHelper do
		let(:klass){ Class.new.extend(NumberHelper) }
		describe ".number_to_human" do
			subject { klass.number_to_human(number, opts) }
			let(:klass){ Class.new.extend(NumberHelper) }
			let(:number){ 0.00123456789 }
			let(:opts){ {:precision => precision, :unit => unit, :format => "%n %u", :units => {:centi => 'cg/g', :mili => 'mg/g', :micro => 'ug/g', :nano => 'ng/g', :pico => 'pg/g'} } }
			let(:precision){ 4 }
			let(:unit){ nil }
			before do
				puts subject
			end
			it {
				expect(subject).to be_eql("1.235 mg/g")
			}
			context "with specified unit = ug/g" do
				let(:unit){ 'ug/g' }
				it {
					expect(subject).to be_eql("1235 ug/g")
				}
			end

			context "with specified unit = cg/g" do
				let(:unit){ 'cg/g' }
				it {
					expect(subject).to be_eql("0.1235 cg/g")
				}
			end

		end

		describe ".number_to_unit" do
			subject { klass.number_to_unit(number, :units => {:unit => 'parts', :centi => 'cg/g', :mili => 'mg/g', :micro => 'ug/g', :nano => 'ng/g', :pico => 'pg/g'}) }

			context "with 1.23e+1" do
				let(:number){ 1.23e+1 }
				it {
					expect(subject).to be_eql("parts")
				}
			end

			context "with 1.23e+0" do
				let(:number){ 1.23e+0 }
				it {
					expect(subject).to be_eql("parts")
				}
			end

			context "with 1.23e-1" do
				let(:number){ 1.23e-1 }
				it {
					expect(subject).to be_eql("cg/g")
				}
			end

			context "with 1.23e-2" do
				let(:number){ 1.23e-2 }
				it {
					expect(subject).to be_eql("cg/g")
				}
			end
			context "with 1.23e-3" do
				let(:number){ 1.23e-3 }
				it {
					expect(subject).to be_eql("mg/g")
				}
			end
			context "with 1.23e-4" do
				let(:number){ 1.23e-4 }
				it {
					expect(subject).to be_eql("ug/g")
				}
			end
			context "with 1.23e-5" do
				let(:number){ 1.23e-5 }
				it {
					expect(subject).to be_eql("ug/g")
				}
			end
			context "with 1.23e-6" do
				let(:number){ 1.23e-6 }
				it {
					expect(subject).to be_eql("ug/g")
				}
			end



		end

		describe ".numbers_to_human" do
			subject { klass.numbers_to_human(numbers, opts) }
			let(:klass){ Class.new.extend(NumberHelper) }
			let(:numbers){ [0.123456789, 0.0123456789, 0.00123456789, 1.23456789, 12.3456789] }
			let(:opts){ {:precision => precision, :significant => significant,  :format => "%n %u", :units => {:centi => 'cg/g', :mili => 'mg/g', :micro => 'ug/g', :nano => 'ng/g', :pico => 'pg/g'} } }
			let(:precision){ 4 }
			context "without siginificant" do
				let(:significant){ nil }				
				it {
					expect(subject).to be_eql(["123.4568 mg/g", "12.3457 mg/g", "1.2346 mg/g", "1234.5679 mg/g", "12345.6789 mg/g"])
				}
			end
			context "with significant true" do
				let(:significant){ true }
				it {
					expect(subject).to be_eql(["123.5 mg/g", "12.35 mg/g", "1.235 mg/g", "1235 mg/g", "12350 mg/g"])
				}
			end
		end

		describe ".number_with_error_to_human" do
			subject { klass.number_with_error_to_human(number, error, opts) }
			let(:klass){ Class.new.extend(NumberHelper) }
			let(:number){ 0.123456789 }
			let(:error){ 0.00005 }
			let(:opts){ {:precision => precision, :format => "%n %u", :units => {:centi => 'cg/g', :mili => 'mg/g', :micro => 'ug/g', :nano => 'ng/g', :pico => 'pg/g'} } }
			let(:precision){ 4 }
			before do
				puts subject
			end
			it {
				expect(subject).to be_an_instance_of(String)
			}

		end

		describe ".number_to", :current => true do
			subject { klass.number_to(number, unit) }
			let(:klass){ Class.new.extend(NumberHelper) }
			let(:number){ 0.33333 }
			let(:unit){ :"cg/g" }
			context "33.333 cg/g" do
				it {
					expect(subject).to be_eql(33.333)
				}
			end
			context "specify undefined unit" do
				let(:unit){ :ppc }
				it {
					expect{subject}.to raise_error(RuntimeError, "unit conversion error [#{unit.to_s}]. try casteml --refresh")
				}
			end
		end

		describe ".number_from", :current => true do
			subject { klass.number_from(number, unit) }

			let(:klass){ Class.new.extend(NumberHelper) }
			let(:unit){ :"cg/g" }
			#before do
			#	puts subject
			#end
			context "33.3 cg/g" do
				let(:number){ 33.3 }
				it {
					expect(subject).to be_eql(0.333)
				}
			end

			context "3.33 cg/g" do
				let(:number){ 3.33 }
				it {
					expect(subject).to be_eql(0.0333)
				}
			end

			context "specify undefined unit" do
				let(:number){ 3.33 }
				let(:unit){ :ppc }
				it {
					expect{subject}.to raise_error(RuntimeError, "unit conversion error [#{unit.to_s}]. try casteml --refresh")
				}				
			end

		end

	end
end
