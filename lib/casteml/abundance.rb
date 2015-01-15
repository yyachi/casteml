require 'medusa_rest_client'
require 'casteml'
require 'casteml/measurement_item'
require 'casteml/unit'
require 'casteml/remote_interaction'
require 'casteml/number_helper'

module Casteml
	class Abundance
		extend Casteml::RemoteInteraction
		extend Casteml::NumberHelper
		set_remote_class MedusaRestClient::Chemistry
		attr_accessor :analysis_id, :nickname, :unit, :error, :info, :label, :data, :error
		attr_reader :data_in_parts, :error_in_parts
		attr_remote :analysis_id, :measurement_item_id, :info, :value, :label, :description, :uncertainty, :unit_id
		alias_attribute :value, :data
		alias_attribute :uncertainty, :error


		def initialize(attrib = {})
			attrib.each do |key, value|
				self.send((key.to_s + '=').to_sym, value)
			end

			@unit ||= :parts
		end

		def data_in_parts
			self.class.number_from(@data.to_f, @unit.to_sym) if @data
		end

		def error_in_parts
			self.class.number_from(@error.to_f, @unit.to_sym) if @error	
		end


		def precision
			if data_in_parts && error_in_parts
				return self.class.precision(data_in_parts, error_in_parts) 
			else
				return nil
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
			obj = Unit.find_by_name_or_text(unit.to_s)
	  		raise "<Unit: #{unit}> not found." unless obj
			return obj.id
		end

	end
end
