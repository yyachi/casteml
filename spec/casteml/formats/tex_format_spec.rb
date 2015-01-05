require 'spec_helper'
require 'casteml/formats/tex_format'
module Casteml::Formats
	describe TexFormat do
		describe ".document" do
			subject {
				TexFormat.document do |doc|
					doc.puts 'Hello \\LaTeX'
				end
			}
			it { expect(subject).to be_an_instance_of(String) }
		end


		describe ".tabular" do
			subject {
				TexFormat.tabular('ccc') do |tab|
					tab.puts 'Hello Table'
				end
			}
			it { expect(subject).to be_an_instance_of(String)}
		end

		describe ".escape", :current => true do
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

		describe ".abundance", :current => true do
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
			context "with compile" do

				before(:each) do
					setup_empty_dir('tmp')
					#setup_file(path)
					File.open(path, "w") do |f|
						f.puts subject
					end
					system("cd #{File.dirname(path)} && pdflatex #{File.basename(path)}")
				end
				it {
					expect(subject).to be_an_instance_of(String)
				}
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
