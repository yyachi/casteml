require 'medusa_rest_client'
require 'casteml/measurement_item'
require 'casteml/unit'
require 'casteml/remote_interaction'
module Casteml
	class Abundance
		extend Casteml::RemoteInteraction
		set_remote_class MedusaRestClient::Chemistry
		attr_accessor :analysis_id, :nickname, :data, :unit, :error, :info, :label
		attr_remote :analysis_id, :measurement_item_id, :info, :value, :label, :description, :uncertainty, :unit_id
		alias_attribute :value, :data
		alias_attribute :uncertainty, :error

		def initialize(attrib = {})
			attrib.each do |key, value|
				self.send((key.to_s + '=').to_sym, value)
			end
		end

		def description
		end

		def measurement_item_id
			return unless nickname
			obj = MeasurementItem.find_or_create_by_name(nickname)
			return obj.id if obj
		end

		def unit_id
			return unless unit
			obj = Unit.find_by_name_or_text(unit)
	  		raise "<Unit: #{unit}> not found." unless obj
			return obj.id
		end
	end
end
