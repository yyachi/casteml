
require 'medusa_rest_client'
require 'casteml/stone'
require 'casteml/technique'
require 'casteml/device'

module Casteml
	class Acquisition
		attr_accessor :session, :instrument, :analyst, :analysed_at, :sample_uid, :sample_name, :bibliography_uid, :description
		attr_accessor :technique
		attr_accessor :device

		alias_attribute :name, :session
		alias_attribute :operator, :analyst

		@@remote_attributes = [:name, :description, :operator, :stone_id, :device_id, :technique_id]

		def initialize(attrib = {})
			attrib.each do |key, value|
				self.send((key.to_s + '=').to_sym, value)
			end			
		end

		def stone_id
			if sample_uid
				obj = Stone.find_by_global_id(sample_uid)
				return obj.id if obj
			elsif sample_name
				obj = Stone.find_or_create_by_name(sample_name)
				return obj.id if obj
			end
			nil
		end

		def device_id
			return unless device
			obj = Device.find_or_create_by_name(device)
			return obj.id if obj
		end

		def technique_id
			return unless technique
			obj = Technique.find_or_create_by_name(technique)
			return obj.id if obj
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
