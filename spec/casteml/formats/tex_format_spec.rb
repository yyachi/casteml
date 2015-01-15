require 'spec_helper'
require 'casteml/formats/tex_format'
require 'alchemist'
module Casteml::Formats
	WithCompile = true
	describe TexFormat do
		describe ".document" do
			subject {
				TexFormat.document do |doc|
					doc.puts 'Hello \\LaTeX'
					doc.puts '\\abundance{Si}'
				end
			}
			before do
				puts subject
			end
			let(:path){ 'tmp/deleteme-document.tex'}
			it { expect(subject).to be_an_instance_of(String) }
			it "should be able to compile", :if => WithCompile do
				expect{ texcompile(subject, path) }.not_to raise_error
			end
		end

		describe ".number_with_error_to_human" do
			subject  { TexFormat.number_with_error_to_human(number, error, :format => "%n(%e) %u", :units => {:centi => 'cg/g', :mili => 'mg/g', :micro => 'ug/g', :nano => 'ng/g', :pico => 'pg/g'} )}
			let(:number){ 0.123456789 }
			let(:error){ 0.000456789 }
			before do
				I18n.enforce_available_locales = false
			end
			it {
				expect(subject).to be_eql("12.35(0.05) cg/g")
			}
		end

		describe ".number_to_human" do
			#subject { TexFormat.number_to_human(0.001, :locale => 'ts')}
			subject { TexFormat.number_to_human(number, :precision => precision, :format => "%n %u", :units => {:centi => 'cg/g', :mili => 'mg/g', :micro => 'ug/g', :nano => 'ng/g', :pico => 'pg/g'} )}
			let(:number_in_text){ "0.0001234" }
			let(:number){ 1.23456789e-1 }
			before do
				I18n.enforce_available_locales = false
			end
			context "precision 4" do
				let(:precision){ 4 }
				it { expect(subject).to be_eql("12.35 cg/g") }
			end

			context "precision 3" do
				let(:precision){ 3 }
				it { expect(subject).to be_eql("12.3 cg/g") }
			end
			context "precision 2" do
				let(:precision){ 2 }				
				it { expect(subject).to be_eql("12 cg/g") }
			end
			context "precision 1" do
				let(:precision){ 1 }				
				it { expect(subject).to be_eql("10 cg/g") }
			end


		end

		describe ".tabular" do
			subject {
				TexFormat.tabular('ccc') do |tab|
					tab.puts 'Hello Table'
				end
			}
			it { expect(subject).to be_an_instance_of(String)}
		end

		describe ".escape" do
			subject { TexFormat.escape(string) }
			let(:string){ 'SiO2_error' } 
			before do
				subject
			end
			it { expect(subject).to be_an_instance_of(String)}
		end

		describe ".array_of_arrays2table" do
			subject { TexFormat.array_of_arrays2table(data) }
			let(:data){ [%w(1 2 3), %w(a b c), %w(d e f)]}
			before do
				puts subject
			end
			it { expect(subject).to be_an_instance_of(String)}
		end

		describe ".abundance" do
			subject { TexFormat.abundance(nickname) }
			let(:path) { 'tmp/deleteme.tex' }			
			let(:nickname){ 'Al2.5O3.2'}
			before(:each) do
				setup_empty_dir('tmp')
				#setup_file(path)
				tex = TexFormat.document do |doc|
					doc.puts subject
				end
				File.open(path, "w") do |f|
					f.puts tex
				end
				system("cd #{File.dirname(path)} && pdflatex #{File.basename(path)}")
			end
			it { expect(subject).to be_an_instance_of(String) }
		end

		describe ".to_string" do
			subject { TexFormat.to_string(data, opts) }
			let(:path) { 'tmp/deleteme.tex' }
			let(:opts){ {} }
			let(:data){ [
				{
					"session" => '000', 
					"instrument" => "EPMA",
					"abundances" => [
						{:nickname => 'SiO2', :unit => 'cg/g', :data => '52.345', :error => '0.3'},
						{:nickname => 'Al2O3', :unit => 'cg/g', :data => '12.345'},
						{:nickname => 'MgO', :unit => 'cg/g', :data => '2.123'},						
					]
				}, 
				{
					"session" => '001',
					"instrument" => "EPMA",
					"abundances" => [
						{:nickname => 'SiO2', :unit => 'cg/g', :data => '52.15'},
						{:nickname => 'Al2O3', :unit => 'cg/g', :data => '14.145'},
						{:nickname => 'MgO', :unit => 'cg/g', :data => '1.123'},
						{:nickname => 'Li', :unit => 'ug/g', :data => '0.123'},							
					]
				}
				] }
				before do
					Casteml::MeasurementItem.record_pool = Casteml::MeasurementItem.load_from_dump("spec/fixtures/files/measurement_items.marshal")
				end
			context "with compile" do
				it "should be able to compile", :if => WithCompile do
					expect{ texcompile(TexFormat.document{|doc| doc.puts subject } , path) }.not_to raise_error
				end

			end


			context "with number_format" do
				let(:opts){ {:number_format => '%.3f'} }
				before do
					puts subject
				end
				it {
					expect(subject).to be_an_instance_of(String)
				}

			end
			context "without number_format" do
				let(:opts){ {} }
				before do
					puts subject
				end
				it {
					expect(subject).to be_an_instance_of(String)
				}

			end

		end
	end
end
