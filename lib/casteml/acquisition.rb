
require 'medusa_rest_client'
require 'casteml/technique'
module Casteml
	class Acquisition
		attr_accessor :session, :instrument, :analyst, :analysed_at, :sample_uid, :sample_name, :bibliography_uid, :description
		attr_accessor :technique

		alias_attribute :name, :session
		alias_attribute :operator, :analyst

		@@remote_attributes = [:name, :description, :operator, :technique_id]

		def initialize(attrib = {})
			attrib.each do |key, value|
				self.send((key.to_s + '=').to_sym, value)
			end			
		end

		def technique_id
			return unless technique
			technique_obj = Technique.find_or_create_by_name(technique)
			technique_obj.id
		end


		def to_remote_hash
			hash = Hash.new
			@@remote_attributes.each do |attrib|
				hash[attrib] = self.send(attrib)
			end
			hash
		end

		def save_remote
			MedusaRestClient::Analysis.new(to_remote_hash)
		end
	end
end
