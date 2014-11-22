require 'spec_helper'
require 'casteml/formats/xml_format'
module Casteml::Formats
	describe XmlFormat do

		describe ".join_docs" do
			let(:doc1){ REXML::Document.new '<?xml version="1.0" encoding="UTF-8" ?><acquisition><abundance></abundance></acquisition>' }
			let(:doc2){ REXML::Document.new '<?xml version="1.0" encoding="UTF-8" ?><acquisitions><acquisition><abundance></abundance></acquisition><acquisition><abundance></abundance></acquisition></acquisitions>' }
			let(:docs){ [doc1, doc2] }
			before do
				@doc = XmlFormat.join_docs(docs)
			end
			it { expect(@doc).to be_an_instance_of(REXML::Document) }
			it { expect(@doc.root.name).to be_eql('acquisitions') }
			it { expect(@doc.get_elements('acquisitions/acquisition').size).to be_eql(3) }
		end

		describe ".split_doc" do
			let(:doc){ REXML::Document.new '<?xml version="1.0" encoding="UTF-8" ?><acquisitions><acquisition><abundance></abundance></acquisition><acquisition><abundance></abundance></acquisition></acquisitions>' }
			it { expect(XmlFormat.split_doc(doc)).to be_an_instance_of(Array) }
		end

		describe ".split_file" do
			let(:file){ 'example.pml' }
			let(:sfile1){ File.join(dirname, basename) + '@1' + extname}
			let(:sfile2){ File.join(dirname, basename) + '@2' + extname}			
			let(:dirname){ File.dirname(file)}
			let(:basename){ File.basename(file,".*")}
			let(:extname){ File.extname(file)}
			let(:input_io){ double('input_io').as_null_object }
			let(:output_io1){ double('output_io1').as_null_object }
			let(:output_io2){ double('output_io2').as_null_object }


			let(:doc){ double('doc').as_null_object }
			let(:sdocs){ [sdoc1, sdoc2]}
			let(:sdoc1){ double('sdoc1').as_null_object }
			let(:sdoc2){ double('sdoc2').as_null_object }

			before do
				allow(File).to receive(:open).with(file).and_return(input_io)
			end
			it {
				expect(REXML::Document).to receive(:new).with(input_io).and_return(doc)
				expect(XmlFormat).to receive(:split_doc).with(doc).and_return(sdocs)
				expect(File).to receive(:open).with(sfile1,'w').and_yield(output_io1)
				expect(File).to receive(:open).with(sfile2,'w').and_yield(output_io2)
				expect(Casteml::Formats::XmlFormat).to receive(:write).with(sdoc1, output_io1)
				expect(Casteml::Formats::XmlFormat).to receive(:write).with(sdoc2, output_io2)


				files = XmlFormat.split_file(file)
				expect(files).to include(sfile1)
				expect(files).to include(sfile2)
			}
		end



		describe ".join_files", :current => true do
			let(:paths){ [path1, path2] }
			let(:path1){ 'tmp/example-1.pml' }
			let(:path2){ 'tt/example-2.pml' }
			let(:doc){ double('doc').as_null_object }			
			let(:doc1){ double('doc1').as_null_object }
			let(:doc2){ double('doc2').as_null_object }
			let(:input1){ double('input1').as_null_object }
			let(:input2){ double('input2').as_null_object }
			let(:output){ double('output', :path => outpath ).as_null_object }
			let(:outpath){ 'tmp/joined-xxxxx.pml'}

			it { 
				expect(File).to receive(:open).with(path1).and_return(input1)
				expect(REXML::Document).to receive(:new).with(input1).and_return(doc1)
				expect(File).to receive(:open).with(path2).and_return(input2)
				expect(REXML::Document).to receive(:new).with(input2).and_return(doc2)				
				expect(XmlFormat).to receive(:join_docs).with([doc1, doc2]).and_return(doc)
				expect(Tempfile).to receive(:open).and_return(output)
				expect(Casteml::Formats::XmlFormat).to receive(:write).with(doc, output)
				path = XmlFormat.join_files(paths)
				expect(path).to be_eql(outpath)
			}
		end

		describe ".split_and_join" do
			let(:pml_path){'tmp/ys_pl_bytownite_c.pml'}
			let(:original){ REXML::Document.new(File.read(pml_path)) }
			let(:splited_paths){ Casteml::Formats::XmlFormat.split_file(pml_path) }
			let(:joined_path){ Casteml::Formats::XmlFormat.join_files(splited_paths) }
			let(:splited_and_joined){ REXML::Document.new(File.read(joined_path))}
			before(:each) do
				setup_empty_dir('tmp')
				setup_file(pml_path)
				splited_paths
				joined_path
				original
				splited_and_joined
			end

			it { expect(splited_and_joined.get_elements('acquisitions/acquisition').size).to be_equal(original.get_elements('acquisitions/acquisition').size) }
		end

	end
end
 