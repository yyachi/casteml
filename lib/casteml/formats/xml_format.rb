require 'rexml/document'
require 'tempfile'
module Casteml::Formats
	class XmlFormat

		def self.decode(xml)

		end

		def self.write(doc, xml)
			formatter = REXML::Formatters::Pretty.new
			formatter.write(doc.root, xml)
		end

		def self.join_files(paths, opts = {})
			docs = []
			paths.each do |path|
				docs << REXML::Document.new(File.open(path))
			end
			doc = join_docs(docs)
			fp = Tempfile.open(["joined-", ".pml"])
			path = fp.path
			write(doc, fp)
			fp.close(false)
			path
	  	end

		def self.split_file(pml_path, opts = {})
			dirname = File.dirname(pml_path)
			basename = File.basename(pml_path, ".*")
			extname = File.extname(pml_path)	
			input = File.open(pml_path).read
		  	
			doc = REXML::Document.new File.open(pml_path)
			sdocs = split_doc(doc)
			files = []
			sdocs.each_with_index do |sdoc, index|
				split_fname = basename + '@' + (index + 1).to_s + extname
				split_path = File.join(dirname,split_fname)
				File.open(split_path,'w') do |o|
					write(sdoc, o)
				end
				files << split_path
			end
			files
		end


	  	def self.join_docs(docs, opts = {})
	  		els = []
	  		docs.each do |doc|
        		if doc.root.name == "acquisitions"
          			doc.elements.each('acquisitions/acquisition') do |el|
            			els << el
          			end
        		elsif doc.root.name == "acquisition"
           			el = doc.get_elements('acquisition')[0]
           			els << el
        		else
          			raise 'invalid args'
        		end
        	end

        	edoc = REXML::Document.new
      		edoc << REXML::XMLDecl.new('1.0', 'UTF-8')
      		acqs = REXML::Element.new "acquisitions"
      
      		els.each do |el|
        		acqs.add_element el
      		end
      		edoc.add_element acqs
      		edoc
	  	end


		def self.split_doc(doc, opts = {})
			docs = []
			if doc.root.name == "acquisitions"
				acqs = []
				doc.elements.each('acquisitions/acquisition') do |el|
					edoc = REXML::Document.new
					edoc << REXML::XMLDecl.new('1.0', 'UTF-8')
					edoc.add_element el
					docs << edoc
				end
			else
				raise 'no acquisitions tag!'
			end
		end


	end
end

