require 'medusa_rest_client'
require 'casteml/remote_interaction'
module Casteml
  class Unit
	extend Casteml::RemoteInteraction
	set_remote_class MedusaRestClient::Unit

    def self.setup
      dump_all unless File.exist?(dump_path)
      @record_pool = load_from_dump
    end

	def self.find_by_text(text)
  		obj = record_pool.find{|obj| obj.text == text }		
	end

	def self.find_by_name_or_text(name_or_text)
		obj = find_by_name(name_or_text)
		obj = find_by_text(name_or_text) unless obj
		return obj
	end

    def self.refresh_abundance_unit_file
    	path = Casteml::ABUNDANCE_UNIT_FILE
       	if File.exist?(path)
			FileUtils.rm(path) 
 		end
    	units = self.find_all
    	hash = {}
    	units.each do |unit|
    		conversion = 1.0/unit.conversion
    		hash[unit.name.to_sym] = conversion
    		hash["\"#{unit.text}\"".to_sym] = conversion unless unit.text.blank?
    		#hash["\"#{unit.html}\"".to_sym] = unit.conversion unless unit.html.blank?	
    	end
    	YAML.dump({:abundance => hash}, File.open(path, 'w'))
    end

  end
end
