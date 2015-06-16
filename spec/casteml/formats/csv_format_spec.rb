require 'spec_helper'
require 'casteml/formats/csv_format'
module Casteml::Formats
	describe CsvFormat do
		describe ".unit_from_numbers", :current => true do
			subject{ CsvFormat.unit_from_numbers(numbers) }
			context "greater than 1.0" do
			let(:numbers){ [12.0, 25.0] }
				it {
					expect(subject).to be_eql('parts')
				}
			end

			context "between 0.9 to 0.01" do
			let(:numbers){ [0.9, 0.01] }
				it {
					expect(subject).to be_eql('%')
				}
			end

			context "between 0.001" do
			let(:numbers){ [0.001] }
				it {
					expect(subject).to be_eql('permil')
				}
			end

			context "0.000001" do
			let(:numbers){ [0.000001] }
				it {
					expect(subject).to be_eql('ppm')
				}
			end

			context "between 0.9e-8 to 0.1e-9" do
			let(:numbers){ [0.001, 0.000000004] }
				it {
					expect(subject).to be_eql('ppb')
				}
			end

		end
		describe ".to_string" do
			subject { CsvFormat.to_string(data, opts) }
			let(:org_string){ <<-EOF
ID,session,sample_name,SiO2 (cg/g),Al2O3 (cg/g),Li (ug/g),SiO2_error,Al2O3_error,Li_error
,test-1,sample-1,12.4,2.4,3.4,0.9,0.2,0.01
,test-2,sample-2,34.5,,4.5,,,
					EOF
			}
			let(:opts){ {} }
			let(:data){ CsvFormat.decode_string(org_string) }
			
			it { expect(subject).to be_an_instance_of(String) }
			it { expect(subject).to match(/ID,session/)}


			context "with transpose" do
				let(:opts){ {:transpose => true} }
				it {
					expect(subject).to match(Regexp.new("session,test-1"))
				}
			end

			context "with unit", :current => true do
				let(:opts){ {:with_unit => 'ppm'}}
				let(:data){
					[
						{:session => 1, :abundances => [{:nickname => 'SiO2', :data => '12.345', :unit => 'cg/g'},{:nickname => 'Li', :data => '1.345', :unit => 'ug/g'}]},
						{:session => 1, :abundances => [{:nickname => 'SiO2', :data => '14.345', :unit => 'cg/g'},{:nickname => 'Li', :data => '0.00000001245', :unit => 'cg/g'}]},						
						{:session => 1, :abundances => [{:nickname => 'SiO2', :data => '0.15345'},{:nickname => 'Li', :data => '1.145', :unit => 'ug/g'}]},
					]
				}
				it {
					puts subject
					expect(subject).to be_an_instance_of(String)
				}
			end

			context "with unit false", :current => true do
				let(:opts){ {:with_unit => false} }
				let(:data){
					[
						{:session => 1, :abundances => [{:nickname => 'SiO2', :data => '12.345', :unit => '%'},{:nickname => 'Pb206zPb204', :data => '1.345'}]},
						{:session => 1, :abundances => [{:nickname => 'SiO2', :data => '0.14345'},{:nickname => 'Pb206zPb204', :data => '23.45'}]},						
						{:session => 1, :abundances => [{:nickname => 'SiO2', :data => '0.15345'},{:nickname => 'Pb206zPb204', :data => '1.145'}]},
					]
				}
				it {
					puts subject
					expect(subject).to be_an_instance_of(String)
				}
			end

			context "without unit", :current => true do
				let(:opts){ {:with_unit => 'parts'} }
				let(:data){
					[
						{:session => 1, :abundances => [{:nickname => 'SiO2', :data => '12.345', :unit => '%'},{:nickname => 'Pb206zPb204', :data => '1.345'}]},
						{:session => 1, :abundances => [{:nickname => 'SiO2', :data => '0.14345'},{:nickname => 'Pb206zPb204', :data => '23.45'}]},						
						{:session => 1, :abundances => [{:nickname => 'SiO2', :data => '0.15345'},{:nickname => 'Pb206zPb204', :data => '1.145'}]},
					]
				}
				it {
					puts subject
					expect(subject).to be_an_instance_of(String)
				}
			end

			context "with omit_null" do
				subject { CsvFormat.to_string(data, opts) }
				let(:data){
					[
						{:session => 1, :abundances => [{:nickname => 'B', :data => '12.345', :unit => 'ug/g'},{:nickname => 'Lu', :data => '1.345', :unit => 'ug/g'}]},
						{:session => 2, :abundances => [{:nickname => 'SiO2', :data => '14.345', :unit => 'cg/g'},{:nickname => 'Li', :data => '0.00000001245', :unit => 'cg/g'}]},						
						{:session => 3, :abundances => [{:nickname => 'Si', :data => '0.15345'},{:nickname => 'Lu', :data => '1.145', :unit => 'ug/g'}]},
					]
				}
				let(:opts){ {:with_nicknames => %w(Lu Ba B), :omit_null => true} }
				before do
					puts subject
				end
				it {
					expect(subject).to be_an_instance_of(String)
					expect(subject.split("\n").count).to be_eql(3)
				}
			end

			context "with opts col_sep => '\t'" do
				subject { CsvFormat.to_string(data, opts) }
				let(:opts){ {:col_sep => "\t" } }
				it {
					expect(subject).to match(/ID\tsession/)
				}
			end


			context "with col_sep => '|'" do
				let(:opts){ {:col_sep => "|"} }
				it { expect(subject).to match(/ID\|session/) }
			end
			context "with opts {:without_error => true, :with_unit => g/g}" do
				subject { CsvFormat.to_string(data, opts) }
				let(:opts){ {:without_error => true, :with_unit => "g/g" } }
				it {
					expect(subject).to be_an_instance_of(String)
				}
			end

			context "with opts {:with_nicknames => ['SiO2', 'TiO2', 'Al2O3']}" do
				subject { CsvFormat.to_string(data, opts) }
				let(:opts){ {:with_nicknames => %w(SiO2 TiO2 Al2O3) } }
				it {
					expect(subject).to be_an_instance_of(String)
				}
			end

			context "with spot" do
				let(:org_string){ <<-EOF
	ID,session,sample_name,spot_x_image,spot_y_image
	,test-1,sample-1,12.4,2.4
	,test-2,sample-2,34.5,4.5
						EOF
				}
				before do
					puts subject
				end
				it {
					expect(subject).to be_an_instance_of(String)
				}

			end
		end

		describe ".tab_separated" do
			subject { CsvFormat.tab_separated?(string) }
			context "with tab-separated string" do
				let(:string){ <<-EOF
ID\tsession
					EOF
				}
				it {
					expect(subject).to be_truthy
				}
			end
			context "with canmma-separated string" do
				let(:string){ <<-EOF
ID,session
					EOF
				}
				it {
					expect(subject).to be_falsey
				}
			end
		end

		describe ".to_method_array" do
			subject { CsvFormat.to_method_array(array)}
			let(:array){ %w(ID session technique stone-ID SiO2) }
			it {
				expect(subject).to include(:stone_ID)
			}
			context "with nil item" do
				let(:array){ %w(ID session technique SiO2) }
				before do
					array << nil
				end
				it {
					expect(subject.size).to be_eql(3)
				}				
			end
			context "with nil item" do
				let(:array){ %w(ID test-1 test-2 test-3) }
				before do
					array << nil
				end
				it {
					expect(subject.size).to be_eql(1)
				}				
			end

		end

		describe ".column_wise?" do
			subject { CsvFormat.column_wise?(string)}
			context "transposed csv" do
				let(:string){ <<-EOF
session,,test-1,test-2
technique,,EPMA,EPMA
instrument,,JXA-8800,JXA-8800
sample_name,,sample-1,sample-2
SiO2,cg/g,34.5,24.5
						EOF
				}
				it { expect(subject).to be_truthy }
			end

			context "inline unit" do
				let(:string){ <<-EOF
ID,session,sample_name,SiO2 (cg/g)
,test-1,sample-1,12.4
,test-2,sample-2,34.5
						EOF
				}
				it { expect(subject).to be_falsey }				
			end
		end

		describe ".org2csv", :current => true do
			subject { CsvFormat.org2csv(string) }

			context "with template" do
				let(:string){ <<-EOF
#+TBLNAME: castemls					
|ID|session|technique|
|-
|111|test-1|EPMA|
|222|test-2|XRF|
						EOF
				}
				it { expect(subject).not_to match(/TBLNAME/) }
			end

			context "with normal table" do
				let(:string){ <<-EOF
+TBLNAME: castemls					
|ID|session|technique|
|-
|111|test-1|EPMA|
|222|test-2|XRF|
						EOF
				}
				it { expect(subject).to be_truthy }
				it { expect(subject).not_to match(/TBLNAME/) }
			end

			context "with tab table" do
				let(:string){ <<-EOF
+TBLNAME: castemls					
|	ID	|	session	|	technique 	|
|-
|	111	|	test-1 	|	EPMA 		|
|	222	|	test-2 	|	XRF 		|
						EOF
				}
				it { expect(subject).to be_truthy }
			end
		end
		describe ".org_mode?", :current => true do
			subject { CsvFormat.org_mode?(string) }
			context "with template" do
				let(:string){ <<-EOF
#+TBLNAME: castemls					
|ID|session|technique|
|-
|111|test-1|EPMA|
|222|test-2|XRF|
						EOF
				}
				it { expect(subject).to be_truthy }
			end

			context "with normal table" do
				let(:string){ <<-EOF
+TBLNAME: castemls					
|ID|session|technique|
|-
|111|test-1|EPMA|
|222|test-2|XRF|
						EOF
				}
				it { expect(subject).to be_truthy }
			end

			context "with tab table" do
				let(:string){ <<-EOF
+TBLNAME: castemls					
|	ID	|	session	|	technique 	|
|-
|	111	|	test-1 	|	EPMA 		|
|	222	|	test-2 	|	XRF 		| 	
						EOF
				}
				it { expect(subject).to be_truthy }
			end

			context "with empty table" do
				let(:string){ <<-EOF
+TBLNAME: castemls					
						EOF
				}
				it { expect(subject).not_to be_truthy }
			end

			context "with csv" do
				let(:string){ <<-EOF		
ID,session,technique
111,test|-1,EPMA
222,test-2,XRF
						EOF
				}
				it { expect(subject).not_to be_truthy }
			end

		end

		describe ".transpose" do
			subject { CsvFormat.transpose(string) }
			context "transposed csv" do
				let(:string){ <<-EOF
ID,
session,,test-1,test-2,test-3,test-4,test-5,test-6
technique,,EPMA,EPMA
instrument,,JXA-8800,JXA-8800
sample_name,,sample-1,sample-2
SiO2,cg/g,34.5,34.4,,23.5,,36.5
Al2O3,cg/g,,,3.4,5.4,,
						EOF
				}
				before do
					puts subject
				end
				it { expect(subject).to be_an_instance_of(String) }
			end

		end

		describe ".decode_string" do
			subject { CsvFormat.decode_string(string) }

			context "with tempfile.tsv" do
				let(:path){ 'tmp/invalid_line_feed.tsv'}
				let(:string){ File.read(path) }
				#let(:string){ "session,name\r\n1,hello\r\n2,world\r\n" }
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(path)
				end
				it {
					expect(subject[0]).to include("session" => "Allende-13")					
				}
			end

			context 'with \n' do
				let(:string){ "session,name\n1,hello\n2,world\n" }
				it {
					expect(subject[0]).to include("session" => "1")					
					expect(subject[1]).to include("session" => "2")					
				}
			end

			context 'with \r\n' do
				let(:string){ "session,name\r\n1,hello\r\n2,world\r\n" }
				it {
					expect(subject[0]).to include("session" => "1")					
					expect(subject[1]).to include("session" => "2")					
				}
			end

			context 'with \r\r\n' do
				let(:string){ "session,name\r\r\n1,hello\r\r\n2,world\r\r\n" }
				it {
					expect(subject[0]).to include("session" => "1")					
					expect(subject[1]).to include("session" => "2")					
				}
			end

			context "with empty string" do
				let(:string){ "" }
				it {
					expect{subject}.to raise_error
				}
			end

			context "with empty data" do
				let(:string){ "session,name" }
				it {
					expect(subject).to be_empty
				}
			end

			context "with empty line" do
				let(:string){ <<-EOF
session,technique
111,EPMA
,,
					EOF
				}
				it {
					expect{ subject }.to raise_error
				}
			end

			context "with empty column" do
				let(:string){ <<-EOF
session,technique,,
111,EPMA,,
					EOF
				}
				it {
					expect{ subject }.not_to raise_error
				}
			end

			context "with session only" do
				let(:string){ <<-EOF
session
test-1
test-2
						EOF
				}

				it {
					expect(subject).not_to be_empty
					expect(subject[0]).to include("session")
				}
			end

			context "with empty session row" do
				let(:string){ <<-EOF
ID,session,technique
111,test-1,EPMA
,
						EOF
				}
				it {
					expect{subject}.to raise_error
				}
			end

			context "with empty name row" do
				let(:string){ <<-EOF
ID,name,technique
111,test-1,EPMA
2,
						EOF
				}
				it {
					expect{subject}.to raise_error
				}
			end

			context "with empty session,name row" do
				let(:string){ <<-EOF
ID,session,name,technique
111,test-1,EPMA
2,
						EOF
				}
				it {
					expect{subject}.to raise_error
				}
			end

			context "with tab separated" do
				let(:string){ <<-EOF
ID\tsession\ttechnique
111\ttest-1\tEPMA
222\ttest-2\tXRF
						EOF
				}
				it { expect(subject[0]).to include("ID" => "111") }
				it { expect(subject[0]).to include("session" => "test-1") }
				it { expect(subject[0]).to include("technique" => "EPMA") }
			end

			context "with org_mode" do
				let(:string){ <<-EOF
+TBLNAME: casteml
|ID|session|technique|
|111|test-1|EPMA|
|222|test-2|XRF|
						EOF
				}
				it { expect(subject[0]).to include("ID" => "111") }
				it { expect(subject[0]).to include("session" => "test-1") }
				it { expect(subject[0]).to include("technique" => "EPMA") }
			end

			context "with tab inserted org_mode" do
				let(:string){ <<-EOF
+TBLNAME: casteml
| 	ID 	|	session 	|	technique 	|
|	111	|	test-1 		|	EPMA 		|
|	222	|	test-2 		|	XRF 		|
										EOF
				}
				it { expect(subject[0]).to include("ID" => "111") }
				it { expect(subject[0]).to include("session" => "test-1") }
				it { expect(subject[0]).to include("technique" => "EPMA") }
			end


			context "abundance with error" do
				let(:string){ <<-EOF
ID,session,stone-ID,bib-ID,SiO2 (cg/g),SiO2_error,Al2O3 (cg/g),Al2O3_error
,test-1,010-1,001-001,12.4,0.3,23.4,1.5
,test-2,020-2,001-002,34.5,0.1,23.5,0.4
						EOF
				}
				it { expect(subject.size).to be_eql(2) }
				it { expect(subject[0]).to include("ID") }
				it { expect(subject[0]).to include("stone-ID") }
				it { expect(subject[0]).to include("bib-ID") }								
				it { expect(subject[0][:abundances][0]).to include(:nickname => "SiO2") }
				it { expect(subject[0][:abundances][0]).to include(:unit => "cg/g") }
				it { expect(subject[0][:abundances][0]).to include(:data => "12.4") }
				it { expect(subject[0][:abundances][0]).to include(:error => "0.3") }						
				it { expect(subject[0][:abundances][1]).to include(:nickname => "Al2O3") }
				it { expect(subject[0][:abundances][1]).to include(:unit => "cg/g") }
				it { expect(subject[0][:abundances][1]).to include(:data => "23.4") }
				it { expect(subject[0][:abundances][1]).to include(:error => "1.5") }						

			end


			context "inline unit" do
				let(:string){ <<-EOF
ID,session,stone-ID,bib-ID,SiO2 (cg/g)
,test-1,010-1,001-001,12.4
,test-2,020-2,001-002,34.5
						EOF
				}
				it { expect(subject.size).to be_eql(2) }
				it { expect(subject[0]).to include("ID") }
				it { expect(subject[0]).to include("stone-ID") }
				it { expect(subject[0]).to include("bib-ID") }								
				it { expect(subject[0][:abundances][0]).to include(:nickname => "SiO2") }
				it { expect(subject[0][:abundances][0]).to include(:unit => "cg/g") }
				it { expect(subject[0][:abundances][0]).to include(:data => "12.4") }				

			end

			context "separate unit with keyword" do
				let(:string){ <<-EOF
ID,session,sample_name,SiO2,B
UNIT,,,cg/g,ug/g
,test-1,sample-1,12.4,1.2
,test-2,sample-2,34.5,3.4
						EOF
				}
				it { expect(subject.size).to be_eql(2) }
				it { expect(subject[0][:abundances][0]).to include(:nickname => "SiO2") }
				it { expect(subject[0][:abundances][0]).to include(:unit => "cg/g") }
				it { expect(subject[0][:abundances][0]).to include(:data => "12.4") }				
				it { expect(subject[0]).to include("ID") }
				#it { expect(subject[0][:abundances][0]).to include(:nickname => "SiO2") }
			end
			context "separate unit with session nil" do
				let(:string){ <<-EOF
ID,session,sample_name,SiO2,B
,,,cg/g,ug/g
,test-1,sample-1,12.4,1.2
,test-2,sample-2,34.5,3.4
						EOF
				}
				it { expect(subject.size).to be_eql(2) }
				it { expect(subject[0][:abundances][0]).to include(:nickname => "SiO2") }
				it { expect(subject[0][:abundances][0]).to include(:unit => "cg/g") }
				it { expect(subject[0][:abundances][0]).to include(:data => "12.4") }				
				it { expect(subject[0]).to include("ID") }
				#it { expect(subject[0][:abundances][0]).to include(:nickname => "SiO2") }
			end

			context "separate unit with name nil" do
				let(:string){ <<-EOF
ID,name,sample_name,SiO2,B
,,,cg/g,ug/g
,test-1,sample-1,12.4,1.2
,test-2,sample-2,34.5,3.4
						EOF
				}
				it { expect(subject.size).to be_eql(2) }
				it { expect(subject[0][:abundances][0]).to include(:nickname => "SiO2") }
				it { expect(subject[0][:abundances][0]).to include(:unit => "cg/g") }
				it { expect(subject[0][:abundances][0]).to include(:data => "12.4") }				
				it { expect(subject[0]).to include("ID") }
				#it { expect(subject[0][:abundances][0]).to include(:nickname => "SiO2") }
			end

			context "with spot" do
				let(:string){ <<-EOF
ID,session,sample_name,spot_image_path,spot_x_image,spot_y_image
,test-1,sample-1,tmp/deleteme.jpg,70.15,45.47
,test-2,sample-2,tmp/deleteme.jpg,34.5,3.4
						EOF
				}
				it { expect(subject[0][:spot]).to include(:image_path => 'tmp/deleteme.jpg')}
				it { expect(subject[0][:spot]).to include(:x_image => "70.15") }
				it { expect(subject[0][:spot]).to include(:y_image => "45.47") }

			end

			context "transposed csv" do
				let(:string){ <<-EOF
session,test-1,test-2
technique,EPMA,EPMA
instrument,JXA-8800,JXA-8800
sample_name,sample-1,sample-2
SiO2 (cg/g),34.5,24.5
						EOF
				}
				it { expect(subject.size).to be_eql(2) }
				it { expect(subject[0]).to include("session") }
				it { expect(subject[0][:abundances][0]).to include(:nickname => "SiO2") }
				it { expect(subject[0][:abundances][0]).to include(:unit => "cg/g") }
				it { expect(subject[0][:abundances][0]).to include(:data => "34.5") }				

			end
		end


		# describe ".decode_file" do
		# 	let(:file){ 'example.csv'}
		# 	let(:input_io){ double('input_io').as_null_object }
		# 	let(:doc){ double('doc').as_null_object }
		# 	let(:array){ [{:session => 'deleteme-1'}, {:session => 'deleteme-2'}] }
		# 	before do
		# 		allow(File).to receive(:open).with(file).and_return(input_io)
		# 	end

		# 	it {
		# 		#expect(REXML::Document).to receive(:new).with(input_io).and_return(doc)				
		# 		#expect(CsvFormat).to receive(:decode_doc).with(doc).and_return(array)
		# 		expect(CsvFormat.decode_file(file)).to be_eql(array)
		# 	}
		# end

	end
end
