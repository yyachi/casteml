require 'rexml/document'
require 'tempfile'

module Casteml::Formats
	class XmlFormat
		def self.to_string(data, opts = {})
			# version = opts[:version] ? opts[:version] : '8'
			# if version == '9'
			# 	data.each do |h|
			# 		if h.has_key?(:abundances)
			# 			abs = h[:abundances]
			# 			abs.each do |ab|
			# 				ab[:value] = ab.delete(:data) if ab.has_key?(:data)
			# 				ab[:uncertainty] = ab.delete(:error) if ab.has_key?(:error)
			# 			end
			# 			h[:chemistries] = h.delete(:abundances)
			# 		end
			# 	end
				
			# 	# data.each do |k,v|
			# 	# 	puts k
			# 	# 	puts v
			# 	# end
			# end
		    fp = StringIO.new
		    write(from_array(data, opts), fp)
		    fp.close
		    fp.string			
		end

		def self.from_array(array, opts = {})
			doc = REXML::Document.new
			doc << REXML::XMLDecl.new('1.0', 'UTF-8')
			#doc.add_element el
			acqs_tag = REXML::Element.new('acquisitions')
			array.each do |hash|
				acqs_tag.add_element from_hash(hash, opts)
			end
			doc.add_element acqs_tag
			doc
		end

		def self.from_hash(hash, opts = {})
			version = opts[:version] ? opts[:version] : '8'
			abundances = hash.delete(:abundances)
			spot = hash.delete(:spot)
			acq_tag = REXML::Element.new('acquisition')
			hash.each do |key, value|
				tag_name = key.to_s
				if version == '9' && key == :session
					tag_name = 'name'
				end
				element = REXML::Element.new(tag_name)
				element.text = value
				acq_tag.elements.add(element)
			end

			if abundances && !abundances.empty?
			    case version
    			  when '9'
					abs_tag = REXML::Element.new('chemistries')
					ab_tag = REXML::Element.new('analysis')
    			  else
					abs_tag = REXML::Element.new('abundances')
					ab_tag = REXML::Element.new('abundance')
				end
				abundances.each do |abundance|
					if version == '9'
						abundance[:value] = abundance.delete(:data) if abundance.has_key?(:data)
						abundance[:uncertainty] = abundance.delete(:error) if abundance.has_key?(:error)
					end
					abundance.each do |key, value|
						element = REXML::Element.new(key.to_s)
						element.text = value
						ab_tag.elements.add(element)
					end
					abs_tag.elements.add(ab_tag)
				end
				acq_tag.elements.add(abs_tag)
			end

			if spot
				spot_tag = REXML::Element.new('spot')
				spot.each do |key, value|
					element = REXML::Element.new(key.to_s)
					element.text = value
					spot_tag.elements.add(element)					
				end
				acq_tag.elements.add(spot_tag)

			end
			acq_tag
		end

		def self.to_hash(rexml)
			elem_to_hash rexml.root
		end

		def self.elem_to_hash(elem)
			value = if elem.has_elements?
				children = {}
				elem.each_element do |e|
					children.merge!(elem_to_hash(e)) do |k,v1,v2|
						v1.class == Array ? v1 << v2 : [v1,v2]
					end
				end
				children
			else
				text = elem.text ? elem.text.strip : nil
				text = nil if text && text.empty?
				text
			end
			{ elem.name.to_sym => value }
		end

		def self.decode_file(path, opts ={})
			doc = REXML::Document.new File.open(path)
			decode_doc(doc)
		end

		def self.decode_string(string, opts ={})
			doc = REXML::Document.new string
			decode_doc(doc)
		end

		def self.decode_doc(doc, opts = {})
	        raise "invalid xml" unless doc.root

	        acquisitions = []

	        hash = to_hash(doc.root)
	        hash = hash.delete(:acquisitions) if hash.has_key?(:acquisitions)

	        if hash.instance_of?(Hash) && hash.has_key?(:acquisition)
	        	case hash[:acquisition]
	        	when Hash
	        		acquisitions << hash[:acquisition]
	        	when Array
	        		acquisitions.concat(hash[:acquisition])
	        	end
	        end
	        acquisitions.each do |acquisition|
	        	if acquisition.has_key?(:place)
	        		place = acquisition.delete(:place)
	        		acquisition[:place] = place if place.instance_of?(Hash)
	        	end
	        	if acquisition.has_key?(:spot)
	        		spot = acquisition.delete(:spot)
	        		acquisition[:spot] = spot if spot.instance_of?(Hash)
	        	end

	        	if acquisition.has_key?(:abundances) || acquisition.has_key?(:chemistries)
	        		abs_key = acquisition.has_key?(:abundances) ? :abundances : :chemistries
	        		hash = acquisition.delete(abs_key)
		       		if hash.instance_of?(Hash) && ( hash.has_key?(:abundance) || hash.has_key?(:analysis))
				 		ab_key = hash.has_key?(:abundance) ? :abundance : :analysis

		       			abundances = []
		       			case hash[ab_key]
		       			when Hash
		       				abundances << hash[ab_key]
		       			when Array
		       				abundances.concat(hash[ab_key])
		       			end
		       			acquisition[:abundances] = abundances
		        	end
	        	end
	        end
	        acquisitions
	    end

		def self.write(doc, xml)
			formatter = REXML::Formatters::Pretty.new
			formatter.write(doc.root, xml)
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
				sdoc.elements.each('acquisition/session') do |element|
				end
				begin
					data = to_hash(sdoc)
					session_name = data[:acquisition][:session]
					split_fname = session_name + extname
				rescue
					split_fname = basename + '@' + (index + 1).to_s + extname
				end
				split_path = File.join(dirname,split_fname)
				File.open(split_path,'w') do |o|
					write(sdoc, o)
				end
				files << split_path
			end
			files
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

		def self.join_strings(strings, opts = {})
			docs = []
			strings.each do |string|
				docs << REXML::Document.new(string)
			end
			doc = join_docs(docs ,opts)
			doc.to_s
			#doc
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

